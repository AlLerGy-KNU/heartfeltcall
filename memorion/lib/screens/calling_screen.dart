import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memorion/const/colors.dart';
import 'package:memorion/const/other.dart';
import 'package:memorion/screens/home_screen.dart';
import 'package:memorion/services/api_client.dart';
import 'package:memorion/services/voice_recorder_service.dart';
import 'package:memorion/services/voice_session_service.dart';

/// 로컬 파일 재생 (다운로드한 질문 WAV)
Future<bool> playLocalWav(String filePath) async {
  final player = AudioPlayer();
  await player.stop();
  await player.play(DeviceFileSource(filePath));
  await player.onPlayerComplete.first;
  await player.dispose();
  return true;
}

/// 에셋 파일 재생 (폴백용)
Future<bool> playAssetWav(String assetPath) async {
  final player = AudioPlayer();
  await player.stop();
  await player.play(AssetSource(assetPath));
  await player.onPlayerComplete.first;
  await player.dispose();
  return true;
}

class CallingScreen extends StatefulWidget {
  const CallingScreen({super.key});

  @override
  State<CallingScreen> createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {
  final recorder = VoiceRecorderService();
  late VoiceSessionService _sessionService;

  String status = "연결중";  // 연결중 → 말하는중 → 듣는중 → 분석중 → 완료/오류
  int audioCnt = 0;  // 현재 질문 인덱스 (0부터 시작)
  int maxCnt = 3;    // 총 질문 개수
  bool isStartVoice = false;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;

  int? _sessionId;
  final List<File> _questionFiles = [];   // 다운로드한 질문 WAV 파일들
  final List<File> _answerFiles = [];     // 녹음한 답변 WAV 파일들
  double? _analysisScore;           // 분석 결과 점수

  @override
  void initState() {
    super.initState();
    _sessionService = VoiceSessionService(ApiClient());
    _initializeSession();
  }

  @override
  void dispose() {
    // 세션이 열려있으면 종료
    if (_sessionId != null) {
      _sessionService.endSession(sessionId: _sessionId!);
    }
    super.dispose();
  }

  /// 세션 시작 및 질문 다운로드
  Future<void> _initializeSession() async {
    setState(() {
      isLoading = true;
      status = "연결중";
      hasError = false;
      errorMessage = null;
    });

    // 1. 세션 시작
    final sessionResult = await _sessionService.startSession();

    if (!mounted) return;

    if (sessionResult['status'] != 200) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = sessionResult['userMessage'] ?? "세션을 시작할 수 없습니다.";
        status = "오류";
      });
      return;
    }

    _sessionId = sessionResult['data']['session_id'] as int;

    // 2. 질문 다운로드
    setState(() {
      status = "질문 다운로드중";
    });

    final downloadedQuestions = await _sessionService.downloadAllQuestions(
      sessionId: _sessionId!,
    );

    if (!mounted) return;

    if (downloadedQuestions.isEmpty) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = "질문을 다운로드할 수 없습니다.";
        status = "오류";
      });
      return;
    }

    _questionFiles.addAll(downloadedQuestions);
    maxCnt = _questionFiles.length;

    setState(() {
      isLoading = false;
      audioCnt = 0;
    });

    // 3. 첫 번째 질문 재생 시작
    _playCurrentQuestion();
  }

  /// 현재 질문 재생
  Future<void> _playCurrentQuestion() async {
    if (audioCnt >= maxCnt) {
      // 모든 질문 완료 → 답변 업로드
      await _uploadAndAnalyze();
      return;
    }

    if (!mounted) return;

    setState(() {
      status = "말하는중";
    });

    final questionFile = _questionFiles[audioCnt];
    final finished = await playLocalWav(questionFile.path);

    if (!mounted) return;

    if (finished) {
      setState(() {
        status = "듣는중";
      });
    }
  }

  /// 녹음 시작
  Future<void> _startVoiceRecord() async {
    await recorder.start();
    setState(() {
      isStartVoice = true;
    });
  }

  /// 녹음 종료 및 다음 질문으로 진행
  Future<void> _endVoiceRecord() async {
    final file = await recorder.stop();

    if (file != null) {
      _answerFiles.add(file);
    }

    setState(() {
      isStartVoice = false;
      audioCnt += 1;
    });

    if (!mounted) return;

    if (audioCnt < maxCnt) {
      // 다음 질문 재생
      _playCurrentQuestion();
    } else {
      // 모든 질문 완료 → 업로드
      await _uploadAndAnalyze();
    }
  }

  /// 답변 업로드 및 분석 결과 받기
  Future<void> _uploadAndAnalyze() async {
    if (_sessionId == null || _answerFiles.isEmpty) {
      _showResultAndReturn(success: false, message: "녹음된 답변이 없습니다.");
      return;
    }

    setState(() {
      status = "분석중";
    });

    final result = await _sessionService.uploadAnswers(
      sessionId: _sessionId!,
      answerFiles: _answerFiles,
    );

    if (!mounted) return;

    if (result['status'] == 200 && result['data']?['success'] == true) {
      final score = result['data']['score'];
      _analysisScore = score is num ? score.toDouble() : null;

      // 세션 종료
      await _sessionService.endSession(sessionId: _sessionId!);
      _sessionId = null;

      _showResultAndReturn(
        success: true,
        score: _analysisScore,
      );
    } else {
      _showResultAndReturn(
        success: false,
        message: result['userMessage'] ?? "분석에 실패했습니다.",
      );
    }
  }

  /// 결과 표시 후 홈으로 이동
  void _showResultAndReturn({
    required bool success,
    double? score,
    String? message,
  }) {
    setState(() {
      status = success ? "완료" : "오류";
    });

    String dialogTitle;
    String dialogContent;

    if (success && score != null) {
      dialogTitle = "분석 완료";
      final percentage = (score * 100).toStringAsFixed(1);
      dialogContent = "오늘의 건강 체크가 완료되었습니다.\n분석 점수: $percentage%";
    } else if (success) {
      dialogTitle = "완료";
      dialogContent = "오늘의 건강 체크가 완료되었습니다.";
    } else {
      dialogTitle = "알림";
      dialogContent = message ?? "오류가 발생했습니다.";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(dialogTitle),
        content: Text(dialogContent),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  /// 전화 끊기 (취소)
  void _hangUp() {
    // 세션 종료 후 홈으로 이동
    if (_sessionId != null) {
      _sessionService.endSession(sessionId: _sessionId!);
      _sessionId = null;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  /// 에러 발생 시 재시도
  void _retry() {
    _questionFiles.clear();
    _answerFiles.clear();
    audioCnt = 0;
    _initializeSession();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.white, AppColors.main],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 160),
              _buildLogo(),
              SizedBox(height: Other.gapS),
              _buildStatusBadge(),
              if (isLoading) _buildLoadingIndicator(),
              if (hasError) _buildErrorRetry(),
              const Spacer(),
              if (!isLoading && !hasError) _buildControlButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.white.withValues(alpha: 0.5),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            "assets/images/memorion_logo.svg",
            width: 80,
            height: 80,
          ),
          Text(
            "따듯한전화",
            style: TextStyle(
              color: AppColors.main,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color statusColor = AppColors.main;
    if (status == "오류") {
      statusColor = Colors.red;
    } else if (status == "완료") {
      statusColor = AppColors.green;
    } else if (status == "분석중") {
      statusColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.white.withValues(alpha: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == "분석중" || status == "연결중" || status == "질문 다운로드중")
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: statusColor,
                ),
              ),
            ),
          Text(
            status,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: statusColor,
            ),
          ),
          if (!isLoading && !hasError && audioCnt < maxCnt)
            Text(
              " (${audioCnt + 1}/$maxCnt)",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: AppColors.main,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          const CircularProgressIndicator(color: AppColors.main),
          const SizedBox(height: 16),
          Text(
            "잠시만 기다려주세요...",
            style: TextStyle(color: AppColors.main),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorRetry() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? "오류가 발생했습니다.",
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _retry,
            child: const Text("다시 시도"),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: EdgeInsets.all(Other.margin),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 대화시작 버튼
              ElevatedButton(
                onPressed: (status == "듣는중" && !isStartVoice)
                    ? _startVoiceRecord
                    : null,
                style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                  backgroundColor: WidgetStatePropertyAll(
                    (status == "듣는중" && !isStartVoice)
                        ? AppColors.effectMain.withValues(alpha: 0.8)
                        : AppColors.effectMain.withValues(alpha: 0.3),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                child: Text(
                  "대화시작",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
              // 대화종료 버튼
              ElevatedButton(
                onPressed: (status == "듣는중" && isStartVoice)
                    ? _endVoiceRecord
                    : null,
                style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                  backgroundColor: WidgetStatePropertyAll(
                    (status == "듣는중" && isStartVoice)
                        ? AppColors.gray.withValues(alpha: 0.8)
                        : AppColors.gray.withValues(alpha: 0.3),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                child: Text(
                  "대화종료",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Other.gapM),
          // 전화 끊기 버튼
          ElevatedButton(
            onPressed: _hangUp,
            style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
              backgroundColor: const WidgetStatePropertyAll(Colors.redAccent),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            child: Icon(
              Icons.call_end_rounded,
              color: AppColors.white,
              size: Other.margin,
            ),
          ),
        ],
      ),
    );
  }
}

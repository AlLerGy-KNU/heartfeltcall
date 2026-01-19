import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memorion/const/colors.dart';
import 'package:memorion/const/other.dart';
import 'package:memorion/screens/call_screen.dart';
import 'package:memorion/screens/calling_screen.dart';
import 'package:memorion/screens/setting_screen.dart';
import 'package:memorion/services/api_client.dart';
import 'package:memorion/services/voice_service.dart';
import 'package:timezone/timezone.dart' as tz;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ApiClient _apiClient;
  late VoiceService _voiceService;

  String? caregiverName;
  String? preferredCallTime;
  int retryCount = 3;
  int retryIntervalMin = 10;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _voiceService = VoiceService(_apiClient);
    _loadProfileAndSchedule();
  }

  /// 프로필 조회 및 통화 스케줄링
  Future<void> _loadProfileAndSchedule() async {
    final result = await _voiceService.getMyProfile();

    if (!mounted) return;

    if (result["status"] == 200) {
      final data = result["data"];
      setState(() {
        caregiverName = data["caregiver_name"];
        preferredCallTime = data["preferred_call_time"];
        retryCount = data["retry_count"] ?? 3;
        retryIntervalMin = data["retry_interval_min"] ?? 10;
      });

      // 통화 시간이 설정되어 있으면 스케줄링
      if (preferredCallTime != null && preferredCallTime!.isNotEmpty) {
        await _scheduleCallAtPreferredTime();
      }
    }
  }

  /// 설정된 시간에 통화 스케줄링
  Future<void> _scheduleCallAtPreferredTime() async {
    if (preferredCallTime == null) return;

    try {
      // "HH:MM" 형식 파싱
      final parts = preferredCallTime!.split(":");
      if (parts.length != 2) return;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // 오늘 또는 내일 해당 시간 계산
      final now = tz.TZDateTime.now(tz.local);
      var scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // 이미 지난 시간이면 내일로 설정
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      // 기존 스케줄 취소 후 새로 설정
      await scheduleCallSeries(
        scheduledTime,
        maxAttempts: retryCount,
        interval: Duration(minutes: retryIntervalMin),
      );

      print("[HomeScreen] 통화 스케줄링 완료: $scheduledTime, 재시도: $retryCount회, 간격: ${retryIntervalMin}분");
    } catch (e) {
      print("[HomeScreen] 스케줄링 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(Other.gapM),
        child: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: Other.gapM),
              // logo
              SvgPicture.asset("assets/images/memorion_logo.svg"),
              Text(
                '따듯한 전화',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: AppColors.main
                ),
              ),
              SizedBox(height: Other.gapM),
              Text(
                "안녕하세요,\n따듯한 오늘을 기록해요",
              ),
              const Spacer(),
              Text(
                caregiverName != null
                    ? "$caregiverName님과 연결되었어요."
                    : "보호자와 연결되었어요",
              ),
              if (preferredCallTime != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "예정된 통화: $preferredCallTime",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.gray,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: Other.margin, right: Other.margin, bottom: Other.margin),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const CallingScreen()
                  ));
                },
                child: Text("통화\n하기"),
              )
            ),
            SizedBox(width: Other.gapS),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const SettingScreen()
                  ));
                },
                style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                  backgroundColor: WidgetStatePropertyAll(AppColors.whiteGray),
                  foregroundColor: WidgetStatePropertyAll(AppColors.black)
                ),
                child: Text("설정\n하기"),
              )
            ),
          ],
        ),
      ),
    );
  }
}

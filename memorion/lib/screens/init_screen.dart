import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memorion/const/colors.dart';
import 'package:memorion/services/invitation_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:memorion/const/other.dart';
import 'package:memorion/screens/home_screen.dart';
import 'package:memorion/services/local_data_manager.dart';
import 'package:memorion/services/api_client.dart';

class InitScreen extends StatefulWidget {
  const InitScreen({super.key});

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  //service
  late LocalDataManager localDataManager;
  late ApiClient _apiClient;
  late InvitationService invitationService;

  // click stat
  bool _isCreateCode = false;

  // code init
  String? code;
  DateTime? expiresAt;

  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  Timer? _statusTimer;
  String _inviteStatus = "pending"; // pending | connected | expired | used

  // 네트워크 에러 추적
  int _consecutiveErrors = 0;
  static const int _maxConsecutiveErrors = 3;
  bool _showingNetworkError = false;

  String get _remainingText {
    if (code == null || expiresAt == null || _remaining.inSeconds <= 0) {
      return "만료됨";
    }

    final minutes = _remaining.inMinutes;
    final seconds = _remaining.inSeconds % 60;

    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();
    LocalDataManager.init();
    localDataManager = LocalDataManager();

    _apiClient = ApiClient();
    invitationService = InvitationService(_apiClient);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = _apiClient.accessToken;

      // 1. If no token → go to login/init page
      if (token == null || token.isEmpty) {
        return;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }

      // TODO: 토큰 재검증
      // try {
      //   // 2. Send GET /auth/me to verify token
      //   final result = await AuthService(_apiClient).getMe();

      //   if (!mounted) return;

      //   // 3. If token is valid → status 200
      //   if (result["status"] == 200) {
      //     Navigator.pushReplacement(
      //       context,
      //       MaterialPageRoute(builder: (_) => const HomeScreen()),
      //     );
      //   } else {
      //     // 4. Invalid token → clear token & go InitScreen
      //     _apiClient.clearToken();
      //   }
      // } catch (e) {
      //   // 5. Any error → treat as invalid token
      //   _apiClient.clearToken();

      //   if (!mounted) return;
      // }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _createCode() async {
    // if (true) {
    //   Navigator.of(context).pushAndRemoveUntil(
    //     MaterialPageRoute(builder: (_) => const HomeScreen()),
    //     (Route<dynamic> route) => false,
    //   ); 
    // }
    // If we already have a valid code → block
    if (code != null && expiresAt != null) {
      final now = DateTime.now().toUtc();
      if (now.isBefore(expiresAt!)) {
        // still valid → do not create new code
        await shareMessage();
        return;
      } else {
        // expired → clear old values
        code = null;
        expiresAt = null;
      }
    }

    setState(() {
      _isCreateCode = true;
    });

    // call API
    final result = await InvitationService(_apiClient).createInvitation();

    setState(() {
      _isCreateCode = false;
    });

    if (!mounted) return;

    // === Error case ===
    if (result["status"] != 200) {
      // 사용자 친화적 메시지 우선 사용
      final errorMsg = result["userMessage"] ?? result["message"] ?? "연결 코드 생성에 실패했습니다.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
      return;
    }

    // === Success case ===
    final data = result["data"];
    final newCode = data["code"] as String?;
    final expireStr = data["expires_at"] as String?;

    if (newCode == null || expireStr == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid server response")),
      );
      return;
    }

    // parse to DateTime
    final expireTime = DateTime.parse(expireStr).toUtc();

    setState(() {
      code = newCode;
      expiresAt = expireTime;
      _remaining = expireTime.difference(DateTime.now().toUtc());
    });

    

    _startCountdown();
    _startStatusPolling();
    await shareMessage();
  }

  Future<void> shareMessage() async {
    final message = '따듯한 전화 앱의 보호자 연결 코드: $code\n'
        '앱에서 이 코드를 입력하면 서로 연결할 수 있어요.';
    await SharePlus.instance.share(
      ShareParams(text: message, title: '연결코드 공유'),
    );
  }

  void _startCountdown() {
    _countdownTimer?.cancel();

    if (expiresAt == null) return;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now().toUtc();
      final expire = expiresAt!;
      final diff = expire.difference(now);
      print(diff.inSeconds);
      print(expire);
      print(now);

      if (!mounted) {
        timer.cancel();
        return;
      }

      if (diff.inSeconds <= 0) {
        print("DEBUG: check");
        // expire
        timer.cancel();
        setState(() {
          _remaining = Duration.zero;
          code = null;
        });
      } else {
        setState(() {
          _remaining = diff;
        });
      }
    });
  }
  
  void _showNetworkErrorSnackbar(String message) {
    if (_showingNetworkError) return;
    _showingNetworkError = true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: "다시 시도",
          onPressed: () {
            _consecutiveErrors = 0;
            _showingNetworkError = false;
          },
        ),
      ),
    ).closed.then((_) {
      _showingNetworkError = false;
    });
  }

  void _startStatusPolling() {
    // stop existing timer
    _statusTimer?.cancel();
    _consecutiveErrors = 0;

    if (code == null) return;

    _statusTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final result = await
          invitationService.getInvitationStatus(code: code!);

      if (!mounted) return;

      // 네트워크 에러 처리
      if (result["status"] != 200) {
        _consecutiveErrors++;

        // 연속 에러가 임계값을 초과하면 사용자에게 알림
        if (_consecutiveErrors >= _maxConsecutiveErrors && !_showingNetworkError) {
          final errorMsg = result["userMessage"] ?? "서버에 연결할 수 없습니다.";
          _showNetworkErrorSnackbar(errorMsg);
        }
        return;
      }

      // 성공 시 에러 카운트 초기화
      _consecutiveErrors = 0;

      final data = result["data"];
      final status = data["status"] as String;

      if (!mounted) return;

      setState(() {
        _inviteStatus = status;
      });

      // 1) 인증 완료
      if (status == "connected") {
        _statusTimer?.cancel();

        // Extract access token from response JSON
        final String? authCode = data["auth_code"] as String?;

        if (authCode != null && authCode.isNotEmpty) {
          // Save token to local storage
          final resp = await invitationService.exchangeDependentToken(code: code!, authCode: authCode);
          if (resp["status"] == 200) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (Route<dynamic> route) => false,
            );
          } else {
            final msg = resp["userMessage"] ?? resp["message"]?.toString() ?? "로그인에 실패했습니다.";
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg)),
            );
          }
        }
      }

      // 2) 만료된 경우
      if (status == "expired") {
        _statusTimer?.cancel();
        setState(() {
          code = null;
          expiresAt = null;
          _remaining = Duration.zero;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("연결 코드가 만료되었습니다. 다시 생성해주세요.")),
        );
        return;
      }

      print("[DEBUG] check function");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(Other.margin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 40,),
            Text("안녕하세요!\n앱을 사용하기 위해\n보호자와 연결해주세요."),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("인증코드", style: Theme.of(context).textTheme.titleSmall,),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: Other.gapS),
                        child: (_inviteStatus == "connected") ?
                          Text(
                            "인증 완료",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : (_inviteStatus == "expired") ?
                          Text(
                            "만료됨",
                            style: Theme.of(context).textTheme.bodySmall
                          ) : code != null ? Text(
                            _remainingText,
                            style: Theme.of(context).textTheme.bodySmall
                          ) : null,
                        // code != null ? Text(_remainingText) : null,
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: Padding(
                        padding: const EdgeInsets.only(right: 36.0),
                        child: Text(code ?? "연결코드 보내기 \n버튼을 눌러주세요", style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 24)),
                      )),
                      TextButton(onPressed: code == null ? null : () async {
                        await Clipboard.setData(ClipboardData(text: code!));
              
                        if (!mounted) return;
              
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("코드를 복사했습니다"),
                          ),
                        );
                      }, child: Icon(Icons.copy, size: 28,)),
                    ],
                  ),
                  SizedBox(height: 20,)
                ],
              ),
            ),
          ],
        ),
      ),
      
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: Other.margin, right: Other.margin, bottom: Other.margin),
        child: ElevatedButton(onPressed: _createCode, 
        child: _isCreateCode ? SizedBox(
            height: 40,
            width: 40,
            child: CircularProgressIndicator(strokeWidth: 2)
          ) : Text("연결코드 보내기")
        ),
      ),
    );
  }
}
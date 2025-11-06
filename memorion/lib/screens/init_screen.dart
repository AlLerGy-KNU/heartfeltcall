import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:memorion/const/other.dart';
import 'package:memorion/screens/call_screen.dart';
import 'package:memorion/screens/home_screen.dart';
import 'package:memorion/services/local_data_manager.dart';
import 'package:memorion/services/api_client.dart';
import 'package:memorion/services/connection_service.dart';

class InitScreen extends StatefulWidget {
  const InitScreen({super.key});

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  //service
  late LocalDataManager localDataManager;
  late ApiClient _apiClient;
  late ConnectionService _connectionService;

  bool _isSubmitting = false;
  String? _lastCode;

  Future<void> _onSubmit() async {
    final whenOpen = DateTime.now().add(const Duration(seconds: 10));
    final tzTime = tz.TZDateTime.from(whenOpen, tz.local);
    // await scheduleCallSeries(
    //   tzTime,
    //   maxAttempts: 3,
    //   interval: const Duration(minutes: 1),
    // );
    await test10sCall();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    LocalDataManager.initData();
    localDataManager = LocalDataManager();

    _apiClient = ApiClient();
    _connectionService = ConnectionService(_apiClient);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(Other.margin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40,),
            Text("안녕하세요!\n앱을 사용하기 위해\n보호자와 연결해주세요."),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: Other.margin, right: Other.margin, bottom: Other.margin),
        child: ElevatedButton(onPressed: _onSubmit, child: Text("연결코드 보내기")),
      ),
    );
  }
}
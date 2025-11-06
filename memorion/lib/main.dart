import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:memorion/const/theme.dart';
import 'package:memorion/screens/calling_screen.dart';
import 'package:memorion/screens/init_screen.dart';
import 'package:memorion/services/local_data_manager.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 바인딩 초기화

  await dotenv.load(fileName: ".env");
  await LocalDataManager.init(); // 저장소 초기화

  // timezone init
  tz.initializeTimeZones();
  // 한국이면
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));


  // Android init
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidInitSettings);

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // This callback is called when user taps the notification or
      // when full-screen intent opens the app.
      _handleNotificationTap(response);
    },
  );

  // Ask Android 13+ notification permission
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  // Ask full-screen intent permission if needed
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestFullScreenIntentPermission(); // from plugin docs

  // Ask local notification intent
  await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.requestExactAlarmsPermission();
  runApp(const MyApp());
}

void _handleNotificationTap(NotificationResponse response) async {
  navigatorKey.currentState?.pushNamed('/call');

  // 통화시도 취소
  for (int i = 0; i < 3; i++) {
    final int id = 5000 + i;
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memorion',
      theme: themeData(),
      navigatorKey: navigatorKey,
      routes: {
        '/call': (_) => const CallingScreen(),
      },
      home: InitScreen(),
    );
  }
}
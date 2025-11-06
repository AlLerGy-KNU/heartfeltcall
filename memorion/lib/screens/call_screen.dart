// import 'package:flutter/material.dart';
// import 'package:memorion/const/colors.dart';

// class CallingScreen extends StatefulWidget {
//   const CallingScreen({super.key});

//   @override
//   State<CallingScreen> createState() => _CallingScreenState();
// }

// class _CallingScreenState extends State<CallingScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(colors: [AppColors.white, AppColors.main], begin: Alignment.topCenter, end: Alignment.bottomCenter)
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.max,
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(height: 160,),
//             Container(
//               padding: EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//                 color: Color.fromARGB(125, 255, 255, 255)
//               ),
//               child: Column(
//                 children: [
//                   //logo
//                   Text("따듯한전화", style: TextStyle(color: AppColors.main, fontSize: 40, fontWeight: FontWeight.bold),)
//                 ],
//               ),
//             ),
//             Spacer(),
//             Padding(
//               padding: const EdgeInsets.all(40.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 mainAxisSize: MainAxisSize.max,
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Color.fromARGB(80, 255, 255, 255),
//                       borderRadius: BorderRadius.circular(100)
//                     ),
//                     child: Container(
//                       padding: EdgeInsets.all(20), decoration: BoxDecoration(
//                         color: Colors.green, 
//                         borderRadius: BorderRadius.circular(100)
//                       ), 
//                       child: Icon(Icons.call_rounded, 
//                       color: AppColors.white, size: 32,)
//                     ),
//                   ),
                  
//                   Container(
//                     padding: EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Color.fromARGB(80, 255, 255, 255),
//                       borderRadius: BorderRadius.circular(100)
//                     ),
//                     child: Container(
//                       padding: EdgeInsets.all(20), decoration: BoxDecoration(
//                         color: Colors.redAccent, 
//                         borderRadius: BorderRadius.circular(100)
//                       ), 
//                       child: Icon(Icons.call_end_rounded, 
//                       color: AppColors.white, size: 32,)
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:memorion/main.dart';

Future<void> showIncomingCallLikeNotification() async {
  const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
    'incoming_call_channel', // channel id
    'Incoming Calls', // channel name
    channelDescription: 'Channel for incoming call alerts',
    importance: Importance.max,
    priority: Priority.high,
    category: AndroidNotificationCategory.call,
    fullScreenIntent: true,
    autoCancel: true,
    ongoing: true, // keep it on screen
    sound: RawResourceAndroidNotificationSound('incoming_call'),
    playSound: true,
  );

  const NotificationDetails platformDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    100, // notification id
    '보호자 전화',
    '통화를 시작하려면 탭하세요',
    platformDetails,
    payload: 'call_payload_123',
  );
}

NotificationDetails _buildCallNotificationDetails() {
  const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
    'incoming_call_channel_v3',
    'Incoming Calls',
    channelDescription: 'Channel for incoming call alerts',
    importance: Importance.max,
    priority: Priority.high,
    category: AndroidNotificationCategory.call,
    fullScreenIntent: true,
    autoCancel: true,
    ongoing: true,
    sound: RawResourceAndroidNotificationSound('incoming_call'),
    playSound: true,
  );

  return const NotificationDetails(android: androidDetails);
}

Future<void> showCallNow() async {
  await flutterLocalNotificationsPlugin.show(
    100,
    '보호자 전화',
    '통화를 시작하려면 탭하세요',
    _buildCallNotificationDetails(),
    payload: 'call_payload',
  );
}

/// Schedule up to [maxAttempts] calls.
/// [firstTime] is the time for the first call.
/// [interval] is the gap between attempts, e.g. Duration(minutes: 2).
Future<void> scheduleCallSeries(
  tz.TZDateTime firstTime, {
  int maxAttempts = 3,
  Duration interval = const Duration(minutes: 2),
}) async {
  final details = _buildCallNotificationDetails();

  for (int i = 0; i < maxAttempts; i++) {
    final attemptTime =
        firstTime.add(interval * i);

    // Give each attempt a different id
    final int notificationId = 5000 + i;

    // You can also encode which attempt it is inside the payload
    final payload = 'call_attempt_$i';

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      '보호자 전화',
      '통화를 시작하려면 탭하세요',
      attemptTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }
}

Future<void> test10sCall() async {
  final when = DateTime.now().add(const Duration(seconds: 10));
  final tzWhen = tz.TZDateTime.from(when, tz.local);

  const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
    'incoming_call_channel_test',
    'Incoming Calls Test',
    channelDescription: 'Test call',
    importance: Importance.max,
    priority: Priority.high,
    category: AndroidNotificationCategory.call,
    fullScreenIntent: true,
    autoCancel: true,
    ongoing: true,
    sound: RawResourceAndroidNotificationSound('incoming_call'),
    playSound: true,
  );

  final details = const NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.zonedSchedule(
    9000,
    '테스트 전화',
    '받으려면 탭하세요',
    tzWhen,
    details,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    payload: 'test_call',
  );
}
import 'package:flutter/material.dart';
import 'package:memorion/const/theme.dart';
import 'package:memorion/screens/init_screen.dart';
import 'package:memorion/services/local_data_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 바인딩 초기화
  await LocalDataManager.init(); // 저장소 초기화
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memorion',
      theme: themeData(),
      home: InitScreen(),
    );
  }
}
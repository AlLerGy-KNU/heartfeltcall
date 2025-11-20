import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:memorion_caregiver/const/theme.dart';
import 'package:memorion_caregiver/screens/splash_screen.dart';
import 'package:memorion_caregiver/services/api_client.dart';
import 'package:memorion_caregiver/services/local_data_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 바인딩 초기화
  await LocalDataManager.init(); // 저장소 초기화
  final apiClient = ApiClient();
  await apiClient.init(); 
  await dotenv.load(fileName: ".env");
  runApp(const Memorion());
}

class Memorion extends StatelessWidget {
  const Memorion({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memorion',
      theme: themeData(),
      home: SplashScreen(),
    );
  }
}
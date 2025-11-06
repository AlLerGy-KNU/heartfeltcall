import 'package:flutter/material.dart';
import 'package:memorion/components/button.dart';
import 'package:memorion/const/colors.dart';
import 'package:memorion/screens/home_screen.dart';
import 'package:memorion/services/local_data_manager.dart';

class InitScreen extends StatefulWidget {
  const InitScreen({super.key});

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  //service
  late LocalDataManager localDataManager;

  @override
  void initState() {
    super.initState();
    // TODO: init data checker
    LocalDataManager.initData();

    print("[DEGUB] test init data");
    localDataManager = LocalDataManager();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40,),
            Text("안녕하세요!\n앱을 사용하기 위해\n보호자와 연결해주세요.", style: TextStyle(
              fontSize: 36, color: AppColors.black, fontWeight: FontWeight.bold
            ),),
            Spacer(),
            bigButton(text: "연결코드 보내기", onPressed: ()=>{
              Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(title: "test",)))
            })
          ],
        ),
      )
    );
  }
}
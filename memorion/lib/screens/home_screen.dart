import 'package:flutter/material.dart';
import 'package:memorion/components/button.dart';
import 'package:memorion/const/colors.dart';
import 'package:memorion/screens/calling_screen.dart';
import 'package:memorion/screens/setting_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String name = "홍길동";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 40,),
              // logo
              const Text(
                '따듯한 전화',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.main),
              ),
              const SizedBox(height: 20,),
              Text(
                "안녕하세요,\n$name님!",
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.black),
              ),
              Spacer(),
              Text(
                "보호자: $name님",
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.black),
              ),
              SizedBox(height: 16,),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: bigButton(text: "통화\n하기", onPressed: ()=>{
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CallingScreen()))
                    }, backgroundColor: AppColors.main)
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: bigButton(text: "설정\n하기", onPressed: ()=>{
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => SettingScreen()
                      ))}, backgroundColor: AppColors.whiteGray, textColor: AppColors.black)
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

import 'package:flutter/material.dart';
import 'package:memorion/components/button.dart';
import 'package:memorion/const/value_name.dart';
import 'package:memorion/services/local_data_manager.dart';

import '../const/colors.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  // service
  late LocalDataManager localDataManager;

  // local value
  late int fontSize;
  late bool isConnection;
  
  @override
  void initState() {
    super.initState();
    localDataManager = LocalDataManager();
    loadSetting();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void loadSetting() async {
    isConnection = (await localDataManager.getBoolData(ValueName.isConnection))!;
    fontSize = (await localDataManager.getIntData(ValueName.fontSize))!;
  }

  void saveSetting() async {
    // service connect
    localDataManager.setBoolData(ValueName.isConnection, isConnection);
    localDataManager.setIntData(ValueName.fontSize, fontSize);
  }

  void disconnect() {
    // disconnect post
    saveSetting();
  }

  void sizeChange(int size) {
    // theme font size change
    saveSetting();
  }

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
                '설정',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.black),
              ),
              const SizedBox(height: 20,),
              Text(
                "보호자 설정",
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.black),
              ),
              bigButton(text: "보호자 연결 끊기", onPressed: ()=>{}, padding: 4, fontSize: 36),
              SizedBox(height: 40,),
              Text(
                "글씨 크기",
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.black),
              ),
              SizedBox(height: 16,),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: bigButton(text: "줄이기", onPressed: ()=>{}, backgroundColor: AppColors.gray, fontSize: 36, padding: 4)
                  ),
                  SizedBox(width: 40,),
                  Expanded(
                    child: bigButton(text: "키우기", onPressed: ()=>{}, backgroundColor: AppColors.main, fontSize: 36, padding: 4)
                  ),
                ],
              ),
              Spacer(),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: bigButton(text: "저장\n하기", onPressed: ()=>{
                      saveSetting(),
                      Navigator.pop(context)
                    }, backgroundColor: AppColors.main)
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: bigButton(text: "취소\n하기", onPressed: ()=>{
                      Navigator.pop(context, )}, backgroundColor: AppColors.whiteGray, textColor: AppColors.black)
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
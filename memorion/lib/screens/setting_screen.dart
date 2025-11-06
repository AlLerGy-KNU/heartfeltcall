import 'package:flutter/material.dart';
import 'package:memorion/const/other.dart';
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
        padding: const EdgeInsets.symmetric(horizontal:  32.0),
        child: SingleChildScrollView(
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
              ElevatedButton(child: Text("보호자 연결 끊기"), onPressed: ()=>{}),
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
                    child: ElevatedButton(child: Text("줄이기"), onPressed: ()=>{})
                  ),
                  SizedBox(width: 40,),
                  Expanded(
                    child: ElevatedButton(child: Text("키우기"), onPressed: ()=>{})
                  ),
                ],
              ),
              
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(right: Other.margin, left: Other.margin, bottom: Other.margin),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: ElevatedButton(child: Text("저장\n하기"), onPressed: ()=>{
                saveSetting(),
                Navigator.pop(context)
              })
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                  backgroundColor: WidgetStatePropertyAll(AppColors.whiteGray),
                  foregroundColor: WidgetStatePropertyAll(AppColors.black)
                ),
                child: Text("취소\n하기",), onPressed: ()=>{
                Navigator.pop(context, )})
            ),
          ],
        ),
      ),
    );
  }
}
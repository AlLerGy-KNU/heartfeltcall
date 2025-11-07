import 'package:flutter/material.dart';
import 'package:memorion/const/other.dart';
import 'package:memorion/const/value_name.dart';
import 'package:memorion/screens/init_screen.dart';
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
              SizedBox(height: Other.gapM,),
              Text(
                '설정',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: Other.gapS,),
              Text(
                "보호자 설정"
              ),
              SizedBox(height: Other.gapSS,),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: ()=>{
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => InitScreen()),
                        ),
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("보호자와 연결이 끊어졌습니다")),
                        )
                      },
                      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                        padding: WidgetStatePropertyAll(EdgeInsets.all(8))
                      ),
                      child: Text("보호자 연결 끊기", style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.white
                      ),),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Other.gapM,),
              
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
            SizedBox(width: Other.gapS,),
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
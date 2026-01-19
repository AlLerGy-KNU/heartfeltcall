import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memorion/const/colors.dart';
import 'package:memorion/const/other.dart';
import 'package:memorion/screens/calling_screen.dart';
import 'package:memorion/screens/setting_screen.dart';
import 'package:memorion/services/api_client.dart';
import 'package:memorion/services/voice_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ApiClient _apiClient;

  String? name;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
  }

  
  Future<void> getUserData() async {
    final result = await VoiceService(_apiClient).getCaregiver();
    if (result["status"] == 200) {
      final caregiver = result["data"]["caregiver"];
      name = caregiver["name"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(Other.gapM),
        child: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: Other.gapM,),
              // logo
              SvgPicture.asset("assets/images/memorion_logo.svg"),
              Text(
                '따듯한 전화',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: AppColors.main
                ),
              ),
              SizedBox(height: Other.gapM,),
              Text(
                "안녕하세요,\n따듯한 오늘을 기록해요",
              ),
              Spacer(),
              Text(
                name != null ?
                "$name님과 연결되었어요." : "보호자와 연결되었어요",
              ),              
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: Other.margin, right: Other.margin, bottom: Other.margin),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const CallingScreen()
                  ));
                },
                child: Text("통화\n하기"),
              )
            ),
            SizedBox(width: Other.gapS,),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const SettingScreen()
                  ));
                },
                style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                  backgroundColor: WidgetStatePropertyAll(AppColors.whiteGray),
                  foregroundColor: WidgetStatePropertyAll(AppColors.black)
                ),
                child: Text("설정\n하기"),
              )
            ),
          ],
        ),
      ),
    );
  }

}

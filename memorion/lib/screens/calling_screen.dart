import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memorion/const/colors.dart';
import 'package:memorion/const/other.dart';
import 'package:memorion/screens/home_screen.dart';
import 'package:memorion/services/voice_recorder_service.dart';

class CallingScreen extends StatefulWidget {
  const CallingScreen({super.key});

  @override
  State<CallingScreen> createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {
  final recorder = VoiceRecorderService();
  
  Future<void> _startVoiceRecord() async {
    await recorder.start();
  }

  Future<void> _endVoiceRecord() async {
    final file = await recorder.stop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.white, AppColors.main], begin: Alignment.topCenter, end: Alignment.bottomCenter)
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 160,),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.white.withValues(alpha: 0.5)
                ),
                child: Column(
                  children: [
                    SvgPicture.asset("assets/images/memorion_logo.svg", width: 80, height: 80,),
                    Text("따듯한전화", style: TextStyle(color: AppColors.main, fontSize: 40, fontWeight: FontWeight.bold),)
                  ],
                ),
              ),
              SizedBox(height: Other.gapS,),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.white.withValues(alpha: 0.5)
                ),
                child: Text("듣는중...", style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppColors.main
                )),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.all(Other.margin),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () => _startVoiceRecord(),
                          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                            backgroundColor: WidgetStatePropertyAll(AppColors.effectMain.withValues(alpha: 0.5)),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                            )
                          ), 
                          child: Text("대화시작", style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: AppColors.white
                          ),),
                        ),
                        ElevatedButton(
                          onPressed: () => _endVoiceRecord(),
                          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                            backgroundColor: WidgetStatePropertyAll(AppColors.gray.withValues(alpha: 0.5)),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                            )
                          ), 
                          child: Text("대화종료", style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: AppColors.white
                          ),),
                        ),
                      ],
                    ),
                    SizedBox(height: Other.gapM,),
                    ElevatedButton(
                      onPressed: () => {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (Route<dynamic> route) => false,
                        )
                      },
                      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                        backgroundColor: WidgetStatePropertyAll(Colors.redAccent),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))
                        )
                      ),
                      child: Icon(Icons.call_end_rounded, color: AppColors.white, size: Other.margin,)
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memorion/const/colors.dart';
import 'package:memorion/const/other.dart';
import 'package:memorion/screens/home_screen.dart';
import 'package:memorion/services/voice_recorder_service.dart';

Future<bool> playWav(String filePath) async {
  final player = AudioPlayer();

  // Stop any previous playback just in case
  await player.stop();

  // Start playing local file
  await player.play(DeviceFileSource(filePath));

  // Wait until player completes
  await player.onPlayerComplete.first;

  // Dispose player after playback
  await player.dispose();

  return true;
}

class CallingScreen extends StatefulWidget {
  const CallingScreen({super.key});

  @override
  State<CallingScreen> createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {
  final recorder = VoiceRecorderService();
  String status = "말하는중";  // 사용자가 말할때는 듣는중으로 표시, 녹음된 파일을 재생할땐 말하는중으로 표시
  bool isStartVoice = false;

  @override
  void initState() async {
    super.initState();
    isStartVoice = false;
    status = "말하는중";
    _play();
  }
  
  Future<void> _startVoiceRecord() async {
    await recorder.start();
    setState(() {
      isStartVoice = true;  
    });
    
  }

  Future<void> _endVoiceRecord() async {
    final file = await recorder.stop();
    setState(() {
      isStartVoice = false;  
    });
  }

  void _play() async {
    // This will block in async until playback is finished
    final finished = await playWav('assets/voices/a1.wav');

    if (finished) {
      setState(() {
        status = "듣는중";
      });
    }
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
                child: Text(status, style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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
                          onPressed: (status == "듣는중" && isStartVoice == false) ? () => _startVoiceRecord() : () {},
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
                          onPressed: (status == "듣는중" && isStartVoice == true) ? () => _endVoiceRecord() : () {},
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
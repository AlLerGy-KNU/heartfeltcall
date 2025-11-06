import 'package:flutter/material.dart';
import 'package:memorion_caregiver/const/colors.dart';
import 'package:memorion_caregiver/const/other.dart';
import 'package:memorion_caregiver/screens/signin_screen.dart';
import 'package:memorion_caregiver/screens/signup_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (!mounted) return;
    //   Navigator.of(context).push(
    //     MaterialPageRoute(builder: (_) => const SigninScreen()),
    //   );
    // });
  }

  int pageCnt = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: Other.margin,),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (pageCnt == index) ? AppColors.main : Colors.grey[400],
                      ),
                    );
                  }),
                ),
              SizedBox(height: Other.gapM,),
              Container(width: 320, height: 320, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.whiteGray),),
              SizedBox(height: Other.gapM,),
              Text("간혈적으로 나타나는 증상을 잡기 위해\n치매는 꾸준히 검사해야합니다", style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center,),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 32.0, right: 32, left: 32, top: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(onPressed: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => SigninScreen()))}, child: Text("로그인"),),
            SizedBox(height: Other.gapS,),
            ElevatedButton(onPressed: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen()))}, child: Text("회원가입"), style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
              backgroundColor: WidgetStatePropertyAll(AppColors.whiteGray),
              foregroundColor: WidgetStatePropertyAll(AppColors.black)
            ),),
          ],
        ),
      ),
    );
  }
}
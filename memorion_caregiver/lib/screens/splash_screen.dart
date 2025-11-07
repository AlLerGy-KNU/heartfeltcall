import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 120,),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset("assets/images/memorion_logo.svg", width: 60,),
                    Text("따듯한전화", style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: AppColors.main
                    ), textAlign: TextAlign.center,)
                  ],
                ),
                SizedBox(height: Other.gapM,),
                Text("독거어르신을 위한\n치매건강관리시스템", style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center,),
              ],
            ),
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
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memorion_caregiver/const/colors.dart';
import 'package:memorion_caregiver/const/other.dart';
import 'package:memorion_caregiver/screens/main_screen.dart';
import 'package:memorion_caregiver/screens/signin_screen.dart';
import 'package:memorion_caregiver/screens/signup_screen.dart';
import 'package:memorion_caregiver/services/api_client.dart';
import 'package:memorion_caregiver/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final apiClient = ApiClient();
  late AuthService authService;

  @override
  void initState() {
    super.initState();
    
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (!mounted) return;
    //   Navigator.of(context).push(
    //     MaterialPageRoute(builder: (_) => const SigninScreen()),
    //   );
    // });
    authService = AuthService(apiClient);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // TODO: 토큰 상태 검증
      final token = apiClient.accessToken;

      // 1. If no token → go to login/init page
      if (token == null || token.isEmpty) {
        return;
      }

      try {
        // 2. Send GET /auth/me to verify token
        final result = await AuthService(apiClient).getMe();

        if (!mounted) return;

        // 3. If token is valid → status 200
        if (result["status"] == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        } else {
          // 4. Invalid token → clear token & go InitScreen
          apiClient.clearToken();
        }
      } catch (e) {
        // 5. Any error → treat as invalid token
        apiClient.clearToken();

        if (!mounted) return;
      }
    });
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
                SvgPicture.asset("assets/images/memorion_logo.svg", width: 60,),
                SizedBox(height: Other.gapSS,),
                Text("따듯한전화", style: Theme.of(context).textTheme.displayLarge!.copyWith(
                  color: AppColors.main
                ), textAlign: TextAlign.center,),
                SizedBox(height: Other.gapS,),
                Text("독거어르신을 위한\n치매건강관리시스템", style: Theme.of(context).textTheme.displayMedium, textAlign: TextAlign.center,),
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
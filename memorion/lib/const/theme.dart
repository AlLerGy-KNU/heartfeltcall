import 'package:flutter/material.dart';
import 'package:memorion/const/colors.dart';

class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Return child directly: no animation
    return child;
  }
}

ThemeData themeData() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.main).copyWith(
      background: Colors.white,         // 일반 background
      surface: Colors.white,            // Card, Dialog 등의 배경
      onBackground: AppColors.black,       // 배경 위 텍스트 색
    ),
    pageTransitionsTheme:const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: NoTransitionsBuilder(),
        TargetPlatform.iOS: NoTransitionsBuilder(),
      },  
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.main, // 필요시 색상 지정
      elevation: 0,                    // 그림자 제거
      highlightElevation: 0,           // 클릭 시 그림자도 제거
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(100)), // 라운드 크게
      ),
    ),

    scaffoldBackgroundColor: Colors.white, // Scaffold 자체 배경,
    useMaterial3: true,
    
    // 기본 글꼴 설정
    fontFamily: 'Pretendard', // pubspec.yaml에 등록한 폰트명

    // 전체 텍스트 스타일 커스터마이징
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
      titleSmall: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      bodySmall: TextStyle(fontSize: 28, color: Colors.grey),
      
      // 버튼 기본 라벨 역할
      labelLarge: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        // 아래 3개를 명시해 두면 보간 경고가 사라지는 데 도움이 됨
        
        backgroundColor: Colors.transparent,
        wordSpacing: 0,
        decorationThickness: 1.0,
      )
    ).apply(
      fontFamily: 'Pretendard',
      bodyColor: AppColors.black,
    ),

    // 버튼 스타일
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        elevation: WidgetStateProperty.resolveWith<double>((_) => 0.0),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        foregroundColor: WidgetStatePropertyAll(AppColors.white),
        backgroundColor: WidgetStatePropertyAll(AppColors.main),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(12))),
        textStyle: WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.bold, fontSize: 40)),
        padding: WidgetStatePropertyAll(EdgeInsets.all(16))
      ),
    ),
  );
}
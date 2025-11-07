import 'package:flutter/material.dart';
import 'package:memorion_caregiver/const/colors.dart';

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

    appBarTheme: const AppBarTheme(
      foregroundColor: AppColors.black,
      backgroundColor: Colors.transparent,     // 배경 투명
      surfaceTintColor: Colors.transparent,    // Material3 틴트 제거
      elevation: 0,                            // 그림자 제거
      scrolledUnderElevation: 0,               // 스크롤 시 생기는 반투명 음영 제거
      iconTheme: IconThemeData(color: AppColors.black), // 아이콘 색상(필요 시)
      titleTextStyle: TextStyle(
        color: AppColors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
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
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 18),
      bodySmall: TextStyle(fontSize: 16, color: Colors.grey),
      
      // 버튼 기본 라벨 역할
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
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
        textStyle: WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        padding: WidgetStatePropertyAll(EdgeInsets.all(8))
      ),
    ),

    // 입력창(TextField 등)
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      hintStyle: const TextStyle(fontSize: 20, color: AppColors.gray),

      // 평소(비활성) 상태 선 색: 회색
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.gray, width: 1.0),
      ),

      // 클릭(포커스) 시 선 색: 주황색
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.main, width: 2.0),
      ),

      // 힌트 → 클릭 시 위로 떠오르게
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: const TextStyle(fontSize: 20, color: AppColors.gray),
      floatingLabelStyle: TextStyle(
        fontSize: 16,
        color: AppColors.gray,
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      // 드롭다운으로 펼쳐졌을 때 메뉴 박스 스타일
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(AppColors.white),
        // elevation: const WidgetStatePropertyAll(0),
      ),
    ),
  );
}
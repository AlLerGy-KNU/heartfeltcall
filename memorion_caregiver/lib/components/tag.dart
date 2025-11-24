import 'package:flutter/material.dart';
import 'package:memorion_caregiver/const/colors.dart';

Widget redTag() {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.effectMain.withAlpha(51),
      borderRadius: BorderRadius.circular(20)
    ),
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Text("위험", style: TextStyle(color: AppColors.effectMain, fontSize: 16, fontWeight: FontWeight.w500)),
  );
}

Widget orangeTag() {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.main.withAlpha(51),
      borderRadius: BorderRadius.circular(20)
    ),
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Text("주의", style: TextStyle(color: AppColors.main, fontSize: 16, fontWeight: FontWeight.w500)),
  );
}

Widget greenTag() {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.green.withAlpha(51),
      borderRadius: BorderRadius.circular(20)
    ),
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Text("정상", style: TextStyle(color: AppColors.green, fontSize: 16, fontWeight: FontWeight.w500)),
  );
}

Widget otherTag() {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.gray.withAlpha(51),
      borderRadius: BorderRadius.circular(20)
    ),
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Text("전화실패", style: TextStyle(color: AppColors.gray, fontSize: 16, fontWeight: FontWeight.w500)),
  );
}

Widget settingTag() {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.gray.withAlpha(51),
      borderRadius: BorderRadius.circular(20)
    ),
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Text("기록없음", style: TextStyle(color: AppColors.gray, fontSize: 16, fontWeight: FontWeight.w500)),
  );
}
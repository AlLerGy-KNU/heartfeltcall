import 'package:flutter/material.dart';
import 'package:memorion/const/colors.dart';

Widget bigButton(
    {required String text,
    required VoidCallback onPressed,
    Color backgroundColor = AppColors.main,
    Color textColor = Colors.white,
    double borderRadius = 12.0,
    double padding = 20,
    double fontSize = 40}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: EdgeInsets.all(padding),
        // maximumSize: Size(400, 200)
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: textColor, fontSize: fontSize, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget logo(
  {
    int width = 100,
    int height = 100
  }
) {
  return Container(
    width: 200,
    height: 200,
    child: SvgPicture.asset('assets/images/memorion_logo.svg'),
  );
}
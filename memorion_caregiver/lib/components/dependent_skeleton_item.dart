// lib/widgets/dependent_skeleton_item.dart
import 'package:flutter/material.dart';
import 'package:memorion_caregiver/const/other.dart';

class DependentSkeletonItem extends StatelessWidget {
  const DependentSkeletonItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Other.gapS, horizontal: Other.margin),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20)
        ),
        width: 20,
        height: 80,
      ),
    );
  }
}

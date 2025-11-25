import 'package:flutter/material.dart';
import 'package:memorion_caregiver/components/report_card.dart';
import 'package:memorion_caregiver/const/colors.dart';
import 'package:memorion_caregiver/const/other.dart';
import 'package:memorion_caregiver/screens/edit_career_screen.dart';
import 'package:memorion_caregiver/screens/report_screen.dart';

class MoreScreen extends StatefulWidget {
  final item;

  const MoreScreen({super.key, required this.item});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  late String name;
  late double stat;

  @override
  void initState() {
    super.initState();

    name = widget.item["name"];
    stat = widget.item["last_state"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$name님"), actions: [
        TextButton(onPressed: ()=>{}, child: Row(
          children: [
            Text("2025년 10월 12일", style: Theme.of(context).textTheme.titleMedium!.copyWith(color: AppColors.main),),
            Icon(Icons.arrow_drop_down_rounded, color: AppColors.main,)
          ],
        ))
      ],),
      body: Padding(
        padding: EdgeInsets.only(right: Other.margin, left: Other.margin),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Other.margin),
              reportCard("assets/images/mel/d01.png", widget.item, context),
              SizedBox(height: Other.gapM,),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 32.0, right: 32, left: 32, top: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(child: ElevatedButton(onPressed: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => EditCareerScreen(item: widget.item,)))}, child: Text("정보수정"),)),
            SizedBox(width: Other.gapS,),
            Expanded(
              child: ElevatedButton(
                onPressed: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => ReportScreen()))},
                style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                  backgroundColor: WidgetStatePropertyAll(AppColors.whiteGray),
                  foregroundColor: WidgetStatePropertyAll(AppColors.black)
                ), child: Text("리포트")
              )),
          ],
        ),
      ),
    );
  }
}
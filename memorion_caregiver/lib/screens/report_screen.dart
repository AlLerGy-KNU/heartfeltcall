import 'package:flutter/material.dart';
import 'package:memorion_caregiver/components/report_card.dart';
import 'package:memorion_caregiver/const/other.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("리포트"),),
      body: Padding(
        padding: EdgeInsets.only(right: Other.margin, left: Other.margin),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Other.margin),
              Text("종합결과", style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: Other.gapSS,),
              reportCard("title", "info", "tag", context),
              SizedBox(height: Other.gapM,),
              Text("수치그래프", style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: Other.gapSS,),
              buildMonthlyBarCard(data: const [
                MonthValue('2월', 13, '정상'),
                MonthValue('3월', 59, '주의'),
                MonthValue('4월', 68, '위험'),
                MonthValue('5월', 50, '주의'),
                MonthValue('6월', 73, '위험'),
                MonthValue('7월', 89, '위험'),
              ],)
            ],
          ),
        ),
      ),
    );
  }
}
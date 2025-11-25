import 'package:flutter/material.dart';
import 'package:memorion_caregiver/components/report_card.dart';
import 'package:memorion_caregiver/const/colors.dart';
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
              ],),
              SizedBox(height: Other.gapM,),
              Text("검사원리", style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: Other.gapSS,),
              Container(
                padding: EdgeInsets.all(Other.gapS),
                decoration: BoxDecoration(
                  color: AppColors.whiteMain,
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("소리로 치매를 탐지하는 AI", style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: Other.gapSS,),
                    Container(
                      padding: EdgeInsets.all(Other.gapS),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20)

                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("먼저 어르신의 통화 음성을 이미지로 변환해요! ", style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(Other.gapSS),
                                child: ClipRRect(
                                  borderRadius: BorderRadiusGeometry.circular(8),
                                  child: Image.asset(
                                    'assets/images/mel/d02.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(height: Other.gapSS,),
                              Text("변환된 음성 이미지", style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                          
                          SizedBox(height: Other.gapS,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("이후, 이미지를 AI로 분석해서 위험 증상이 있는지 확인합니다. ", style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                          SizedBox(height: Other.gapS,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(Other.gapSS),
                                child: ClipRRect(
                                  borderRadius: BorderRadiusGeometry.circular(8),
                                  child: Image.asset(
                                    'assets/images/mel/d01.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Text("정상 스펙트럼 이미지", style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                          
                          SizedBox(height: Other.gapS,),
                          Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(Other.gapSS),
                                child: ClipRRect(
                                  borderRadius: BorderRadiusGeometry.circular(8),
                                  child: Image.asset(
                                    'assets/images/mel/e01.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Text("비정상 스펙트럼 이미지", style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                          
                          SizedBox(height: Other.gapS,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("AI는 89.33%의 정확도를 가졌어요", style: Theme.of(context).textTheme.bodyMedium),
                              Text("예측 결과에서 높은 위험도를 보이면 전문의와 상담을 하세요", style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                          
                        ],
                      )),
                  ],
                ),
              ),
              SizedBox(height: Other.gapM,),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:memorion_caregiver/components/tag.dart';
import 'package:memorion_caregiver/const/colors.dart';
import 'package:memorion_caregiver/const/other.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

Widget reportCard(String title, String info, String tag, context) {
  return Container(
    decoration: BoxDecoration(color: AppColors.whiteMain, borderRadius: BorderRadius.circular(20)),
    padding: EdgeInsets.all(20),
    child: Column(
      children: [
        redTag(),
        SizedBox(height: Other.gapS,),
        Text("홍길동님에게 인지저하가 나타나고 있어요", style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center ),
        SizedBox(height: Other.gapS,),
        Container(
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20)),
          padding: EdgeInsets.all(12),
          child: Text("홍길동님과 대화를 진행할때, 특정 기억을 반복적으로 잊으셨어요. 진단 설문을 통해 확인해본 결과 치매가 강하게 의심되니 병원에 방문하여 정확한 결과를 확인하길 권해드려요.")
        )
      ],
    ),
  );
}

Widget reportGraph(context) {
  return Column(
    children: [
      Container(
        decoration: BoxDecoration(color: AppColors.whiteMain, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("일"),
            Text("월"),
            Text("년"),
          ],
        ),
      ),
      SizedBox(height: Other.gapS,),
      Container(
        height: 200,
        decoration: BoxDecoration(color: AppColors.whiteMain, borderRadius: BorderRadius.circular(20)),
      ),
    ],
  );
}

/// Data model for each bar
class MonthValue {
  final String monthLabel; // e.g., "2월"
  final double value;      // 0~100
  final String level;      // e.g., "정상" | "주의" | "위험"
  const MonthValue(this.monthLabel, this.value, this.level);
}

/// Build a card-like monthly bar chart (no need to place inside a build method)
Widget buildMonthlyBarCard({
  required List<MonthValue> data,
  // Legend labels order and colors
  List<String> legendOrder = const ['정상', '주의', '위험'],
  Map<String, Color> legendColors = const {
    '정상': Color(0xFFF3EEE9), // light beige
    '주의': Color(0xFFF3C7A6), // light orange
    '위험': Color(0xFFEF8A3E), // strong orange
  },

  // Look & feel
  double height = 260,
  double barCornerRadius = 6,
  double barWidthRatio = 0.5,
  EdgeInsetsGeometry outerPadding = const EdgeInsets.fromLTRB(12, 8, 12, 12),
  Color cardColor = AppColors.white,
}) {
  // Color mapper by level
  Color colorForLevel(String level) =>
      legendColors[level] ?? Colors.grey;

  return SizedBox(
    height: height,
    child: Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: outerPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Chart
            Expanded(
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  labelStyle: const TextStyle(fontSize: 12),
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  minimum: 0,
                  maximum: 100,
                  interval: 20,
                  labelFormat: '{value}%',
                  axisLine: const AxisLine(width: 0),
                  majorTickLines: const MajorTickLines(size: 0),
                ),
                series: [
                  ColumnSeries<MonthValue, String>(
                    dataSource: data,
                    xValueMapper: (d, _) => d.monthLabel,
                    yValueMapper: (d, _) => d.value,
                    pointColorMapper: (d, _) => colorForLevel(d.level),
                    borderRadius: BorderRadius.circular(barCornerRadius),
                    width: barWidthRatio,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.outer,
                      textStyle: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Legend (정상 / 주의 / 위험)
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 6,
              children: legendOrder.map((label) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colorForLevel(label),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(label, style: const TextStyle(fontSize: 12)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ),
  );
}
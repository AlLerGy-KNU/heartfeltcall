import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memorion_caregiver/components/tag.dart';
import 'package:memorion_caregiver/const/colors.dart';
import 'package:memorion_caregiver/const/other.dart';
import 'package:memorion_caregiver/screens/add_career_screen.dart';
import 'package:memorion_caregiver/screens/more_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Map<String, String>> people = [
  {
    'name': '홍길동',
    'status': '치매 증상이 의심돼요',
    'tag': '위험'
  },
  {
    'name': '이순신',
    'status': '기억력 점검이 필요해요',
    'tag': '주의'
  },
  {
    'name': '강감찬',
    'status': '인지 기능이 안정적이에요',
    'tag': '정상'
  },
  {
    'name': '신사임당',
    'status': '경미한 인지 저하가 보여요',
    'tag': '주의'
  },
  {
    'name': '세종대왕',
    'status': '정상 범주 내 인지 능력',
    'tag': '정상'
  },
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        leadingWidth: 92,
        toolbarHeight: 40,
        titleSpacing: -16,
        leading: SvgPicture.asset("assets/images/memorion_logo.svg", fit: BoxFit.fitHeight,), 
        title: Text("따듯한전화", style: Theme.of(context).textTheme.titleLarge!.copyWith(
          color: AppColors.main
        )),
      ),
      body: Padding(
        padding: EdgeInsets.all(Other.margin),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: Other.gapS),
          itemCount: people.length, // 표시할 데이터 개수
          itemBuilder: (context, index) {
            final person = people[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MoreScreen(name: person["name"]!, id: "ASDF"))),
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(AppColors.whiteMain),
                  padding: WidgetStatePropertyAll(EdgeInsets.all(Other.marginS)),
                  elevation: const WidgetStatePropertyAll(0.0), // 그림자 제거
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${person["name"]}님",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: Other.gapSS),
                        Text(
                          "${person["status"]}",
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                color: AppColors.gray,
                              ),
                        ),
                      ],
                    ),
                    person["tag"] == "위험" ? redTag() : person["tag"] == "주의" ? orangeTag() : person["tag"] == "정상" ? greenTag() : otherTag(), // 예: 상태 아이콘/라벨 위젯
                  ],
                ),
              ),
            );
          },
        )

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddCareerScreen()));
        },
        backgroundColor: AppColors.main,
        disabledElevation: 0, // 주황색 등 테마색
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
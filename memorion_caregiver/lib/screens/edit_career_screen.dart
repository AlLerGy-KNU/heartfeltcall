import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:memorion_caregiver/const/other.dart';

class EditCareerScreen extends StatefulWidget {
  @override
  State<EditCareerScreen> createState() => _EditCareerScreenState();
}

class _EditCareerScreenState extends State<EditCareerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("피보호자 수정"),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Other.margin),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Other.gapM,),  
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '피보호자 이름',
                  hintText: '피보호자 이름을 입력해주세요',
                ),
              ),
              SizedBox(height: Other.gapS,),  
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '피보호자 추가코드',
                  hintText: 'ABCD-ABCD',
                ),
              ),
              SizedBox(height: Other.gapS,),  
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '통화 시작시각',
                  hintText: '20시 30분',
                ),
              ),
              SizedBox(height: Other.gapS,),  
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '통화간격',
                  hintText: '4시간',
                ),
              ),
              SizedBox(height: Other.gapS,),  
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '통화 시도횟수',
                  hintText: '3회',
                ),
              ),
              SizedBox(height: Other.gapS,),  
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '통화 시도간격',
                  hintText: '30분',
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 32.0, right: 32, left: 32, top: 0),
        child: ElevatedButton(onPressed: () => {Navigator.pop(context)}, child: Text("확인"),),
      ),
    );
  }
}
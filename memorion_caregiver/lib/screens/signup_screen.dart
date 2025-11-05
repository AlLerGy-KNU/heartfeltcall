import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:memorion_caregiver/const/other.dart';
import 'package:memorion_caregiver/screens/main_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(Other.margin),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("회원가입을 위해 \n정보를 입력해주세요", style: Theme.of(context).textTheme.titleLarge,),
              SizedBox(height: Other.gapS,),  
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '이름',
                  hintText: '이름을 입력해주세요',
                ),
              ),
              SizedBox(height: Other.gapS,),  
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '아이디',
                  hintText: 'example@email.com',
                ),
              ),
              SizedBox(height: Other.gapS,),  
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  hintText: '비밀번호를 입력하세요',
                ),
              ),
              SizedBox(height: Other.gapS,),  
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '비밀번호 확인',
                  hintText: '비밀번호를 다시 한번 입력하세요',
                ),
              )
            ],
          ),
        ),
    ),
    bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 32.0, right: 32, left: 32, top: 0),
        child: ElevatedButton(onPressed: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()))}, child: Text("회원가입"),),
      ),
    );
    
  }
}
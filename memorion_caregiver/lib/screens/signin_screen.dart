import 'package:flutter/material.dart';
import 'package:memorion_caregiver/const/other.dart';
import 'package:memorion_caregiver/screens/main_screen.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(Other.margin),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("아이디와 비밀번호를 \n입력해주세요", style: Theme.of(context).textTheme.titleLarge,),
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 32.0, right: 32, left: 32, top: 0),
        child: ElevatedButton(onPressed: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()))}, child: Text("로그인"),),
      ),
    );
  }
}
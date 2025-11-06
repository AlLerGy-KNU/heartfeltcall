import 'package:flutter/material.dart';
import 'package:memorion_caregiver/const/other.dart';
import 'package:memorion_caregiver/screens/main_screen.dart';
import 'package:memorion_caregiver/services/api_client.dart';
import 'package:memorion_caregiver/services/auth_service.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  // controllers for form fields
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  late final ApiClient _apiClient;
  late final AuthService _authService;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _authService = AuthService(_apiClient);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    // check empty fields
    if (_emailCtrl.text.trim().isEmpty || _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("이메일과 비밀번호를 입력해주세요.")),
      );
      return;
    }

    // email format check
    final email = _emailCtrl.text.trim();
    final emailReg = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!emailReg.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("이메일 형식이 올바르지 않습니다.")),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // call auth service
    final resp = await _authService.signIn(
      email: email,
      password: _passwordCtrl.text,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (!mounted) return;

    if (resp["status"] == 200) {
      // login success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen()),
      );
    } else {
      final msg = resp["message"]?.toString() ?? "로그인에 실패했습니다.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }
  
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
              Text("이메일과 비밀번호를 \n입력해주세요", style: Theme.of(context).textTheme.titleLarge,),
              SizedBox(height: Other.gapS,),  
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: '이메일',
                  hintText: '이메일을 입력해주세요',
                ),
              ),
              SizedBox(height: Other.gapS,),  
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  hintText: '비밀번호를 입력해주세요',
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 32.0, right: 32, left: 32, top: 0),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _onSubmit, 
          child: _isSubmitting ? const CircularProgressIndicator() : Text("로그인"),
        ),
      ),
    );
  }
}
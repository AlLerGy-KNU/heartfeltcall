import 'package:flutter/material.dart';
import 'package:memorion_caregiver/const/other.dart';
import 'package:memorion_caregiver/screens/main_screen.dart';
import 'package:memorion_caregiver/services/api_client.dart';
import 'package:memorion_caregiver/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // controllers for form fields
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordConfirmCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

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
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordConfirmCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    // basic validation
    if (_passwordCtrl.text != _passwordConfirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("비밀번호가 일치하지 않습니다.")),
      );
      return;
    }

    // check empty fields
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _phoneCtrl.text.trim().isEmpty ||
        _passwordCtrl.text.isEmpty ||
        _passwordConfirmCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("모든 항목을 입력해주세요.")),
      );
      return;
    }

    // email format check
    // very basic email regex
    final email = _emailCtrl.text.trim();
    final emailReg = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!emailReg.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("이메일 형식이 올바르지 않습니다.")),
      );
      return;
    }

    // phone format check (010-1234-5678 or 01012345678)
    final phone = _phoneCtrl.text.trim();
    final phoneReg = RegExp(r'^(010\-?\d{4}\-?\d{4})$');
    if (!phoneReg.hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("전화번호 형식이 올바르지 않습니다.\n예) 010-1234-5678")),
      );
      return;
    }

    // password strength check
    final password = _passwordCtrl.text;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasLower = RegExp(r'[a-z]').hasMatch(password);
    final hasDigit = RegExp(r'\d').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\[\]\\;/+=]').hasMatch(password);
    final hasMinLength = password.length >= 12;

    if (!(hasUpper && hasLower && hasDigit && hasSpecial && hasMinLength)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar( 
          content: Text("비밀번호는 12자 이상, 대문자/소문자/숫자/특수문자를 포함해야 합니다."),
        ),
      );
      return;
    }
    

    setState(() {
      _isSubmitting = true;
    });

    final resp = await _authService.signUp(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      phone: _phoneCtrl.text.trim(),
    );

    setState(() {
      _isSubmitting = false;
    });

    if (!mounted) return;

    if (resp["status"] == 200 || resp["status"] == 201) {
      // success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen()),
      );
    } else {
      // show error from server
      final msg = resp["message"]?.toString() ?? "회원가입에 실패했습니다.";
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
              Text("회원가입을 위해 \n정보를 입력해주세요", style: Theme.of(context).textTheme.titleLarge,),
              SizedBox(height: Other.gapS,),  
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: '이름',
                  hintText: '이름을 입력해주세요',
                ),
              ),
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
                controller: _phoneCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '전화번호',
                  hintText: '010-0000-0000',
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
              SizedBox(height: Other.gapS,),  
              TextFormField(
                controller: _passwordConfirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '비밀번호 확인',
                  hintText: '비밀번호를 다시 한번 입력해주세요',
                ),
              )
            ],
          ),
        ),
    ),
    bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 32.0, right: 32, left: 32, top: 0),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _onSubmit, 
          child: _isSubmitting ? const CircularProgressIndicator() : Text("회원가입"),
        ),
      ),
    );
    
  }
}
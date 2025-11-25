import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memorion_caregiver/const/colors.dart';
import 'package:memorion_caregiver/const/other.dart';
import 'package:memorion_caregiver/screens/main_screen.dart';
import 'package:memorion_caregiver/services/api_client.dart';
import 'package:memorion_caregiver/services/dependent_service.dart';
import 'package:memorion_caregiver/services/invitation_service.dart';

class AddCareerScreen extends StatefulWidget {
  const AddCareerScreen({super.key});

  @override
  State<AddCareerScreen> createState() => _AddCareerScreenState();
}

class _AddCareerScreenState extends State<AddCareerScreen> {
  // controllers for form fields
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _birthCtrl = TextEditingController();
  final _relationCtrl = TextEditingController();
  final _callTimeCtrl = TextEditingController();
  final _callRetryCtrl = TextEditingController();
  final _callIntervalCtrl = TextEditingController();

  late final ApiClient _apiClient;
  late final DependentService _dependentService;
  late final InvitationService _invitationService;

  // click stat
  bool _isSubmitting = false;
  
  // form init
  String? gender = 'M';

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _dependentService = DependentService(_apiClient);
    _invitationService = InvitationService(_apiClient);
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _birthCtrl.dispose();
    _relationCtrl.dispose();
    _callTimeCtrl.dispose();
    _callRetryCtrl.dispose();
    _callIntervalCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    // validate required fields
    if (_codeCtrl.text.trim().isEmpty ||
        _nameCtrl.text.trim().isEmpty ||
        _birthCtrl.text.trim().isEmpty ||
        _callTimeCtrl.text.trim().isEmpty ||
        _callRetryCtrl.text.trim().isEmpty ||
        _callIntervalCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("필수 항목을 모두 입력해주세요.")),
      );
      return;
    }

    // validate birth date format (YYYY-MM-DD)
    final birth = _birthCtrl.text.trim();
    final birthReg = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!birthReg.hasMatch(birth)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("생년월일 형식이 올바르지 않습니다. 예) 1945-02-12")),
      );
      return;
    }

    // relation is optional in UI text, but API needs relation, so fallback
    final relation = _relationCtrl.text.trim().isEmpty
        ? "family"
        : _relationCtrl.text.trim();

    setState(() {
      _isSubmitting = true;
    });

    // call API
    final resp = await _dependentService.createDependent(
      name: _nameCtrl.text.trim(),
      birthDate: birth,
      relation: relation,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (!mounted) return;

    if (resp["status"] == 200 || resp["status"] == 201) {
      // success
      // TODO: call connection code API
      int connectStat = await connect(resp["data"]);

      if (connectStat != 200) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      final msg = resp["message"]?.toString() ?? "등록에 실패했습니다.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  Future<int> connect(final data) async {
    try {
      final resp = await _invitationService.acceptConnection(
        code: _codeCtrl.text,
        dependentId: data["id"]
      );
      return resp["status"];
    } catch (e) {
      return 500;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Other.margin),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("피보호자의 정보를 \n입력해주세요", style: Theme.of(context).textTheme.titleLarge,),
              SizedBox(height: Other.gapM,),  
              Text("피보호자 연결코드", style: Theme.of(context).textTheme.titleSmall,),
              TextFormField(
                controller: _codeCtrl,
                decoration: const InputDecoration(
                  labelText: '연결코드 *',
                  hintText: '연결코드를 입력해주세요',
                ),
              ),
              SizedBox(height: Other.gapM,),  
              Text("피보호자 인적사항", style: Theme.of(context).textTheme.titleSmall,),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: '이름 *',
                  hintText: '이름을 입력해주세요',
                ),
              ),
              SizedBox(height: Other.gapS,),  
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _birthCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '생년월일 *',
                        hintText: 'YYYY-MM-DD',
                      ),
                    ),
                  ),
                  SizedBox(width: Other.gapS,),
                  DropdownMenu<String>(
                    initialSelection: gender,
                    label: const Text('성별'),
                    onSelected: (val) {
                      setState(() {
                        gender = val;
                      });
                    },
                    dropdownMenuEntries: [
                      DropdownMenuEntry(value: 'M', label: '남'),
                      DropdownMenuEntry(value: 'F', label: '여'),
                      DropdownMenuEntry(value: 'O', label: '기타            '),
                    ],
                  ),
                ],
              ),
              
              SizedBox(height: Other.gapS,),  
              TextFormField(
                controller: _relationCtrl,
                decoration: const InputDecoration(
                  labelText: '관계',
                  hintText: '부모님',
                ),
              ),
              SizedBox(height: Other.gapM,),  
              Text("전화 설정", style: Theme.of(context).textTheme.titleSmall,),
              TextFormField(
                controller: _callTimeCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '통화시각 *',
                  hintText: 'HH:MM',
                ),
              ),
              SizedBox(height: Other.gapS,),  
              TextFormField(
                controller: _callRetryCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '통화 시도횟수 *',
                  hintText: '통화 시도횟수를 입력해주세요',
                ),
              ),
              SizedBox(height: Other.gapS,),  
              TextFormField(
                controller: _callIntervalCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '통화 시도간격 *',
                  hintText: 'MM',
                ),
              ),
              SizedBox(height: Other.gapM,),  
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: Other.gapM, right: Other.gapM, left: Other.gapM, top: 0),
        child: ElevatedButton(
          onPressed: (_isSubmitting) ? null : _onSubmit,
          style: ButtonStyle(
            // backgroundColor: WidgetStatePropertyAll(_inviteStatus != "connected" ? AppColors.whiteGray : null)
          ),
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("확인"),
        ),
      ),
    );
  }
}
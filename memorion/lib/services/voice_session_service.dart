import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:memorion/services/api_client.dart';
import 'package:path_provider/path_provider.dart';

/// 음성 세션 정보
class VoiceSessionInfo {
  final int sessionId;
  final String token;
  final int expiresIn;

  VoiceSessionInfo({
    required this.sessionId,
    required this.token,
    required this.expiresIn,
  });

  factory VoiceSessionInfo.fromJson(Map<String, dynamic> json) {
    return VoiceSessionInfo(
      sessionId: json['session_id'] as int,
      token: json['token'] as String,
      expiresIn: json['expires_in'] as int,
    );
  }
}

/// 질문 파일 정보
class QuestionFile {
  final String name;
  final String url;

  QuestionFile({required this.name, required this.url});

  factory QuestionFile.fromJson(Map<String, dynamic> json) {
    return QuestionFile(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }
}

/// 음성 세션 서비스 - 서버 API와 통신
class VoiceSessionService {
  final ApiClient _client;

  VoiceSessionInfo? _currentSession;
  VoiceSessionInfo? get currentSession => _currentSession;

  VoiceSessionService(this._client);

  /// 새 음성 세션 시작
  /// POST /voice/sessions
  Future<Map<String, dynamic>> startSession() async {
    try {
      final resp = await _client.post(
        "/voice/sessions",
        {},
        useAuth: true,
      );

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        _currentSession = VoiceSessionInfo.fromJson(data);
        return {
          "status": 200,
          "message": "session started",
          "data": data,
        };
      } else {
        return {
          "status": resp.statusCode,
          "message": "failed to start session: ${resp.body}",
        };
      }
    } catch (e) {
      return {
        "status": 0,
        "message": "error: $e",
        "userMessage": "서버에 연결할 수 없습니다.",
      };
    }
  }

  /// 질문 목록 조회
  /// GET /voice/sessions/{session_id}/question
  Future<Map<String, dynamic>> getQuestions({required int sessionId}) async {
    try {
      final resp = await _client.get(
        "/voice/sessions/$sessionId/question",
        useAuth: true,
      );

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        final files = (data['files'] as List)
            .map((f) => QuestionFile.fromJson(f as Map<String, dynamic>))
            .toList();
        return {
          "status": 200,
          "message": "questions fetched",
          "data": {"files": files},
        };
      } else {
        return {
          "status": resp.statusCode,
          "message": "failed to get questions: ${resp.body}",
        };
      }
    } catch (e) {
      return {
        "status": 0,
        "message": "error: $e",
        "userMessage": "질문을 불러올 수 없습니다.",
      };
    }
  }

  /// 질문 오디오 파일 다운로드 및 로컬 저장
  /// GET /voice/sessions/{session_id}/question/{filename}
  Future<File?> downloadQuestion({
    required int sessionId,
    required String filename,
  }) async {
    try {
      final uri = Uri.parse("${_client.baseUrl}/voice/sessions/$sessionId/question/$filename");
      final token = _client.accessToken;

      final headers = <String, String>{};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final resp = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: 30),
      );

      if (resp.statusCode == 200) {
        // 임시 디렉토리에 저장
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$filename');
        await file.writeAsBytes(resp.bodyBytes);
        return file;
      } else {
        return null;
      }
    } catch (e) {
      print("Error downloading question: $e");
      return null;
    }
  }

  /// 모든 질문 오디오 파일 다운로드
  Future<List<File>> downloadAllQuestions({required int sessionId}) async {
    final result = await getQuestions(sessionId: sessionId);
    if (result['status'] != 200) {
      return [];
    }

    final files = result['data']['files'] as List<QuestionFile>;
    final downloadedFiles = <File>[];

    for (final q in files) {
      final file = await downloadQuestion(
        sessionId: sessionId,
        filename: q.name,
      );
      if (file != null) {
        downloadedFiles.add(file);
      }
    }

    return downloadedFiles;
  }

  /// 녹음된 답변 업로드
  /// POST /voice/sessions/{session_id}/answer (multipart)
  Future<Map<String, dynamic>> uploadAnswers({
    required int sessionId,
    required List<File> answerFiles,
  }) async {
    try {
      final multipartFiles = <http.MultipartFile>[];

      for (int i = 0; i < answerFiles.length; i++) {
        final file = answerFiles[i];
        final bytes = await file.readAsBytes();
        multipartFiles.add(
          http.MultipartFile.fromBytes(
            'files',
            bytes,
            filename: 'answer${i + 1}.wav',
          ),
        );
      }

      final resp = await _client.postMultipart(
        "/voice/sessions/$sessionId/answer",
        files: multipartFiles,
        useAuth: true,
        timeout: const Duration(seconds: 120),
      );

      final respBody = await resp.stream.bytesToString();

      if (resp.statusCode == 200) {
        final data = json.decode(respBody) as Map<String, dynamic>;
        return {
          "status": 200,
          "message": "answers uploaded",
          "data": data,
        };
      } else {
        return {
          "status": resp.statusCode,
          "message": "failed to upload answers: $respBody",
        };
      }
    } catch (e) {
      return {
        "status": 0,
        "message": "error: $e",
        "userMessage": "답변 업로드에 실패했습니다.",
      };
    }
  }

  /// 세션 종료
  /// DELETE /voice/sessions/{session_id}
  Future<Map<String, dynamic>> endSession({required int sessionId}) async {
    try {
      final resp = await _client.delete(
        "/voice/sessions/$sessionId",
        useAuth: true,
      );

      _currentSession = null;

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        return {
          "status": 200,
          "message": "session closed",
          "data": data,
        };
      } else {
        return {
          "status": resp.statusCode,
          "message": "failed to close session: ${resp.body}",
        };
      }
    } catch (e) {
      return {
        "status": 0,
        "message": "error: $e",
        "userMessage": "세션 종료에 실패했습니다.",
      };
    }
  }

  /// 현재 세션 ID 반환 (없으면 null)
  int? get currentSessionId => _currentSession?.sessionId;
}

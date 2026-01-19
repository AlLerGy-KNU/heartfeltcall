import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:memorion/services/api_client.dart';

/// Service for dependent voice-related APIs
class VoiceService {
  final ApiClient client;

  VoiceService(this.client);

  /// JSON 안전하게 디코딩
  Map<String, dynamic> _safeJsonDecode(String body) {
    if (body.isEmpty) return <String, dynamic>{};
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return <String, dynamic>{"data": decoded};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  /// 예외를 사용자 친화적 메시지로 변환
  Map<String, dynamic> _handleException(dynamic e) {
    String userMessage;

    if (e is TimeoutException) {
      userMessage = "서버가 응답하지 않습니다. 잠시 후 다시 시도해주세요.";
    } else if (e is SocketException) {
      userMessage = "인터넷 연결을 확인해주세요.";
    } else if (e is http.ClientException) {
      userMessage = "서버에 연결할 수 없습니다.";
    } else {
      userMessage = "알 수 없는 오류가 발생했습니다.";
    }

    return {
      "message": "error: $e",
      "userMessage": userMessage,
      "status": 0,
      "isNetworkError": true,
    };
  }

  /// GET /voice/caregiver
  /// Header: Authorization: Bearer dependentToken
  /// Response(200): { caregiver: { id: number, name: string } }
  /// return: { "message": ..., "status": ..., "data": ... }
  Future<Map<String, dynamic>> getCaregiver() async {
    try {
      final http.Response resp = await client.get(
        "/voice/caregiver",
        useAuth: true, // dependent token required
      );

      final Map<String, dynamic> data = _safeJsonDecode(resp.body);

      if (resp.statusCode == 200) {
        return {
          "message": "caregiver fetched",
          "status": resp.statusCode,
          "data": data,
        };
      } else {
        return {
          "message": data["detail"] ?? "failed to fetch caregiver",
          "userMessage": "보호자 정보를 가져오는데 실패했습니다.",
          "status": resp.statusCode,
        };
      }
    } catch (e) {
      return _handleException(e);
    }
  }
}

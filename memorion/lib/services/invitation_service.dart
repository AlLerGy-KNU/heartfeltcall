import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:memorion/services/api_client.dart';
import 'package:memorion/services/local_data_manager.dart';

/// Service for invitation / connection flow
class InvitationService {
  final ApiClient client;

  InvitationService(this.client);

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

  /// 1) POST /connections
  /// Create invitation code (15 minutes valid)
  /// Response: { code: string, expires_at: string }
  /// return: { "message": ..., "status": ..., "data": ... }
  Future<Map<String, dynamic>> createInvitation() async {
    try {
      final http.Response resp = await client.post(
        "/connections",
        {}, // no body required
        useAuth: false, // public endpoint
      );

      final Map<String, dynamic> data = _safeJsonDecode(resp.body);

      if (resp.statusCode == 200) {
        return {
          "message": "invitation created",
          "status": resp.statusCode,
          "data": data,
        };
      } else {
        return {
          "message": data["detail"] ?? "failed to create invitation",
          "userMessage": "연결 코드 생성에 실패했습니다.",
          "status": resp.statusCode,
        };
      }
    } catch (e) {
      return _handleException(e);
    }
  }

  /// 2) GET /connections/{code}/status
  /// Check invitation status
  /// Response: { status: "pending"|"connected"|"used"|"expired", auth_code?: string }
  /// return: { "message": ..., "status": ..., "data": ... }
  Future<Map<String, dynamic>> getInvitationStatus({
    required String code,
  }) async {
    try {
      final http.Response resp = await client.get(
        "/connections/$code/status",
        useAuth: false, // public endpoint
      );

      final Map<String, dynamic> data = _safeJsonDecode(resp.body);

      if (resp.statusCode == 200) {
        return {
          "message": "status fetched",
          "status": resp.statusCode,
          "data": data,
        };
      } else {
        return {
          "message": data["detail"] ?? "failed to fetch status",
          "userMessage": "상태 확인에 실패했습니다.",
          "status": resp.statusCode,
        };
      }
    } catch (e) {
      return _handleException(e);
    }
  }

  /// 4) POST /auth/dependent/exchange
  /// Dependent app exchanges code + auth_code for dependent JWT
  /// Body: { code: string, auth_code: string }
  /// Response 200: {
  ///   access_token: string,
  ///   token_type: "bearer",
  ///   expires_in: number,
  ///   dependent_id: number
  /// }
  /// return: { "message": ..., "status": ..., "data": ... }
  Future<Map<String, dynamic>> exchangeDependentToken({
    required String code,
    required String authCode,
  }) async {
    try {
      final http.Response resp = await client.post(
        "/auth/dependent/exchange",
        {
          "code": code,
          "auth_code": authCode,
        },
        useAuth: false, // public endpoint
      );

      final Map<String, dynamic> data = _safeJsonDecode(resp.body);

      if (resp.statusCode == 200) {
        // Extract access token from response JSON
        final String? accessToken = data["access_token"] as String?;

        if (accessToken != null && accessToken.isNotEmpty) {
          // Save token to local storage
          await LocalDataManager.setAccessToken(accessToken);
        }
        return {
          "message": "exchange success",
          "status": resp.statusCode,
          "data": data,
        };
      } else {
        // 400 / 401 / 409 etc
        return {
          "message": data["detail"] ?? "exchange failed",
          "userMessage": "인증에 실패했습니다. 다시 시도해주세요.",
          "status": resp.statusCode,
        };
      }
    } catch (e) {
      return _handleException(e);
    }
  }
}

// dependent_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class DependentService {
  final ApiClient client;

  DependentService(this.client);

  /// JSON 안전하게 디코딩
  Map<String, dynamic> _safeJsonDecode(String body) {
    if (body.isEmpty) return <String, dynamic>{};
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      // List나 다른 타입인 경우 data 키로 감싸서 반환
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
      "status": 0,
      "message": "error: $e",
      "userMessage": userMessage,
      "isNetworkError": true,
    };
  }

  /// Create a new dependent
  /// body example:
  /// { "name": "Grandma Kim", "birth_date": "1945-02-12", "relation": "grandmother" }
  Future<Map<String, dynamic>> createDependent({
    required String name,
    required String birthDate,
    required String relation,
  }) async {
    try {
      final http.Response resp = await client.post(
        "/dependents",
        {
          "name": name,
          "birth_date": birthDate,
          "relation": relation,
        },
        useAuth: true,
      );

      final data = _safeJsonDecode(resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return {
          "status": resp.statusCode,
          "data": data,
        };
      } else {
        return {
          "status": resp.statusCode,
          "message": data["detail"] ?? resp.body,
          "userMessage": "피보호자 등록에 실패했습니다.",
        };
      }
    } catch (e) {
      return _handleException(e);
    }
  }

  /// Get all dependents of current caregiver
  Future<Map<String, dynamic>> getDependents() async {
    try {
      final http.Response resp =
          await client.get("/dependents", useAuth: true);

      final decoded = _safeJsonDecode(resp.body);

      if (resp.statusCode == 200) {
        // API가 배열을 반환하면 decoded["data"]에 있음
        final data = decoded.containsKey("data") ? decoded["data"] : decoded;
        return {
          "status": 200,
          "data": data,
        };
      } else {
        return {
          "status": resp.statusCode,
          "message": decoded["detail"] ?? resp.body,
          "userMessage": "피보호자 목록을 불러오는데 실패했습니다.",
        };
      }
    } catch (e) {
      return _handleException(e);
    }
  }

  /// Get single dependent by id
  Future<Map<String, dynamic>> getDependent(int id) async {
    try {
      final http.Response resp =
          await client.get("/dependents/$id", useAuth: true);

      final data = _safeJsonDecode(resp.body);

      if (resp.statusCode == 200) {
        return {
          "status": 200,
          "data": data,
        };
      } else {
        return {
          "status": resp.statusCode,
          "message": data["detail"] ?? resp.body,
          "userMessage": "피보호자 정보를 불러오는데 실패했습니다.",
        };
      }
    } catch (e) {
      return _handleException(e);
    }
  }

  /// Update dependent info
  /// Pass only fields you want to change
  Future<Map<String, dynamic>> updateDependent(
    int id, {
    String? name,
    String? birthDate,
    String? relation,
  }) async {
    try {
      // build partial body
      final Map<String, dynamic> body = {};
      if (name != null) body["name"] = name;
      if (birthDate != null) body["birth_date"] = birthDate;
      if (relation != null) body["relation"] = relation;

      final http.Response resp =
          await client.patch("/dependents/$id", body, useAuth: true);

      final data = _safeJsonDecode(resp.body);

      if (resp.statusCode == 200) {
        return {
          "status": 200,
          "data": data,
        };
      } else {
        return {
          "status": resp.statusCode,
          "message": data["detail"] ?? resp.body,
          "userMessage": "피보호자 정보 수정에 실패했습니다.",
        };
      }
    } catch (e) {
      return _handleException(e);
    }
  }

  /// Soft delete dependent
  Future<Map<String, dynamic>> deleteDependent(int id) async {
    try {
      final http.Response resp =
          await client.delete("/dependents/$id", useAuth: true);

      if (resp.statusCode == 200 || resp.statusCode == 204) {
        return {
          "status": resp.statusCode,
          "message": "deleted",
        };
      } else {
        final data = _safeJsonDecode(resp.body);
        return {
          "status": resp.statusCode,
          "message": data["detail"] ?? resp.body,
          "userMessage": "피보호자 삭제에 실패했습니다.",
        };
      }
    } catch (e) {
      return _handleException(e);
    }
  }
}

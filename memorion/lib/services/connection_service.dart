import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class ConnectionService {
  final ApiClient client;

  ConnectionService(this.client);

  /// Issue invite code for a dependent
  /// POST /connections
  /// body: { "dependent_id": 1 }
  /// return: { "status": ..., "data": {...} }
  Future<Map<String, dynamic>> createConnection({
    required int dependentId,
  }) async {
    try {
      final http.Response resp = await client.post(
        "/connections",
        {
          "dependent_id": dependentId,
        },
        useAuth: true,
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = json.decode(resp.body);
        return {
          "status": resp.statusCode,
          "data": data, // { "dependent_id": 1, "code": "A3B5F9" }
        };
      } else {
        return {
          "status": resp.statusCode,
          "message": resp.body,
        };
      }
    } catch (e) {
      return {
        "status": 500,
        "message": "error: $e",
      };
    }
  }

  /// Verify invite code on dependent side
  /// POST /connections/verify
  /// body: { "code": "A3B5F9" }
  /// return: { "status": ..., "data": {...} }
  Future<Map<String, dynamic>> verifyCode({
    required String code,
  }) async {
    try {
      final http.Response resp = await client.post(
        "/connections/verify",
        {
          "code": code,
        },
        // in spec this can be unauthenticated, so keep auth off
        useAuth: false,
      );

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        return {
          "status": 200,
          "data": data, // { "valid": true, "dependent_id": 1 }
        };
      } else {
        return {
          "status": resp.statusCode,
          "message": resp.body,
        };
      }
    } catch (e) {
      return {
        "status": 500,
        "message": "error: $e",
      };
    }
  }

  /// Accept connection on dependent app
  /// POST /connections/accept
  /// spec does not define exact body, but code-based accept is the most natural
  /// body: { "code": "A3B5F9" }
  Future<Map<String, dynamic>> acceptConnection({
    required String code,
  }) async {
    try {
      final http.Response resp = await client.post(
        "/connections/accept",
        {
          "code": code,
        },
        // likely authenticated on dependent side, but keep it optional
        useAuth: false,
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data =
            resp.body.isNotEmpty ? json.decode(resp.body) : <String, dynamic>{};
        return {
          "status": resp.statusCode,
          "data": data,
        };
      } else {
        return {
          "status": resp.statusCode,
          "message": resp.body,
        };
      }
    } catch (e) {
      return {
        "status": 500,
        "message": "error: $e",
      };
    }
  }
}

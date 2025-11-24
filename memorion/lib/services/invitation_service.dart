import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:memorion/services/api_client.dart';

/// Service for invitation / connection flow
class InvitationService {
  final ApiClient client;

  InvitationService(this.client);

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

      if (resp.statusCode == 200) {
        final Map<String, dynamic> data =
            resp.body.isNotEmpty ? json.decode(resp.body) : <String, dynamic>{};

        return {
          "message": "invitation created",
          "status": resp.statusCode,
          "data": data,
        };
      } else {
        return {
          "message": "failed to create invitation: ${resp.body}",
          "status": resp.statusCode,
        };
      }
    } catch (e) {
      return {
        "message": "error: $e",
        "status": 500,
      };
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

      if (resp.statusCode == 200) {
        final Map<String, dynamic> data =
            resp.body.isNotEmpty ? json.decode(resp.body) : <String, dynamic>{};

        return {
          "message": "status fetched",
          "status": resp.statusCode,
          "data": data,
        };
      } else {
        return {
          "message": "failed to fetch status: ${resp.body}",
          "status": resp.statusCode,
        };
      }
    } catch (e) {
      return {
        "message": "error: $e",
        "status": 500,
      };
    }
  }

  /// 3) POST /connections/accept
  /// Caregiver accepts invitation and creates/links dependent
  /// Auth: caregiver token required
  /// Request body is assumed: { code: string }
  /// Response: { "success": true, "dependent_id": number }
  /// return: { "message": ..., "status": ..., "data": ... }
  Future<Map<String, dynamic>> acceptInvitation({
    required String code,
  }) async {
    try {
      final http.Response resp = await client.post(
        "/connections/accept",
        {
          "code": code,
        },
        useAuth: true, // caregiver token required
      );

      if (resp.statusCode == 200) {
        final Map<String, dynamic> data =
            resp.body.isNotEmpty ? json.decode(resp.body) : <String, dynamic>{};

        return {
          "message": "invitation accepted",
          "status": resp.statusCode,
          "data": data,
        };
      } else {
        return {
          "message": "failed to accept invitation: ${resp.body}",
          "status": resp.statusCode,
        };
      }
    } catch (e) {
      return {
        "message": "error: $e",
        "status": 500,
      };
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

      if (resp.statusCode == 200) {
        final Map<String, dynamic> data =
            resp.body.isNotEmpty ? json.decode(resp.body) : <String, dynamic>{};

        return {
          "message": "exchange success",
          "status": resp.statusCode,
          "data": data,
        };
      } else {
        // 400 / 401 / 409 etc
        return {
          "message": "exchange failed: ${resp.body}",
          "status": resp.statusCode,
        };
      }
    } catch (e) {
      return {
        "message": "error: $e",
        "status": 500,
      };
    }
  }
}

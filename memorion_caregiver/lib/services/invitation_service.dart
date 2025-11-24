import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:memorion_caregiver/services/api_client.dart';

/// Service for invitations / connection and dependent token exchange
class InvitationService {
  final ApiClient client;

  InvitationService(this.client);

  /// POST /connections (public)
  /// Create a new invitation code (15 minutes valid)
  /// Header/Body: none
  /// Response(200): { code: string, expires_at: string(ISO8601) }
  /// return: { "message": ..., "status": ..., "data": ... }
  Future<Map<String, dynamic>> createConnection() async {
    try {
      final http.Response resp = await client.post(
        "/connections",
        {}, // no body
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

  /// GET /connections/{code}/status (public)
  /// Check invitation status
  /// Header: none
  /// Response(200): { status: "pending"|"connected"|"used"|"expired", auth_code?: string }
  /// return: { "message": ..., "status": ..., "data": ... }
  Future<Map<String, dynamic>> getConnectionStatus({
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

  /// POST /connections/accept (caregiver only)
  /// Caregiver accepts invitation and creates/links dependent + issues auth_code
  ///
  /// Header:
  ///   Authorization: Bearer caregiverToken
  ///   Content-Type: application/json
  ///
  /// Body:
  ///   { 
  ///     code: string,
  ///     dependent_id?: number,
  ///     dependent?: {
  ///       name: string,
  ///       birth_date?,
  ///       relation?,
  ///       preferred_call_time?,
  ///       retry_interval_min?
  ///     }
  ///   }
  ///
  /// Response(200): { success: true, dependent_id: number }
  ///
  /// You can:
  ///   - pass dependentId only (link existing dependent)
  ///   - or pass dependent info (create new dependent)
  ///
  /// return: { "message": ..., "status": ..., "data": ... }
  Future<Map<String, dynamic>> acceptConnection({
    required String code,
    int? dependentId,
    String? dependentName,
    String? birthDate,
    String? relation,
    String? preferredCallTime,
    int? retryIntervalMin,
  }) async {
    try {
      final Map<String, dynamic> body = {
        "code": code,
      };

      // existing dependent
      if (dependentId != null) {
        body["dependent_id"] = dependentId;
      }

      // new dependent info
      final Map<String, dynamic> dependent = {};

      if (dependentName != null) {
        dependent["name"] = dependentName;
      }
      if (birthDate != null) {
        dependent["birth_date"] = birthDate;
      }
      if (relation != null) {
        dependent["relation"] = relation;
      }
      if (preferredCallTime != null) {
        dependent["preferred_call_time"] = preferredCallTime;
      }
      if (retryIntervalMin != null) {
        dependent["retry_interval_min"] = retryIntervalMin;
      }

      // attach dependent only if not empty
      if (dependent.isNotEmpty) {
        body["dependent"] = dependent;
      }

      final http.Response resp = await client.post(
        "/connections/accept",
        body,
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

  /// POST /auth/dependent/exchange (public)
  ///
  /// Dependent app exchanges { code, auth_code } for dependent JWT
  ///
  /// Header:
  ///   Content-Type: application/json
  ///
  /// Body:
  ///   { code: string, auth_code: string }
  ///
  /// Response(200):
  ///   {
  ///     access_token: string,
  ///     token_type: "bearer",
  ///     expires_in: number,
  ///     dependent_id: number
  ///   }
  ///
  /// Errors: 400 / 401 / 409
  ///
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

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:memorion/services/api_client.dart';

/// Service for dependent voice-related APIs
class VoiceService {
  final ApiClient client;

  VoiceService(this.client);

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

      if (resp.statusCode == 200) {
        final Map<String, dynamic> data =
            resp.body.isNotEmpty ? json.decode(resp.body) : <String, dynamic>{};

        return {
          "message": "caregiver fetched",
          "status": resp.statusCode,
          "data": data,
        };
      } else {
        return {
          "message": "failed to fetch caregiver: ${resp.body}",
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

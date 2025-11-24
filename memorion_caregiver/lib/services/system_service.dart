import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:memorion_caregiver/services/api_client.dart';

class SystemService {
  final ApiClient client;

  SystemService(this.client);

  /// GET /system/health
  /// Simple health check for backend
  /// Response: { status: "ok" }
  /// return: { "message": ..., "status": ..., "data": ... }
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final http.Response resp = await client.get(
        "/system/health",
        useAuth: false, // health check does not require auth
      );

      if (resp.statusCode == 200) {
        final Map<String, dynamic> data =
            resp.body.isNotEmpty ? json.decode(resp.body) : <String, dynamic>{};

        return {
          "message": "health ok",
          "status": resp.statusCode,
          "data": data,
        };
      } else {
        return {
          "message": "health check failed: ${resp.body}",
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

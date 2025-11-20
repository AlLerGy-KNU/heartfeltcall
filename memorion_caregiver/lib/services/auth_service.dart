import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'local_data_manager.dart';

class AuthService {
  final ApiClient client;

  AuthService(this.client);

  /// Sign up a new caregiver user
  /// return: { "message": ..., "status": ..., "data": ... }
  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final http.Response resp = await client.post(
        "/auth/signup",
        {
          "name": name,
          "email": email,
          "password": password,
          "phone": phone,
        },
        // usually no auth needed for signup
        useAuth: false,
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final Map<String, dynamic> data =
            resp.body.isNotEmpty ? json.decode(resp.body) : <String, dynamic>{};

        return {
          "message": "signup success",
          "status": resp.statusCode,
          "data": data,
        };
      } else {
        return {
          "message": "signup failed: ${resp.body}",
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

  /// Login and store token
  /// return: { "message": ..., "status": ..., "data": ... }
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final http.Response resp = await client.post(
        "/auth/login",
        {
          "email": email,
          "password": password,
        },
        useAuth: false,
      );

      final int status = resp.statusCode;

      // Try to decode body safely
      Map<String, dynamic> data = <String, dynamic>{};
      if (resp.body.isNotEmpty) {
        try {
          final decoded = json.decode(resp.body);
          if (decoded is Map<String, dynamic>) {
            data = decoded;
          }
        } catch (_) {
          // If JSON decoding fails, keep data as empty map
        }
      }

      if (status == 200) {
        // Extract access token from response JSON
        final String? accessToken = data["access_token"] as String?;

        if (accessToken != null && accessToken.isNotEmpty) {
          // Save token to local storage
          await LocalDataManager.setAccessToken(accessToken);
        }

        return {
          "message": "login success",
          "status": 200,
          "data": data,
        };
      } else {
        return {
          "message": "login failed: ${resp.body}",
          "status": status,
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

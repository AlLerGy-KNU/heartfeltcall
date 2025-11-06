import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

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
      final http.Response resp = await client.post("/auth/signup", {
        "name": name,
        "email": email,
        "password": password,
        "phone": phone,
      });

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data =
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
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final http.Response resp = await client.post("/auth/login", {
        "email": email,
        "password": password,
      });

      final data = json.decode(resp.body);

      if (resp.statusCode == 200) {
        client.accessToken = data["access_token"] as String?;
        return {
          "message": "login success",
          "status": 200,
          "data": data,
        };
      } else {
        return {
          "message": "login failed: ${resp.body}",
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

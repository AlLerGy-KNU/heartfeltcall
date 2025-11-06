import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl = dotenv.env["BASE_URL"] ?? "";
  String? accessToken;

  /// Build full uri
  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final full = "$baseUrl$path";
    if (query == null || query.isEmpty) {
      return Uri.parse(full);
    }
    return Uri.parse(full).replace(
      queryParameters: query.map((k, v) => MapEntry(k, v.toString())),
    );
    // toString() to make sure all values are String
  }

  /// Common headers
  Map<String, String> _headers({bool useAuth = false}) {
    return {
      "Content-Type": "application/json",
      if (useAuth && accessToken != null) "Authorization": "Bearer $accessToken",
    };
  }

  /// POST request
  Future<http.Response> post(
    String path,
    Map<String, dynamic> body, {
    bool useAuth = false,
  }) {
    return http.post(
      _uri(path),
      headers: _headers(useAuth: useAuth),
      body: json.encode(body),
    );
  }

  /// GET request
  Future<http.Response> get(
    String path, {
    Map<String, dynamic>? query,
    bool useAuth = false,
  }) {
    return http.get(
      _uri(path, query),
      headers: _headers(useAuth: useAuth),
    );
  }

  /// PATCH request
  Future<http.Response> patch(
    String path,
    Map<String, dynamic> body, {
    bool useAuth = false,
  }) {
    return http.patch(
      _uri(path),
      headers: _headers(useAuth: useAuth),
      body: json.encode(body),
    );
  }

  /// DELETE request
  Future<http.Response> delete(
    String path, {
    bool useAuth = false,
  }) {
    return http.delete(
      _uri(path),
      headers: _headers(useAuth: useAuth),
    );
  }
}

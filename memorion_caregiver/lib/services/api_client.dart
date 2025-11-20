import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:memorion_caregiver/services/local_data_manager.dart';

class ApiClient {
  ApiClient._internal();
  static final ApiClient instance = ApiClient._internal();
  factory ApiClient() => instance;

  String? baseUrl;
  String? _accessToken;
  String? get accessToken => _accessToken;

  Future<void> init() async {
    _accessToken = LocalDataManager.getAccessToken();
    baseUrl = dotenv.env["BASE_URL"]!;
  }

  set accessToken(String? token) {
    _accessToken = token;
    if (token == null) {
      LocalDataManager.clearAccessToken();
    } else {
      LocalDataManager.setAccessToken(token);
    }
  }

  /// Common headers
  Map<String, String> _headers({bool useAuth = false}) {
    final headers = <String, String>{
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    if (useAuth) {
      final token = LocalDataManager.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }
    }
    return headers;
  }

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

  /// POST multipart/form-data
  Future<http.StreamedResponse> postMultipart(
    String path, {
    List<http.MultipartFile>? files,
    Map<String, String>? fields,
    bool useAuth = false,
  }) async {
    final uri = _uri(path);
    final req = http.MultipartRequest('POST', uri);
    if (useAuth && accessToken != null) {
      req.headers['Authorization'] = 'Bearer $accessToken';
    }
    if (fields != null) req.fields.addAll(fields);
    if (files != null) req.files.addAll(files);
    return await req.send();
  }
}

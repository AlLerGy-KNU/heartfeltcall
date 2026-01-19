import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:memorion_caregiver/services/local_data_manager.dart';

/// 네트워크 에러 타입
enum NetworkErrorType {
  timeout,      // 서버 응답 없음
  noConnection, // 인터넷 연결 없음
  serverError,  // 서버 오류
  unknown,      // 알 수 없는 오류
}

/// 네트워크 예외 정보
class NetworkException implements Exception {
  final NetworkErrorType type;
  final String message;
  final String userMessage;

  NetworkException({
    required this.type,
    required this.message,
    required this.userMessage,
  });

  @override
  String toString() => message;
}

/// API 응답 결과를 표준화하는 클래스
class ApiResult {
  final int status;
  final String? message;
  final String? userMessage;
  final Map<String, dynamic>? data;
  final bool isNetworkError;
  final NetworkErrorType? errorType;

  ApiResult({
    required this.status,
    this.message,
    this.userMessage,
    this.data,
    this.isNetworkError = false,
    this.errorType,
  });

  bool get isSuccess => status >= 200 && status < 300;

  Map<String, dynamic> toMap() => {
    "status": status,
    "message": message,
    "userMessage": userMessage,
    "data": data,
    "isNetworkError": isNetworkError,
  };
}

class ApiClient {
  static const Duration defaultTimeout = Duration(seconds: 15);
  static const Duration shortTimeout = Duration(seconds: 10);
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


  /// 네트워크 예외를 분류하고 사용자 친화적 메시지 반환
  NetworkException _classifyException(dynamic e) {
    if (e is TimeoutException) {
      return NetworkException(
        type: NetworkErrorType.timeout,
        message: "Request timeout: $e",
        userMessage: "서버가 응답하지 않습니다. 잠시 후 다시 시도해주세요.",
      );
    } else if (e is SocketException) {
      return NetworkException(
        type: NetworkErrorType.noConnection,
        message: "Socket exception: $e",
        userMessage: "인터넷 연결을 확인해주세요.",
      );
    } else if (e is http.ClientException) {
      return NetworkException(
        type: NetworkErrorType.noConnection,
        message: "Client exception: $e",
        userMessage: "서버에 연결할 수 없습니다.",
      );
    } else {
      return NetworkException(
        type: NetworkErrorType.unknown,
        message: "Unknown error: $e",
        userMessage: "알 수 없는 오류가 발생했습니다.",
      );
    }
  }

  /// JSON 안전하게 디코딩
  Map<String, dynamic> _safeJsonDecode(String body) {
    if (body.isEmpty) return <String, dynamic>{};
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return <String, dynamic>{"data": decoded};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  /// POST request with timeout
  Future<http.Response> post(
    String path,
    Map<String, dynamic> body, {
    bool useAuth = false,
    Duration? timeout,
  }) {
    return http.post(
      _uri(path),
      headers: _headers(useAuth: useAuth),
      body: json.encode(body),
    ).timeout(timeout ?? defaultTimeout);
  }

  /// GET request with timeout
  Future<http.Response> get(
    String path, {
    Map<String, dynamic>? query,
    bool useAuth = false,
    Duration? timeout,
  }) {
    return http.get(
      _uri(path, query),
      headers: _headers(useAuth: useAuth),
    ).timeout(timeout ?? defaultTimeout);
  }

  /// PATCH request with timeout
  Future<http.Response> patch(
    String path,
    Map<String, dynamic> body, {
    bool useAuth = false,
    Duration? timeout,
  }) {
    return http.patch(
      _uri(path),
      headers: _headers(useAuth: useAuth),
      body: json.encode(body),
    ).timeout(timeout ?? defaultTimeout);
  }

  /// DELETE request with timeout
  Future<http.Response> delete(
    String path, {
    bool useAuth = false,
    Duration? timeout,
  }) {
    return http.delete(
      _uri(path),
      headers: _headers(useAuth: useAuth),
    ).timeout(timeout ?? defaultTimeout);
  }

  /// POST multipart/form-data with timeout
  Future<http.StreamedResponse> postMultipart(
    String path, {
    List<http.MultipartFile>? files,
    Map<String, String>? fields,
    bool useAuth = false,
    Duration? timeout,
  }) async {
    final uri = _uri(path);
    final req = http.MultipartRequest('POST', uri);
    if (useAuth && accessToken != null) {
      req.headers['Authorization'] = 'Bearer $accessToken';
    }
    if (fields != null) req.fields.addAll(fields);
    if (files != null) req.files.addAll(files);
    return await req.send().timeout(timeout ?? Duration(seconds: 60));
  }

  /// 안전한 API 호출 - 네트워크 예외를 표준화된 결과로 반환
  Future<ApiResult> safeGet(
    String path, {
    Map<String, dynamic>? query,
    bool useAuth = false,
    Duration? timeout,
  }) async {
    try {
      final resp = await get(path, query: query, useAuth: useAuth, timeout: timeout);
      return ApiResult(
        status: resp.statusCode,
        message: resp.statusCode >= 200 && resp.statusCode < 300 ? "success" : resp.body,
        data: _safeJsonDecode(resp.body),
      );
    } catch (e) {
      final netErr = _classifyException(e);
      return ApiResult(
        status: 0,
        message: netErr.message,
        userMessage: netErr.userMessage,
        isNetworkError: true,
        errorType: netErr.type,
      );
    }
  }

  /// 안전한 POST 호출
  Future<ApiResult> safePost(
    String path,
    Map<String, dynamic> body, {
    bool useAuth = false,
    Duration? timeout,
  }) async {
    try {
      final resp = await post(path, body, useAuth: useAuth, timeout: timeout);
      return ApiResult(
        status: resp.statusCode,
        message: resp.statusCode >= 200 && resp.statusCode < 300 ? "success" : resp.body,
        data: _safeJsonDecode(resp.body),
      );
    } catch (e) {
      final netErr = _classifyException(e);
      return ApiResult(
        status: 0,
        message: netErr.message,
        userMessage: netErr.userMessage,
        isNetworkError: true,
        errorType: netErr.type,
      );
    }
  }

  /// 안전한 PATCH 호출
  Future<ApiResult> safePatch(
    String path,
    Map<String, dynamic> body, {
    bool useAuth = false,
    Duration? timeout,
  }) async {
    try {
      final resp = await patch(path, body, useAuth: useAuth, timeout: timeout);
      return ApiResult(
        status: resp.statusCode,
        message: resp.statusCode >= 200 && resp.statusCode < 300 ? "success" : resp.body,
        data: _safeJsonDecode(resp.body),
      );
    } catch (e) {
      final netErr = _classifyException(e);
      return ApiResult(
        status: 0,
        message: netErr.message,
        userMessage: netErr.userMessage,
        isNetworkError: true,
        errorType: netErr.type,
      );
    }
  }

  /// 안전한 DELETE 호출
  Future<ApiResult> safeDelete(
    String path, {
    bool useAuth = false,
    Duration? timeout,
  }) async {
    try {
      final resp = await delete(path, useAuth: useAuth, timeout: timeout);
      return ApiResult(
        status: resp.statusCode,
        message: resp.statusCode >= 200 && resp.statusCode < 300 ? "success" : resp.body,
        data: _safeJsonDecode(resp.body),
      );
    } catch (e) {
      final netErr = _classifyException(e);
      return ApiResult(
        status: 0,
        message: netErr.message,
        userMessage: netErr.userMessage,
        isNetworkError: true,
        errorType: netErr.type,
      );
    }
  }

  void clearToken() {
    accessToken = null;
  }
}

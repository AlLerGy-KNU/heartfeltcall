import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

/// Dependent-side invitation flow
/// - Caregiver creates code (not here)
/// - Dependent polls status → gets auth_code when connected
/// - Dependent exchanges code+auth_code → dependent_token
class InvitationService {
  final ApiClient client;
  InvitationService(this.client);

  Future<Map<String, dynamic>> getStatus(String code) async {
    try {
      final http.Response resp = await client.get('/connections/$code/status');
      final data = json.decode(resp.body);
      return { 'status': resp.statusCode, 'data': data };
    } catch (e) {
      return { 'status': 500, 'message': 'error: $e' };
    }
  }

  Future<Map<String, dynamic>> exchangeToken({
    required String code,
    required String authCode,
  }) async {
    try {
      final http.Response resp = await client.post(
        '/auth/dependent/exchange',
        { 'code': code, 'auth_code': authCode },
      );
      final data = json.decode(resp.body);
      if (resp.statusCode == 200) {
        // store dependent token for subsequent voice calls
        client.accessToken = data['access_token'] as String?;
      }
      return { 'status': resp.statusCode, 'data': data };
    } catch (e) {
      return { 'status': 500, 'message': 'error: $e' };
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:memorion_caregiver/services/api_client.dart';

/// Service for dependent analyses (caregiver only)
class AnalysesService {
  final ApiClient client;

  AnalysesService(this.client);

  /// 1) GET /dependents/{dep_id}/analyses/latest
  /// Fetch latest analysis result for a dependent
  /// Response(200): {
  ///   state?: "NORMAL"|"MCI"|"DEMENTIA",
  ///   risk_score?: number,
  ///   created_at: string (ISO8601)
  /// }
  /// If no analysis exists, state/risk_score may be null, created_at is current time
  /// return: { "message": ..., "status": ..., "data": ... }
  Future<Map<String, dynamic>> getLatestAnalysis({
    required int dependentId,
  }) async {
    try {
      final http.Response resp = await client.get(
        "/dependents/$dependentId/analyses/latest",
        useAuth: true, // caregiver token required
      );

      if (resp.statusCode == 200) {
        final Map<String, dynamic> data =
            resp.body.isNotEmpty ? json.decode(resp.body) : <String, dynamic>{};

        return {
          "message": "latest analysis fetched",
          "status": resp.statusCode,
          "data": data,
        };
      } else {
        return {
          "message": "failed to fetch latest analysis: ${resp.body}",
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

  /// 2) GET /dependents/{dep_id}/analyses/history
  /// Fetch analysis history for a dependent
  /// Response(200): {
  ///   analyses: [
  ///     { state?, risk_score?, created_at }
  ///   ]
  /// }
  /// return: { "message": ..., "status": ..., "data": ... }
  Future<Map<String, dynamic>> getAnalysisHistory({
    required int dependentId,
  }) async {
    try {
      final http.Response resp = await client.get(
        "/dependents/$dependentId/analyses/history",
        useAuth: true, // caregiver token required
      );

      if (resp.statusCode == 200) {
        final Map<String, dynamic> data =
            resp.body.isNotEmpty ? json.decode(resp.body) : <String, dynamic>{};

        return {
          "message": "analysis history fetched",
          "status": resp.statusCode,
          "data": data,
        };
      } else {
        return {
          "message": "failed to fetch analysis history: ${resp.body}",
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

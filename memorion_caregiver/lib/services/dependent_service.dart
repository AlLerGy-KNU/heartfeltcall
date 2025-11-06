// dependent_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class DependentService {
  final ApiClient client;

  DependentService(this.client);

  /// Create a new dependent
  /// body example:
  /// { "name": "Grandma Kim", "birth_date": "1945-02-12", "relation": "grandmother" }
  Future<Map<String, dynamic>> createDependent({
    required String name,
    required String birthDate,
    required String relation,
  }) async {
    try {
      final http.Response resp = await client.post(
        "/dependents",
        {
          "name": name,
          "birth_date": birthDate,
          "relation": relation,
        },
        useAuth: true,
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data =
            resp.body.isNotEmpty ? json.decode(resp.body) : <String, dynamic>{};
        return {
          "status": resp.statusCode,
          "data": data,
        };
      } else {
        return {
          "status": resp.statusCode,
          "message": resp.body,
        };
      }
    } catch (e) {
      return {
        "status": 500,
        "message": "error: $e",
      };
    }
  }

  /// Get all dependents of current caregiver
  Future<Map<String, dynamic>> getDependents() async {
    try {
      final http.Response resp =
          await client.get("/dependents", useAuth: true);

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        return {
          "status": 200,
          "data": data,
        };
      } else {
        return {
          "status": resp.statusCode,
          "message": resp.body,
        };
      }
    } catch (e) {
      return {
        "status": 500,
        "message": "error: $e",
      };
    }
  }

  /// Get single dependent by id
  Future<Map<String, dynamic>> getDependent(int id) async {
    try {
      final http.Response resp =
          await client.get("/dependents/$id", useAuth: true);

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        return {
          "status": 200,
          "data": data,
        };
      } else {
        return {
          "status": resp.statusCode,
          "message": resp.body,
        };
      }
    } catch (e) {
      return {
        "status": 500,
        "message": "error: $e",
      };
    }
  }

  /// Update dependent info
  /// Pass only fields you want to change
  Future<Map<String, dynamic>> updateDependent(
    int id, {
    String? name,
    String? birthDate,
    String? relation,
  }) async {
    try {
      // build partial body
      final Map<String, dynamic> body = {};
      if (name != null) body["name"] = name;
      if (birthDate != null) body["birth_date"] = birthDate;
      if (relation != null) body["relation"] = relation;

      final http.Response resp =
          await client.patch("/dependents/$id", body, useAuth: true);

      if (resp.statusCode == 200) {
        final data =
            resp.body.isNotEmpty ? json.decode(resp.body) : <String, dynamic>{};
        return {
          "status": 200,
          "data": data,
        };
      } else {
        return {
          "status": resp.statusCode,
          "message": resp.body,
        };
      }
    } catch (e) {
      return {
        "status": 500,
        "message": "error: $e",
      };
    }
  }

  /// Soft delete dependent
  Future<Map<String, dynamic>> deleteDependent(int id) async {
    try {
      final http.Response resp =
          await client.delete("/dependents/$id", useAuth: true);

      if (resp.statusCode == 200 || resp.statusCode == 204) {
        return {
          "status": resp.statusCode,
          "message": "deleted",
        };
      } else {
        return {
          "status": resp.statusCode,
          "message": resp.body,
        };
      }
    } catch (e) {
      return {
        "status": 500,
        "message": "error: $e",
      };
    }
  }
}

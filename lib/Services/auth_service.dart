import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://localhost:3000";

  static String _extractError(dynamic body, String fallback) {
    try {
      if (body == null) return fallback;
      if (body is String) return body;
      if (body is Map<String, dynamic>) {
        // Prefer explicit error/message fields
        final msg = body['error'] ?? body['message'];
        // Gather list messages (common in validation libraries)
        final messages = <String>[];

        // body.errors can be Map or List
        final errors = body['errors'];
        if (errors is Map) {
          errors.forEach((k, v) {
            if (v is List) {
              messages.add("$k: ${v.join(', ')}");
            } else if (v is String) {
              messages.add("$k: $v");
            }
          });
        } else if (errors is List) {
          for (final e in errors) {
            if (e is Map) {
              // NestJS/class-validator style: { property, constraints: {rule: msg} }
              final prop = e['property'] ?? e['field'] ?? '';
              final constraints = e['constraints'];
              if (constraints is Map) {
                final constraintMsgs = (constraints.values)
                    .whereType<String>()
                    .toList();
                if (constraintMsgs.isNotEmpty) {
                  messages.add([
                    if (prop is String && prop.isNotEmpty) prop,
                    constraintMsgs.join(', ')
                  ].where((s) => s != null && s.toString().isNotEmpty).join(': '));
                }
              } else if (e['message'] is String) {
                messages.add(e['message']);
              }
            } else if (e is String) {
              messages.add(e);
            }
          }
        }

        // Sometimes message itself is a list
        final msgField = body['message'];
        if (msgField is List) {
          messages.addAll(msgField.whereType<String>());
        }

        // details array with message strings
        final details = body['details'];
        if (details is List) {
          for (final d in details) {
            if (d is Map && d['message'] is String) messages.add(d['message']);
            if (d is String) messages.add(d);
          }
        }

        final combined = [if (msg is String) msg, ...messages]
            .whereType<String>()
            .where((s) => s.trim().isNotEmpty)
            .toList();
        if (combined.isNotEmpty) return combined.join('\n');
      }
    } catch (_) {}
    return fallback;
  }

  // POST /api/auth/register
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String role, // e.g. "merchant" | "user"
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    final url = Uri.parse("$baseUrl/api/auth/register");
    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "role": role,
          "firstName": firstName,
          "lastName": lastName,
          "phone": phone,
        }),
      );

      final Map<String, dynamic> body =
          res.body.isNotEmpty ? jsonDecode(res.body) : <String, dynamic>{};

      if (res.statusCode == 201 || res.statusCode == 200) {
        return {
          "success": true,
          "message": body["message"],
          "user": body["user"],
          "tokens": body["tokens"],
        };
      }

      // Extract validation/field errors and surface them
      final message = _extractError(body, "Registration failed");
      return {
        "success": false,
        "message": message,
      };
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // POST /api/auth/login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/api/auth/login");
    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final Map<String, dynamic> body =
          res.body.isNotEmpty ? jsonDecode(res.body) : <String, dynamic>{};

      if (res.statusCode == 200) {
        return {
          "success": true,
          "message": body["message"],
          "user": body["user"],
          "tokens": body["tokens"],
        };
      }

      final message = _extractError(body, "Login failed");
      return {
        "success": false,
        "message": message,
      };
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // POST /api/auth/refresh-token
  static Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async {
    final url = Uri.parse("$baseUrl/api/auth/refresh-token");
    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      final Map<String, dynamic> body =
          res.body.isNotEmpty ? jsonDecode(res.body) : <String, dynamic>{};

      if (res.statusCode == 200) {
        return {
          "success": true,
          "tokens": {
            "idToken": body["idToken"],
            "refreshToken": body["refreshToken"],
            "expiresIn": body["expiresIn"],
            "uid": body["uid"],
          }
        };
      }

      return {
        "success": false,
        "message": body["error"] ?? body["message"] ?? "Refresh token failed",
      };
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}

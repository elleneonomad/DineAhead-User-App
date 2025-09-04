import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "https://08b11d6f2553.ngrok-free.app/api"; // Replace with your real backend URL

  // SEND VERIFICATION CODE API
  static Future<Map<String, dynamic>> sendVerifyCode(String email) async {
    final url = Uri.parse("$baseUrl/send_verify_code");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json", "type": "user"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return {
          "success": true,
          "message": body['msg'] ?? "Verification code sent",
          "data": body['data'] ?? {}
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          "success": false,
          "message": error["msg"] ?? "Failed to send verification code"
        };
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // REGISTER API
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String verifyCode,
    String avatar = "avatar.png",
  }) async {
    final url = Uri.parse("$baseUrl/register");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json", "type": "user"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "verify_code": verifyCode,
          "avatar": avatar,
        }),
      );

      // Safely decode response only if body is valid JSON
      Map<String, dynamic> body = {};
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = {"msg": response.body};
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "data": body['data'] ?? {}};
      } else {
        return {
          "success": false,
          "message": body["msg"] ?? "Registration failed"
        };
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // LOGIN API
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/login");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json", "type": "user"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)['data']};
      } else {
        final error = jsonDecode(response.body);
        return {"success": false, "message": error["msg"] ?? "Login failed"};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/cuisine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/restaurants.dart';
import '../Models/table_model.dart';

class ApiService {
  // Point to the new backend (keep without trailing /api; endpoints include it)
  static const String baseUrl = "http://localhost:3000";

  // SEND VERIFICATION CODE
  static Future<Map<String, dynamic>> sendVerifyCode(String email) async {
    final url = Uri.parse("$baseUrl/send_verify_code");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json", "type": "user"},
        body: jsonEncode({"email": email}),
      );

      Map<String, dynamic> body = {};
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = {"msg": response.body};
      }

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": body['msg'] ?? "Verification code sent",
          "data": body['data'] ?? {}
        };
      } else {
        return {
          "success": false,
          "message": body['msg'] ?? "Failed to send verification code"
        };
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // REGISTER
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String verifyCode,
    // String avatar = "avatar.png",
  }) async {
    final url = Uri.parse("$baseUrl/register");
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "type": "user"
        },
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "verify_code": verifyCode,
          // "avatar": avatar,
        }),
      );

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

  // LOGIN
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

      Map<String, dynamic> body = {};
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = {"msg": response.body};
      }

      if (response.statusCode == 200) {
        final token = body['data']['token'] ?? "";

        // ✅ Save token to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        return {"success": true, "data": body['data']};
      } else {
        return {"success": false, "message": body["msg"] ?? "Login failed"};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // New backend has no dedicated cuisine list endpoint for users.
  // Derive cuisines from the public restaurants list (cuisine: string[]).
  static Future<List<Cuisine>> getCuisines() async {
    try {
      final restaurants = await getRestaurants();
      final set = <String>{};
      for (final r in restaurants) {
        set.addAll(r.tags);
      }
      final list = set.toList()..sort();
      // Synthesize Cuisine models for UI compatibility
      final cuisines = <Cuisine>[];
      for (var i = 0; i < list.length; i++) {
        cuisines.add(Cuisine(
          id: i + 1,
          name: list[i],
          description: '',
          isActive: true,
        ));
      }
      return cuisines;
    } catch (e) {
      throw Exception("Failed to derive cuisines: $e");
    }
  }

  // Restaurant details (public) - New backend
  static Future<Map<String, dynamic>> getRestaurantDetails(String restaurantId) async {
    final url = Uri.parse("$baseUrl/api/user/restaurants/$restaurantId");
    final response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      if (parsed is Map<String, dynamic>) return parsed;
      throw Exception("Unexpected response shape for restaurant details");
    } else {
      throw Exception("Failed to load restaurant details: ${response.body}");
    }
  }

  // Availability: time slots for a table
  static Future<Map<String, dynamic>> getAvailableTimeSlots({
    required String tableId,
    required String date, // YYYY-MM-DD
    int? duration,
  }) async {
    Uri url = Uri.parse("$baseUrl/api/user/availability/time-slots");
    final qp = <String, String>{
      'tableId': tableId,
      'date': date,
    };
    if (duration != null && duration > 0) qp['duration'] = duration.toString();
    url = url.replace(queryParameters: qp);

    // Auth header
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('idToken') ?? prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Access token required. Please login again.');
    }

    final response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      if (parsed is Map<String, dynamic>) return parsed;
      throw Exception("Unexpected response for time slots");
    } else {
      throw Exception("Failed to load time slots: ${response.body}");
    }
  }

  // Create booking
  static Future<Map<String, dynamic>> createBooking({
    required String restaurantId,
    required String tableId,
    required String date, // YYYY-MM-DD
    required String time, // HH:mm
    int? duration,
    required int partySize,
    required String name,
    required String phone,
    required String email,
    String? specialRequests,
    List<Map<String, dynamic>> preOrder = const [],
  }) async {
    final url = Uri.parse("$baseUrl/api/user/bookings");
    final payload = <String, dynamic>{
      'restaurantId': restaurantId,
      'tableId': tableId,
      'date': date,
      'time': time,
      if (duration != null && duration > 0) 'duration': duration,
      'partySize': partySize,
      'customerInfo': {
        'name': name,
        'phone': phone,
        'email': email,
      },
      if (specialRequests != null && specialRequests.isNotEmpty)
        'specialRequests': specialRequests,
      'preOrder': preOrder,
    };

    // Auth header
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('idToken') ?? prefs.getString('token');
    if (token == null || token.isEmpty) {
      return {'success': false, 'error': 'Access token required. Please login again.'};
    }

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(payload),
    );

    final parsed = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    if (response.statusCode == 201 || response.statusCode == 200) {
      return {'success': true, ...parsed};
    } else {
      return {'success': false, ...parsed};
    }
  }

  // Get bookings (protected)
  static Future<List<dynamic>> getBookings({
    String? status, // "pending" | "confirmed" | "rejected" | "cancelled" | "completed" | "no-show"
    bool? upcoming,
  }) async {
    Uri url = Uri.parse("$baseUrl/api/user/bookings");

    final qp = <String, String>{};
    if (status != null && status.isNotEmpty) qp['status'] = status;
    if (upcoming != null) qp['upcoming'] = upcoming.toString();
    if (qp.isNotEmpty) url = url.replace(queryParameters: qp);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('idToken') ?? prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Access token required. Please login again.');
    }

    final response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      if (parsed is List) return parsed;
      if (parsed is Map && parsed['data'] is List) return parsed['data'] as List;
      // Fallback: wrap non-list into a list for inspection
      return [parsed];
    } else {
      throw Exception("Failed to load bookings: ${response.body}");
    }
  }

  // Get Restaurants (public, no auth) - New backend
  static Future<List<Restaurant>> getRestaurants({
    String? cuisine,
    String? priceRange, // 'budget' | 'mid-range' | 'fine-dining'
    String? search,
  }) async {
    Uri url = Uri.parse("$baseUrl/api/user/restaurants");

    // Only include valid, non-empty filters to avoid validation errors
    final qp = <String, String>{};
    if (cuisine != null) {
      final c = cuisine.trim();
      if (c.length >= 2) qp['cuisine'] = c;
    }
    if (priceRange != null) {
      final p = priceRange.trim().toLowerCase();
      const allowed = {'budget', 'mid-range', 'fine-dining'};
      if (allowed.contains(p)) qp['priceRange'] = p;
    }
    if (search != null) {
      final s = search.trim();
      if (s.length >= 2 && s.length <= 100) qp['search'] = s;
    }
    if (qp.isNotEmpty) {
      url = url.replace(queryParameters: qp);
    }

    final response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final body = response.body;
      final parsed = jsonDecode(body);
      if (parsed is List) {
        return parsed.map<Restaurant>((e) => Restaurant.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        // Some environments may wrap list inside {data: []}
        final List data = (parsed['data'] ?? []) as List;
        return data.map<Restaurant>((e) => Restaurant.fromJson(e as Map<String, dynamic>)).toList();
      }
    } else {
      throw Exception("Failed to load restaurants: ${response.body}");
    }
  }

  // Cancel booking
  static Future<Map<String, dynamic>> cancelBooking({
    required String bookingId,
    String? reason,
  }) async {
    final url = Uri.parse("$baseUrl/api/user/bookings/$bookingId/cancel");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('idToken') ?? prefs.getString('token');
    
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'Access token required. Please login again.'};
    }

    try {
      final response = await http.patch(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'reason': reason ?? 'User requested cancellation',
        }),
      );

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        return {'success': true, 'data': parsed};
      } else {
        final parsed = jsonDecode(response.body);
        // Return full error details from backend
        return {
          'success': false,
          'message': parsed['message'] ?? parsed['error'] ?? 'Failed to cancel booking',
          'error': parsed['error'],
          'details': parsed['details'],
          'requiredHours': parsed['requiredHours'],
          'hoursUntilBooking': parsed['hoursUntilBooking'],
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // get table of each restaurant
static Future<List<TableModel>> getTables(String storeId, String token) async {
  final url = Uri.parse("$baseUrl/table/public-list?store_id=$storeId");
  final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');


  final response = await http.get(
    url,
    headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
      "type": "user"
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    final List data = jsonResponse['data'];
    return data.map((e) => TableModel.fromJson(e)).toList();
  } else {
    throw Exception(
        "Failed to load tables: ${response.statusCode} ${response.body}");
  }
}

}

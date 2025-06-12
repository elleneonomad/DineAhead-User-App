import 'dart:async';

class MockApiService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(Duration(seconds: 1)); // simulate network delay

    // Simulate success response
    if (email == 'test@user.com' && password == 'password123') {
      return {
        'success': true,
        'code': 200,
        'data': {
          'token': 'mock_token_123',
          'refresh_token': 'mock_refresh_token_456',
          'name': 'Test User',
          'email': email,
          'avatar': 'avatar.png',
          'type': 'user'
        }
      };
    }

    // Simulate failure
    return {
      'success': false,
      'code': 401,
      'message': 'Invalid email or password'
    };
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password, String type, String avatar) async {
    await Future.delayed(Duration(seconds: 1)); // simulate network delay

    // Simulate a successful registration
    return {
      'success': true,
      'code': 200,
      'data': {
        'token': 'mock_token_789',
        'refresh_token': 'mock_refresh_token_987',
        'name': name,
        'email': email,
        'avatar': avatar,
        'type': type
      }
    };
  }
}

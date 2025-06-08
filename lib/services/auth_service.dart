// lib/services/auth_service.dart
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static const String baseUrl =
      'https://crafted-well-laravel.up.railway.app/api/auth';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Demo credentials for cost-effective testing
  static const String demoEmail = "user@craftedwell.com";
  static const String demoPassword = "qaz!QAZ";

  // Login with API (with demo fallback first to save money)
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    print('🔐 Auth: Attempting login for $email');

    // FIRST: Check demo credentials to save API costs
    if (email == demoEmail && password == demoPassword) {
      final demoUser = {
        'id': 1,
        'name': 'Demo User (SSP)',
        'email': email,
        'email_verified_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };

      await _saveAuthData('demo_ssp_token_123', demoUser);

      print('✅ Demo credentials login successful (saving API costs)');

      return {
        'success': true,
        'message': 'Demo login successful! (Cost-effective mode)',
        'user': demoUser,
        'token': 'demo_ssp_token_123',
      };
    }

    // SECOND: Try real API for other credentials
    try {
      print('💰 Using real API for non-demo credentials');

      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(Duration(seconds: 10));

      print('📡 API Response: ${response.statusCode}');
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await _saveAuthData(data['token'], data['user']);

        print('✅ Real API login successful');

        return {
          'success': true,
          'message': data['message'] ?? 'Login successful',
          'user': data['user'],
          'token': data['token'],
        };
      } else {
        print('❌ API login failed: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Invalid credentials',
        };
      }
    } catch (e) {
      print('🚨 API Error: $e');

      return {
        'success': false,
        'message':
            'Login failed. Use demo credentials:\nEmail: $demoEmail\nPassword: $demoPassword',
      };
    }
  }

  // Register with API (demo note for costs)
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    print('📝 Auth: Attempting registration for $email');

    // Note about demo for assignment
    if (email == demoEmail) {
      return {
        'success': false,
        'message':
            'Demo email reserved. Use demo login instead:\nEmail: $demoEmail\nPassword: $demoPassword',
      };
    }

    try {
      print('💰 Using real API for registration');

      final response = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'name': name,
              'email': email,
              'password': password,
              'password_confirmation': password,
            }),
          )
          .timeout(Duration(seconds: 10));

      print('📡 Register Response: ${response.statusCode}');
      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        print('✅ Real API registration successful');

        return {
          'success': true,
          'message':
              data['message'] ?? 'Registration successful! Please login.',
        };
      } else {
        String errorMessage = data['message'] ?? 'Registration failed';

        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          final errorMessages = <String>[];

          errors.forEach((field, messages) {
            if (messages is List) {
              errorMessages.addAll(messages.cast<String>());
            }
          });

          if (errorMessages.isNotEmpty) {
            errorMessage = errorMessages.join('\n');
          }
        }

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('🚨 Registration Error: $e');

      return {
        'success': false,
        'message':
            'Registration failed. Network error.\n\nFor assignment demo, use:\nEmail: $demoEmail\nPassword: $demoPassword',
      };
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      final token = await getToken();

      if (token != null && !token.startsWith('demo_')) {
        print('🚪 Auth: API logout');
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(Duration(seconds: 5));
      } else {
        print('🚪 Auth: Demo logout');
      }
    } catch (e) {
      print('⚠️ Logout error: $e');
    } finally {
      await _clearAuthData();
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    final isLoggedIn = token != null && token.isNotEmpty;
    if (isLoggedIn) {
      final user = await getUser();
      print('🔍 Auth state: Logged in as ${user?['email']}');
    }
    return isLoggedIn;
  }

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get stored user data
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString != null) {
      return json.decode(userString);
    }
    return null;
  }

  // Save authentication data
  static Future<void> _saveAuthData(
      String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, json.encode(user));
    print('💾 Auth data saved for ${user['email']}');
  }

  // Clear authentication data
  static Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    print('🗑️ Auth data cleared');
  }

  // Verify token
  static Future<bool> verifyToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      // Demo tokens are always valid
      if (token.startsWith('demo_')) {
        return true;
      }

      // Verify real tokens with API
      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('⚠️ Token verification error: $e');
      return false;
    }
  }
}

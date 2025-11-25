import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get _baseUrl {
    if (Platform.isAndroid) {
      return 'https://cleaner-app-t1jm.onrender.com/api';
    }
    return 'https://cleaner-app-t1jm.onrender.com/api';
  }

  static Future<Map<String, dynamic>> registerUser(Map<String, String> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final body = jsonDecode(response.body);
      if (body['error'] != null) {
        throw Exception(body['error']);
      } else if (body['errors'] != null) {
        final errors = List<Map<String, dynamic>>.from(body['errors']);
        final messages = errors.map((e) => e['msg']).join('\n');
        throw Exception(messages);
      }
      throw Exception('Failed to register user: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['token']);
      return data;
    } else {
      final body = jsonDecode(response.body);
      if (body['error'] != null) {
        throw Exception(body['error']);
      } else if (body['errors'] != null) {
        final errors = List<Map<String, dynamic>>.from(body['errors']);
        final messages = errors.map((e) => e['msg']).join('\n');
        throw Exception(messages);
      }
      throw Exception('Failed to login: ${response.body}');
    }
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<void> seedTestAccounts() async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/auth/seed-test-accounts'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
    } catch (e) {
      // Silently fail - test accounts may already exist
    }
  }

  static Future<void> seedServices() async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/services/seed'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
    } catch (e) {
      // Silently fail - services may already exist
    }
  }

  static Future<Map<String, dynamic>> createService({
    required String title,
    required String description,
    required String category,
    required int basePrice,
    String? image,
  }) async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/services'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'category': category,
        'basePrice': basePrice,
        'image': image,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Failed to create service');
    }
  }

  static Future<List<dynamic>> getServices() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/services'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Failed to load services');
    }
  }
}

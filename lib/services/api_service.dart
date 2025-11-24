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
}

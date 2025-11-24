import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('http://localhost:5000/api/auth/register');
  final headers = {'Content-Type': 'application/json; charset=UTF-8'};
  final data = {
    'name': 'Test User',
    'email': 'test.user@example.com',
    'password': 'password123',
    'phone': '1234567890',
    'address': '123 Main St',
    'role': 'customer',
  };

  try {
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    print('Status Code: ${response.statusCode}');
    print('Body: ${response.body}');
  } catch (e) {
    print('Error: $e');
  }
}

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
      final responseData = jsonDecode(response.body);
      // Save token after successful registration
      if (responseData['token'] != null) {
        await saveToken(responseData['token']);
      }
      return responseData;
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

  // ===================== ADMIN API METHODS =====================

  // Get dashboard statistics
  static Future<Map<String, dynamic>> getDashboardStats() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/admin/dashboard'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? {};
    } else {
      throw Exception('Failed to load dashboard stats');
    }
  }

  // Get all bookings (admin)
  static Future<List<dynamic>> getAdminBookings({String? status}) async {
    final token = await getToken();
    String url = '$_baseUrl/admin/bookings';
    if (status != null) {
      url += '?status=$status';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Failed to load bookings');
    }
  }

  // Get all cleaners (admin)
  static Future<List<dynamic>> getCleaners() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/admin/cleaners'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Failed to load cleaners');
    }
  }

  // Assign cleaner to booking
  static Future<Map<String, dynamic>> assignCleanerToBooking(String bookingId, String cleanerId) async {
    final token = await getToken();

    final response = await http.put(
      Uri.parse('$_baseUrl/admin/bookings/$bookingId/assign'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'cleanerId': cleanerId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? {};
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Failed to assign cleaner');
    }
  }

  // Get all users (admin)
  static Future<List<dynamic>> getUsers({String? role}) async {
    final token = await getToken();
    String url = '$_baseUrl/admin/users';
    if (role != null) {
      url += '?role=$role';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Failed to load users');
    }
  }

  // Save user data to SharedPreferences
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', jsonEncode(userData));
  }

  // Get user data from SharedPreferences
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  // Clear all saved data (for logout)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userData');
  }

  // ===================== CUSTOMER API METHODS =====================

  // Get customer's bookings
  static Future<List<dynamic>> getCustomerBookings({String? status}) async {
    final token = await getToken();
    String url = '$_baseUrl/bookings';
    if (status != null) {
      url += '?status=$status';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Failed to load bookings');
    }
  }

  // Generate unique booking ID
  static String _generateBookingId() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(7);
    return 'BK$timestamp';
  }

  // Create a new booking
  static Future<Map<String, dynamic>> createBooking({
    required String serviceId,
    required String bookingDate,
    required String bookingTime,
    required String location,
    required String address,
    required String phone,
    required String paymentMethod,
    required int subtotal,
    int discount = 0,
    required int total,
    String? notes,
  }) async {
    final token = await getToken();
    final bookingId = _generateBookingId();

    final response = await http.post(
      Uri.parse('$_baseUrl/bookings'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'bookingId': bookingId,
        'service': serviceId,
        'bookingDate': bookingDate,
        'bookingTime': bookingTime,
        'location': location,
        'address': address,
        'phone': phone,
        'paymentMethod': paymentMethod,
        'subtotal': subtotal,
        'discount': discount,
        'total': total,
        'notes': notes ?? '',
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? {};
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Failed to create booking');
    }
  }

  // Cancel a booking
  static Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    final token = await getToken();

    final response = await http.put(
      Uri.parse('$_baseUrl/bookings/$bookingId/cancel'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? {};
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Failed to cancel booking');
    }
  }

  // Get single booking details
  static Future<Map<String, dynamic>> getBookingDetails(String bookingId) async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/bookings/$bookingId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? {};
    } else {
      throw Exception('Failed to load booking details');
    }
  }

  // ===================== CLEANER API METHODS =====================

  // Get cleaner's assigned bookings (uses same endpoint, filtered by backend)
  static Future<List<dynamic>> getCleanerBookings({String? status}) async {
    final token = await getToken();
    String url = '$_baseUrl/bookings';
    if (status != null) {
      url += '?status=$status';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Failed to load assigned bookings');
    }
  }

  // Update booking status (for cleaner to mark as in_progress or completed)
  static Future<Map<String, dynamic>> updateBookingStatus(String bookingId, String status) async {
    final token = await getToken();

    final response = await http.put(
      Uri.parse('$_baseUrl/bookings/$bookingId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? {};
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Failed to update booking status');
    }
  }

  // ===================== MESSAGING API METHODS =====================

  // Send a message (to cleaner, customer, or admin)
  static Future<Map<String, dynamic>> sendMessage({
    String? bookingId,
    required String recipientId,
    required String recipientType, // 'customer', 'cleaner', 'admin'
    required String message,
  }) async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/messages'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'bookingId': bookingId,
        'recipientId': recipientId,
        'recipientType': recipientType,
        'message': message,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? {};
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Failed to send message');
    }
  }

  // Get messages for a specific booking
  static Future<List<dynamic>> getMessagesForBooking(String bookingId) async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/messages/booking/$bookingId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Failed to load messages');
    }
  }

  // Get all conversations for current user
  static Future<List<dynamic>> getConversations() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/messages/conversations'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Failed to load conversations');
    }
  }

  // Mark messages as read
  static Future<void> markMessagesAsRead(String conversationId) async {
    final token = await getToken();

    await http.put(
      Uri.parse('$_baseUrl/messages/$conversationId/read'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
  }

  // Get messages between current user and admin
  static Future<List<dynamic>> getAdminMessages() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/messages/admin'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Failed to load admin messages');
    }
  }
}

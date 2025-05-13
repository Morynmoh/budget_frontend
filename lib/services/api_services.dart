// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000'; // Your backend URL

  // Login method (already added)
  Future<void> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Login successful: $data');
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  // 👇 NEW Signup method
  Future<void> signup(String email, String password) async {
    final url = Uri.parse('$baseUrl/signup');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user': {
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print('Signup successful: $data');
    } else {
      print('Signup failed: ${response.body}');
    }
  }
  // Future<void> signup(String email, String password) async {
  //   final url = Uri.parse('$baseUrl/signup');
  //   final response = await http.post(
  //     url,
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({'email': email, 'password': password}),
  //   );

  //   if (response.statusCode == 201 || response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     print('Signup successful: $data');
  //   } else {
  //     throw Exception('Signup failed: ${response.body}');
  //   }
  // }
}

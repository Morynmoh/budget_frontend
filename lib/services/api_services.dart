// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://localhost:3000'; // Replace with your backend URL

  // Function to log in a user
  Future<void> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login'); // API endpoint
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Login successful: $data');
      // Save token or user data, e.g., using shared preferences or go to the next screen
    } else {
      print('Login failed: ${response.body}');
      // Show error message
    }
  }
}

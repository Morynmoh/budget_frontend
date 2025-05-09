import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_constants.dart';

class AuthService {
  static Future<String?> login(String email, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Save the token using secure storage if needed
      return data['token'];
    }

    return null;
  }
}

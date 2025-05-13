
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import '../config/api_constants.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', data['token']);
      await prefs.setInt('userId', data['user']['id']); // ✅ Store userId

      return true;
    } else {
      print('Login failed: ${response.body}');
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('userId');
  }

  static Future<String?> getJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }
}

// class AuthService {
//   // static   Future<bool> login(String email, String password) async {
//   //   final url = Uri.parse('${ApiConstants.baseUrl}/login');

//   //   final response = await http.post(
//   //     url,
//   //     headers: {'Content-Type': 'application/json'},
//   //     body: jsonEncode({'email': email, 'password': password}),
//   //   );

//   //   if (response.statusCode == 200) {
//   //     final data = jsonDecode(response.body);
//   //     final token = data['token'];
//   //     final userId = data['user']['id'];

//   //     await _saveAuthData(token, userId);
//   //     return true;
//   //   }

//   //   return false;
//   // }
//   static Future<bool> login(String email, String password) async {
//     final url = Uri.parse('${ApiConstants.baseUrl}/login');

//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'email': email, 'password': password}),
//     );

//     if (response.statusCode == 200) {
//       try {
//         final data = jsonDecode(response.body);

//         // Validate that token and user object exist
//         if (data != null &&
//             data.containsKey('token') &&
//             data.containsKey('user') &&
//             data['user'] != null &&
//             data['user'].containsKey('id')) {
//           final token = data['token'];
//           final userId = data['user']['id'];

//           await _saveAuthData(token, userId);
//           return true;
//         } else {
//           print('Unexpected response structure: $data');
//         }
//       } catch (e) {
//         print('Failed to parse login response: $e');
//       }
//     } else {
//       print(
//         'Login failed with status ${response.statusCode}: ${response.body}',
//       );
//     }

//     return false;
//   }


//   static Future<void> _saveAuthData(String token, int userId) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('jwt_token', token);
//     await prefs.setInt('user_id', userId);
//   }

//   static Future<String?> getJwtToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('jwt_token');
//   }

//   static Future<int?> getUserId() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getInt('user_id');
//   }

//   static Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('jwt_token');
//     await prefs.remove('user_id');
//   }
// }



// // import 'dart:convert';
// // import 'package:http/http.dart' as http;
// // import '../config/api_constants.dart';

// // class AuthService {
// //   static Future<String?> login(String email, String password) async {
// //     final url = Uri.parse('${ApiConstants.baseUrl}/login');

// //     final response = await http.post(
// //       url,
// //       headers: {'Content-Type': 'application/json'},
// //       body: jsonEncode({'email': email, 'password': password}),
// //     );

// //     if (response.statusCode == 200) {
// //       final data = jsonDecode(response.body);
// //       // Save the token using secure storage if needed
// //       return data['token'];
// //     }

// //     return null;
// //   }
// // }

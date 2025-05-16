import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl =
      'http://206.189.131.126:3012'; //  Your backend URL

  // Mock implementation of getJwtToken
  Future<String> getJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      throw Exception('JWT token not found');
    }
    return token;
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Login successful: $data');

      // Optionally save JWT if your API returns one
      final prefs = await SharedPreferences.getInstance();
      if (data['token'] != null) {
        await prefs.setString('jwt_token', data['token']);
      }

      return data;
    } else {
      print('Login failed: ${response.body}');
      throw Exception('Login failed');
    }
  }

  // Signup
  Future<void> signup(String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/signup');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user': {
          'name': name, // Add the name field here
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

  Future<Map<String, dynamic>> getUserById(int userId) async {
    final url = Uri.parse('$baseUrl/users/$userId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getJwtToken()}',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'id': data['id'], 'name': data['name'], 'email': data['email']};
    } else {
      throw Exception('Failed to fetch user: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final url = Uri.parse('$baseUrl/users');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Ensure 'name' is handled correctly in the response
      // Assuming each user object contains 'name', 'email', etc.
      return List<Map<String, dynamic>>.from(
        data.map((user) {
          return {
            'id': user['id'],
            'name': user['name'], // Add name here
            'email': user['email'],
            // You can include any other fields returned by the API
          };
        }),
      );
    } else {
      throw Exception('Failed to load users: ${response.body}');
    }
  }

  // Future<List<Map<String, dynamic>>> getUsers() async {
  //     final url = Uri.parse('$baseUrl/users');
  //     final response = await http.get(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       return List<Map<String, dynamic>>.from(data);
  //     } else {
  //       throw Exception('Failed to load users: ${response.body}');
  //     }
  //   }

  // ------------------ Fetch Methods ------------------

  Future<List<Map<String, dynamic>>> getAccounts() async {
    final url = Uri.parse('$baseUrl/accounts');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load accounts');
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final url = Uri.parse('$baseUrl/categories');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<Map<String, dynamic>>> getExpenses() async {
    final url = Uri.parse('$baseUrl/expenses');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  // ----------------------Delete Methods---------------
  Future<void> deleteAccount(int id) async {
    final url = Uri.parse('$baseUrl/accounts/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete account');
    }
  }

  Future<void> deleteExpense(int id) async {
    final url = Uri.parse('$baseUrl/expenses/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete expense');
    }
  }

  Future<void> deleteCategory(int id) async {
    final url = Uri.parse('$baseUrl/categories/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete category');
    }
  }

  // ---------------Update Methods ------------------
  Future<bool> updateAccount(int id, Map<String, dynamic> updatedData) async {
    final url = Uri.parse('$baseUrl/accounts/$id');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        // Account updated successfully
        return true;
      } else {
        // Handle error if response is not 200
        print('Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Failed to update account: $e');
      return false;
    }
  }

  Future<bool> updateCategory(int id, Map<String, dynamic> updatedData) async {
    final url = Uri.parse('$baseUrl/categories/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        // Category updated successfully
        return true;
      } else {
        // Handle error if response is not 200
        print('Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Failed to update category: $e');
      return false;
    }
  }

  Future<void> updateExpense(int id, Map<String, dynamic> updatedData) async {
    final url = Uri.parse('$baseUrl/expenses/$id');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update Expenses');
    }
  }

  // ------------------ Post Methods ------------------

  Future<bool> addExpense(Map<String, dynamic> expenseData) async {
    final url = Uri.parse('$baseUrl/expenses');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'expense': expenseData}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('Expense added successfully: ${response.body}');
      return true;
    } else {
      print('Failed to add expense: ${response.body}');
      return false;
    }
  }

  Future<bool> addIncome(Map<String, dynamic> incomeData) async {
    final url = Uri.parse('$baseUrl/incomes');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'income': incomeData}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('Income added successfully: ${response.body}');
      return true;
    } else {
      print('Failed to add income: ${response.body}');
      return false;
    }
  }

  Future<bool> addInvestment(Map<String, dynamic> investmentData) async {
    final url = Uri.parse('$baseUrl/investments');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'investment': investmentData}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('Investment added successfully: ${response.body}');
      return true;
    } else {
      print('Failed to add investment: ${response.body}');
      return false;
    }
  }

  Future<bool> addAccount(Map<String, dynamic> accountData) async {
    final token = await getJwtToken();

    final response = await http.post(
      Uri.parse('$baseUrl/accounts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(accountData),
    );

    return response.statusCode == 201;
  }

  Future<bool> addCategory(Map<String, dynamic> categoryData) async {
    final url = Uri.parse('$baseUrl/categories');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'category': categoryData}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('Category added successfully: ${response.body}');
      return true;
    } else {
      print('Failed to add category: ${response.body}');
      return false;
    }
  }
}




// // lib/services/api_service.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ApiService {
//   static const String baseUrl = 'http://localhost:3000'; // Your backend URL

//   // Login method (already added)
//   Future<void> login(String email, String password) async {
//     final url = Uri.parse('$baseUrl/login');
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'email': email, 'password': password}),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       print('Login successful: $data');
//     } else {
//       throw Exception('Login failed: ${response.body}');
//     }
//   }

//   // Signup method (already added)
//   Future<void> signup(String email, String password) async {
//     final url = Uri.parse('$baseUrl/signup');
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'user': {
//           'email': email,
//           'password': password,
//           'password_confirmation': password,
//         },
//       }),
//     );

//     if (response.statusCode == 201) {
//       final data = jsonDecode(response.body);
//       print('Signup successful: $data');
//     } else {
//       print('Signup failed: ${response.body}');
//     }
//   }

//   // Fetch Accounts
//   Future<List<Map<String, dynamic>>> getAccounts() async {
//     final url = Uri.parse('$baseUrl/accounts');
//     final response = await http.get(
//       url,
//       headers: {'Content-Type': 'application/json'},
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return List<Map<String, dynamic>>.from(data);
//     } else {
//       throw Exception('Failed to load accounts');
//     }
//   }

//   // Fetch Categories
//   Future<List<Map<String, dynamic>>> getCategories() async {
//     final url = Uri.parse('$baseUrl/categories');
//     final response = await http.get(
//       url,
//       headers: {'Content-Type': 'application/json'},
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return List<Map<String, dynamic>>.from(data);
//     } else {
//       throw Exception('Failed to load categories');
//     }
//   }

//   // Add Expense method
//   Future<bool> addExpense(Map<String, dynamic> expenseData) async {
//     final url = Uri.parse('$baseUrl/expenses');
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'expense': expenseData}),
//     );

//     if (response.statusCode == 201 || response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       print('Expense added successfully: $data');
//       return true;
//     } else {
//       print('Failed to add expense: ${response.body}');
//       return false;
//     }
//   }
// }



// // lib/services/api_service.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ApiService {
//   static const String baseUrl = 'http://localhost:3000'; // Your backend URL

//   // Login method (already added)
//   Future<void> login(String email, String password) async {
//     final url = Uri.parse('$baseUrl/login');
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'email': email, 'password': password}),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       print('Login successful: $data');
//     } else {
//       throw Exception('Login failed: ${response.body}');
//     }
//   }

//   // 👇 NEW Signup method
//   Future<void> signup(String email, String password) async {
//     final url = Uri.parse('$baseUrl/signup');
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'user': {
//           'email': email,
//           'password': password,
//           'password_confirmation': password,
//         },
//       }),
//     );

//     if (response.statusCode == 201) {
//       final data = jsonDecode(response.body);
//       print('Signup successful: $data');
//     } else {
//       print('Signup failed: ${response.body}');
//     }
//   }
//   // Future<void> signup(String email, String password) async {
//   //   final url = Uri.parse('$baseUrl/signup');
//   //   final response = await http.post(
//   //     url,
//   //     headers: {'Content-Type': 'application/json'},
//   //     body: jsonEncode({'email': email, 'password': password}),
//   //   );

//   //   if (response.statusCode == 201 || response.statusCode == 200) {
//   //     final data = jsonDecode(response.body);
//   //     print('Signup successful: $data');
//   //   } else {
//   //     throw Exception('Signup failed: ${response.body}');
//   //   }
//   // }
// }

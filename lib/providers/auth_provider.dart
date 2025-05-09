import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String email, String password) async {
    final token = await AuthService.login(email, password);

    if (token != null) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }

    return false;
  }
}

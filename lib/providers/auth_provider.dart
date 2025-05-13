import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  int? _userId;

  String? get token => _token;
  int? get userId => _userId;

  Future<bool> login(String email, String password) async {
    final result = await AuthService.login(email, password);

    if (result) {
      _token = await AuthService.getJwtToken();
      _userId = await AuthService.getUserId();
      notifyListeners();
      return true;
    }

    return false;
  }

  void logout() async {
    await AuthService.logout();
    _token = null;
    _userId = null;
    notifyListeners();
  }
}




// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';

// class AuthProvider with ChangeNotifier {
//   String? _token;
//   int? _userId;

//   String? get token => _token;
//   int? get userId => _userId;

//   Future<bool> login(String email, String password) async {
//     final result = await AuthService.login(email, password);

//     if (result) {
//       _token = await AuthService.getJwtToken();
//       _userId = await AuthService.getUserId();
//       notifyListeners();
//       return true;
//     }

//     return false;
//   }

//   void logout() async {
//     await AuthService.logout();
//     _token = null;
//     _userId = null;
//     notifyListeners();
//   }
// }

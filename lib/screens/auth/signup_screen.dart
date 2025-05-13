import 'package:flutter/material.dart';
import 'package:budget/services/api_services.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;

  void _signup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      await _apiService.signup(email, password);

      if (!mounted) return;

      // ✅ Show success dialog before navigating to login
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text('Signup Successful'),
              content: Text('Your account has been created. Please log in.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pushReplacementNamed(
                      context,
                      '/login',
                    ); // Go to login screen
                  },
                  child: Text('OK'),
                ),
              ],
            ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Signup failed. ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _signup,
                  child: const Text("Sign Up"),
                ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:budget/services/api_services.dart';

// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});
//   @override
//   SignUpScreenState createState() => SignUpScreenState();
// }

// class SignUpScreenState extends State<SignUpScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final ApiService _apiService = ApiService();
//   bool _isLoading = false;
//   String? _errorMessage;

//   void _signup() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     String email = _emailController.text;
//     String password = _passwordController.text;

//     try {
//       await _apiService.signup(email, password);
//       if (mounted) {
//         Navigator.pushReplacementNamed(context, '/login'); // Go back to login
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Signup failed. ${e.toString()}';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Sign Up")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _emailController,
//               decoration: InputDecoration(labelText: 'Email'),
//             ),
//             TextField(
//               controller: _passwordController,
//               obscureText: true,
//               decoration: InputDecoration(labelText: 'Password'),
//             ),
//             SizedBox(height: 20),
//             _isLoading
//                 ? CircularProgressIndicator()
//                 : ElevatedButton(onPressed: _signup, child: Text("Sign Up")),
//             if (_errorMessage != null)
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   _errorMessage!,
//                   style: TextStyle(color: Colors.red),
//                 ),
//               ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pushReplacementNamed(context, '/login');
//               },
//               child: Text("Already have an account? Login"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

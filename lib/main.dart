// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart'; // ✅ Import signup
import 'screens/dashboard/dashboard_screen.dart';
import 'providers/auth_provider.dart';
import 'screens/forms/add_expense_screen.dart';
import 'screens/forms/add_income_screen.dart';
import 'screens/forms/add_investment_screen.dart';
import 'screens/forms/add_category_screen.dart';
import 'screens/forms/add_account_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginScreen(),
        '/login': (_) => const LoginScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/signup': (_) => SignUpScreen(), // ✅ Added signup route
        '/add_expense': (_) => AddExpenseScreen(),
        '/add_income': (_) => AddIncomeScreen(),
        '/add_investment': (_) => AddInvestmentScreen(),
        '/add_category': (_) => AddCategoryScreen(),
        '/add_account': (_) => AddAccountScreen(),
      },
    );
  }
}

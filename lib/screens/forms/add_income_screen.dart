// lib/screens/forms/add_income_screen.dart

import 'package:flutter/material.dart';
import 'package:budget/services/api_services.dart';
import 'package:intl/intl.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  DateTime? _selectedDate;
  int? _selectedAccountId;

  List<Map<String, dynamic>> _accounts = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // Set today's date as default
    _fetchAccounts();
  }

  Future<void> _fetchAccounts() async {
    try {
      final accounts = await ApiService().getAccounts();
      setState(() {
        _accounts = accounts;
      });
    } catch (e) {
      print('Failed to load accounts: $e');
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _submitForm() async {
    final amount = double.tryParse(_amountController.text.trim());
    final source = _sourceController.text.trim();
    final date = _selectedDate;
    final accountId = _selectedAccountId;

    if (accountId == null || amount == null || date == null || source.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please complete all fields')));
      return;
    }

    final incomeData = {
      'account_id': accountId,
      'amount': amount,
      'date': date.toIso8601String(),
      'source': source,
    };

    final success = await ApiService().addIncome(incomeData);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Income added successfully')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add income')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Income')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButtonFormField<int>(
              value: _selectedAccountId,
              decoration: InputDecoration(labelText: 'Select Account'),
              items:
                  _accounts.map((account) {
                    return DropdownMenuItem<int>(
                      value: account['id'],
                      child: Text(
                        account['description'] ?? 'Account ${account['id']}',
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAccountId = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Amount'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _sourceController,
              decoration: InputDecoration(labelText: 'Source'),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text(
                _selectedDate == null
                    ? 'Pick a Date'
                    : DateFormat('yyyy-MM-dd').format(_selectedDate!),
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            SizedBox(height: 24),
            ElevatedButton(onPressed: _submitForm, child: Text('Add Income')),
          ],
        ),
      ),
    );
  }
}


// class _AddIncomeScreenState extends State<AddIncomeScreen> {
//   final TextEditingController _amountController = TextEditingController();
//   final TextEditingController _sourceController = TextEditingController();
//   DateTime? _selectedDate;
//   int? _selectedAccountId;

//   List<Map<String, dynamic>> _accounts = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchAccounts();
//   }

//   Future<void> _fetchAccounts() async {
//     try {
//       final accounts = await ApiService().getAccounts();
//       setState(() {
//         _accounts = accounts;
//       });
//     } catch (e) {
//       print('Failed to load accounts: $e');
//     }
//   }

//   Future<void> _pickDate() async {
//     final pickedDate = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );

//     if (pickedDate != null) {
//       setState(() {
//         _selectedDate = pickedDate;
//       });
//     }
//   }

//   Future<void> _submitForm() async {
//     final amount = double.tryParse(_amountController.text.trim());
//     final source = _sourceController.text.trim();
//     final date = _selectedDate;
//     final accountId = _selectedAccountId;

//     if (accountId == null || amount == null || date == null || source.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Please complete all fields')));
//       return;
//     }

//     final incomeData = {
//       'account_id': accountId,
//       'amount': amount,
//       'date': date.toIso8601String(),
//       'source': source,
//     };

//     final success = await ApiService().addIncome(incomeData);

//     if (success) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Income added successfully')));
//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Failed to add income')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Add Income')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             DropdownButtonFormField<int>(
//               value: _selectedAccountId,
//               decoration: InputDecoration(labelText: 'Select Account'),
//               items:
//                   _accounts.map((account) {
//                     return DropdownMenuItem<int>(
//                       value: account['id'],
//                       child: Text(
//                         account['description'] ?? 'Account ${account['id']}',
//                       ),
//                     );
//                   }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedAccountId = value;
//                 });
//               },
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: _amountController,
//               keyboardType: TextInputType.numberWithOptions(decimal: true),
//               decoration: InputDecoration(labelText: 'Amount'),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: _sourceController,
//               decoration: InputDecoration(labelText: 'Source'),
//             ),
//             SizedBox(height: 16),
//             ListTile(
//               title: Text(
//                 _selectedDate == null
//                     ? 'Pick a Date'
//                     : DateFormat('yyyy-MM-dd').format(_selectedDate!),
//               ),
//               trailing: Icon(Icons.calendar_today),
//               onTap: _pickDate,
//             ),
//             SizedBox(height: 24),
//             ElevatedButton(onPressed: _submitForm, child: Text('Add Income')),
//           ],
//         ),
//       ),
//     );
//   }
// }

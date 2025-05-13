// lib/screens/forms/add_investment_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:budget/services/api_services.dart';

class AddInvestmentScreen extends StatefulWidget {
  const AddInvestmentScreen({super.key});

  @override
  State<AddInvestmentScreen> createState() => _AddInvestmentScreenState();
}

class _AddInvestmentScreenState extends State<AddInvestmentScreen> {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
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
      print('Error loading accounts: $e');
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
    if (_selectedAccountId == null ||
        _typeController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final investmentData = {
      'account_id': _selectedAccountId,
      'investment_type': _typeController.text.trim(),
      'amount': double.tryParse(_amountController.text.trim()),
      'date': _selectedDate!.toIso8601String(),
      'comments': _commentsController.text.trim(),
    };

    final success = await ApiService().addInvestment(investmentData);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Investment added successfully')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add investment')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Investment')),
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
              onChanged: (value) => setState(() => _selectedAccountId = value),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _typeController,
              decoration: InputDecoration(labelText: 'Investment Type'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Amount'),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text(
                _selectedDate == null
                    ? 'Pick Date'
                    : DateFormat('yyyy-MM-dd').format(_selectedDate!),
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _commentsController,
              decoration: InputDecoration(labelText: 'Comments (optional)'),
              maxLines: 3,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Add Investment'),
            ),
          ],
        ),
      ),
    );
  }
}


// class _AddInvestmentScreenState extends State<AddInvestmentScreen> {
//   final TextEditingController _typeController = TextEditingController();
//   final TextEditingController _amountController = TextEditingController();
//   final TextEditingController _commentsController = TextEditingController();
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
//       print('Error loading accounts: $e');
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
//     if (_selectedAccountId == null ||
//         _typeController.text.isEmpty ||
//         _amountController.text.isEmpty ||
//         _selectedDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please fill all required fields')),
//       );
//       return;
//     }

//     final investmentData = {
//       'account_id': _selectedAccountId,
//       'investment_type': _typeController.text.trim(),
//       'amount': double.tryParse(_amountController.text.trim()),
//       'date': _selectedDate!.toIso8601String(),
//       'comments': _commentsController.text.trim(),
//     };

//     final success = await ApiService().addInvestment(investmentData);

//     if (success) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Investment added successfully')));
//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Failed to add investment')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Add Investment')),
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
//               onChanged: (value) => setState(() => _selectedAccountId = value),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: _typeController,
//               decoration: InputDecoration(labelText: 'Investment Type'),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: _amountController,
//               keyboardType: TextInputType.numberWithOptions(decimal: true),
//               decoration: InputDecoration(labelText: 'Amount'),
//             ),
//             SizedBox(height: 16),
//             ListTile(
//               title: Text(
//                 _selectedDate == null
//                     ? 'Pick Date'
//                     : DateFormat('yyyy-MM-dd').format(_selectedDate!),
//               ),
//               trailing: Icon(Icons.calendar_today),
//               onTap: _pickDate,
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: _commentsController,
//               decoration: InputDecoration(labelText: 'Comments (optional)'),
//               maxLines: 3,
//             ),
//             SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: _submitForm,
//               child: Text('Add Investment'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

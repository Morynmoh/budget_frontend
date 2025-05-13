import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:budget/services/api_services.dart';

class AddExpenseScreen extends StatefulWidget {
  final Map<String, dynamic>? expense; // Add this to handle editing

  const AddExpenseScreen({super.key, this.expense});

  @override
  AddExpenseScreenState createState() => AddExpenseScreenState();
}

class AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  int? _selectedAccount;
  int? _selectedCategory;

  List<Map<String, dynamic>> _accounts = [];
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchAccountsAndCategories();

    if (widget.expense != null) {
      // If editing, pre-fill the data
      _descriptionController.text = widget.expense!['description'];
      _amountController.text = widget.expense!['amount'].toString();
      _dateController.text = widget.expense!['date'];
      _selectedAccount = widget.expense!['account_id'];
      _selectedCategory = widget.expense!['category_id'];
    } else {
      // Set default date to today if adding new expense
      _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  // Fetch accounts and categories
  void _fetchAccountsAndCategories() async {
    final apiService = ApiService();
    var accounts = await apiService.getAccounts();
    var categories = await apiService.getCategories();

    setState(() {
      _accounts = accounts;
      _categories = categories;
    });
  }

  void _submitExpense() async {
    if (_selectedAccount == null ||
        _selectedCategory == null ||
        _descriptionController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _dateController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final expenseData = {
      'account_id': _selectedAccount,
      'category_id': _selectedCategory,
      'description': _descriptionController.text,
      'amount': double.tryParse(_amountController.text),
      'date': _dateController.text,
    };

    final apiService = ApiService();

    try {
      if (widget.expense != null) {
        // Editing existing expense
        await apiService.updateExpense(widget.expense!['id'], expenseData);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Expense updated successfully')));
      } else {
        // Adding new expense
        await apiService.addExpense(expenseData);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Expense added successfully')));
      }
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save expense: $error')));
    }
  }

  // Date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // today's date by default
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense != null ? 'Edit Expense' : 'Add Expense'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                value: _selectedAccount,
                decoration: InputDecoration(labelText: 'Select Account'),
                onChanged: (value) {
                  setState(() {
                    _selectedAccount = value;
                  });
                },
                items:
                    _accounts.map((account) {
                      return DropdownMenuItem<int>(
                        value: account['id'],
                        child: Text(account['name']),
                      );
                    }).toList(),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'Select Category'),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                items:
                    _categories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category['id'],
                        child: Text(category['name']),
                      );
                    }).toList(),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Amount'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: 'Date (YYYY-MM-DD)',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(onPressed: _submitExpense, child: Text('Submit')),
            ],
          ),
        ),
      ),
    );
  }
}

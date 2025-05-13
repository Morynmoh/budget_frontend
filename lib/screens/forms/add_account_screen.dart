import 'package:flutter/material.dart';
import 'package:budget/services/api_services.dart';
// import 'package:budget/services/auth_service.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();

  Future<void> _submitForm() async {
    if (_descriptionController.text.isEmpty ||
        _balanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    final accountData = {
      'account': {
        'name': _descriptionController.text,
        'balance': double.tryParse(_balanceController.text),
      },
    };

    final success = await ApiService().addAccount(accountData);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account added successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to add account')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Account Description',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _balanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Initial Balance'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


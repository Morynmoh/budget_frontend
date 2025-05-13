import 'package:flutter/material.dart';
import 'package:budget/services/api_services.dart';

class AddCategoryScreen extends StatefulWidget {
  final Map<String, dynamic>? category; // Add this parameter for editing

  const AddCategoryScreen({super.key, this.category});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.category != null) {
      // If editing, pre-fill the data
      _descriptionController.text = widget.category!['name'];
      _budgetController.text = widget.category!['monthly_budget'].toString();
    }
  }

  Future<void> _submitForm() async {
    final name = _descriptionController.text.trim();
    final budget = double.tryParse(_budgetController.text.trim());

    if (name.isEmpty || budget == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid description and budget')),
      );
      return;
    }

    final categoryData = {'name': name, 'monthly_budget': budget};

    bool success;
    if (widget.category != null) {
      // If editing, update the category
      success = await ApiService().updateCategory(
        widget.category!['id'],
        categoryData,
      );
    } else {
      // If adding a new category
      success = await ApiService().addCategory(categoryData);
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.category != null
                ? 'Category updated successfully'
                : 'Category added successfully',
          ),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save category')));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category != null ? 'Edit Category' : 'Add Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Category Description'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Monthly Budget (amount)'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(
                widget.category != null ? 'Update Category' : 'Add Category',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/screens/forms/add_category_screen.dart

import 'package:flutter/material.dart';
import 'package:budget/services/api_services.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

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

    final success = await ApiService().addCategory(categoryData);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Category added successfully')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add category')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Category')),
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
            ElevatedButton(onPressed: _submitForm, child: Text('Add Category')),
          ],
        ),
      ),
    );
  }
}




// // lib/screens/forms/add_category_screen.dart

// import 'package:flutter/material.dart';
// import 'package:budget/services/api_services.dart';

// class AddCategoryScreen extends StatefulWidget {
//   const AddCategoryScreen({super.key});

//   @override
//   State<AddCategoryScreen> createState() => _AddCategoryScreenState();
// }

// class _AddCategoryScreenState extends State<AddCategoryScreen> {
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _budgetController = TextEditingController();

//   Future<void> _submitForm() async {
//     final description = _descriptionController.text.trim();
//     final budget = double.tryParse(_budgetController.text.trim());

//     if (description.isEmpty || budget == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please enter a valid description and budget')),
//       );
//       return;
//     }

//     // final categoryData = {'description': description, 'monthly_budget': budget};
//     final categoryData = {
//       'category': {
//         'name': _descriptionController.text,
//         'monthly_budget': double.tryParse(_budgetController.text),
//       },
//     };
//     final success = await ApiService().addCategory(categoryData);

//     if (success) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Category added successfully')));
//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Failed to add category')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Add Category')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _descriptionController,
//               decoration: InputDecoration(labelText: 'Category Description'),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: _budgetController,
//               keyboardType: TextInputType.numberWithOptions(decimal: true),
//               decoration: InputDecoration(labelText: 'Monthly Budget (amount)'),
//             ),
//             SizedBox(height: 24),
//             ElevatedButton(onPressed: _submitForm, child: Text('Add Category')),
//           ],
//         ),
//       ),
//     );
//   }
// }

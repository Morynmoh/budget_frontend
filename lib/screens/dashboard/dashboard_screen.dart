import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:budget/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budget/screens/forms/add_expense_screen.dart';
import 'package:budget/screens/forms/add_account_screen.dart';
import 'package:budget/screens/forms/add_category_screen.dart';
import 'package:budget/screens/forms/add_income_screen.dart';
import 'package:budget/screens/forms/add_investment_screen.dart';

String formatAmount(dynamic value) {
  try {
    final doubleAmount =
        value is num ? value.toDouble() : double.parse(value.toString());
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: 'KES ');
    return formatter.format(doubleAmount);
  } catch (e) {
    return 'KES 0.00';
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? userName;
  List accounts = [];
  List categories = [];
  List expenses = [];

  @override
  void initState() {
    super.initState();
    fetchUserName();
    loadData();
  }

  Future<void> fetchUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId != null) {
      final user = await ApiService().getUserById(userId);
      setState(() {
        userName = user['name'] ?? 'User';
      });
    }
  }

  Future<void> loadData() async {
    final acc = await ApiService().getAccounts();
    final cat = await ApiService().getCategories();
    final exp = await ApiService().getExpenses();
    setState(() {
      accounts = acc;
      categories = cat;
      expenses = exp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome, ${userName ?? '...'}")),
      body: RefreshIndicator(
        onRefresh: loadData,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildButtonGrid(),
              const Divider(thickness: 2),
              _buildTableSection('Accounts', accounts, [
                'id',
                'name',
                'balance',
              ], onDeleteAccount),
              const Divider(thickness: 2),
              _buildTableSection('Categories', categories, [
                'id',
                'name',
                'monthly_budget',
              ], onDeleteCategory),
              const Divider(thickness: 2),
              _buildTableSection('Expenses', expenses, [
                'id',
                'description',
                'amount',
                'date',
              ], onDeleteExpense),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonGrid() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 6,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          _buildTinyButton(
            Icons.account_balance_wallet,
            'Account',
            _showAccountForm,
          ),
          _buildTinyButton(Icons.category, 'Category', _showCategoryForm),
          _buildTinyButton(Icons.remove_circle, 'Expense', _showExpenseForm),
          _buildTinyButton(Icons.add_circle, 'Income', _showIncomeForm),
          _buildTinyButton(Icons.trending_up, 'Invest', _showInvestForm),
        ],
      ),
    );
  }

  Widget _buildTinyButton(IconData icon, String label, Function showForm) {
    return GestureDetector(
      onTap: () => showForm(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade600,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableSection(
    String title,
    List data,
    List<String> fields,
    Function(int) onDelete,
  ) {
    const int pageSize = 5;
    int pageCount = (data.length / pageSize).ceil();
    int currentPage = 0;

    return StatefulBuilder(
      builder: (context, setTableState) {
        final start = currentPage * pageSize;
        final end =
            (start + pageSize < data.length) ? start + pageSize : data.length;
        final pageItems = data.sublist(start, end);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  ...fields.map(
                    (c) => DataColumn(label: Text(c.toUpperCase())),
                  ),
                  const DataColumn(label: Text("Actions")),
                ],
                rows:
                    pageItems.map<DataRow>((item) {
                      return DataRow(
                        cells: [
                          ...fields.map((f) {
                            return DataCell(
                              (f == 'amount' ||
                                      f == 'balance' ||
                                      f == 'monthly_budget')
                                  ? Text(formatAmount(item[f]))
                                  : Text(item[f]?.toString() ?? ''),
                            );
                          }),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    // Edit logic here
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => onDelete(item['id']),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
            if (pageCount > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(pageCount, (i) {
                  return TextButton(
                    onPressed: () => setTableState(() => currentPage = i),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontWeight:
                            currentPage == i
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                  );
                }),
              ),
          ],
        );
      },
    );
  }

  void onDeleteAccount(int id) async {
    await ApiService().deleteAccount(id);
    loadData();
  }

  void onDeleteCategory(int id) async {
    await ApiService().deleteCategory(id);
    loadData();
  }

  void onDeleteExpense(int id) async {
    await ApiService().deleteExpense(id);
    loadData();
  }

  void _showAccountForm(BuildContext context) {
    _showFormDialog(context, const AddAccountScreen());
  }

  void _showExpenseForm(BuildContext context) {
    _showFormDialog(context, const AddExpenseScreen());
  }

  void _showIncomeForm(BuildContext context) {
    _showFormDialog(context, const AddIncomeScreen());
  }

  void _showInvestForm(BuildContext context) {
    _showFormDialog(context, const AddInvestmentScreen());
  }

  void _showCategoryForm(BuildContext context) {
    _showFormDialog(context, const AddCategoryScreen());
  }

  void _showFormDialog(BuildContext context, Widget form) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 10,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.lightBlue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16.0),
            child: form,
          ),
        );
      },
    );
  }
}


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:budget/services/api_services.dart';
// import 'package:budget/screens/forms/add_account_screen.dart';
// import 'package:budget/screens/forms/add_category_screen.dart';
// import 'package:budget/screens/forms/add_expense_screen.dart';
// import 'package:budget/screens/forms/add_income_screen.dart';
// import 'package:budget/screens/forms/add_investment_screen.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   String? userName;

//   List accounts = [];
//   List categories = [];
//   List expenses = [];
//   int accountPage = 0;
//   int categoryPage = 0;
//   int expensePage = 0;

//   @override
//   void initState() {
//     super.initState();
//     fetchUserName();
//     fetchAllData();
//   }

//   Future<void> fetchUserName() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userId = prefs.getInt('userId');

//     if (userId != null) {
//       final user = await ApiService().getUserById(userId);
//       setState(() {
//         userName = user['name'] ?? 'User';
//       });
//     }
//   }

//   Future<void> fetchAllData() async {
//     await fetchAccounts();
//     await fetchCategories();
//     await fetchExpenses();
//   }

//   Future<void> fetchAccounts() async {
//     final res = await http.get(
//       Uri.parse('http://localhost:3000/accounts?page=$accountPage'),
//     );
//     if (res.statusCode == 200) {
//       setState(() {
//         accounts = json.decode(res.body);
//       });
//     }
//   }

//   Future<void> fetchCategories() async {
//     final res = await http.get(
//       Uri.parse('http://localhost:3000/categories?page=$categoryPage'),
//     );
//     if (res.statusCode == 200) {
//       setState(() {
//         categories = json.decode(res.body);
//       });
//     }
//   }

//   Future<void> fetchExpenses() async {
//     final res = await http.get(
//       Uri.parse('http://localhost:3000/expenses?page=$expensePage'),
//     );
//     if (res.statusCode == 200) {
//       setState(() {
//         expenses = json.decode(res.body);
//       });
//     }
//   }

//   Future<void> deleteAccount(int id) async {
//     final res = await http.delete(
//       Uri.parse('http://localhost:3000/accounts/$id'),
//     );
//     if (res.statusCode == 200) {
//       fetchAccounts();
//     }
//   }

//   Future<void> deleteCategory(int id) async {
//     final res = await http.delete(
//       Uri.parse('http://localhost:3000/categories/$id'),
//     );
//     if (res.statusCode == 200) {
//       fetchCategories();
//     }
//   }

//   Future<void> deleteExpense(int id) async {
//     final res = await http.delete(
//       Uri.parse('http://localhost:3000/expenses/$id'),
//     );
//     if (res.statusCode == 200) {
//       fetchExpenses();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Welcome, ${userName ?? '...'}")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             GridView.count(
//               crossAxisCount: 6,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               mainAxisSpacing: 8,
//               crossAxisSpacing: 8,
//               children: [
//                 _buildTinyButton(
//                   context,
//                   Icons.account_balance_wallet,
//                   'Account',
//                   _showAccountForm,
//                 ),
//                 _buildTinyButton(
//                   context,
//                   Icons.category,
//                   'Category',
//                   _showCategoryForm,
//                 ),
//                 _buildTinyButton(
//                   context,
//                   Icons.remove_circle,
//                   'Expense',
//                   _showExpenseForm,
//                 ),
//                 _buildTinyButton(
//                   context,
//                   Icons.add_circle,
//                   'Income',
//                   _showIncomeForm,
//                 ),
//                 _buildTinyButton(
//                   context,
//                   Icons.trending_up,
//                   'Invest',
//                   _showInvestForm,
//                 ),
//               ],
//             ),

//             const Divider(height: 32, thickness: 2),
//             _buildPaginatedTable(
//               title: 'Accounts',
//               data: accounts,
//               columns: const ['Name', 'Balance', 'Actions'],
//               fields: const ['name', 'balance'],
//               onNext: () {
//                 setState(() => accountPage++);
//                 fetchAccounts();
//               },
//               onPrev: () {
//                 if (accountPage > 0) {
//                   setState(() => accountPage--);
//                   fetchAccounts();
//                 }
//               },
//               onDelete: deleteAccount,
//             ),

//             const Divider(height: 32, thickness: 2),
//             _buildPaginatedTable(
//               title: 'Categories',
//               data: categories,
//               columns: const ['Name', 'Monthly Budget', 'Actions'],
//               fields: const ['name', 'monthly_budget'],
//               onNext: () {
//                 setState(() => categoryPage++);
//                 fetchCategories();
//               },
//               onPrev: () {
//                 if (categoryPage > 0) {
//                   setState(() => categoryPage--);
//                   fetchCategories();
//                 }
//               },
//               onDelete: deleteCategory,
//             ),

//             const Divider(height: 32, thickness: 2),
//             _buildPaginatedTable(
//               title: 'Expenses',
//               data: expenses,
//               columns: const ['Date', 'Description', 'Amount', 'Actions'],
//               fields: const ['date', 'description', 'amount'],
//               onNext: () {
//                 setState(() => expensePage++);
//                 fetchExpenses();
//               },
//               onPrev: () {
//                 if (expensePage > 0) {
//                   setState(() => expensePage--);
//                   fetchExpenses();
//                 }
//               },
//               onDelete: deleteExpense,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTinyButton(
//     BuildContext context,
//     IconData icon,
//     String label,
//     Function showForm,
//   ) {
//     return GestureDetector(
//       onTap: () => showForm(context),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.blue.shade600,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 20, color: Colors.white),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: const TextStyle(color: Colors.white, fontSize: 10),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPaginatedTable({
//     required String title,
//     required List data,
//     required List<String> columns,
//     required List<String> fields,
//     required VoidCallback onNext,
//     required VoidCallback onPrev,
//     required Function onDelete,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         const SizedBox(height: 8),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: DataTable(
//             columns: columns.map((c) => DataColumn(label: Text(c))).toList(),
//             rows:
//                 data.map<DataRow>((item) {
//                   return DataRow(
//                     cells: [
//                       ...fields.map((f) {
//                         return DataCell(Text(item[f]?.toString() ?? ''));
//                       }).toList(),
//                       DataCell(
//                         Row(
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.edit),
//                               onPressed: () {
//                                 // Handle edit logic here
//                               },
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.delete),
//                               onPressed: () => onDelete(item['id']),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   );
//                 }).toList(),
//           ),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             TextButton(onPressed: onPrev, child: const Text("Previous")),
//             TextButton(onPressed: onNext, child: const Text("Next")),
//           ],
//         ),
//       ],
//     );
//   }

//   // Dialog form displays
//   void _showAccountForm(BuildContext context) =>
//       _showFormDialog(context, AddAccountScreen());
//   void _showCategoryForm(BuildContext context) =>
//       _showFormDialog(context, AddCategoryScreen());
//   void _showExpenseForm(BuildContext context) =>
//       _showFormDialog(context, AddExpenseScreen());
//   void _showIncomeForm(BuildContext context) =>
//       _showFormDialog(context, AddIncomeScreen());
//   void _showInvestForm(BuildContext context) =>
//       _showFormDialog(context, AddInvestmentScreen());

//   void _showFormDialog(BuildContext context, Widget formWidget) {
//     showDialog(
//       context: context,
//       builder:
//           (_) => Dialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             elevation: 10,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.lightBlue.shade100,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: const EdgeInsets.all(16.0),
//               child: formWidget,
//             ),
//           ),
//     );
//   }
// }

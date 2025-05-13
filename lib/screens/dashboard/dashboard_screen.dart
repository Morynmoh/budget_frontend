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
  int currentPage = 0;
  final int pageSize = 3;

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
    // final inv = await ApiService().getInvestments();
    setState(() {
      accounts = acc;
      categories = cat;
      expenses = exp;
      // investments = inv;
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
              _buildTableSection(
                'Accounts',
                accounts,
                ['name', 'balance'],
                onDeleteAccount,
                onEditAccount,
              ),
              const Divider(thickness: 2),
              _buildTableSection(
                'Categories',
                categories,
                ['name', 'monthly_budget'],
                onDeleteCategory,
                onEditCategory,
              ),
              const Divider(thickness: 2),
              _buildTableSection(
                'Expenses',
                expenses,
                ['date', 'description', 'amount'],
                onDeleteExpense,
                onEditExpense,
              ),
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
    Function(Map<String, dynamic>) onEdit,
  ) {
    const int pageSize = 5;
    int pageCount = (data.length / pageSize).ceil();

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
                  const DataColumn(label: Text("No")),
                  ...fields.map(
                    (c) => DataColumn(label: Text(c.toUpperCase())),
                  ),
                  const DataColumn(label: Text("Actions")),
                ],
                rows:
                    pageItems.map<DataRow>((item) {
                      int rowIndex =
                          data.indexOf(item) + 1 + (currentPage * pageSize);
                      return DataRow(
                        cells: [
                          DataCell(Text('$rowIndex')),
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
                                  onPressed: () => onEdit(item),
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

  // Reload data and refresh the UI on delete ---------------------
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

  // Edit Functions --------------------------------
  void onEditAccount(Map<String, dynamic> account) {
    _showFormDialog(context, AddAccountScreen(account: account));
    loadData();
  }

  void onEditCategory(Map<String, dynamic> category) {
    _showFormDialog(context, AddCategoryScreen(category: category));
        loadData();
  }

  void onEditExpense(Map<String, dynamic> expense) {
    _showFormDialog(context, AddExpenseScreen(expense: expense));
        loadData();
  }

  // Show Form Dialogs --------------------------------
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

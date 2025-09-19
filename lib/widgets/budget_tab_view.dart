// lib/widgets/budget_tab_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trip_planner_app/models/expense_model.dart';
import 'package:trip_planner_app/models/trip_model.dart';
import 'package:trip_planner_app/services/firestore_service.dart';

class BudgetTabView extends StatefulWidget {
  final Trip trip;
  const BudgetTabView({super.key, required this.trip});

  @override
  State<BudgetTabView> createState() => _BudgetTabViewState();
}

class _BudgetTabViewState extends State<BudgetTabView> {
  final FirestoreService _firestoreService = FirestoreService();

  void _showAddExpenseDialog() {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'Food'; // Default category

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items:
                      [
                            'Food',
                            'Transport',
                            'Accommodation',
                            'Shopping',
                            'Other',
                          ]
                          .map(
                            (label) => DropdownMenuItem(
                              child: Text(label),
                              value: label,
                            ),
                          )
                          .toList(),
                  onChanged: (value) => selectedCategory = value!,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Add'),
              onPressed: () {
                final newExpense = Expense(
                  description: descriptionController.text,
                  amount: double.tryParse(amountController.text) ?? 0.0,
                  category: selectedCategory,
                  date: DateTime.now(),
                  tripId: widget.trip.id!,
                );
                _firestoreService.addExpense(newExpense);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Expense>>(
        stream: _firestoreService.getExpenses(widget.trip.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final expenses = snapshot.data ?? [];
          final totalSpent = expenses.fold(
            0.0,
            (sum, item) => sum + item.amount,
          );
          final remaining = widget.trip.budget - totalSpent;

          return Column(
            children: [
              // Summary Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryColumn(
                        'Budget',
                        widget.trip.budget,
                        Colors.blue,
                      ),
                      _buildSummaryColumn('Spent', totalSpent, Colors.red),
                      _buildSummaryColumn('Remaining', remaining, Colors.green),
                    ],
                  ),
                ),
              ),
              // Expenses List
              Expanded(
                child: ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return ListTile(
                      leading: Icon(_getCategoryIcon(expense.category)),
                      title: Text(expense.description),
                      subtitle: Text(expense.category),
                      trailing: Text(
                        'LKR ${expense.amount.toStringAsFixed(2)}',
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: Icon(Icons.add),
        tooltip: 'Add Expense',
      ),
    );
  }

  // Helper widgets and functions
  Column _buildSummaryColumn(String title, double amount, Color color) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_US',
      symbol: '',
      decimalDigits: 2,
    );
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        SizedBox(height: 4),
        Text(
          currencyFormat.format(amount),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.fastfood_rounded;
      case 'Transport':
        return Icons.directions_bus_rounded;
      case 'Accommodation':
        return Icons.hotel_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }
}

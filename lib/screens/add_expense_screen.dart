import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;

  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Others',
  ];

  Future<void> _saveExpenseToDatabase(Expense expense) async {
    const String url =
        'https://domain2004.atwebpages.com/add_expense.php'; // Replace with your PHP script URL
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'category': expense.category,
          'description': expense.description,
          'amount': expense.amount.toString(),
        },
      );
      final responseData = json.decode(response.body);

      if (responseData['success'] == true) {
        Navigator.pop(context, expense); // Return the added expense
      } else {
        throw Exception(responseData['error'] ?? 'Failed to save expense');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final String amountText = _amountController.text;
                final String description = _descriptionController.text;

                if (amountText.isNotEmpty &&
                    _selectedCategory != null &&
                    double.tryParse(amountText) != null) {
                  final double amount = double.parse(amountText);
                  final expense = Expense(
                    category: _selectedCategory!,
                    description: description,
                    amount: amount,
                  );
                  _saveExpenseToDatabase(expense);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill in all fields correctly'),
                    ),
                  );
                }
              },
              child: Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }
}

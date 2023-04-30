import 'package:expanse_app/components/expense_summary.dart';
import 'package:expanse_app/components/expense_tile.dart';
import 'package:expanse_app/data/expense_data.dart';
import 'package:expanse_app/models/expense_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // text controllers
  final newExpenseNameController = TextEditingController();
  final newExpenseDollarController = TextEditingController();
  final newExpenseCentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // prepare data on startup
    Provider.of<ExpenseData>(context, listen: false).prepareData();
  }

  // add new expense

  void addNewExpense() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add new expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //expense item
            TextField(
              controller: newExpenseNameController,
              decoration: const InputDecoration(
                hintText: 'Expense name',
              ),
            ),
            //expense amount
            Row(
              children: [
                // dollars
                Expanded(
                  child: TextField(
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                    ],
                    cursorColor: Colors.pinkAccent,
                    keyboardType: TextInputType.number,
                    controller: newExpenseDollarController,
                    decoration: const InputDecoration(
                      hintText: 'Amount',
                    ),
                  ),
                ),
                // cents
                Expanded(
                  child: TextField(
                    maxLength: 2,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                    ],
                    keyboardType: TextInputType.number,
                    controller: newExpenseCentsController,
                    decoration: const InputDecoration(
                      hintText: 'Cents',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // save button
          MaterialButton(
            onPressed: save,
            child: const Text('Save'),
          ),
          // cancel button
          MaterialButton(
            onPressed: cancel,
            child: const Text('Cancel'),
          )
        ],
      ),
    );
  }

  // delete expense

  void deleteExpense(ExpenseItem expense) {
    Provider.of<ExpenseData>(context, listen: false).deleteExpense(expense);
  }

  // save
  void save() {
    // only save expense if all fields are filled
    if (newExpenseCentsController.text.isNotEmpty &&
        newExpenseDollarController.text.isNotEmpty &&
        newExpenseNameController.text.isNotEmpty) {
      // put dollars and cents together
      String amount =
          '${newExpenseDollarController.text}.${newExpenseCentsController.text.isEmpty ? '0' : newExpenseCentsController.text}';

      // create expense
      ExpenseItem newExpense = ExpenseItem(
        name: newExpenseNameController.text,
        amount: amount,
        dateTime: DateTime.now(),
      );
      // add new expense
      Provider.of<ExpenseData>(context, listen: false)
          .addNewExpense(newExpense);
    }
    Navigator.pop(context);
    clear();
  }

  // cancel
  void cancel() {
    Navigator.pop(context);
    clear();
  }

  // clear controllers

  void clear() {
    newExpenseNameController.clear();
    newExpenseCentsController.clear();
    newExpenseDollarController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseData>(
      builder: (context, value, child) => Scaffold(
        backgroundColor: Colors.grey[300],
        floatingActionButton: FloatingActionButton(
          onPressed: addNewExpense,
          backgroundColor: Colors.black,
          child: const Icon(Icons.add),
        ),
        body: ListView(
          children: [
            // weekly summary
            ExpenseSummary(startOfWeek: value.startOfWeekDate()),

            const SizedBox(height: 24),
            // expense list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: value.getAllExpenseList().length,
              itemBuilder: (context, index) => ExpenseTile(
                name: value.getAllExpenseList()[index].name,
                amount: value.getAllExpenseList()[index].amount,
                dateTime: value.getAllExpenseList()[index].dateTime,
                deleteTapped: (p0) =>
                    deleteExpense(value.getAllExpenseList()[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

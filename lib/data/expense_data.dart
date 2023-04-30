import 'package:expanse_app/data/hive_database.dart';
import 'package:expanse_app/datetime/date_time_helper.dart';
import 'package:flutter/material.dart';

import '../models/expense_item.dart';

class ExpenseData extends ChangeNotifier {
// list of ALL expanses

  List<ExpenseItem> overallExpenseList = [];

// get expense list
  List<ExpenseItem> getAllExpenseList() {
    return overallExpenseList;
  }

// prepare data to display
  final db = HiveDataBase();
  void prepareData() {
    // if there exists data, get it
    if (db.readData().isNotEmpty) {
      overallExpenseList = db.readData();
    }
  }

// add new expense
  void addNewExpense(ExpenseItem newExpense) {
    overallExpenseList.add(newExpense);
    notifyListeners();
    db.saveData(overallExpenseList);
  }

// delete expense
  void deleteExpense(ExpenseItem expense) {
    overallExpenseList.remove(expense);
    notifyListeners();
    db.saveData(overallExpenseList);
  }

// get weekday (mon, tues, etc) from a dateTime object
  String getDayTime(DateTime dateTime) {
    switch (dateTime.weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thur';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';

      default:
        return '';
    }
  }

// get the date from the start of the week (sunday)
  DateTime startOfWeekDate() {
    DateTime? startOfWeek;

    // get todays date

    DateTime today = DateTime.now();

    // go backwards from today to find sunday
    for (int i = 0; i < 7; i++) {
      if (getDayTime(today.subtract(Duration(days: i))) == 'Sun') {
        startOfWeek = today.subtract(Duration(days: i));
      }
    }
    return startOfWeek!;
  }

/*

convert overall list of expanses into a daily expanses summary

e.g. 


overallExpanseList = [

  [food, 2023/01/30, $22],
  [clothes, 2023/02/30, $221]
  [drinks, 2023/01/10, $32]

]


-> 

DailyExpanseSummary = 

{

[ 2023/01/30: 25$ ]
[ 2023/01/3: 15$ ]
[ 2023/01/5: 5$ ]


}

*/
  Map<String, double> calculateDailyExpenseSummary() {
    Map<String, double> dailyExpenseSummary = {
      // date (yyyymmdd) : amountTotalForDay
    };

    for (var expense in overallExpenseList) {
      String date = convertDateTimeToString(expense.dateTime);
      double amount = double.parse(expense.amount);

      if (dailyExpenseSummary.containsKey(date)) {
        double currentAmount = dailyExpenseSummary[date]!;
        currentAmount += amount;
        dailyExpenseSummary[date] = currentAmount;
      } else {
        dailyExpenseSummary.addAll({date: amount});
      }
    }
    return dailyExpenseSummary;
  }
}

import '../models/expense.dart';

class ExpenseService {
  final List<Expense> _expenses = [];

  List<Expense> getAllExpenses() => _expenses;

  void addExpense(Expense expense) {
    _expenses.add(expense);
  }

  void updateExpense(Expense expense) {
    int index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
    }
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
  }
}

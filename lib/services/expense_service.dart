import 'dart:convert'; // ⬅️ untuk jsonEncode dan jsonDecode
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ⬅️ untuk SharedPreferences
import '../models/expense.dart';
import '../models/category.dart';
import 'storage_service.dart';

class ExpenseService extends ChangeNotifier {
  ExpenseService._();
  static final ExpenseService instance = ExpenseService._();

  final StorageService _storage = StorageServiceManager.instance.storage;

  List<Expense> _expenses = [];
  List<CategoryModel> _categories = [];

  List<Expense> get expenses => List.unmodifiable(_expenses);
  List<CategoryModel> get categories => List.unmodifiable(_categories);

  Future<void> loadInitialData() async {
    _expenses = await _storage.loadExpenses();
    _categories = await _storage.loadCategories();

    ensureDefaultCategories();
    notifyListeners();
  }

  // ---------- Category default ----------
  void ensureDefaultCategories() {
    if (_categories.isEmpty) {
      _categories.addAll([
        CategoryModel(id: 'c1', name: 'Makanan'),
        CategoryModel(id: 'c2', name: 'Transportasi'),
        CategoryModel(id: 'c3', name: 'Utilitas'),
        CategoryModel(id: 'c4', name: 'Hiburan'),
        CategoryModel(id: 'c5', name: 'Pendidikan'),
      ]);
      _storage.saveCategories(_categories);
    }
  }

  // ---------- Expense CRUD ----------
  Future<void> addExpense(Expense e) async {
    _expenses.add(e);
    await _storage.saveExpenses(_expenses);
    notifyListeners();
  }

  // Future<void> updateExpense(Expense updatedExpense) async {
  //   final prefs = await SharedPreferences.getInstance();

  //   // cari index dari expense lama
  //   final index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
  //   if (index != -1) {
  //     _expenses[index] = updatedExpense; // update di list memori

  //     // simpan ulang semua data ke SharedPreferences
  //     final expensesJson = _expenses.map((e) => e.toJson()).toList();
  //     await prefs.setString('expenses', jsonEncode(expensesJson));

  //     notifyListeners();
  //   }
  // }

Future<void> updateExpense(Expense updatedExpense) async {
  final index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
  if (index != -1) {
    // 🔹 Pastikan kategori valid di daftar kategori
    final matchedCategory = _categories.firstWhere(
      (c) => c.name == updatedExpense.category,
      orElse: () => CategoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: updatedExpense.category,
      ),
    );

    // 🔹 Ganti data lama dengan yang baru
    _expenses[index] = Expense(
      id: updatedExpense.id,
      title: updatedExpense.title,
      amount: updatedExpense.amount,
      category: matchedCategory.name,
      date: updatedExpense.date,
      description: updatedExpense.description,
    );

    // 🔹 Simpan ulang ke storage
    await _storage.saveExpenses(_expenses);

    print('✅ Updated expense saved: ${updatedExpense.title} (${updatedExpense.category})');

    // 🔹 Reload dari storage biar kategori & data sinkron
    await loadInitialData();

    // 🔹 Panggil notify agar UI langsung refresh
    notifyListeners();
  } else {
    print('⚠️ Expense not found for update: ${updatedExpense.id}');
  }
}




  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((x) => x.id == id);
    await _storage.saveExpenses(_expenses);
    notifyListeners();
  }

  Expense? getById(String id) {
    try {
      return _expenses.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  // ---------- Category management ----------
  bool addCategory(String name) {
    final n = name.trim();
    if (n.isEmpty) return false;
    if (_categories.any((c) => c.name.toLowerCase() == n.toLowerCase())) {
      return false;
    }
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _categories.add(CategoryModel(id: id, name: n));
    _storage.saveCategories(_categories);
    notifyListeners();
    return true;
  }

  bool renameCategory(String id, String newName) {
    final n = newName.trim();
    if (n.isEmpty) return false;
    if (_categories.any((c) => c.name.toLowerCase() == n.toLowerCase())) {
      return false;
    }
    final idx = _categories.indexWhere((c) => c.id == id);
    if (idx == -1) return false;

    final oldName = _categories[idx].name;
    _categories[idx] = CategoryModel(id: id, name: n);

    // migrasi semua expense yang pakai kategori lama
    for (int i = 0; i < _expenses.length; i++) {
      if (_expenses[i].category == oldName) {
        _expenses[i] = Expense(
          id: _expenses[i].id,
          title: _expenses[i].title,
          amount: _expenses[i].amount,
          category: n,
          date: _expenses[i].date,
          description: _expenses[i].description,
        );
      }
    }

    _storage.saveCategories(_categories);
    _storage.saveExpenses(_expenses);
    notifyListeners();
    return true;
  }

  bool deleteCategory(String id) {
    final cat = _categories.firstWhere(
      (c) => c.id == id,
      orElse: () => CategoryModel(id: '', name: ''),
    );
    if (cat.id.isEmpty) return false;
    final inUse = _expenses.any((e) => e.category == cat.name);
    if (inUse) return false;
    _categories.removeWhere((c) => c.id == id);
    _storage.saveCategories(_categories);
    notifyListeners();
    return true;
  }

  // ---------- Stats ----------
  double get totalAll => _expenses.fold(0.0, (s, e) => s + e.amount);

  Map<String, double> get totalPerCategory {
    final map = <String, double>{};
    for (final e in _expenses) {
      map[e.category] = (map[e.category] ?? 0.0) + e.amount;
    }
    return map;
  }

  Map<int, double> get totalPerMonth {
    final map = <int, double>{};
    for (final e in _expenses) {
      map[e.date.month] = (map[e.date.month] ?? 0.0) + e.amount;
    }
    return map;
  }

    // ==================== Getter tambahan untuk dashboard ====================
  double get monthlyBudget {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  int get totalTransactions => _expenses.length;


}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

class EditExpenseScreen extends StatefulWidget {
  const EditExpenseScreen({super.key});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _descController;
  String? _selectedCategory;
  late Expense expense;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    expense = ModalRoute.of(context)!.settings.arguments as Expense;

    final svc = Provider.of<ExpenseService>(context, listen: false);
    final categories = svc.categories;

    _titleController = TextEditingController(text: expense.title);
    _amountController = TextEditingController(text: expense.amount.toString());
    _descController = TextEditingController(text: expense.description ?? '');
    _selectedCategory = expense.category;

    // Pastikan dropdown tetap valid
    if (!categories.any((c) => c.name == _selectedCategory)) {
      _selectedCategory = categories.isNotEmpty ? categories.first.name : null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final svc = Provider.of<ExpenseService>(context, listen: false);
    final categories = svc.categories;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Edit Expense"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Title wajib diisi" : null,
              ),
              const SizedBox(height: 12),

              // ===== Category Dropdown =====
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
                items: categories
                    .map((c) => DropdownMenuItem<String>(
                          value: c.name,
                          child: Text(c.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                  print('🟢 Category changed to: $value');
                },
                validator: (v) =>
                    v == null || v.isEmpty ? "Category wajib dipilih" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Amount wajib diisi" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final updated = Expense(
                      id: expense.id,
                      title: _titleController.text.trim(),
                      category: _selectedCategory ?? expense.category,
                      amount: double.tryParse(_amountController.text) ?? 0.0,
                      description: _descController.text.trim(),
                      date: expense.date,
                    );

                    print(
                        '🟡 Saving update: ${updated.title} - ${updated.category}');

                    // Update expense di service
                    await svc.updateExpense(updated);

                    // Pastikan data terbaru dimuat kembali dari storage
                    await svc.loadInitialData();

                    // 🔥 Tambahan penting: pastikan state di-refresh
                    setState(() {
                      _selectedCategory = updated.category;
                    });

                    if (mounted) {
                      Navigator.pop(context, true);
                    }
                  }
                },
                child: const Text(
                  "Simpan Perubahan",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

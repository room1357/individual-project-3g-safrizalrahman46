import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

class EditExpenseScreen extends StatefulWidget {
  final String? expenseId;

  const EditExpenseScreen({super.key, this.expenseId});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _descController;
  late Expense expense;
  String? _selectedCategory; // untuk dropdown value

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    expense = ModalRoute.of(context)!.settings.arguments as Expense;

    _titleController = TextEditingController(text: expense.title);
    _amountController = TextEditingController(text: expense.amount.toString());
    _descController = TextEditingController(text: expense.description ?? '');
    _selectedCategory = expense.category;
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
    final categories = svc.categories; // ambil data kategori

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
              // ===== Title =====
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
                validator:
                    (v) => v == null || v.isEmpty ? "Title wajib diisi" : null,
              ),
              const SizedBox(height: 12),

              // ===== Category (Dropdown) =====
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
                items: categories
                    .map(
                      (c) => DropdownMenuItem<String>(
                        value: c.name,
                        child: Text(c.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (v) =>
                    v == null || v.isEmpty ? "Category wajib dipilih" : null,
              ),
              const SizedBox(height: 12),

              // ===== Amount =====
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(),
                ),
                validator:
                    (v) => v == null || v.isEmpty ? "Amount wajib diisi" : null,
              ),
              const SizedBox(height: 12),

              // ===== Description =====
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // ===== Save Button =====
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
                    final updatedExpense = Expense(
                      id: expense.id,
                      title: _titleController.text,
                      category: _selectedCategory ?? expense.category,
                      amount: double.parse(_amountController.text),
                      description: _descController.text,
                      date: expense.date,
                    );

                    await svc.updateExpense(updatedExpense);

                    if (mounted) {
                      Navigator.pop(context, true);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Perubahan berhasil disimpan"),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
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

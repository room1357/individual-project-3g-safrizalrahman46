import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../models/expense.dart';
import '../utils/date_utils.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleC = TextEditingController();
  final _amountC = TextEditingController();
  final _descC = TextEditingController();
  DateTime _date = DateTime.now();
  String? _catId;

  @override
  void initState() {
    super.initState();
    final svc = ExpenseService.instance;
    svc.ensureDefaultCategories();
    final cats = svc.categories;
    _catId = cats.isNotEmpty ? cats.first.id : null;
  }

  @override
  void dispose() {
    _titleC.dispose();
    _amountC.dispose();
    _descC.dispose();
    super.dispose();
  }

  // ✅ UNIVERSAL DATE PICKER (Android, iOS, Web)
  Future<void> _pickDate() async {
    // 📱 Android/iOS pakai date picker biasa
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final svc = ExpenseService.instance;
    final cat = svc.categories.firstWhere((c) => c.id == _catId);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final amount = double.tryParse(_amountC.text.replaceAll(',', '.')) ?? 0;

    svc.addExpense(
      Expense(
        id: id,
        title: _titleC.text.trim(),
        amount: amount,
        category: cat.name,
        date: _date,
        description: _descC.text.trim(),
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final svc = ExpenseService.instance;
    final cats = svc.categories;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Expense',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade200,
              child: const Icon(Icons.person, color: Colors.green),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),
              _buildLabel("Name"),
              _inputBox(
                controller: _titleC,
                hint: "Name",
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 20),
              _buildLabel("Type"),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      value: 'Income',
                      groupValue: 'Expense',
                      onChanged: (_) {},
                      title: const Text('Income'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      value: 'Expense',
                      groupValue: 'Expense',
                      onChanged: (_) {},
                      title: const Text('Expense'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- BAGIAN YANG DIPERBAIKI ---
              _buildLabel("Date"),
              _inputBox(
                // Hapus InkWell dan gunakan onTap langsung dari TextFormField
                onTap: _pickDate,
                readOnly: true,
                // Gunakan controller agar teks terlihat, bukan sebagai hint
                controller: TextEditingController(text: formatYmd(_date)),
                suffix: const Icon(Icons.calendar_today, size: 18),
              ),
              // --- BATAS PERBAIKAN ---

              const SizedBox(height: 20),
              _buildLabel("Amount"),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F1FF),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: const Text(
                      "IDR",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: _inputBox(
                      controller: _amountC,
                      hint: "0",
                      keyboardType: TextInputType.number,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      validator: (v) {
                        final d =
                            double.tryParse((v ?? '').replaceAll(',', '.'));
                        if (d == null || d <= 0) {
                          return 'Masukkan jumlah yang valid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildLabel("Category"),
              DropdownButtonFormField<String>(
                value: _catId,
                decoration: _inputDecoration(),
                items: cats
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _catId = v),
                validator: (v) => v == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 20),
              _buildLabel("Description (Optional)"),
              _inputBox(
                controller: _descC,
                hint: "Description (Optional)",
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.attach_file_rounded, color: Colors.grey),
                label: const Text(
                  "Add Attachment",
                  style: TextStyle(color: Colors.grey),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6EE7B7), Color(0xFF3BAE8C)],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Add Expense',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  // --- FUNGSI YANG DIPERBAIKI ---
  Widget _inputBox({
    TextEditingController? controller,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool readOnly = false,
    Widget? suffix,
    int maxLines = 1,
    BorderRadius? borderRadius,
    VoidCallback? onTap, // Tambahkan parameter onTap
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onTap: onTap, // Gunakan parameter onTap di sini
      decoration: _inputDecoration(
        hint: hint,
        suffix: suffix,
        borderRadius: borderRadius,
      ),
    );
  }
  // --- BATAS PERBAIKAN ---

  InputDecoration _inputDecoration({
    String? hint,
    Widget? suffix,
    BorderRadius? borderRadius,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF6F8FF),
      suffixIcon: suffix,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6EE7B7), width: 2),
      ),
      errorBorder: OutlineInputBorder( // Tambahkan ini untuk konsistensi
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder( // Tambahkan ini untuk konsistensi
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import '../services/expense_service.dart';
// import '../models/expense.dart';
// import '../utils/date_utils.dart';

// class AddExpenseScreen extends StatefulWidget {
//   const AddExpenseScreen({super.key});

//   @override
//   State<AddExpenseScreen> createState() => _AddExpenseScreenState();
// }

// class _AddExpenseScreenState extends State<AddExpenseScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleC = TextEditingController();
//   final _amountC = TextEditingController();
//   final _descC = TextEditingController();
//   DateTime _date = DateTime.now();
//   String? _catId;

//   @override
//   void initState() {
//     super.initState();
//     final svc = ExpenseService.instance;

//     // Pastikan kategori default tersedia
//     svc.ensureDefaultCategories();

//     final cats = svc.categories;
//     _catId = cats.isNotEmpty ? cats.first.id : null;
//   }

//   @override
//   void dispose() {
//     _titleC.dispose();
//     _amountC.dispose();
//     _descC.dispose();
//     super.dispose();
//   }

//   Future<void> _pickDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _date,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null) setState(() => _date = picked);
//   }

//   void _save() {
//     if (!_formKey.currentState!.validate()) return;
//     final svc = ExpenseService.instance;
//     final cat = svc.categories.firstWhere((c) => c.id == _catId);
//     final id = DateTime.now().millisecondsSinceEpoch.toString();
//     final amount = double.tryParse(_amountC.text.replaceAll(',', '.')) ?? 0;

//     svc.addExpense(Expense(
//       id: id,
//       title: _titleC.text.trim(),
//       amount: amount,
//       category: cat.name,
//       date: _date,
//       description: _descC.text.trim(),
//     ));
//     Navigator.pop(context, true);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final svc = ExpenseService.instance;
//     final cats = svc.categories;

//     return Scaffold(
//       appBar: AppBar(title: const Text('Tambah Pengeluaran')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 controller: _titleC,
//                 decoration: const InputDecoration(
//                   labelText: 'Judul',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (v) =>
//                     (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _amountC,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   labelText: 'Jumlah (Rp)',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (v) {
//                   final d =
//                       double.tryParse((v ?? '').replaceAll(',', '.'));
//                   if (d == null || d <= 0) return 'Masukkan jumlah yang valid';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 12),
//               DropdownButtonFormField<String>(
//                 value: _catId,
//                 decoration: const InputDecoration(
//                   labelText: 'Kategori',
//                   border: OutlineInputBorder(),
//                 ),
//                 items: cats
//                     .map((c) =>
//                         DropdownMenuItem(value: c.id, child: Text(c.name)))
//                     .toList(),
//                 onChanged: (v) => setState(() => _catId = v),
//                 validator: (v) => v == null ? 'Pilih kategori' : null,
//               ),
//               const SizedBox(height: 12),
//               InkWell(
//                 onTap: _pickDate,
//                 child: InputDecorator(
//                   decoration: const InputDecoration(
//                     labelText: 'Tanggal',
//                     border: OutlineInputBorder(),
//                   ),
//                   child: Text(formatYmd(_date)),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _descC,
//                 maxLines: 3,
//                 decoration: const InputDecoration(
//                   labelText: 'Deskripsi',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _save,
//                   child: const Text('Simpan'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

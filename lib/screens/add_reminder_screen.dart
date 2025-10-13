import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/expense_service.dart';
import '../services/reminder_service.dart';
import '../models/reminder.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController(text: '0');
  final _descController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    ExpenseService.instance.loadInitialData();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    final reminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _nameController.text,
      category: _selectedCategory ?? '',
      dateTime: _selectedDate!,
      amount: double.tryParse(_amountController.text) ?? 0,
      description: _descController.text,
    );

    await ReminderService.instance.addReminder(reminder);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ExpenseService.instance.categories;
    final dateText = _selectedDate == null
        ? ''
        : DateFormat('dd/MM/yy').format(_selectedDate!);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Add Reminder',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFBFEACF),
              child: Icon(Icons.person, color: Colors.black54, size: 18),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 8),
              const Text('Name'),
              const SizedBox(height: 6),
              _buildTextField(_nameController, 'Name', validator: true),

              const SizedBox(height: 16),
              const Text('Date'),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: _buildTextField(
                    TextEditingController(text: dateText),
                    'DD/MM/YY',
                    icon: Icons.calendar_today_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Text('Amount'),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDFF1FF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'IDR',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFF4F8FF),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Text('Category'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: _inputDecoration(),
                items: categories
                    .map((c) =>
                        DropdownMenuItem(value: c.name, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),

              const SizedBox(height: 16),
              const Text('Description (Optional)'),
              const SizedBox(height: 6),
              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: _inputDecoration(
                    hint: 'Description (Optional)', filled: true),
              ),

              const SizedBox(height: 16),
              // Add Attachment
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey.shade400,
                    style: BorderStyle.solid,
                  ),
                ),
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.attach_file_outlined, size: 18),
                  label: const Text(
                    'Add Attachment',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              // Add Reminder Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveReminder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6EE19E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add Reminder',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint, bool filled = true}) {
    return InputDecoration(
      hintText: hint,
      filled: filled,
      fillColor: const Color(0xFFF4F8FF),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool validator = false, IconData? icon}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF4F8FF),
        suffixIcon: icon != null ? Icon(icon) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator
          ? (v) => v == null || v.isEmpty ? '$hint is required' : null
          : null,
    );
  }
}

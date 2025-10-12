import 'package:flutter/material.dart';
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
  String? _title;
  String? _category;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    ExpenseService.instance.loadInitialData();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _selectedDate = date;
      _selectedTime = time;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal & waktu reminder')),
      );
      return;
    }
    _formKey.currentState!.save();

    final dt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final reminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _title!,
      category: _category ?? '',
      dateTime: dt,
    );

    ReminderService.instance.addReminder(reminder);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ExpenseService.instance.categories;

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Judul Reminder'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                onSaved: (v) => _title = v,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: categories
                    .map((c) =>
                        DropdownMenuItem(value: c.name, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v),
                value: _category,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(_selectedDate == null
                        ? 'Belum pilih tanggal'
                        : '${_selectedDate!.toLocal()} ${_selectedTime?.format(context) ?? ''}'),
                  ),
                  ElevatedButton(
                    onPressed: _pickDateTime,
                    child: const Text('Pilih'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Simpan Reminder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

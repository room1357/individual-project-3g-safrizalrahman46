import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';
import '../models/reminder.dart';

class ReminderService extends ChangeNotifier {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  final StorageService _storage = StorageServiceManager.instance.storage;
  List<Reminder> _reminders = [];

  List<Reminder> get reminders => List.unmodifiable(_reminders);

  Future<void> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = _storage.currentUserId;
    if (userId == null) return;

    final key = 'reminders_$userId';
    final data = prefs.getString(key);
    if (data == null) {
      _reminders = [];
    } else {
      final decoded = jsonDecode(data) as List;
      _reminders = decoded.map((e) => Reminder.fromJson(e)).toList();
    }
    notifyListeners();
  }

  Future<void> saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = _storage.currentUserId;
    if (userId == null) return;

    final key = 'reminders_$userId';
    final encoded =
        jsonEncode(_reminders.map((e) => e.toJson()).toList(growable: false));
    await prefs.setString(key, encoded);
  }

  void addReminder(Reminder r) {
    _reminders.add(r);
    saveReminders();
    notifyListeners();
  }

  void deleteReminder(String id) {
    _reminders.removeWhere((r) => r.id == id);
    saveReminders();
    notifyListeners();
  }
}

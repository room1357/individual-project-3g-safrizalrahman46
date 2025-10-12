import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder.dart';
import 'storage_service.dart';

class ReminderService extends ChangeNotifier {
  ReminderService._internal();
  static final ReminderService instance = ReminderService._internal();

  final StorageService _storage = StorageServiceManager.instance.storage;
  List<Reminder> _reminders = [];

  List<Reminder> get reminders => List.unmodifiable(_reminders);

  /// ✅ Load semua reminder milik user aktif
  Future<void> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = _storage.currentUserId;

    if (userId == null) {
      debugPrint('⚠️ ReminderService: currentUserId masih null, kosongkan data');
      _reminders = [];
      notifyListeners();
      return;
    }

    final key = 'reminders_$userId';
    final jsonStr = prefs.getString(key);

    debugPrint('📦 [ReminderService] Load key: $key');

    if (jsonStr == null || jsonStr.isEmpty) {
      debugPrint('ℹ️ Tidak ada data reminder tersimpan untuk user $userId');
      _reminders = [];
    } else {
      try {
        final decoded = jsonDecode(jsonStr) as List<dynamic>;
        _reminders = decoded.map((e) => Reminder.fromJson(e)).toList();
        debugPrint('✅ ${_reminders.length} reminder berhasil dimuat');
      } catch (e) {
        debugPrint('❌ Gagal decode reminder JSON: $e');
        _reminders = [];
      }
    }

    notifyListeners();
  }

  /// ✅ Simpan semua reminder user aktif
  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = _storage.currentUserId;

    if (userId == null) {
      debugPrint('⚠️ ReminderService: userId null, tidak menyimpan data');
      return;
    }

    final key = 'reminders_$userId';
    final jsonStr = jsonEncode(_reminders.map((r) => r.toJson()).toList());
    await prefs.setString(key, jsonStr);
    debugPrint('💾 Reminder disimpan ke key: $key (${_reminders.length} items)');
  }

  /// ✅ Tambahkan reminder baru
  Future<void> addReminder(Reminder reminder) async {
    _reminders.add(reminder);
    await _saveReminders();
    notifyListeners();
  }

  /// ✅ Hapus reminder berdasarkan ID
  Future<void> deleteReminder(String id) async {
    _reminders.removeWhere((r) => r.id == id);
    await _saveReminders();
    notifyListeners();
  }

  /// ✅ Kosongkan semua reminder user (opsional)
  Future<void> clearAll() async {
    _reminders.clear();
    await _saveReminders();
    notifyListeners();
  }
}

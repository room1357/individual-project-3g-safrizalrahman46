import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  final List<User> _users = [];
  User? _currentUser;

  User? get currentUser => _currentUser;

  /// Register user baru
  Future<bool> register(User user) async {
    final prefs = await SharedPreferences.getInstance();

    // Ambil data users lama
    final usersJson = prefs.getString('users');
    if (usersJson != null) {
      final decoded = jsonDecode(usersJson) as List;
      _users.clear();
      _users.addAll(decoded.map((u) => User.fromJson(u)));
    }

    // Cek apakah email sudah ada
    if (_users.any((u) => u.email == user.email)) return false;

    // Tambah user baru
    _users.add(user);

    // Simpan ke SharedPreferences
    await prefs.setString('users', jsonEncode(_users.map((u) => u.toJson()).toList()));
    return true;
  }

  /// Login user
  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final usersJson = prefs.getString('users');
    if (usersJson != null) {
      final decoded = jsonDecode(usersJson) as List;
      _users.clear();
      _users.addAll(decoded.map((u) => User.fromJson(u)));
    }

    try {
      final user = _users.firstWhere((u) => u.email == email && u.password == password);
      _currentUser = user;

      // Simpan current user ke SharedPreferences
      await prefs.setString('currentUser', jsonEncode(user.toJson()));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
  }

  /// Load current user saat startup
  Future<void> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('currentUser');
    if (userJson != null) {
      _currentUser = User.fromJson(jsonDecode(userJson));
    }
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  final List<User> _users = [];
  User? _currentUser;

  User? get currentUser => _currentUser;

  // --- FUNGSI BARU DITAMBAHKAN DI SINI ---
  /// 🔹 Menambahkan data user dummy jika belum ada.
  /// Panggil fungsi ini di main.dart sebelum runApp()
  Future<void> addDummyUsers() async {
    final prefs = await SharedPreferences.getInstance();

    // Cek dulu apakah sudah ada data users
    final usersJson = prefs.getString('users');
    if (usersJson == null || usersJson.isEmpty || usersJson == '[]') {
      print('🌱 Menanam data user dummy...'); // Pesan untuk debugging

      // Buat daftar user dummy
      final List<User> dummyUsers = [
        User(
          id: 'user-001',
          username: 'budi',
          email: 'budi@gmail.com',
          password: 'password123',
          fullName: 'Budi Santoso',
        ),
        User(
          id: 'user-002',
          username: 'susi',
          email: 'susi@gmail.com',
          password: 'password456',
          fullName: 'Susi Susanti',
        ),
      ];

      // Simpan ke SharedPreferences
      await prefs.setString(
        'users',
        jsonEncode(dummyUsers.map((u) => u.toJson()).toList()),
      );
      print('✅ Data user dummy berhasil disimpan.');
    } else {
      print('👍 Data users sudah ada, tidak perlu menanam data dummy.');
    }
  }
  // --- BATAS PENAMBAHAN FUNGSI BARU ---

  /// 🔹 Register user baru
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
    await prefs.setString(
      'users',
      jsonEncode(_users.map((u) => u.toJson()).toList()),
    );

    // Set sebagai currentUser
    _currentUser = user;
    await prefs.setString('currentUser', jsonEncode(user.toJson()));

    // Integrasi ke StorageService
    StorageServiceManager.instance.currentUserId = user.id;

    return true;
  }

  /// 🔹 Login user
  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final usersJson = prefs.getString('users');
    if (usersJson != null) {
      final decoded = jsonDecode(usersJson) as List;
      _users.clear();
      _users.addAll(decoded.map((u) => User.fromJson(u)));
    }

    try {
      final user = _users.firstWhere(
        (u) => u.email == email && u.password == password,
      );
      _currentUser = user;

      // Simpan current user ke SharedPreferences
      await prefs.setString('currentUser', jsonEncode(user.toJson()));

      // Integrasi ke StorageService
      StorageServiceManager.instance.currentUserId = user.id;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// 🔹 Logout user
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');

    // Reset user id di storage
    StorageServiceManager.instance.currentUserId = null;
  }

  /// ✅ 🔹 Load current user saat startup (AKTIFKAN KEMBALI)
  Future<void> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('currentUser');
    if (userJson != null) {
      _currentUser = User.fromJson(jsonDecode(userJson));

      // Set juga ke storage
      StorageServiceManager.instance.currentUserId = _currentUser!.id;
      print('👤 Current user loaded: ${_currentUser!.username}');
    } else {
      print('ℹ️ Belum ada user yang login.');
    }
  }

  /// 🔹 Update profile (bisa update username, fullname, email, password)
  Future<void> updateProfile(
    String username,
    String fullName, {
    String? email,
    String? password,
  }) async {
    if (_currentUser == null) return;

    final prefs = await SharedPreferences.getInstance();

    // Update current user
    _currentUser = User(
      id: _currentUser!.id,
      username: username,
      fullName: fullName,
      email: email ?? _currentUser!.email,
      password: password ?? _currentUser!.password,
    );

    // Update list users
    final usersJson = prefs.getString('users');
    if (usersJson != null) {
      final decoded = jsonDecode(usersJson) as List;
      _users.clear();
      _users.addAll(decoded.map((u) => User.fromJson(u)));
    }

    final index = _users.indexWhere((u) => u.id == _currentUser!.id);
    if (index != -1) {
      _users[index] = _currentUser!;
    }

    // Simpan ke SharedPreferences
    await prefs.setString(
      'users',
      jsonEncode(_users.map((u) => u.toJson()).toList()),
    );
    await prefs.setString('currentUser', jsonEncode(_currentUser!.toJson()));
  }

  /// 🔹 Forgot Password
  Future<bool> sendPasswordReset(String email) async {
    final prefs = await SharedPreferences.getInstance();

    // Ambil semua user
    final usersJson = prefs.getString('users');
    if (usersJson == null) return false;

    final decoded = jsonDecode(usersJson) as List;
    final users = decoded.map((u) => User.fromJson(u)).toList();

    // Cari user berdasarkan email
    final user = users.where((u) => u.email == email).toList();

    if (user.isEmpty) {
      print('❌ Email not found: $email');
      return false;
    }

    // Simulasi pengiriman email reset password
    await Future.delayed(const Duration(seconds: 2));
    print('📩 Password reset link sent to $email');

    return true;
  }

  /// 🔹 Reset Password (ubah password user berdasarkan email)
  Future<bool> resetPassword(String email, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');
    if (usersJson == null) return false;

    final decoded = jsonDecode(usersJson) as List;
    final users = decoded.map((u) => User.fromJson(u)).toList();

    final index = users.indexWhere((u) => u.email == email);
    if (index == -1) return false;

    // Update password
    final user = users[index];
    final updatedUser = User(
      id: user.id,
      username: user.username,
      fullName: user.fullName,
      email: user.email,
      password: newPassword,
    );
    users[index] = updatedUser;

    await prefs.setString(
      'users',
      jsonEncode(users.map((u) => u.toJson()).toList()),
    );

    // Jika current user sama, update juga
    if (_currentUser?.email == email) {
      _currentUser = updatedUser;
      await prefs.setString('currentUser', jsonEncode(updatedUser.toJson()));
    }

    print('✅ Password updated for $email');
    return true;
  }
}

// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/user.dart';
// import '../services/storage_service.dart';

// class AuthService {
//   static final AuthService instance = AuthService._internal();
//   AuthService._internal();

//   final List<User> _users = [];
//   User? _currentUser;

//   User? get currentUser => _currentUser;

//   /// 🔹 Register user baru
//   Future<bool> register(User user) async {
//     final prefs = await SharedPreferences.getInstance();

//     // Ambil data users lama
//     final usersJson = prefs.getString('users');
//     if (usersJson != null) {
//       final decoded = jsonDecode(usersJson) as List;
//       _users.clear();
//       _users.addAll(decoded.map((u) => User.fromJson(u)));
//     }

//     // Cek apakah email sudah ada
//     if (_users.any((u) => u.email == user.email)) return false;

//     // Tambah user baru
//     _users.add(user);

//     // Simpan ke SharedPreferences
//     await prefs.setString(
//       'users',
//       jsonEncode(_users.map((u) => u.toJson()).toList()),
//     );

//     // Set sebagai currentUser
//     _currentUser = user;
//     await prefs.setString('currentUser', jsonEncode(user.toJson()));

//     // Integrasi ke StorageService
//     StorageServiceManager.instance.currentUserId = user.id;

//     return true;
//   }

//   /// 🔹 Login user
//   Future<bool> login(String email, String password) async {
//     final prefs = await SharedPreferences.getInstance();

//     final usersJson = prefs.getString('users');
//     if (usersJson != null) {
//       final decoded = jsonDecode(usersJson) as List;
//       _users.clear();
//       _users.addAll(decoded.map((u) => User.fromJson(u)));
//     }

//     try {
//       final user = _users.firstWhere(
//         (u) => u.email == email && u.password == password,
//       );
//       _currentUser = user;

//       // Simpan current user ke SharedPreferences
//       await prefs.setString('currentUser', jsonEncode(user.toJson()));

//       // Integrasi ke StorageService
//       StorageServiceManager.instance.currentUserId = user.id;

//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   /// 🔹 Logout user
//   Future<void> logout() async {
//     _currentUser = null;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('currentUser');

//     // Reset user id di storage
//     StorageServiceManager.instance.currentUserId = null;
//   }

//   /// 🔹 Load current user saat startup
//   Future<void> loadCurrentUser() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userJson = prefs.getString('currentUser');
//     if (userJson != null) {
//       _currentUser = User.fromJson(jsonDecode(userJson));

//       // Set juga ke storage
//       StorageServiceManager.instance.currentUserId = _currentUser!.id;
//     }
//   }

//   /// 🔹 Update profile
//   Future<void> updateProfile(String username, String fullName) async {
//     if (_currentUser == null) return;

//     final prefs = await SharedPreferences.getInstance();

//     // Update current user
//     _currentUser = User(
//       id: _currentUser!.id,
//       username: username,
//       fullName: fullName,
//       email: _currentUser!.email,
//       password: _currentUser!.password,
//     );

//     // Update list users
//     final usersJson = prefs.getString('users');
//     if (usersJson != null) {
//       final decoded = jsonDecode(usersJson) as List;
//       _users.clear();
//       _users.addAll(decoded.map((u) => User.fromJson(u)));
//     }

//     final index = _users.indexWhere((u) => u.id == _currentUser!.id);
//     if (index != -1) {
//       _users[index] = _currentUser!;
//     }

//     // Simpan lagi ke SharedPreferences
//     await prefs.setString(
//       'users',
//       jsonEncode(_users.map((u) => u.toJson()).toList()),
//     );
//     await prefs.setString('currentUser', jsonEncode(_currentUser!.toJson()));
//   }

//   /// ✅ 🔹 FUNGSI BARU: Forgot Password
//   Future<bool> sendPasswordReset(String email) async {
//     final prefs = await SharedPreferences.getInstance();

//     // Ambil semua user
//     final usersJson = prefs.getString('users');
//     if (usersJson == null) return false;

//     final decoded = jsonDecode(usersJson) as List;
//     final users = decoded.map((u) => User.fromJson(u)).toList();

//     // Cari user berdasarkan email
//     final user = users.where((u) => u.email == email).toList();

//     if (user.isEmpty) {
//       // Email tidak ditemukan
//       print('❌ Email not found: $email');
//       return false;
//     }

//     // Simulasi pengiriman email reset password
//     await Future.delayed(const Duration(seconds: 2));
//     print('📩 Password reset link sent to $email');

//     // Kamu bisa tambahkan logika lain, seperti update token reset di future versi
//     return true;
//   }

//   /// 🔹 Reset Password (ubah password user berdasarkan email)
//   Future<bool> resetPassword(String email, String newPassword) async {
//     final prefs = await SharedPreferences.getInstance();
//     final usersJson = prefs.getString('users');
//     if (usersJson == null) return false;

//     final decoded = jsonDecode(usersJson) as List;
//     final users = decoded.map((u) => User.fromJson(u)).toList();

//     final index = users.indexWhere((u) => u.email == email);
//     if (index == -1) return false;

//     // Update password
//     final user = users[index];
//     final updatedUser = User(
//       id: user.id,
//       username: user.username,
//       fullName: user.fullName,
//       email: user.email,
//       password: newPassword,
//     );
//     users[index] = updatedUser;

//     await prefs.setString(
//       'users',
//       jsonEncode(users.map((u) => u.toJson()).toList()),
//     );

//     // Jika current user sama, update juga
//     if (_currentUser?.email == email) {
//       _currentUser = updatedUser;
//       await prefs.setString('currentUser', jsonEncode(updatedUser.toJson()));
//     }

//     print('✅ Password updated for $email');
//     return true;
//   }
// }

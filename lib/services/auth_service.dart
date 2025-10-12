import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../utils/web_image_helper.dart';

// ✅ Import helper universal agar tidak error di web
import '../utils/app_directory_stub.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  final List<User> _users = [];
  User? _currentUser;

  User? get currentUser => _currentUser;

  // ✅ Tambahan getter untuk ReminderService
  String? get currentUserId => _currentUser?.id;

  // --- FUNGSI BARU DITAMBAHKAN DI SINI ---
  Future<void> addDummyUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');
    if (usersJson == null || usersJson.isEmpty || usersJson == '[]') {
      print('🌱 Menanam data user dummy...');
      final List<User> dummyUsers = [
        User(
          id: 'user-001',
          username: 'budi',
          email: 'budi@gmail.com',
          password: 'password123',
          fullName: 'Budi Santoso',
          profileImagePath: '',
        ),
        User(
          id: 'user-002',
          username: 'susi',
          email: 'susi@gmail.com',
          password: 'password456',
          fullName: 'Susi Susanti',
          profileImagePath: '',
        ),
      ];
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

  Future<bool> register(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');
    if (usersJson != null) {
      final decoded = jsonDecode(usersJson) as List;
      _users.clear();
      _users.addAll(decoded.map((u) => User.fromJson(u)));
    }

    if (_users.any((u) => u.email == user.email)) return false;

    _users.add(user);
    await prefs.setString(
      'users',
      jsonEncode(_users.map((u) => u.toJson()).toList()),
    );

    _currentUser = user;
    await prefs.setString('currentUser', jsonEncode(user.toJson()));
    StorageServiceManager.instance.currentUserId = user.id;
    return true;
  }

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

      await prefs.setString('currentUser', jsonEncode(user.toJson()));
      StorageServiceManager.instance.currentUserId = user.id;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
    StorageServiceManager.instance.currentUserId = null;
  }

  /// ✅ Load user aktif saat startup
  Future<void> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('currentUser');

    if (userJson != null && userJson.isNotEmpty) {
      final userData = jsonDecode(userJson);
      _currentUser = User.fromJson(userData);

      if (!kIsWeb &&
          _currentUser!.profileImagePath != null &&
          _currentUser!.profileImagePath!.isNotEmpty) {
        final file = File(_currentUser!.profileImagePath!);
        if (!file.existsSync()) {
          print('⚠️ File foto hilang: ${_currentUser!.profileImagePath}');
          _currentUser = _currentUser!.copyWith(profileImagePath: '');
          await prefs.setString('currentUser', jsonEncode(_currentUser!.toJson()));
        }
      }

      StorageServiceManager.instance.currentUserId = _currentUser!.id;

      print('👤 Current user loaded: ${_currentUser!.username}');
      print('🖼️ Profile image path: ${_currentUser!.profileImagePath}');
    } else {
      print('ℹ️ Belum ada user yang login.');
    }
  }

  /// 🔹 Update profile (termasuk foto profil)
  Future<void> updateProfile(
    String username,
    String fullName, {
    String? email,
    String? password,
    String? profileImagePath,
  }) async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();

    String? safePath = _currentUser!.profileImagePath;

    if (profileImagePath != null && profileImagePath.isNotEmpty) {
      if (!kIsWeb) {
        // Mobile: copy ke appDocumentsDirectory (sudah benar)
        try {
          final appDirPath = await getAppDocumentsDirectoryPath();
          if (appDirPath != null) {
            final fileName = profileImagePath.split('/').last;
            final newPath = '$appDirPath/$fileName';
            final srcFile = File(profileImagePath);
            final destFile = File(newPath);

            if (await srcFile.exists()) {
              if (await destFile.exists()) await destFile.delete();
              await srcFile.copy(newPath);
              safePath = newPath;
            } else {
              print('⚠️ File source tidak ada: $profileImagePath');
            }
          }
        } catch (e) {
          print('⚠️ Gagal menyimpan gambar lokal: $e');
        }
      } else {
        // Web: pakai helper Web untuk convert ke Base64
        final base64Str = await imageFileToBase64Web(profileImagePath);
        if (base64Str != null) safePath = base64Str;
      }
    }

    _currentUser = _currentUser!.copyWith(
      username: username,
      fullName: fullName,
      email: email,
      password: password,
      profileImagePath: safePath,
    );

    // Update user list
    final usersJson = prefs.getString('users');
    if (usersJson != null) {
      final decoded = jsonDecode(usersJson) as List;
      _users.clear();
      _users.addAll(decoded.map((u) => User.fromJson(u)));
    }

    final index = _users.indexWhere((u) => u.id == _currentUser!.id);
    if (index != -1) _users[index] = _currentUser!;

    await prefs.setString('users', jsonEncode(_users.map((u) => u.toJson()).toList()));
    await prefs.setString('currentUser', jsonEncode(_currentUser!.toJson()));

    print('✅ Profile updated for ${_currentUser!.username}');
    print('🖼️ Saved image path: ${_currentUser!.profileImagePath}');
  }

  Future<bool> sendPasswordReset(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');
    if (usersJson == null) return false;

    final decoded = jsonDecode(usersJson) as List;
    final users = decoded.map((u) => User.fromJson(u)).toList();
    final user = users.where((u) => u.email == email).toList();

    if (user.isEmpty) {
      print('❌ Email not found: $email');
      return false;
    }

    await Future.delayed(const Duration(seconds: 2));
    print('📩 Password reset link sent to $email');
    return true;
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');
    if (usersJson == null) return false;

    final decoded = jsonDecode(usersJson) as List;
    final users = decoded.map((u) => User.fromJson(u)).toList();

    final index = users.indexWhere((u) => u.email == email);
    if (index == -1) return false;

    final user = users[index];
    final updatedUser = User(
      id: user.id,
      username: user.username,
      fullName: user.fullName,
      email: user.email,
      password: newPassword,
      profileImagePath: user.profileImagePath,
    );
    users[index] = updatedUser;

    await prefs.setString(
      'users',
      jsonEncode(users.map((u) => u.toJson()).toList()),
    );

    if (_currentUser?.email == email) {
      _currentUser = updatedUser;
      await prefs.setString('currentUser', jsonEncode(updatedUser.toJson()));
    }

    print('✅ Password updated for $email');
    return true;
  }

  // ✅ Tambahan opsional agar data user bisa di-refresh dari penyimpanan
  Future<void> reloadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');
    if (usersJson != null) {
      final decoded = jsonDecode(usersJson) as List;
      _users
        ..clear()
        ..addAll(decoded.map((u) => User.fromJson(u)));
    }

    if (_currentUser != null) {
      _currentUser = _users.firstWhere(
        (u) => u.id == _currentUser!.id,
        orElse: () => _currentUser!,
      );
      await prefs.setString('currentUser', jsonEncode(_currentUser!.toJson()));
    }
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

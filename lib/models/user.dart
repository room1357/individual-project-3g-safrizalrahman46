import 'dart:convert';

class User {
  final String id;
  final String username;
  final String email;
  final String password; // sementara plain text
  final String fullName;
  final String? profileImagePath; // boleh null

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
    this.profileImagePath,
  });

  /// Convert ke JSON (untuk disimpan ke SharedPreferences / API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'fullName': fullName,
      'profileImagePath': profileImagePath,
    };
  }

  /// Factory untuk buat User dari JSON (ambil dari SharedPreferences / API)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      fullName: json['fullName'] as String,
      profileImagePath: json['profileImagePath'] as String?, // ✅ ditambahkan
    );
  }
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    String? fullName,
    String? profileImagePath,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}


// class User {
//   final String id;
//   final String username;
//   final String email;
//   final String password; // sementara plain text (bisa diganti hash pakai crypto)
//   final String fullName;
  

//   User({
//     required this.id,
//     required this.username,
//     required this.email,
//     required this.password,
//     required this.fullName,
//   });

//   /// Convert ke JSON (untuk disimpan ke SharedPreferences / API)
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'username': username,
//       'email': email,
//       'password': password,
//       'fullName': fullName,
//     };
//   }

//   /// Factory untuk buat User dari JSON (ambil dari SharedPreferences / API)
//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'] as String,
//       username: json['username'] as String,
//       email: json['email'] as String,
//       password: json['password'] as String,
//       fullName: json['fullName'] as String,
//     );
//   }
// }

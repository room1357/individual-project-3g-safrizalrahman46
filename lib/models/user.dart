class User {
  final String id;
  final String username;
  final String email;
  final String password; // sementara plain text (bisa diganti hash pakai crypto)
  final String fullName;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
  });

  /// Convert ke JSON (untuk disimpan ke SharedPreferences / API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'fullName': fullName,
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
    );
  }
}

class User {
  final String id;
  final String username;
  final String email;
  final String password; // sementara plain text (bisa diganti hash)
  final String fullName;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
  });
}

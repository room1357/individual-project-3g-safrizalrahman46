import '../models/user.dart';

class AuthService {
  final List<User> _users = [];
  User? _currentUser;

  User? get currentUser => _currentUser;

  bool register(User user) {
    if (_users.any((u) => u.email == user.email)) {
      return false; // Email sudah terdaftar
    }
    _users.add(user);
    return true;
  }

  bool login(String email, String password) {
    try {
      final user = _users.firstWhere((u) => u.email == email && u.password == password);
      _currentUser = user;
      return true;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _currentUser = null;
  }
}

// import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';
// import '../models/user.dart';
// import '../services/auth_service.dart';
// import 'home_screen.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _usernameController = TextEditingController();
//   final _fullnameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _loading = false;

//   Future<void> _register() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _loading = true);

//     final newUser = User(
//       id: const Uuid().v4(),
//       username: _usernameController.text.trim(),
//       email: _emailController.text.trim(),
//       password: _passwordController.text.trim(),
//       fullName: _fullnameController.text.trim(),
//     );

//     final success = await AuthService.instance.register(newUser);
//     setState(() => _loading = false);

//     if (!mounted) return;
//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Registrasi berhasil')),
//       );
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const HomeScreen()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Email sudah terdaftar')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Daftar'), backgroundColor: Colors.blue),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 controller: _usernameController,
//                 decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
//                 validator: (v) => v == null || v.isEmpty ? 'Username wajib diisi' : null,
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _fullnameController,
//                 decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
//                 validator: (v) => v == null || v.isEmpty ? 'Nama lengkap wajib diisi' : null,
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
//                 keyboardType: TextInputType.emailAddress,
//                 validator: (v) {
//                   if (v == null || v.isEmpty) return 'Email wajib diisi';
//                   if (!v.contains('@')) return 'Email tidak valid';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
//                 obscureText: true,
//                 validator: (v) => v != null && v.length < 6 ? 'Password minimal 6 karakter' : null,
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _loading ? null : _register,
//                   child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('DAFTAR'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import '../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _agree = false;

  String? _errorMessage;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _errorMessage = 'Please fill all required fields correctly');
      return;
    }

    if (!_agree) {
      setState(() => _errorMessage = 'You must agree to the Terms & Privacy Policy');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final newUser = User(
      id: const Uuid().v4(),
      username: _fullnameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      fullName: _fullnameController.text.trim(),
    );

    final success = await AuthService.instance.register(newUser);
    setState(() => _loading = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() {
        _errorMessage = 'Email sudah terdaftar';
      });
    }
  }

  InputDecoration _inputStyle(String hint) {
    final borderColor = const Color(0xFFE6E6E6);
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      prefixIcon: hint == 'Password'
          ? const Icon(Icons.lock_outline)
          : hint == 'Email'
              ? const Icon(Icons.email_outlined)
              : const Icon(Icons.person_outline),
      suffixIcon: hint == 'Password'
          ? IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3BAA81), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // 🔴 Error Alert Box (seperti di login)
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE6E6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.redAccent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Full Name
                TextFormField(
                  controller: _fullnameController,
                  decoration: _inputStyle('Name'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: _inputStyle('Email'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email wajib diisi';
                    if (!v.contains('@')) return 'Email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _inputStyle('Password'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password wajib diisi';
                    if (v.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _agree,
                      activeColor: const Color(0xFF3BAA81),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (v) => setState(() => _agree = v ?? false),
                    ),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                          children: [
                            TextSpan(text: 'By signing up, you agree to the '),
                            TextSpan(
                              text: 'Terms of Service ',
                              style: TextStyle(
                                color: Color(0xFF3BAA81),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(text: 'and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: Color(0xFF3BAA81),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Tombol Sign Up
                _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF3BAA81),
                        ),
                      )
                    : PrimaryButton(
                        text: 'Sign Up',
                        onPressed: _register,
                      ),
                const SizedBox(height: 24),

                // Sudah punya akun
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.black54),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Color(0xFF3BAA81),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

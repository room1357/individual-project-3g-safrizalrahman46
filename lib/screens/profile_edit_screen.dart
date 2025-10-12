import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _fullnameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  File? _profileImage;
  String? _webImagePath; // khusus Web

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.currentUser;

    _usernameController = TextEditingController(text: user?.username ?? '');
    _fullnameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _passwordController = TextEditingController(text: user?.password ?? '');
    _confirmPasswordController =
        TextEditingController(text: user?.password ?? '');

    // Load foto profil jika ada
    if (user?.profileImagePath != null) {
      if (kIsWeb) {
        _webImagePath = user!.profileImagePath!;
      } else {
        final file = File(user!.profileImagePath!);
        if (file.existsSync()) {
          _profileImage = file;
        }
      }
    }
  }

  /// 📸 Ambil gambar dari kamera atau galeri
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Pilih dari Galeri"),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Ambil dari Kamera"),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          if (kIsWeb) {
            _webImagePath = pickedFile.path;
          } else {
            _profileImage = File(pickedFile.path);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green.shade100,
              child: const Icon(Icons.person, color: Colors.black54, size: 18),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // FOTO PROFIL
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.green.shade200,
                        backgroundImage: (!kIsWeb && _profileImage != null)
                            ? FileImage(_profileImage!)
                            : (kIsWeb && _webImagePath != null)
                                ? NetworkImage(_webImagePath!) as ImageProvider
                                : null,
                        child: (_profileImage == null && _webImagePath == null)
                            ? Text(
                                user.username.isNotEmpty
                                    ? user.username[0].toUpperCase()
                                    : "?",
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("Tap untuk ubah foto",
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // FORM INPUT
              _buildField("Full Name", _fullnameController,
                  validator: (val) =>
                      val == null || val.isEmpty ? "Nama wajib diisi" : null),
              _buildField("Username", _usernameController,
                  validator: (val) => val == null || val.isEmpty
                      ? "Username wajib diisi"
                      : null),
              _buildField("Email", _emailController,
                  validator: (val) =>
                      val == null || val.isEmpty ? "Email wajib diisi" : null),
              _buildField(
                "Password",
                _passwordController,
                obscure: _obscurePassword,
                toggleObscure: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                validator: (val) => val == null || val.isEmpty
                    ? "Password wajib diisi"
                    : (val.length < 6
                        ? "Password minimal 6 karakter"
                        : null),
              ),
              _buildField(
                "Confirm Password",
                _confirmPasswordController,
                obscure: _obscureConfirmPassword,
                toggleObscure: () => setState(() =>
                    _obscureConfirmPassword = !_obscureConfirmPassword),
                validator: (val) => val != _passwordController.text
                    ? "Konfirmasi password tidak cocok"
                    : null,
              ),

              const SizedBox(height: 30),

              // BUTTON SIMPAN
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await AuthService.instance.updateProfile(
                        _usernameController.text.trim(),
                        _fullnameController.text.trim(),
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                        profileImagePath:
                            kIsWeb ? _webImagePath : _profileImage?.path,
                      );

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Profil berhasil diperbarui")),
                      );

                      Navigator.pop(context, true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade400,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Simpan Perubahan",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget reusable untuk text field
  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    VoidCallback? toggleObscure,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: toggleObscure != null
              ? IconButton(
                  icon: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: toggleObscure,
                )
              : null,
        ),
      ),
    );
  }
}

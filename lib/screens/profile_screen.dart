import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  String? _webImagePath;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser(); // 🔁 Load user + foto profil
  }

  /// 🔁 Muat ulang data user dan foto profil
  Future<void> _loadCurrentUser() async {
    await AuthService.instance.loadCurrentUser();
    await _loadProfileImage();
    setState(() {}); // perbarui tampilan
  }

  /// 🖼️ Muat ulang foto profil berdasarkan platform
  Future<void> _loadProfileImage() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    if (kIsWeb) {
      // Web pakai path string langsung
      setState(() {
        _webImagePath = user.profileImagePath?.isNotEmpty == true
            ? user.profileImagePath
            : null;
      });
    } else {
      // Mobile pakai File
      if (user.profileImagePath != null &&
          user.profileImagePath!.isNotEmpty) {
        final file = File(user.profileImagePath!);
        if (file.existsSync()) {
          setState(() => _profileImage = file);
        } else {
          setState(() => _profileImage = null);
        }
      } else {
        setState(() => _profileImage = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        body: const Center(child: Text("Belum ada user yang login.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
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

      // 🔄 Pull-to-refresh untuk memuat ulang data
      body: RefreshIndicator(
        onRefresh: _loadCurrentUser,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 10),

            // 🖼️ FOTO PROFIL
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.green.shade200,
                  backgroundImage: (!kIsWeb && _profileImage != null)
                      ? FileImage(_profileImage!)
                      : (kIsWeb && _webImagePath != null)
                          ? NetworkImage(_webImagePath!)
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

                // ✏️ Tombol Edit
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileEditScreen(),
                        ),
                      );

                      // jika berhasil update, muat ulang data
                      if (result == true) {
                        await _loadCurrentUser();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text("Full Name", style: TextStyle(color: Colors.grey)),
            Text(
              user.fullName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text("Username", style: TextStyle(color: Colors.grey)),
            Text(
              user.username,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text("Email", style: TextStyle(color: Colors.grey)),
            Text(
              user.email,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            const SizedBox(height: 30),

            // 📋 MENU ITEMS
            _menuItem(
              icon: Icons.person_rounded,
              label: "Account",
              color: const Color(0xFF6B4EFF),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
                );
                if (result == true) {
                  await _loadCurrentUser(); // ✅ update foto & data
                }
              },
            ),
            _divider(),
            _menuItem(
              icon: Icons.settings_rounded,
              label: "Settings",
              color: const Color(0xFF6B4EFF),
            ),
            _divider(),
            _menuItem(
              icon: Icons.file_upload_rounded,
              label: "Export Data",
              color: const Color(0xFF6B4EFF),
            ),
            _divider(),
            _menuItem(
              icon: Icons.logout_rounded,
              label: "Logout",
              color: Colors.redAccent,
              onTap: () async {
                await AuthService.instance.logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Divider(color: Colors.grey.shade300, thickness: 1);
}



// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';
// import 'login_screen.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _usernameController;
//   late TextEditingController _fullnameController;

//   @override
//   void initState() {
//     super.initState();
//     final user = AuthService.instance.currentUser;
//     _usernameController = TextEditingController(text: user?.username ?? '');
//     _fullnameController = TextEditingController(text: user?.fullName ?? '');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = AuthService.instance.currentUser;

//     if (user == null) {
//       // Kalau tidak ada user (misal belum login)
//       return Scaffold(
//         appBar: AppBar(title: const Text('Profile')),
//         body: const Center(
//           child: Text('Tidak ada data user. Silakan login dulu.'),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('User Profile'),
//         backgroundColor: Colors.blue,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Card(
//             elevation: 4,
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Avatar
//                   Center(
//                     child: CircleAvatar(
//                       radius: 40,
//                       backgroundColor: Colors.blue,
//                       child: Text(
//                         user.username[0].toUpperCase(),
//                         style: const TextStyle(
//                           fontSize: 32,
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Editable fields
//                   TextFormField(
//                     controller: _usernameController,
//                     decoration: const InputDecoration(
//                       labelText: "Username",
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (v) =>
//                         v == null || v.isEmpty ? "Username wajib diisi" : null,
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: _fullnameController,
//                     decoration: const InputDecoration(
//                       labelText: "Nama Lengkap",
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (v) => v == null || v.isEmpty
//                         ? "Nama lengkap wajib diisi"
//                         : null,
//                   ),
//                   const SizedBox(height: 20),

//                   // Tombol Simpan
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       icon: const Icon(Icons.save),
//                       label: const Text("Simpan Perubahan"),
//                       onPressed: () async {
//                         if (_formKey.currentState!.validate()) {
//                           await AuthService.instance.updateProfile(
//                             _usernameController.text.trim(),
//                             _fullnameController.text.trim(),
//                           );
//                           if (!mounted) return;
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                                 content: Text("Profile berhasil diperbarui")),
//                           );
//                           setState(() {}); // refresh UI
//                         }
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 10),

//                   // Logout dari Profile
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       icon: const Icon(Icons.logout),
//                       label: const Text("Logout"),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                       ),
//                       onPressed: () async {
//                         await AuthService.instance.logout();
//                         if (!context.mounted) return;
//                         Navigator.pushAndRemoveUntil(
//                           context,
//                           MaterialPageRoute(
//                               builder: (_) => const LoginScreen()),
//                           (route) => false,
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currency = "USD";
  String _language = "English";
  String _theme = "Dark";
  String _security = "Fingerprint";

  @override
  Widget build(BuildContext context) {
    final valueColor = Colors.green.shade400;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Setting",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Padding(
          //   padding: const EdgeInsets.only(right: 16),
          //   child: CircleAvatar(
          //     radius: 16,
          //     backgroundColor: Colors.green.shade100,
          //     child: const Icon(Icons.person, color: Colors.black54, size: 18),
          //   ),
          // ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        children: [
          _settingItem(
            title: "Currency",
            value: _currency,
            valueColor: valueColor,
            onTap: () {
              // Contoh aksi
              setState(() => _currency = _currency == "USD" ? "IDR" : "USD");
            },
          ),
          _divider(),
          _settingItem(
            title: "Language",
            value: _language,
            valueColor: valueColor,
            onTap: () {
              setState(() =>
                  _language = _language == "English" ? "Bahasa" : "English");
            },
          ),
          _divider(),
          _settingItem(
            title: "Theme",
            value: _theme,
            valueColor: valueColor,
            onTap: () {
              setState(() => _theme = _theme == "Dark" ? "Light" : "Dark");
            },
          ),
          _divider(),
          _settingItem(
            title: "Security",
            value: _security,
            valueColor: valueColor,
            onTap: () {
              setState(() => _security =
                  _security == "Fingerprint" ? "PIN" : "Fingerprint");
            },
          ),
          _divider(),
          _settingItem(
            title: "Notification",
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _settingItem(
            title: "About",
            onTap: () {},
          ),
          _divider(),
          _settingItem(
            title: "Help",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  /// 🔧 Widget Item Setting
  Widget _settingItem({
    required String title,
    String? value,
    Color? valueColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (value != null)
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      color: valueColor ?? Colors.grey,
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.green.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Divider(
        color: Colors.grey.shade300,
        height: 0,
        thickness: 0.7,
      );
}

// import 'package:flutter/material.dart';

// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Settings'),
//         backgroundColor: Colors.blue,
//       ),
//       body: ListView(
//         children: [
//           SwitchListTile(
//             title: const Text('Dark Mode'),
//             value: false,
//             onChanged: (val) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('Dark Mode Coming Soon!')),
//               );
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.info),
//             title: const Text('About App'),
//             onTap: () {
//               showAboutDialog(
//                 context: context,
//                 applicationName: 'Aplikasi Pengeluaran',
//                 applicationVersion: '1.0.0',
//                 children: [const Text('Dibuat untuk latihan navigasi & ListView.')],
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
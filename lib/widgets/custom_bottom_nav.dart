import 'package:flutter/material.dart';
// import 'package:pemrograman_mobile/screens/settings_screen.dart';
import '../screens/home_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/category_screen.dart';
import '../screens/add_expense_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/reminder_screen.dart';


class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap; // <- Tambahan opsional callback dari luar

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CategoryScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReminderScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      elevation: 10,
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomIcon(context, Icons.home_rounded, 0, "Home"),
            _bottomIcon(context, Icons.category_rounded, 1, "Category"),
            const SizedBox(width: 60), // ruang untuk FAB di tengah
            _bottomIcon(context, Icons.notification_add_outlined, 2, "Reminder"),
            _bottomIcon(context, Icons.settings_rounded, 3, "Settings"),
          ],
        ),
      ),
    );
  }

  Widget _bottomIcon(BuildContext context, IconData icon, int index, String label) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () {
        // jika ada callback dari luar, panggil itu
        if (onTap != null) {
          onTap!(index);
        } else {
          _onItemTapped(context, index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 6),
          Icon(
            icon,
            color: isActive ? const Color(0xFF8EE5B5) : Colors.grey,
            size: 26,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? const Color(0xFF8EE5B5) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import '../screens/home_screen.dart';
// import '../screens/statistics_screen.dart';
// import '../screens/profile_screen.dart';
// import '../screens/category_screen.dart';
// import '../screens/add_expense_screen.dart';

// class CustomBottomNav extends StatelessWidget {
//   final int currentIndex;
//   const CustomBottomNav({super.key, required this.currentIndex});

//   void _onItemTapped(BuildContext context, int index) {
//     if (index == currentIndex) return;

//     switch (index) {
//       case 0:
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const HomeScreen()),
//         );
//         break;
//       case 1:
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const CategoryScreen()),
//         );
//         break;
//       case 2:
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const StatisticsScreen()),
//         );
//         break;
//       case 3:
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const ProfileScreen()),
//         );
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BottomAppBar(
//       shape: const CircularNotchedRectangle(),
//       notchMargin: 8,
//       color: Colors.white,
//       elevation: 8,
//       child: SizedBox(
//         height: 65,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _bottomIcon(context, Icons.home_rounded, 0, "Home"),
//             _bottomIcon(context, Icons.category_rounded, 1, "Category"),
//             const SizedBox(width: 60), // spasi tengah buat FAB
//             _bottomIcon(context, Icons.bar_chart_rounded, 2, "Stats"),
//             _bottomIcon(context, Icons.settings_rounded, 3, "Settings"),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _bottomIcon(
//       BuildContext context, IconData icon, int index, String label) {
//     final isActive = currentIndex == index;
//     return GestureDetector(
//       onTap: () => _onItemTapped(context, index),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const SizedBox(height: 8),
//           Icon(
//             icon,
//             color: isActive ? const Color(0xFF8EE5B5) : Colors.grey,
//             size: 26,
//           ),
//         ],
//       ),
//     );
//   }
// }

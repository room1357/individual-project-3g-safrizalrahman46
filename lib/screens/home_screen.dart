// import 'package:flutter/material.dart';
// import 'login_screen.dart';
// import 'expense_list_screen.dart';
// import 'profile_screen.dart'; // tambahkan import profile
// import '../services/expense_service.dart';
// import '../utils/currency_utils.dart';
// import '../utils/export_utils.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final svc = ExpenseService.instance;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Expense Manager'),
//         backgroundColor: Colors.blue,
//         leading: IconButton(
//           tooltip: 'Profile',
//           icon: const Icon(Icons.account_circle),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const ProfileScreen()),
//             );
//           },
//         ),
//         actions: [
//           IconButton(
//             tooltip: 'Logout',
//             onPressed: () {
//               // Logout: kembali ke Login dan hapus semua route sebelumnya
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (_) => const LoginScreen()),
//                 (route) => false,
//               );
//             },
//             icon: const Icon(Icons.logout),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header + Total
//             const Text(
//               'Dashboard',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Card(
//               elevation: 2,
//               child: ListTile(
//                 title: const Text('Total Pengeluaran'),
//                 subtitle: const Text('Semua kategori & bulan'),
//                 trailing: Text(
//                   rp(svc.totalAll),
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Grid menu
//             Expanded(
//               child: GridView.count(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 12,
//                 mainAxisSpacing: 12,
//                 children: [
//                   // 1) Expenses
//                   _buildDashboardCard(
//                     'Expenses',
//                     Icons.attach_money,
//                     Colors.green,
//                     () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const ExpenseListScreen(),
//                         ),
//                       );
//                     },
//                   ),

//                   // 2) Add Expense
//                   _buildDashboardCard(
//                     'Add Expense',
//                     Icons.add_circle,
//                     Colors.teal,
//                     () async {
//                       final ok = await Navigator.pushNamed(context, '/add');
//                       if (ok == true && context.mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Pengeluaran ditambahkan'),
//                           ),
//                         );
//                       }
//                     },
//                   ),

//                   // 3) Categories
//                   _buildDashboardCard(
//                     'Categories',
//                     Icons.category,
//                     Colors.indigo,
//                     () {
//                       Navigator.pushNamed(context, '/categories');
//                     },
//                   ),

//                   // 4) Statistics
//                   _buildDashboardCard(
//                     'Statistics',
//                     Icons.bar_chart,
//                     Colors.orange,
//                     () {
//                       Navigator.pushNamed(context, '/stats');
//                     },
//                   ),

//                   // 5) Export PDF
//                   _buildDashboardCard(
//                     'Export PDF',
//                     Icons.picture_as_pdf,
//                     Colors.red,
//                     () async {
//                       await ExportPdf.exportAll(filename: 'expenses.pdf');
//                       if (!context.mounted) return;
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('PDF diekspor. Silakan simpan/print.'),
//                         ),
//                       );
//                     },
//                   ),

//                   // 6) Setting
//                   _buildDashboardCard(
//                     'Setting',
//                     Icons.settings,
//                     Colors.purple,
//                     () {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Feature Setting coming soon!'),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDashboardCard(
//     String title,
//     IconData icon,
//     Color color,
//     VoidCallback? onTap,
//   ) {
//     return Card(
//       elevation: 4,
//       child: Builder(
//         builder: (context) => InkWell(
//           onTap: onTap ??
//               () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Feature $title coming soon!')),
//                 );
//               },
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(icon, size: 48, color: color),
//                 const SizedBox(height: 12),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'expense_list_screen.dart';
import 'profile_screen.dart';
import '../services/expense_service.dart';
import '../utils/currency_utils.dart';
import '../utils/export_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 1;
  final svc = ExpenseService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),

      // === AppBar ===
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFF9AE6B4),
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
        ],
      ),

      // === Body ===
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Summary Cards
            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    title: "Total Expense",
                    value: rp(svc.totalAll),
                    color: Colors.white,
                    textColor: Colors.black87,
                    icon: Icons.credit_card_outlined,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _summaryCard(
                    title: "Categories",
                    value: rp(svc.totalAll),
                    color: const Color(0xFFD9FBE3),
                    textColor: const Color(0xFF166534),
                    icon: Icons.category_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // 🔹 Tab Menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _tabButton(0, "+ Categories"),
                _tabButton(1, "Statistic"),
                _tabButton(2, "Export"),
              ],
            ),

            const SizedBox(height: 10),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: selectedTab == i ? 30 : 10,
                    height: 3,
                    decoration: BoxDecoration(
                      color: selectedTab == i
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Latest Expense',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Dummy List
            Column(
              children: List.generate(5, (index) {
                return _expenseTile(
                  title: 'Food',
                  date: '20 Oktober 2025',
                  source: 'GoFood',
                  amount: '- 25.000',
                );
              }),
            ),
          ],
        ),
      ),

      // === Floating Button ===
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x806EE7B7),
              blurRadius: 25,
              spreadRadius: 6,
            ),
          ],
        ),
        child: FloatingActionButton(
          elevation: 4,
          onPressed: () async {
            final ok = await Navigator.pushNamed(context, '/add');
            if (ok == true && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pengeluaran ditambahkan')),
              );
              setState(() {});
            }
          },
          backgroundColor: const Color(0xFF22C55E),
          child: const Icon(Icons.add, size: 36),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // === Bottom Navigation Bar ===
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 15,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomAppBar(
          elevation: 0,
          color: Colors.transparent,
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _bottomIcon(Icons.home_rounded, 0),
                _bottomIcon(Icons.category_outlined, 1),
                const SizedBox(width: 40),
                _bottomIcon(Icons.bar_chart_rounded, 2),
                _bottomIcon(Icons.settings_rounded, 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // === Summary Card ===
  Widget _summaryCard({
    required String title,
    required String value,
    required Color color,
    required Color textColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 26),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  // === Tab Button ===
  Widget _tabButton(int index, String text) {
    final bool isActive = selectedTab == index;
    return GestureDetector(
      onTap: () async {
        setState(() => selectedTab = index);
        if (index == 0) {
          Navigator.pushNamed(context, '/categories');
        } else if (index == 1) {
          Navigator.pushNamed(context, '/stats');
        } else if (index == 2) {
          await ExportPdf.exportAll(filename: 'expenses.pdf');
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF diekspor. Silakan simpan/print.')),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFDCFCE7) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? const Color(0xFF22C55E) : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? const Color(0xFF15803D) : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // === Expense Item ===
  Widget _expenseTile({
    required String title,
    required String date,
    required String source,
    required String amount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fastfood_outlined,
                    color: Colors.grey, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    date,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                source,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // === Bottom Bar Icon ===
  Widget _bottomIcon(IconData icon, int index) {
    final isActive = selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() => selectedTab = index);
        if (index == 0) {
          Navigator.pushNamed(context, '/');
        } else if (index == 1) {
          Navigator.pushNamed(context, '/categories');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/stats');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Settings coming soon!')),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFDCFCE7) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? const Color(0xFF22C55E) : Colors.grey.shade400,
          size: isActive ? 28 : 26,
        ),
      ),
    );
  }
}

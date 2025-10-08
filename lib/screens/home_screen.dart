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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int selectedTab = 0;
  int selectedBottomNav = 0;
  final svc = ExpenseService.instance;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      resizeToAvoidBottomInset: true,

      // === AppBar ===
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
            onPressed: () {},
          ),
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF9AE6B4),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 26),
              ),
            ),
          ),
        ],
      ),

      // === Body ===
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // 🔹 Summary Cards
            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    title: "Total Expense",
                    value: rp(svc.totalAll),
                    color: Colors.white,
                    textColor: Colors.black,
                    icon: Icons.credit_card_rounded,
                    iconBg: const Color(0xFFF5F5F5),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _summaryCard(
                    title: "Categories",
                    value: rp(svc.totalAll),
                    color: const Color(0xFF8EE5B5),
                    textColor: Colors.white,
                    icon: Icons.credit_card_rounded,
                    iconBg: Colors.white.withOpacity(0.25),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 🔹 Tab Menu
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _tabButton(0, "+ Categories"),
                      const SizedBox(width: 10),
                      _tabButton(1, "Statistic"),
                      const SizedBox(width: 10),
                      _tabButton(2, "Export"),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: selectedTab == i ? 32 : 10,
                        height: 3,
                        decoration: BoxDecoration(
                          color: selectedTab == i
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFDEDEDE),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 🔹 Header Latest Expense
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'latest Expense',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.more_horiz,
                    color: Colors.black,
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 🔹 Expense List
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
            const SizedBox(height: 100),
          ],
        ),
      ),

      // === Floating Button ===
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _fabController,
          curve: Curves.elasticOut,
        ),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF6EE7B7),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6EE7B7).withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(32),
              onTap: () async {
                _fabController.reverse().then((_) => _fabController.forward());
                final ok = await Navigator.pushNamed(context, '/add');
                if (ok == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Pengeluaran ditambahkan'),
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height - 150,
                        left: 20,
                        right: 20,
                      ),
                    ),
                  );
                  setState(() {});
                }
              },
              child: const Center(
                child: Icon(Icons.add, size: 32, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // === Bottom Navigation Bar ===
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomAppBar(
          elevation: 0,
          color: Colors.transparent,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _bottomIcon(Icons.home_rounded, 0),
                _bottomIcon(Icons.grid_view_rounded, 1),
                const SizedBox(width: 60),
                _bottomIcon(Icons.notifications_outlined, 2),
                _bottomIcon(Icons.settings_outlined, 3),
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
    required Color iconBg,
  }) {
    return Container(
      height: 170,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color == Colors.white
                ? Colors.black.withOpacity(0.06)
                : const Color(0xFF8EE5B5).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: textColor, size: 26),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // === Tab Button ===
  Widget _tabButton(int index, String text) {
    final bool isActive = selectedTab == index;
    return Expanded(
      child: GestureDetector(
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
              SnackBar(
                content: const Text('PDF diekspor. Silakan simpan/print.'),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height - 150,
                  left: 20,
                  right: 20,
                ),
              ),
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF6EE7B7) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive ? const Color(0xFF6EE7B7) : const Color(0xFFE8E8E8),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: Colors.grey.shade400,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                source,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // === Bottom Bar Icon ===
  Widget _bottomIcon(IconData icon, int index) {
    final isActive = selectedBottomNav == index;
    return GestureDetector(
      onTap: () {
        setState(() => selectedBottomNav = index);
        if (index == 0) {
          Navigator.pushNamed(context, '/');
        } else if (index == 1) {
          Navigator.pushNamed(context, '/categories');
        } else if (index == 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Notifications coming soon!'),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 150,
                left: 20,
                right: 20,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Settings coming soon!'),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 150,
                left: 20,
                right: 20,
              ),
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6EE7B7) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey.shade400,
          size: 26,
        ),
      ),
    );
  }
}
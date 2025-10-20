import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/expense_service.dart';
import '../utils/currency_utils.dart';
import '../utils/export_utils.dart';
import '../models/expense.dart';
import 'profile_screen.dart';
import '../widgets/custom_bottom_nav.dart';
import 'expense_list_screen.dart'; // ✅ tambahkan import ini
import 'export_data_screen.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int selectedTab = 0;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ExpenseService.instance.loadInitialData();
    });
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
    final svc = Provider.of<ExpenseService>(context);
    final expenses = svc.expenses;
    final categories = svc.categories;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      // === AppBar ===
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 70,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
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
            // 🔹 Summary Cards
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          debugPrint("✅ Total Expense tapped");
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ExpenseListScreen(),
                            ),
                          );
                        },
                        child: _summaryCard(
                          title: "Total Expense",
                          value: rp(svc.totalAll),
                          color: Colors.white,
                          textColor: Colors.black,
                          icon: Icons.credit_card_rounded,
                          iconBg: const Color(0xFFF5F5F5),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _summaryCard(
                    title: "Categories",
                    value: categories.length.toString(),
                    color: const Color(0xFF8EE5B5),
                    textColor: Colors.white,
                    icon: Icons.category_outlined,
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
                      _tabButton(0, "Categories"),
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
                          color:
                              selectedTab == i
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
              children: const [
                Text(
                  'Latest Expense',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                Icon(Icons.more_horiz, color: Colors.black, size: 28),
              ],
            ),
            const SizedBox(height: 18),

            // 🔹 Expense List
            if (expenses.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: const [
                      Icon(Icons.hourglass_empty, size: 60, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Belum ada pengeluaran',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children:
                    expenses.reversed
                        .take(5)
                        .map(
                          (e) => _expenseTile(
                            title: e.category,
                            date:
                                "${e.date.day} ${_monthName(e.date.month)} ${e.date.year}",
                            source: e.description ?? '',
                            amount: "- ${rp(e.amount)}",
                          ),
                        )
                        .toList(),
              ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      // === Floating Add Button ===
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _fabController,
          curve: Curves.elasticOut,
        ),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF6EE7B7),
          elevation: 8,
          onPressed: () async {
            _fabController.reverse().then((_) => _fabController.forward());
            final ok = await Navigator.pushNamed(context, '/add');
            if (ok == true && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengeluaran ditambahkan'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              setState(() {});
            }
          },
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ✅ Gunakan CustomBottomNav
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }

  // === Reusable Widgets ===
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
            color:
                color == Colors.white
                    ? Colors.black.withOpacity(0.06)
                    : const Color(0xFF8EE5B5).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabButton(int index, String text) {
    final isActive = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          setState(() => selectedTab = index);
          if (index == 0) {
            Navigator.pushNamed(context, '/categories');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/stats');
          } else if (index == 2) {
           Navigator.pushNamed(context, '/ExportScreen');
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
              color:
                  isActive ? const Color(0xFF6EE7B7) : const Color(0xFFE8E8E8),
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
            child: const Icon(
              Icons.receipt_long_outlined,
              color: Colors.grey,
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
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
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
                ),
              ),
              const SizedBox(height: 3),
              Text(
                source,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[m - 1];
  }
}

// // import 'package:flutter/material.dart';
// // import 'login_screen.dart';
// // import 'expense_list_screen.dart';
// // import 'profile_screen.dart'; // tambahkan import profile
// // import '../services/expense_service.dart';
// // import '../utils/currency_utils.dart';
// // import '../utils/export_utils.dart';

// // class HomeScreen extends StatelessWidget {
// //   const HomeScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     final svc = ExpenseService.instance;

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Expense Manager'),
// //         backgroundColor: Colors.blue,
// //         leading: IconButton(
// //           tooltip: 'Profile',
// //           icon: const Icon(Icons.account_circle),
// //           onPressed: () {
// //             Navigator.push(
// //               context,
// //               MaterialPageRoute(builder: (_) => const ProfileScreen()),
// //             );
// //           },
// //         ),
// //         actions: [
// //           IconButton(
// //             tooltip: 'Logout',
// //             onPressed: () {
// //               // Logout: kembali ke Login dan hapus semua route sebelumnya
// //               Navigator.pushAndRemoveUntil(
// //                 context,
// //                 MaterialPageRoute(builder: (_) => const LoginScreen()),
// //                 (route) => false,
// //               );
// //             },
// //             icon: const Icon(Icons.logout),
// //           ),
// //         ],
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // Header + Total
// //             const Text(
// //               'Dashboard',
// //               style: TextStyle(
// //                 fontSize: 24,
// //                 fontWeight: FontWeight.bold,
// //                 color: Colors.blue,
// //               ),
// //             ),
// //             const SizedBox(height: 12),
// //             Card(
// //               elevation: 2,
// //               child: ListTile(
// //                 title: const Text('Total Pengeluaran'),
// //                 subtitle: const Text('Semua kategori & bulan'),
// //                 trailing: Text(
// //                   rp(svc.totalAll),
// //                   style: const TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 16,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             const SizedBox(height: 20),

// //             // Grid menu
// //             Expanded(
// //               child: GridView.count(
// //                 crossAxisCount: 2,
// //                 crossAxisSpacing: 12,
// //                 mainAxisSpacing: 12,
// //                 children: [
// //                   // 1) Expenses
// //                   _buildDashboardCard(
// //                     'Expenses',
// //                     Icons.attach_money,
// //                     Colors.green,
// //                     () {
// //                       Navigator.push(
// //                         context,
// //                         MaterialPageRoute(
// //                           builder: (_) => const ExpenseListScreen(),
// //                         ),
// //                       );
// //                     },
// //                   ),

// //                   // 2) Add Expense
// //                   _buildDashboardCard(
// //                     'Add Expense',
// //                     Icons.add_circle,
// //                     Colors.teal,
// //                     () async {
// //                       final ok = await Navigator.pushNamed(context, '/add');
// //                       if (ok == true && context.mounted) {
// //                         ScaffoldMessenger.of(context).showSnackBar(
// //                           const SnackBar(
// //                             content: Text('Pengeluaran ditambahkan'),
// //                           ),
// //                         );
// //                       }
// //                     },
// //                   ),

// //                   // 3) Categories
// //                   _buildDashboardCard(
// //                     'Categories',
// //                     Icons.category,
// //                     Colors.indigo,
// //                     () {
// //                       Navigator.pushNamed(context, '/categories');
// //                     },
// //                   ),

// //                   // 4) Statistics
// //                   _buildDashboardCard(
// //                     'Statistics',
// //                     Icons.bar_chart,
// //                     Colors.orange,
// //                     () {
// //                       Navigator.pushNamed(context, '/stats');
// //                     },
// //                   ),

// //                   // 5) Export PDF
// //                   _buildDashboardCard(
// //                     'Export PDF',
// //                     Icons.picture_as_pdf,
// //                     Colors.red,
// //                     () async {
// //                       await ExportPdf.exportAll(filename: 'expenses.pdf');
// //                       if (!context.mounted) return;
// //                       ScaffoldMessenger.of(context).showSnackBar(
// //                         const SnackBar(
// //                           content: Text('PDF diekspor. Silakan simpan/print.'),
// //                         ),
// //                       );
// //                     },
// //                   ),

// //                   // 6) Setting
// //                   _buildDashboardCard(
// //                     'Setting',
// //                     Icons.settings,
// //                     Colors.purple,
// //                     () {
// //                       ScaffoldMessenger.of(context).showSnackBar(
// //                         const SnackBar(
// //                           content: Text('Feature Setting coming soon!'),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildDashboardCard(
// //     String title,
// //     IconData icon,
// //     Color color,
// //     VoidCallback? onTap,
// //   ) {
// //     return Card(
// //       elevation: 4,
// //       child: Builder(
// //         builder: (context) => InkWell(
// //           onTap: onTap ??
// //               () {
// //                 ScaffoldMessenger.of(context).showSnackBar(
// //                   SnackBar(content: Text('Feature $title coming soon!')),
// //                 );
// //               },
// //           child: Container(
// //             padding: const EdgeInsets.all(16),
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Icon(icon, size: 48, color: color),
// //                 const SizedBox(height: 12),
// //                 Text(
// //                   title,
// //                   style: const TextStyle(
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../services/expense_service.dart';
// import '../utils/currency_utils.dart';
// import '../utils/export_utils.dart';
// import '../models/expense.dart';
// import 'profile_screen.dart';
// import '../widgets/custom_bottom_nav.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
//   int selectedTab = 0;
//   late AnimationController _fabController;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ExpenseService.instance.loadInitialData();
//     });
//     _fabController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );
//     _fabController.forward();
//   }

//   @override
//   void dispose() {
//     _fabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final svc = Provider.of<ExpenseService>(context);
//     final expenses = svc.expenses;
//     final categories = svc.categories;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F7F7),

//       // === AppBar ===
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         toolbarHeight: 70,
//         title: const Text(
//           'Dashboard',
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.w700,
//             fontSize: 24,
//           ),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 20),
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const ProfileScreen()),
//                 );
//               },
//               child: Container(
//                 width: 45,
//                 height: 45,
//                 decoration: const BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Color(0xFF9AE6B4),
//                 ),
//                 child: const Icon(Icons.person, color: Colors.white, size: 26),
//               ),
//             ),
//           ),
//         ],
//       ),

//       // === Body ===
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 16),

//             // 🔹 Summary Cards
//             Row(
//               children: [
//                 Expanded(
//                   child: _summaryCard(
//                     title: "Total Expense",
//                     value: rp(svc.totalAll),
//                     color: Colors.white,
//                     textColor: Colors.black,
//                     icon: Icons.credit_card_rounded,
//                     iconBg: const Color(0xFFF5F5F5),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: _summaryCard(
//                     title: "Categories",
//                     value: categories.length.toString(),
//                     color: const Color(0xFF8EE5B5),
//                     textColor: Colors.white,
//                     icon: Icons.category_outlined,
//                     iconBg: Colors.white.withOpacity(0.25),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 24),

//             // 🔹 Tab Menu
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.03),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       _tabButton(0, "Categories"),
//                       const SizedBox(width: 10),
//                       _tabButton(1, "Statistic"),
//                       const SizedBox(width: 10),
//                       _tabButton(2, "Export"),
//                     ],
//                   ),
//                   const SizedBox(height: 14),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: List.generate(3, (i) {
//                       return AnimatedContainer(
//                         duration: const Duration(milliseconds: 300),
//                         curve: Curves.easeInOut,
//                         margin: const EdgeInsets.symmetric(horizontal: 3),
//                         width: selectedTab == i ? 32 : 10,
//                         height: 3,
//                         decoration: BoxDecoration(
//                           color: selectedTab == i
//                               ? const Color(0xFF22C55E)
//                               : const Color(0xFFDEDEDE),
//                           borderRadius: BorderRadius.circular(2),
//                         ),
//                       );
//                     }),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 28),

//             // 🔹 Header Latest Expense
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: const [
//                 Text(
//                   'Latest Expense',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 18,
//                     color: Colors.black,
//                   ),
//                 ),
//                 Icon(Icons.more_horiz, color: Colors.black, size: 28),
//               ],
//             ),
//             const SizedBox(height: 18),

//             // 🔹 Expense List
//             if (expenses.isEmpty)
//               Center(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 40),
//                   child: Column(
//                     children: const [
//                       Icon(Icons.hourglass_empty, size: 60, color: Colors.grey),
//                       SizedBox(height: 8),
//                       Text(
//                         'Belum ada pengeluaran',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             else
//               Column(
//                 children: expenses.reversed
//                     .take(5)
//                     .map((e) => _expenseTile(
//                           title: e.category,
//                           date:
//                               "${e.date.day} ${_monthName(e.date.month)} ${e.date.year}",
//                           source: e.description ?? '',
//                           amount: "- ${rp(e.amount)}",
//                         ))
//                     .toList(),
//               ),

//             const SizedBox(height: 100),
//           ],
//         ),
//       ),

//       // === Floating Add Button ===
//       floatingActionButton: ScaleTransition(
//         scale: CurvedAnimation(
//           parent: _fabController,
//           curve: Curves.elasticOut,
//         ),
//         child: FloatingActionButton(
//           backgroundColor: const Color(0xFF6EE7B7),
//           elevation: 8,
//           onPressed: () async {
//             _fabController.reverse().then((_) => _fabController.forward());
//             final ok = await Navigator.pushNamed(context, '/add');
//             if (ok == true && context.mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Pengeluaran ditambahkan'),
//                   behavior: SnackBarBehavior.floating,
//                 ),
//               );
//               setState(() {});
//             }
//           },
//           child: const Icon(Icons.add, size: 32, color: Colors.white),
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

//       // ✅ Gunakan CustomBottomNav
//       bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
//     );
//   }

//   // === Reusable Widgets ===
//   Widget _summaryCard({
//     required String title,
//     required String value,
//     required Color color,
//     required Color textColor,
//     required IconData icon,
//     required Color iconBg,
//   }) {
//     return Container(
//       height: 170,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: color == Colors.white
//                 ? Colors.black.withOpacity(0.06)
//                 : const Color(0xFF8EE5B5).withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               color: iconBg,
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Icon(icon, color: textColor, size: 26),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(title,
//                   style: TextStyle(
//                       color: textColor.withOpacity(0.9), fontSize: 13)),
//               const SizedBox(height: 6),
//               Text(value,
//                   style: TextStyle(
//                       color: textColor,
//                       fontSize: 22,
//                       fontWeight: FontWeight.w700)),
//             ],
//           )
//         ],
//       ),
//     );
//   }

//   Widget _tabButton(int index, String text) {
//     final isActive = selectedTab == index;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () async {
//           setState(() => selectedTab = index);
//           if (index == 0) {
//             Navigator.pushNamed(context, '/categories');
//           } else if (index == 1) {
//             Navigator.pushNamed(context, '/stats');
//           } else if (index == 2) {
//             await ExportPdf.exportAll(filename: 'expenses.pdf');
//             if (!context.mounted) return;
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('PDF berhasil diekspor!')),
//             );
//           }
//         },
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             color: isActive ? const Color(0xFF6EE7B7) : Colors.white,
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(
//               color: isActive
//                   ? const Color(0xFF6EE7B7)
//                   : const Color(0xFFE8E8E8),
//               width: 1,
//             ),
//           ),
//           child: Center(
//             child: Text(
//               text,
//               style: TextStyle(
//                 color: isActive ? Colors.white : Colors.black87,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 13,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _expenseTile({
//     required String title,
//     required String date,
//     required String source,
//     required String amount,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 18),
//       child: Row(
//         children: [
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               color: const Color(0xFFE8E8E8),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: const Icon(Icons.receipt_long_outlined,
//                 color: Colors.grey, size: 24),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title,
//                     style: const TextStyle(
//                         fontWeight: FontWeight.w600, fontSize: 15)),
//                 const SizedBox(height: 3),
//                 Text(date,
//                     style:
//                         TextStyle(color: Colors.grey.shade500, fontSize: 12)),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(amount,
//                   style: const TextStyle(
//                       fontWeight: FontWeight.w600, fontSize: 15)),
//               const SizedBox(height: 3),
//               Text(source,
//                   style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   String _monthName(int m) {
//     const months = [
//       'Januari',
//       'Februari',
//       'Maret',
//       'April',
//       'Mei',
//       'Juni',
//       'Juli',
//       'Agustus',
//       'September',
//       'Oktober',
//       'November',
//       'Desember'
//     ];
//     return months[m - 1];
//   }
// }

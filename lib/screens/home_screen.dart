import 'package:flutter/material.dart';
import 'package:pemrograman_mobile/screens/massage_screen.dart';
import 'package:provider/provider.dart';
import '../services/expense_service.dart';
import '../utils/currency_utils.dart';
import '../utils/export_utils.dart';
import '../models/expense.dart';
import 'profile_screen.dart';
import '../widgets/custom_bottom_nav.dart';
import 'expense_list_screen.dart';
import 'export_data_screen.dart';
import '../services/auth_service.dart';
import 'category_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';
import 'reminder_screen.dart';

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

    // ===== Filtered expenses bulan ini =====
    final now = DateTime.now();
    final filteredExpenses = expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .toList();

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

            // 🔹 Summary Cards - Row horizontal scroll
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardWrapper(
                    child: _summaryCard(
                      title: "Total Expense",
                      value: rp(svc.totalAll),
                      color: Colors.white,
                      textColor: Colors.black,
                      icon: Icons.credit_card_rounded,
                      iconBg: const Color(0xFFF5F5F5),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ExpenseListScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  _buildCardWrapper(
                    child: _summaryCard(
                      title: "Categories",
                      value: categories.length.toString(),
                      color: const Color(0xFF8EE5B5),
                      textColor: Colors.white,
                      icon: Icons.category_outlined,
                      iconBg: Colors.white.withOpacity(0.25),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CategoryScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  _buildCardWrapper(
                    child: _summaryCard(
                      title: "Monthly Budget",
                      value: rp(svc.monthlyBudget),
                      color: const Color(0xFFFFC107),
                      textColor: Colors.black,
                      icon: Icons.attach_money_outlined,
                      iconBg: Colors.white.withOpacity(0.25),
                    ),
                  ),
                  _buildCardWrapper(
                    child: _summaryCard(
                      title: "Statistics",
                      value: filteredExpenses.length.toString(),
                      color: const Color(0xFF4CAF50),
                      textColor: Colors.white,
                      icon: Icons.bar_chart_outlined,
                      iconBg: Colors.white.withOpacity(0.25),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const StatisticsScreen()),
                        );
                      },
                    ),
                  ),
                  _buildCardWrapper(
                    child: _summaryCard(
                      title: "Reminder & Setting",
                      value: "-",
                      color: const Color(0xFF2196F3),
                      textColor: Colors.white,
                      icon: Icons.settings_outlined,
                      iconBg: Colors.white.withOpacity(0.25),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ReminderScreen()),
                        );
                      },
                    ),
                  ),

                  _buildCardWrapper(
                child: _summaryCard(
                  title: "Massage",
                  value: "API Data", // Anda bisa ganti value ini
                  color: const Color(0xFFFFA726), // Warna oranye
                  textColor: Colors.white,
                  icon: Icons.message_outlined, // Ikon pesan
                  iconBg: Colors.white.withOpacity(0.25),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // Penting: Hapus 'const' karena MassageScreen
                        // adalah StatefulWidget
                        builder: (_) => MassageScreen(),
                      ),
                    );
                  },
                ),
              ),
                ],
                
              ),
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
                children: expenses.reversed
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

  // === Helper wrapper untuk scroll horizontal
  Widget _buildCardWrapper({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: SizedBox(width: 160, child: child),
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
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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

  static String _monthName(int m) {
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

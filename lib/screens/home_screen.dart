import 'package:flutter/material.dart';
import 'add_expense_screen.dart';
import 'category_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Manager"),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text("Dashboard Utama"),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Menu", style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ListTile(
              title: const Text("Tambah Pengeluaran"),
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AddExpenseScreen()));
              },
            ),
            ListTile(
              title: const Text("Kategori"),
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const CategoryScreen()));
              },
            ),
            ListTile(
              title: const Text("Statistik"),
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const StatisticsScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

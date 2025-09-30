import 'package:flutter/material.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/edit_expense_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/category_screen.dart';

// Services
import 'services/expense_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load data user + data expense dari SharedPreferences
  await AuthService.instance.loadCurrentUser();
  await ExpenseService.instance.loadInitialData();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      // Jika user sudah login -> langsung ke Home
      // Jika belum -> ke Login
      home: user != null ? const HomeScreen() : const LoginScreen(),

      // Named routes
      routes: {
        '/home': (_) => const HomeScreen(),
        '/add': (_) => const AddExpenseScreen(),
        '/stats': (_) => const StatisticsScreen(),
        '/categories': (_) => const CategoryScreen(),
      },

      // Route dinamis untuk Edit (butuh argumen id)
      onGenerateRoute: (settings) {
        if (settings.name == '/edit') {
          final id = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => EditExpenseScreen(expenseId: id),
          );
        }
        return null;
      },
    );
  }
}

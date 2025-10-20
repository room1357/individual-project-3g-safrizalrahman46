import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/edit_expense_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/category_screen.dart';
import 'screens/reminder_screen.dart';
import 'screens/export_data_screen.dart';

// Services
import 'services/expense_service.dart';
import 'services/auth_service.dart';
import 'services/reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Tambahkan dummy user jika belum ada
  await AuthService.instance.addDummyUsers();

  // 🔹 Load data user + expense
  await AuthService.instance.loadCurrentUser();
  await ExpenseService.instance.loadInitialData();
  await ReminderService.instance.loadReminders();

  runApp(
    MultiProvider(
      providers: [
        // ✅ ExpenseService sebagai ChangeNotifier
        ChangeNotifierProvider(create: (_) => ExpenseService.instance),

        // ✅ ReminderService juga ChangeNotifier
        ChangeNotifierProvider(create: (_) => ReminderService.instance),

        // ✅ AuthService bukan ChangeNotifier
        Provider(create: (_) => AuthService.instance),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),

      // 👇 SplashScreen sebagai tampilan awal
      home: user != null ? const HomeScreen() : const SplashScreen(),

      // 👇 Daftar route aplikasi (tidak termasuk '/edit' di sini)
      routes: {
        '/home': (_) => const HomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/add': (_) => const AddExpenseScreen(),
        '/stats': (_) => const StatisticsScreen(),
        '/categories': (_) => const CategoryScreen(),
        '/reminder': (_) => const ReminderScreen(),
        '/ExportScreen': (context) => const ExportDataScreen(), // ✅ pastikan ini ada

        // jangan daftarkan '/edit' di sini supaya onGenerateRoute menangani dan kita
        // tetap mengoper argumen lewat settings.arguments
      },

      // 👇 Route dinamis untuk halaman edit (dengan argumen lewat settings.arguments)
      onGenerateRoute: (settings) {
        if (settings.name == '/edit') {
          // Kita tidak memaksa konstruktor EditExpenseScreen menerima parameter.
          // EditExpenseScreen sebaiknya membaca argumen dengan:
          //   final args = ModalRoute.of(context)!.settings.arguments;
          // dan melakukan cast sesuai kebutuhan (Expense atau id).
          return MaterialPageRoute(
            builder: (context) => const EditExpenseScreen(),
            settings: settings, // pastikan argument tetap diteruskan
          );
        }

        // Jika route tidak dikenali, kembali null (atau bisa arahkan ke 404 screen)
        return null;
      },
    );
  }
}


// // import 'package:flutter/material.dart';

// // // Screens
// // import 'screens/login_screen.dart';
// // import 'screens/home_screen.dart';
// // import 'screens/add_expense_screen.dart';
// // import 'screens/edit_expense_screen.dart';
// // import 'screens/statistics_screen.dart';
// // import 'screens/category_screen.dart';
// // import 'screens/splash_screen.dart';


// // // Services
// // import 'services/expense_service.dart';
// // import 'services/auth_service.dart';

// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();

// //   // Load data user + data expense dari SharedPreferences
// //   await AuthService.instance.loadCurrentUser();
// //   await ExpenseService.instance.loadInitialData();

// //   runApp(const MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     final user = AuthService.instance.currentUser;

// //     return MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       title: 'Expense Application',
// //       theme: ThemeData(
// //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
// //         useMaterial3: true,
// //       ),

// //       // Jika user sudah login -> langsung ke Home
// //       // Jika belum -> ke Login
// //       home: user != null ? const HomeScreen() : const LoginScreen(),

// //       // Named routes
// //       routes: {
// //         '/home': (_) => const HomeScreen(),
// //         '/add': (_) => const AddExpenseScreen(),
// //         '/stats': (_) => const StatisticsScreen(),
// //         '/categories': (_) => const CategoryScreen(),
// //       },

// //       // Route dinamis untuk Edit (butuh argumen id)
// //       onGenerateRoute: (settings) {
// //         if (settings.name == '/edit') {
// //           final id = settings.arguments as String;
// //           return MaterialPageRoute(
// //             builder: (_) => EditExpenseScreen(expenseId: id),
// //           );
// //         }
// //         return null;
// //       },
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// // Screens
// import 'screens/splash_screen.dart';
// import 'screens/login_screen.dart';
// import 'screens/home_screen.dart';
// import 'screens/add_expense_screen.dart';
// import 'screens/edit_expense_screen.dart';
// import 'screens/statistics_screen.dart';
// import 'screens/category_screen.dart';
// import 'screens/reminder_screen.dart';

// // Services
// import 'services/expense_service.dart';
// import 'services/auth_service.dart';
// import 'services/reminder_service.dart'; 

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // 🔹 Tambahkan dummy user jika belum ada
//   await AuthService.instance.addDummyUsers();

//   // 🔹 Load data user + expense
//   await AuthService.instance.loadCurrentUser();
//   await ExpenseService.instance.loadInitialData();

//   await ReminderService.instance.loadReminders();


//   runApp(
//     MultiProvider(
//       providers: [
//         // ✅ ExpenseService adalah ChangeNotifier
//         ChangeNotifierProvider(create: (_) => ExpenseService.instance),

//          // ✅ ReminderService juga ChangeNotifier
//         ChangeNotifierProvider(create: (_) => ReminderService.instance),

//         // ✅ AuthService bukan ChangeNotifier → Provider biasa
//         Provider(create: (_) => AuthService.instance),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authService = Provider.of<AuthService>(context);
//     final user = authService.currentUser;

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Expense Application',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
//         useMaterial3: true,
//       ),

//       // 👇 SplashScreen sebagai tampilan awal
//       home: user != null ? const HomeScreen() : const SplashScreen(),

//       // 👇 Daftar route aplikasi
//       routes: {
//         '/home': (_) => const HomeScreen(),
//         '/login': (_) => const LoginScreen(),
//         '/add': (_) => const AddExpenseScreen(),
//         '/stats': (_) => const StatisticsScreen(),
//         '/categories': (_) => const CategoryScreen(),
//         '/reminder': (_) => const ReminderScreen()
        
//       },

//       // 👇 Route dinamis untuk halaman edit
//       onGenerateRoute: (settings) {
//         if (settings.name == '/edit') {
//           final id = settings.arguments as String;
//           return MaterialPageRoute(
//             builder: (_) => EditExpenseScreen(expenseId: id),
//           );
//         }
//         return null;
//       },
//     );
//   }
// }


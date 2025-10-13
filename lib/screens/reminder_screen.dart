import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/reminder_service.dart';
import '../models/reminder.dart';
import 'add_reminder_screen.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ReminderService.instance.loadReminders();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: ReminderService.instance,
      child: Consumer<ReminderService>(
        builder: (context, reminderService, _) {
          final reminders = reminderService.reminders;

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text(
                'Reminder',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: const Icon(Icons.person, color: Colors.black54),
                  ),
                )
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddReminderScreen()),
                );
                await ReminderService.instance.loadReminders();
                setState(() {});
              },
              child: const Icon(Icons.add, size: 36),
            ),
            body: reminders.isEmpty
                ? const Center(
                    child: Text(
                      'No reminders yet.\nTap + to add one!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reminders.length,
                    itemBuilder: (context, index) {
                      final r = reminders[index];
                      return _buildReminderCard(r);
                    },
                  ),
          );
        },
      ),
    );
  }

  // Tampilan kartu data asli tetap seperti desain
  Widget _buildReminderCard(Reminder r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F2FF),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                r.dateTime.toString().substring(0, 10),
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          Text(
            '+ IDR ${r.amount?.toStringAsFixed(0) ?? '0'}',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import '../services/reminder_service.dart';
// import '../models/reminder.dart';
// import 'add_reminder_screen.dart';

// class ReminderScreen extends StatefulWidget {
//   const ReminderScreen({super.key});

//   @override
//   State<ReminderScreen> createState() => _ReminderScreenState();
// }

// class _ReminderScreenState extends State<ReminderScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // ✅ Pastikan data dimuat pertama kali
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await ReminderService.instance.loadReminders();
//       setState(() {});
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ✅ Gunakan Consumer agar otomatis rebuild jika ReminderService.notifyListeners() terpanggil
//     return ChangeNotifierProvider.value(
//       value: ReminderService.instance,
//       child: Consumer<ReminderService>(
//         builder: (context, reminderService, _) {
//           final reminders = reminderService.reminders;

//           return Scaffold(
//             backgroundColor: const Color(0xFFF9FFF7),
//             appBar: AppBar(
//               title: const Text(
//                 'Reminders',
//                 style: TextStyle(fontWeight: FontWeight.w600),
//               ),
//               centerTitle: true,
//               backgroundColor: Colors.white,
//               foregroundColor: Colors.black87,
//               elevation: 0,
//             ),
//             floatingActionButton: FloatingActionButton(
//               backgroundColor: Colors.green,
//               onPressed: () async {
//                 // ✅ Buka halaman Add Reminder
//                 await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const AddReminderScreen(),
//                   ),
//                 );

//                 // ✅ Setelah kembali, reload data agar muncul
//                 await ReminderService.instance.loadReminders();
//                 setState(() {});
//               },
//               child: const Icon(Icons.add, size: 32),
//             ),
//             body: reminders.isEmpty
//                 ? const Center(
//                     child: Text(
//                       'No reminders yet.\nTap + to add one!',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.grey, fontSize: 16),
//                     ),
//                   )
//                 : ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: reminders.length,
//                     itemBuilder: (context, index) {
//                       final r = reminders[index];
//                       return _buildReminderCard(r);
//                     },
//                   ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildReminderCard(Reminder r) {
//     final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(r.dateTime);
//     final amount = r.amount != null ? r.amount!.toStringAsFixed(0) : '0';

//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 2,
//       color: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             // Left: icon / category color
//             Container(
//               width: 48,
//               height: 48,
//               decoration: BoxDecoration(
//                 color: Colors.green.shade100,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Icon(
//                 Icons.notifications_active_outlined,
//                 color: Colors.green,
//               ),
//             ),
//             const SizedBox(width: 12),

//             // Middle: info
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     r.title,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     r.category.isNotEmpty ? r.category : 'No category',
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: Colors.black54,
//                       height: 1.2,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     formattedDate,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       color: Colors.black45,
//                       height: 1.3,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Right: amount & delete
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   'IDR $amount',
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.green,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete_outline, color: Colors.red),
//                   onPressed: () async {
//                     await ReminderService.instance.deleteReminder(r.id);
//                     setState(() {});
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

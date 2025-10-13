import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/expense_service.dart';
import '../models/expense.dart';
import '../utils/currency_utils.dart';
import '../utils/category_style.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String activeFilter = 'Month';

  List<Expense> _getFilteredExpenses() {
    final allExpenses = ExpenseService.instance.expenses;
    final now = DateTime.now();
    switch (activeFilter) {
      case 'Day':
        return allExpenses
            .where((e) => DateUtils.isSameDay(e.date, now))
            .toList();
      case 'Week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return allExpenses
            .where(
              (e) =>
                  e.date.isAfter(
                    startOfWeek.subtract(const Duration(days: 1)),
                  ) &&
                  e.date.isBefore(endOfWeek.add(const Duration(days: 1))),
            )
            .toList();
      case 'Year':
        return allExpenses.where((e) => e.date.year == now.year).toList();
      case 'Month':
      default:
        return allExpenses
            .where((e) => e.date.year == now.year && e.date.month == now.month)
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = _getFilteredExpenses();
    filteredExpenses.sort((a, b) => a.date.compareTo(b.date));

    final grouped = groupBy(filteredExpenses, (Expense e) {
      switch (activeFilter) {
        case 'Year':
          return DateFormat.MMM().format(e.date);
        case 'Month':
          return DateFormat.d().format(e.date);
        case 'Week':
          return DateFormat.E().format(e.date);
        default:
          return DateFormat.Hm().format(e.date);
      }
    });

    final labels = grouped.keys.toList();
    final totals =
        grouped.values
            .map((list) => list.fold(0.0, (sum, e) => sum + e.amount))
            .toList();

    // === Siapkan data untuk Bar Chart ===
    final barGroups = List.generate(labels.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: totals[i],
            color: Colors.green,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Statistic',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 8),

          // ===== Filter Tabs =====
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                [
                  'Day',
                  'Week',
                  'Month',
                  'Year',
                ].map((f) => _buildFilterButton(f)).toList(),
          ),

          const SizedBox(height: 20),

          // ===== Bar Chart =====
          if (totals.isNotEmpty)
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: true, horizontalInterval: 20),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 20,
                        getTitlesWidget:
                            (value, meta) => Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value < 0 || value >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            labels[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      tooltipRoundedRadius: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${labels[group.x.toInt()]}\nRp ${rod.toY.toStringAsFixed(0)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                      getTooltipColor:
                          (group) =>
                              Colors.black87, // ✅ pengganti tooltipBgColor
                    ),
                  ),

                  barGroups: barGroups,
                ),
              ),
            ),

          const SizedBox(height: 24),

          // ===== Data Total per Grup =====
          if (totals.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 60),
              child: Center(
                child: Text(
                  'Tidak ada data untuk periode ini.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            Column(
              children: List.generate(labels.length, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        labels[i],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        rp(totals[i]),
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

          const SizedBox(height: 24),
          const Text(
            'Detail Pengeluaran',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),

          if (filteredExpenses.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  'Belum ada transaksi.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredExpenses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final expense = filteredExpenses[index];
                return _buildExpenseItem(expense);
              },
            ),

          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label) {
    final isActive = activeFilter == label;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: () => setState(() => activeFilter = label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? Colors.green[100] : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.green[800] : Colors.black54,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseItem(Expense expense) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: categoryColor(expense.category).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              categoryIcon(expense.category),
              color: categoryColor(expense.category),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('d MMM yyyy').format(expense.date),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '- ${rp(expense.amount)}',
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../services/expense_service.dart';
// import '../utils/currency_utils.dart';

// class StatisticsScreen extends StatefulWidget {
//   const StatisticsScreen({super.key});

//   @override
//   State<StatisticsScreen> createState() => _StatisticsScreenState();
// }

// class _StatisticsScreenState extends State<StatisticsScreen> {
//   String activeFilter = 'Day'; // default aktif "Day"

//   @override
//   Widget build(BuildContext context) {
//     final svc = ExpenseService.instance;
//     final perCat = svc.totalPerCategory;
//     final perMonth = svc.totalPerMonth;
//     final double maxMonth = perMonth.values.isEmpty
//         ? 0.0
//         : perMonth.values.reduce((a, b) => a > b ? a : b);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         centerTitle: true,
//         title: const Text(
//           'Statistic',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: Colors.black,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.share_outlined, color: Colors.black),
//             onPressed: () {},
//           ),
//           Padding(
//             padding: const EdgeInsets.only(right: 16),
//             child: CircleAvatar(
//               radius: 16,
//               backgroundColor: Colors.green[100],
//               child: const Icon(Icons.person, color: Colors.black54),
//             ),
//           ),
//         ],
//       ),

//       body: ListView(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         children: [
//           const SizedBox(height: 8),

//           // ===== Filter Tabs =====
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               for (final label in ['Day', 'Week', 'Month', 'Year'])
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 4),
//                   child: GestureDetector(
//                     onTap: () => setState(() => activeFilter = label),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 8,
//                       ),
//                       decoration: BoxDecoration(
//                         color: activeFilter == label
//                             ? Colors.green[100]
//                             : Colors.transparent,
//                         border: Border.all(
//                           color: activeFilter == label
//                               ? Colors.green
//                               : Colors.grey[300]!,
//                         ),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         label,
//                         style: TextStyle(
//                           color: activeFilter == label
//                               ? Colors.green[700]
//                               : Colors.black,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),

//           const SizedBox(height: 16),

//           // ===== Dropdown Expense =====
//           Align(
//             alignment: Alignment.centerRight,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey[300]!),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: const [
//                   Text('Expense', style: TextStyle(fontWeight: FontWeight.w500)),
//                   SizedBox(width: 6),
//                   Icon(Icons.arrow_drop_down),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 20),

//           // ===== Area Chart =====
//           SizedBox(
//             height: 200,
//             child: LineChart(
//               LineChartData(
//                 gridData: FlGridData(show: false),
//                 titlesData: FlTitlesData(
//                   leftTitles:
//                       const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   rightTitles:
//                       const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   topTitles:
//                       const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 22,
//                       getTitlesWidget: (value, meta) {
//                         const months = [
//                           'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//                           'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
//                         ];
//                         if (value < 1 || value > 12) return const SizedBox();
//                         return Text(
//                           months[value.toInt() - 1],
//                           style:
//                               const TextStyle(fontSize: 10, color: Colors.black54),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//                 borderData: FlBorderData(show: false),
//                 minX: 1,
//                 maxX: 12,
//                 minY: 0,
//                 lineBarsData: [
//                   LineChartBarData(
//                     isCurved: true,
//                     color: Colors.green,
//                     barWidth: 3,
//                     belowBarData: BarAreaData(
//                       show: true,
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.green.withOpacity(0.3),
//                           Colors.transparent
//                         ],
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                       ),
//                     ),
//                     dotData: FlDotData(show: false),
//                     spots: List.generate(12, (i) {
//                       final m = i + 1;
//                       final v = (perMonth[m] ?? 0).toDouble();
//                       final scaled = maxMonth == 0 ? 0 : v / maxMonth * 1000;
//                       return FlSpot(m.toDouble(), scaled.toDouble());
//                     }),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 24),

//           const Text(
//             'Top Spending',
//             style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
//           ),
//           const SizedBox(height: 8),

//           if (perCat.isEmpty)
//             const Text('No data available', style: TextStyle(color: Colors.grey))
//           else
//             Column(
//               children: perCat.entries.map((e) {
//                 return Container(
//                   margin: const EdgeInsets.symmetric(vertical: 6),
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.1),
//                         blurRadius: 4,
//                         offset: const Offset(0, 2),
//                       )
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 36,
//                         height: 36,
//                         decoration: BoxDecoration(
//                           color: Colors.grey[300],
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(e.key,
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.w500)),
//                             const SizedBox(height: 2),
//                             Text('20 Oktober 2025',
//                                 style: TextStyle(
//                                     fontSize: 12, color: Colors.grey[600])),
//                           ],
//                         ),
//                       ),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text('- ${rp(e.value)}',
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.black)),
//                           const Text('GoFood',
//                               style:
//                                   TextStyle(fontSize: 12, color: Colors.grey)),
//                         ],
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//           const SizedBox(height: 80),
//         ],
//       ),
//     );
//   }
// }

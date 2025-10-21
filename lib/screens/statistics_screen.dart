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

  List<FlSpot> _getLineSpots(List<Expense> expenses) {
    final grouped = groupBy(expenses, (Expense e) {
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

    final totals =
        grouped.values
            .map((list) => list.fold(0.0, (sum, e) => sum + e.amount))
            .toList();

    return List.generate(totals.length, (i) => FlSpot(i.toDouble(), totals[i]));
  }

  Widget _bottomTitleWidgets(
    double value,
    List<String> labels,
    double chartWidth,
  ) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.green,
      fontSize: 12 * chartWidth / 500,
    );
    if (value < 0 || value >= labels.length) return const SizedBox.shrink();
    return Text(labels[value.toInt()], style: style);
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

    final spots = _getLineSpots(filteredExpenses);

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
          if (totals.isNotEmpty)
            SizedBox(
              height: 250,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return LineChart(
                    LineChartData(
                      minY: 0,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [Colors.green, Colors.lightGreen],
                          ),
                          barWidth: 4,
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.withOpacity(0.3),
                                Colors.lightGreen.withOpacity(0.3),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval:
                                totals.isNotEmpty
                                    ? totals.reduce((a, b) => a > b ? a : b) / 5
                                    : 20,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget:
                                (value, _) => _bottomTitleWidgets(
                                  value,
                                  labels,
                                  constraints.maxWidth,
                                ),
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval:
                            totals.isNotEmpty
                                ? totals.reduce((a, b) => a > b ? a : b) / 5
                                : 20,
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (spots) {
                            return spots.map((spot) {
                              return LineTooltipItem(
                                'Rp ${spot.y.toStringAsFixed(0)}',
                                const TextStyle(
                                  color: Colors.white, // teks putih
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 24),
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

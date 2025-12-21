/// Finance Dashboard Screen
/// 
/// Dashboard with summary cards and trend charts.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../providers/finance_provider.dart';

class FinanceDashboardScreen extends ConsumerWidget {
  const FinanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(financeSummaryProvider);
    final trendAsync = ref.watch(monthlyTrendProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Keuangan'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(financeSummaryProvider);
          ref.invalidate(monthlyTrendProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              summaryAsync.when(
                loading: () => const _LoadingCards(),
                error: (e, _) => Text('Error: $e'),
                data: (summary) => _SummaryCards(summary: summary),
              ),
              const SizedBox(height: 24),
              
              // Trend Chart
              const Text(
                'Trend 6 Bulan Terakhir',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              trendAsync.when(
                loading: () => const SizedBox(
                  height: 250,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text('Error: $e'),
                data: (trend) => _TrendChart(data: trend),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingCards extends StatelessWidget {
  const _LoadingCards();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Card(child: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())))),
        SizedBox(width: 8),
        Expanded(child: Card(child: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())))),
      ],
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final Map<String, double> summary;

  const _SummaryCards({required this.summary});

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final income = summary['income'] ?? 0;
    final expense = summary['expense'] ?? 0;
    final balance = summary['balance'] ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Pemasukan',
                value: _formatCurrency(income),
                icon: Icons.arrow_upward,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Pengeluaran',
                value: _formatCurrency(expense),
                icon: Icons.arrow_downward,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          title: 'Saldo',
          value: _formatCurrency(balance),
          icon: Icons.account_balance_wallet,
          color: balance >= 0 ? Colors.blue : Colors.orange,
          fullWidth: true,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: fullWidth ? 20 : 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  final List<MonthlyTrendData> data;

  const _TrendChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Belum ada data')),
      );
    }

    final maxY = data.fold<double>(0, (max, d) {
      final higher = d.income > d.expense ? d.income : d.expense;
      return higher > max ? higher : max;
    });

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY * 1.2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final d = data[groupIndex];
                final value = rodIndex == 0 ? d.income : d.expense;
                final label = rodIndex == 0 ? 'Pemasukan' : 'Pengeluaran';
                return BarTooltipItem(
                  '$label\n${NumberFormat.compact(locale: "id").format(value)}',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(data[index].month, style: const TextStyle(fontSize: 10)),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  return Text(
                    NumberFormat.compact(locale: 'id').format(value),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: data.asMap().entries.map((entry) {
            final index = entry.key;
            final d = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: d.income,
                  color: Colors.green,
                  width: 12,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                BarChartRodData(
                  toY: d.expense,
                  color: Colors.red,
                  width: 12,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

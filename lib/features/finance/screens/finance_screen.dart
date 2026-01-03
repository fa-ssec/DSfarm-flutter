/// Finance Screen - Redesigned to match modern dashboard reference
/// 4 Summary Cards + Chart + Expense Allocation + Recent Transactions

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/widgets/dashboard_shell.dart';
import '../../../models/finance.dart';
import '../../../providers/finance_provider.dart';
import '../../../providers/farm_provider.dart';
import '../../../services/finance_export_service.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  String _activePreset = '6M';
  String _searchQuery = '';
  String _categoryFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final txAsync = ref.watch(financeNotifierProvider);
    final trendAsync = ref.watch(monthlyTrendProvider);
    final isLargeScreen = MediaQuery.of(context).size.width > 900;

    return DashboardShell(
      selectedIndex: 3, // Keuangan (index updated after breeding removal)
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(financeNotifierProvider);
          ref.invalidate(monthlyTrendProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Header
            Row(
              children: [
                Text('Keuangan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                const Spacer(),
                // Export Button
                PopupMenuButton<String>(
                  icon: const Icon(Icons.file_download_outlined),
                  tooltip: 'Export Laporan',
                  onSelected: (value) => _handleExport(value, txAsync),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'pdf', child: Row(children: [Icon(Icons.picture_as_pdf, color: Colors.red), SizedBox(width: 8), Text('Export PDF')])),
                    const PopupMenuItem(value: 'excel', child: Row(children: [Icon(Icons.table_chart, color: Colors.green), SizedBox(width: 8), Text('Export Excel')])),
                  ],
                ),
                // Delete all button
                IconButton(
                  icon: const Icon(Icons.delete_sweep, color: Colors.red),
                  tooltip: 'Hapus Semua Transaksi',
                  onPressed: () => _confirmDeleteAll(),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  heroTag: 'addFinance',
                  onPressed: () => _showAddSheet(),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ═══════════════════════════════════════════
            // 4 SUMMARY CARDS
            // ═══════════════════════════════════════════
            txAsync.when(
              loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('Error: $e'),
              data: (transactions) {
                // Current month data
                final now = DateTime.now();
                final currentMonthStart = DateTime(now.year, now.month, 1);
                final lastMonthStart = DateTime(now.year, now.month - 1, 1);
                
                // Filter transactions by month
                final currentMonthTx = transactions.where((t) => 
                    t.transactionDate.isAfter(currentMonthStart.subtract(const Duration(days: 1))));
                final lastMonthTx = transactions.where((t) => 
                    t.transactionDate.isAfter(lastMonthStart.subtract(const Duration(days: 1))) &&
                    t.transactionDate.isBefore(currentMonthStart));
                
                // Calculate current month totals
                final income = transactions.where((t) => t.isIncome).fold<double>(0, (s, t) => s + t.amount);
                final expense = transactions.where((t) => !t.isIncome).fold<double>(0, (s, t) => s + t.amount);
                final profit = income - expense;
                final totalAssets = income;
                
                // Calculate last month totals
                final lastIncome = lastMonthTx.where((t) => t.isIncome).fold<double>(0, (s, t) => s + t.amount);
                final lastExpense = lastMonthTx.where((t) => !t.isIncome).fold<double>(0, (s, t) => s + t.amount);
                final lastProfit = lastIncome - lastExpense;
                final lastAssets = lastIncome;
                
                // Current month only
                final currIncome = currentMonthTx.where((t) => t.isIncome).fold<double>(0, (s, t) => s + t.amount);
                final currExpense = currentMonthTx.where((t) => !t.isIncome).fold<double>(0, (s, t) => s + t.amount);
                
                // Calculate trends (percentage change)
                double calcTrend(double current, double previous) {
                  if (previous == 0) return current > 0 ? 100.0 : 0.0;
                  return ((current - previous) / previous) * 100;
                }
                
                final assetTrend = calcTrend(currIncome, lastIncome);
                final incomeTrend = calcTrend(currIncome, lastIncome);
                final expenseTrend = calcTrend(currExpense, lastExpense);
                final profitTrend = calcTrend(currIncome - currExpense, lastProfit);
                
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _SummaryCard(
                      title: 'TOTAL ASET',
                      value: totalAssets,
                      trend: assetTrend,
                      icon: Icons.account_balance_wallet_rounded,
                      iconColor: const Color(0xFF3B82F6),
                    ),
                    _SummaryCard(
                      title: 'TOTAL PEMASUKAN',
                      value: income,
                      trend: incomeTrend,
                      icon: Icons.trending_up_rounded,
                      iconColor: const Color(0xFF10B981),
                    ),
                    _SummaryCard(
                      title: 'TOTAL PENGELUARAN',
                      value: expense,
                      trend: expenseTrend,
                      icon: Icons.trending_down_rounded,
                      iconColor: const Color(0xFFEF4444),
                    ),
                    _SummaryCard(
                      title: 'LABA BERSIH',
                      value: profit,
                      trend: profitTrend,
                      icon: Icons.account_balance_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      isPremium: true,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // ═══════════════════════════════════════════
            // MIDDLE ROW: Chart + Expense Allocation
            // ═══════════════════════════════════════════
            isLargeScreen
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Financial Trend Chart (larger)
                      Expanded(
                        flex: 2,
                        child: _buildTrendChartCard(trendAsync),
                      ),
                      const SizedBox(width: 16),
                      // Expense Allocation + Scheduled Payments
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            _buildExpenseAllocationCard(txAsync),
                            const SizedBox(height: 16),
                            _buildScheduledPaymentsCard(),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildTrendChartCard(trendAsync),
                      const SizedBox(height: 16),
                      _buildExpenseAllocationCard(txAsync),
                      const SizedBox(height: 16),
                      _buildScheduledPaymentsCard(),
                    ],
                  ),
            const SizedBox(height: 24),

            // ═══════════════════════════════════════════
            // RECENT TRANSACTIONS
            // ═══════════════════════════════════════════
            txAsync.when(
              loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('Error: $e'),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return _buildEmptyTransactions();
                }
                
                // Filter transactions safely using for loop
                final List<FinanceTransaction> filtered = [];
                for (final tx in transactions) {
                  bool include = true;
                  
                  // Search filter
                  if (_searchQuery.isNotEmpty) {
                    final query = _searchQuery.toLowerCase();
                    final cat = tx.categoryName ?? '';
                    final desc = tx.description ?? '';
                    if (!cat.toLowerCase().contains(query) && 
                        !desc.toLowerCase().contains(query)) {
                      include = false;
                    }
                  }
                  
                  // Category filter
                  if (include && _categoryFilter == 'income' && !tx.isIncome) {
                    include = false;
                  }
                  if (include && _categoryFilter == 'expense' && tx.isIncome) {
                    include = false;
                  }
                  
                  if (include) filtered.add(tx);
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search & Filter Bar
                    _buildSearchFilterBar(transactions),
                    const SizedBox(height: 16),
                    // Transactions Table
                    if (filtered.isEmpty)
                      _buildEmptySearch()
                    else
                      _buildTransactionsTable(filtered),
                  ],
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TREND CHART CARD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTrendChartCard(AsyncValue<List<MonthlyTrendData>> trendAsync) {
    final txAsync = ref.watch(financeNotifierProvider);
    
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tren Keuangan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      _activePreset == '1M' ? 'Data Harian (30 hari terakhir)' : 'Pemasukan vs Pengeluaran', 
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                // Period Toggle
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: ['1M', '6M', '1Y'].map((p) => _periodChip(p)).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: _activePreset == '1M'
                  // For 1M: Use daily data from transactions
                  ? txAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                      data: (transactions) {
                        final dailyData = _buildDailyTrendData(transactions);
                        if (dailyData.isEmpty) {
                          return Center(child: Text('Belum ada data', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)));
                        }
                        return _buildDailyLineChart(dailyData);
                      },
                    )
                  // For 6M, 1Y: Use monthly data
                  : trendAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                      data: (data) {
                        final filtered = _filterTrendData(data);
                        if (filtered.isEmpty) {
                          return Center(child: Text('Belum ada data', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)));
                        }
                        return _buildLineChart(filtered);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _periodChip(String label) {
    final active = _activePreset == label;
    return GestureDetector(
      onTap: () => setState(() => _activePreset = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            color: active ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  List<MonthlyTrendData> _filterTrendData(List<MonthlyTrendData> data) {
    switch (_activePreset) {
      case '1M': return data.length > 1 ? data.sublist(data.length - 1) : data;
      case '6M': return data.length > 6 ? data.sublist(data.length - 6) : data;
      case '1Y': return data;
      default: return data;
    }
  }

  /// Build daily trend data from transactions for 1M view
  List<_DailyTrendData> _buildDailyTrendData(List<FinanceTransaction> transactions) {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 30));
    
    // Create map for all days in the last 30 days
    final Map<String, _DailyTrendData> dailyMap = {};
    for (int i = 0; i <= 30; i++) {
      final date = startDate.add(Duration(days: i));
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final label = '${date.day}';
      dailyMap[key] = _DailyTrendData(day: label, date: date, income: 0, expense: 0);
    }
    
    // Aggregate transactions by day
    for (final tx in transactions) {
      final txDate = tx.transactionDate;
      if (txDate.isBefore(startDate)) continue;
      
      final key = '${txDate.year}-${txDate.month.toString().padLeft(2, '0')}-${txDate.day.toString().padLeft(2, '0')}';
      if (dailyMap.containsKey(key)) {
        final existing = dailyMap[key]!;
        if (tx.isIncome) {
          dailyMap[key] = _DailyTrendData(
            day: existing.day,
            date: existing.date,
            income: existing.income + tx.amount,
            expense: existing.expense,
          );
        } else {
          dailyMap[key] = _DailyTrendData(
            day: existing.day,
            date: existing.date,
            income: existing.income,
            expense: existing.expense + tx.amount,
          );
        }
      }
    }
    
    // Sort by date and return
    final sortedKeys = dailyMap.keys.toList()..sort();
    return sortedKeys.map((k) => dailyMap[k]!).toList();
  }

  Widget _buildDailyLineChart(List<_DailyTrendData> data) {
    if (data.isEmpty) return const SizedBox();
    
    final maxVal = data.fold<double>(0, (m, d) => [m, d.income, d.expense].reduce((a, b) => a > b ? a : b));
    final lastIncome = data.isNotEmpty ? data.last.income : 0.0;

    return Stack(
      children: [
        LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxVal > 0 ? maxVal / 4 : 1000000,
              getDrawingHorizontalLine: (v) => FlLine(
                color: Theme.of(context).colorScheme.outlineVariant.withAlpha(60),
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 5, // Show every 5th day
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx >= 0 && idx < data.length && idx % 5 == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          data[idx].day,
                          style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minY: 0,
            maxY: maxVal > 0 ? maxVal * 1.3 : 1000000,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (spots) => spots.map((spot) {
                  final idx = spot.x.toInt();
                  final isIncome = spot.barIndex == 0;
                  final value = spot.y;
                  return LineTooltipItem(
                    '${isIncome ? "Income" : "Expense"}: ${_formatCurrency(value)}',
                    TextStyle(color: isIncome ? const Color(0xFF4CAF50) : const Color(0xFFEF4444), fontSize: 12),
                  );
                }).toList(),
              ),
            ),
            lineBarsData: [
              // Income line
              LineChartBarData(
                spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i].income)),
                isCurved: true,
                color: const Color(0xFF4CAF50),
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [const Color(0xFF4CAF50).withAlpha(80), const Color(0xFF4CAF50).withAlpha(10)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // Expense line
              LineChartBarData(
                spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i].expense)),
                isCurved: true,
                color: const Color(0xFF64B5F6),
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                dashArray: [5, 5],
              ),
            ],
          ),
        ),
        // Value badge
        if (lastIncome > 0)
          Positioned(
            right: 0,
            top: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Text(_formatCurrency(lastIncome), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ),
      ],
    );
  }

  Widget _buildLineChart(List<MonthlyTrendData> data) {
    if (data.isEmpty) return const SizedBox();
    
    final maxVal = data.fold<double>(0, (m, d) => [m, d.income, d.expense].reduce((a, b) => a > b ? a : b));
    final lastIncome = data.isNotEmpty ? data.last.income : 0.0;

    return Stack(
      children: [
        LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxVal > 0 ? maxVal / 4 : 1000000,
              getDrawingHorizontalLine: (v) => FlLine(
                color: Theme.of(context).colorScheme.outlineVariant.withAlpha(60),
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx >= 0 && idx < data.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          data[idx].month,
                          style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minY: 0,
            maxY: maxVal * 1.3,
            lineBarsData: [
              // Income line (with gradient area)
              LineChartBarData(
                spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.income)).toList(),
                isCurved: true,
                curveSmoothness: 0.35,
                color: const Color(0xFF3B82F6),
                barWidth: 2.5,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    if (index == data.length - 1) {
                      return FlDotCirclePainter(
                        radius: 5,
                        color: const Color(0xFF3B82F6),
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    }
                    return FlDotCirclePainter(radius: 0, color: Colors.transparent);
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF3B82F6).withAlpha(40),
                      const Color(0xFF3B82F6).withAlpha(5),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Tooltip for last value
        Positioned(
          right: 0,
          top: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inverseSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formatCurrency(lastIncome),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EXPENSE ALLOCATION CARD (Donut Chart)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildExpenseAllocationCard(AsyncValue<List<FinanceTransaction>> txAsync) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                const Text('Alokasi Pengeluaran', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 20),
            txAsync.when(
              loading: () => const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('Error: $e'),
              data: (transactions) {
                final expenses = transactions.where((t) => !t.isIncome).toList();
                if (expenses.isEmpty) {
                  return const SizedBox(height: 150, child: Center(child: Text('Belum ada pengeluaran')));
                }
                
                // Group by category
                final Map<String, double> categoryTotals = {};
                for (final tx in expenses) {
                  final cat = tx.categoryName ?? 'Lainnya';
                  categoryTotals[cat] = (categoryTotals[cat] ?? 0) + tx.amount;
                }
                
                // Get top category
                final sorted = categoryTotals.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
                final topCategory = sorted.isNotEmpty ? sorted.first.key : 'N/A';
                
                final total = expenses.fold<double>(0, (s, t) => s + t.amount);
                final colors = [
                  const Color(0xFF1E3A5F),
                  const Color(0xFF3B82F6),
                  const Color(0xFFE5E7EB),
                ];
                
                return Column(
                  children: [
                    SizedBox(
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: sorted.take(3).toList().asMap().entries.map((e) {
                                final percent = (e.value.value / total * 100).round();
                                return PieChartSectionData(
                                  value: e.value.value,
                                  color: colors[e.key % colors.length],
                                  radius: 30,
                                  showTitle: false,
                                );
                              }).toList(),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Top Spend', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                              Text(topCategory, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: sorted.take(3).toList().asMap().entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(color: colors[e.key % colors.length], shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              Text(e.value.key, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCHEDULED PAYMENTS CARD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildScheduledPaymentsCard() {
    // For now, showing reminders from finance context - can be enhanced later
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pembayaran Terjadwal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 16),
            _scheduledPaymentItem(
              icon: Icons.bolt_rounded,
              iconColor: Colors.amber,
              title: 'Tagihan Listrik',
              subtitle: 'Besok',
              amount: 150000,
            ),
            const Divider(height: 24),
            _scheduledPaymentItem(
              icon: Icons.medical_services_rounded,
              iconColor: Colors.blue,
              title: 'Vaksinasi Bulanan',
              subtitle: 'Dalam 3 hari',
              amount: 250000,
            ),
          ],
        ),
      ),
    );
  }

  Widget _scheduledPaymentItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required double amount,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text('$subtitle • ${_formatCurrency(amount)}', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SEARCH & FILTER BAR
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSearchFilterBar(List<FinanceTransaction> allTransactions) {
    final thisWeek = allTransactions.where((tx) {
      final diff = DateTime.now().difference(tx.transactionDate).inDays;
      return diff <= 7;
    }).toList();
    final weekTotal = thisWeek.fold<double>(0, (s, t) => s + (t.isIncome ? t.amount : -t.amount));
    
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Quick Stats Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withAlpha(15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insights_rounded, size: 18, color: Color(0xFF059669)),
                  const SizedBox(width: 8),
                  Text(
                    '${thisWeek.length} transaksi minggu ini',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF059669)),
                  ),
                  const Spacer(),
                  Text(
                    'Total: ${_formatCurrency(weekTotal.abs())}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: weekTotal >= 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Search & Filter Row
            Row(
              children: [
                // Search Input
                Expanded(
                  flex: 2,
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Cari transaksi...',
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(150)),
                      prefixIcon: Icon(Icons.search, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Category Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _categoryFilter,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      onChanged: (v) => setState(() => _categoryFilter = v ?? 'all'),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Semua')),
                        DropdownMenuItem(value: 'income', child: Text('Pemasukan')),
                        DropdownMenuItem(value: 'expense', child: Text('Pengeluaran')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TRANSACTIONS TABLE
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildEmptyTransactions() {
    return Card(
      margin: EdgeInsets.zero,
      child: SizedBox(
        height: 150,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long_rounded, size: 48, color: Theme.of(context).colorScheme.outlineVariant),
              const SizedBox(height: 12),
              Text('Belum ada transaksi', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySearch() {
    return Card(
      margin: EdgeInsets.zero,
      child: SizedBox(
        height: 120,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded, size: 40, color: Theme.of(context).colorScheme.outlineVariant),
              const SizedBox(height: 8),
              Text('Tidak ada hasil', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text('Coba kata kunci lain', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(150))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsTable(List<FinanceTransaction> transactions) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Transaksi Terbaru', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                TextButton(
                  onPressed: () => _showAllTransactions(transactions),
                  child: Row(
                    children: [
                      Text('Lihat Semua', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 14, color: Theme.of(context).colorScheme.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = MediaQuery.of(context).size.width < 600;
                if (isMobile) {
                  // Mobile: 3 columns only
                  return const Row(
                    children: [
                      Expanded(flex: 2, child: Text('ID', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 0.5))),
                      Expanded(flex: 2, child: Text('KATEGORI', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 0.5))),
                      Expanded(flex: 2, child: Text('JUMLAH', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 0.5))),
                    ],
                  );
                }
                // Desktop: 5 columns
                return const Row(
                  children: [
                    Expanded(flex: 2, child: Text('ID TRANSAKSI', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 0.5))),
                    Expanded(flex: 2, child: Text('KATEGORI', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 0.5))),
                    Expanded(flex: 2, child: Text('TANGGAL', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 0.5))),
                    Expanded(flex: 1, child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 0.5))),
                    Expanded(flex: 2, child: Text('JUMLAH', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 0.5))),
                  ],
                );
              },
            ),
          ),
          // Table Rows
          ...transactions.take(10).map((tx) => _buildTransactionRow(tx)),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(FinanceTransaction tx) {
    final isIncome = tx.isIncome;
    final color = isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    // Format: IN-YYMM-XXXX or EX-YYMM-XXXX
    final prefix = isIncome ? 'IN' : 'EX';
    final yearMonth = '${tx.transactionDate.year.toString().substring(2)}${tx.transactionDate.month.toString().padLeft(2, '0')}';
    final hash = tx.id.substring(0, 4).toUpperCase();
    final shortId = '$prefix-$yearMonth-$hash';

    return InkWell(
      onTap: () => _showTransactionDetail(tx),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withAlpha(60))),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = MediaQuery.of(context).size.width < 600;
            
            if (isMobile) {
              // Mobile: 3 columns - ID, Category, Amount
              return Row(
                children: [
                  // Transaction ID
                  Expanded(
                    flex: 2,
                    child: Text(shortId, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ),
                  // Category with icon
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: color.withAlpha(20),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                            color: color,
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            tx.categoryName ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Amount
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${isIncome ? '+' : '-'}${_formatCurrency(tx.amount)}',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: color),
                    ),
                  ),
                ],
              );
            }
            
            // Desktop: 5 columns
            return Row(
              children: [
                // Transaction ID
                Expanded(
                  flex: 2,
                  child: Text(shortId, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
                // Category with icon
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: color.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                          color: color,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tx.categoryName ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Date
                Expanded(
                  flex: 2,
                  child: Text(
                    _formatDate(tx.transactionDate),
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
                // Status
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Selesai',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
                    ),
                  ),
                ),
                // Amount
                Expanded(
                  flex: 2,
                  child: Text(
                    '${isIncome ? '+' : '-'}${_formatCurrency(tx.amount)}',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VIEW ALL TRANSACTIONS
  // ═══════════════════════════════════════════════════════════════════════════
  void _showAllTransactions(List<FinanceTransaction> transactions) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, color: Color(0xFF4CAF50)),
                  const SizedBox(width: 12),
                  Text('Semua Transaksi (${transactions.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Transaction list
            Expanded(
              child: transactions.isEmpty
                  ? const Center(child: Text('Belum ada transaksi'))
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: transactions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, indent: 20, endIndent: 20),
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        final isIncome = tx.isIncome;
                        final color = isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444);
                        return ListTile(
                          onTap: () {
                            Navigator.pop(ctx);
                            _showTransactionDetail(tx);
                          },
                          leading: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: color.withAlpha(25),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                              color: color,
                              size: 20,
                            ),
                          ),
                          title: Text(tx.categoryName ?? 'Transaksi', style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(_formatDate(tx.transactionDate), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          trailing: Text(
                            '${isIncome ? '+' : '-'}${_formatCurrency(tx.amount)}',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: color),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TRANSACTION DETAIL
  // ═══════════════════════════════════════════════════════════════════════════
  void _showTransactionDetail(FinanceTransaction tx) {
    final isIncome = tx.isIncome;
    final color = isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Theme.of(ctx).colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)))),
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(12)),
                  child: Icon(isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tx.categoryName ?? 'Transaksi', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                      Text(isIncome ? 'Pemasukan' : 'Pengeluaran', style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withAlpha(15), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Text('Jumlah', style: TextStyle(fontSize: 12, color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text('${isIncome ? '+' : '-'} ${_formatCurrency(tx.amount)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _detailRow('Tanggal', _formatDate(tx.transactionDate)),
            if (tx.description != null && tx.description!.isNotEmpty)
              _detailRow('Catatan', tx.description!),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(tx, ctx),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Hapus'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  void _confirmDelete(FinanceTransaction tx, BuildContext ctx) {
    print('DEBUG _confirmDelete: Called for transaction ${tx.id}');
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: Text('Yakin ingin menghapus transaksi ${tx.categoryName ?? ""} sebesar ${_formatCurrency(tx.amount)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              print('DEBUG _confirmDelete: User confirmed delete for ${tx.id}');
              Navigator.pop(dialogCtx);
              Navigator.pop(ctx);
              try {
                print('DEBUG _confirmDelete: Calling delete...');
                await ref.read(financeNotifierProvider.notifier).delete(tx.id);
                print('DEBUG _confirmDelete: Delete complete, refreshing UI');
                // Force rebuild by triggering setState
                if (mounted) {
                  ref.invalidate(financeNotifierProvider);
                  ref.invalidate(monthlyTrendProvider);
                  setState(() {}); // Force rebuild
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaksi dihapus'), backgroundColor: Colors.orange));
                }
              } catch (e) {
                print('DEBUG _confirmDelete: ERROR - $e');
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _handleExport(String type, AsyncValue<List<FinanceTransaction>> txAsync) {
    txAsync.whenData((transactions) async {
      if (transactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada transaksi untuk di-export')),
        );
        return;
      }
      
      final farm = ref.read(currentFarmProvider);
      final farmName = farm?.name ?? 'DSFarm';
      
      try {
        if (type == 'pdf') {
          await FinanceExportService.exportToPdf(
            transactions: transactions,
            farmName: farmName,
          );
        } else if (type == 'excel') {
          await FinanceExportService.exportToExcel(
            transactions: transactions,
            farmName: farmName,
          );
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Export ${type.toUpperCase()} berhasil!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal export: $e')),
          );
        }
      }
    });
  }

  void _confirmDeleteAll() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus Semua Transaksi?'),
        content: const Text('Yakin ingin menghapus SEMUA transaksi? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              try {
                await ref.read(financeNotifierProvider.notifier).deleteAll();
                if (mounted) {
                  ref.invalidate(financeNotifierProvider);
                  ref.invalidate(monthlyTrendProvider);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua transaksi dihapus'), backgroundColor: Colors.orange));
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ADD TRANSACTION SHEET
  // ═══════════════════════════════════════════════════════════════════════════
  void _showAddSheet() {
    final type = ValueNotifier(TransactionType.expense);
    final amount = TextEditingController();
    final desc = TextEditingController();
    var date = DateTime.now();
    String? categoryId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: Theme.of(ctx).colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)))),
                const Text('Tambah Transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                // Type selector
                ValueListenableBuilder<TransactionType>(
                  valueListenable: type,
                  builder: (_, t, __) => Row(
                    children: [
                      _typeBtn('Masuk', const Color(0xFF10B981), t == TransactionType.income, () { type.value = TransactionType.income; categoryId = null; setState(() {}); }),
                      const SizedBox(width: 10),
                      _typeBtn('Keluar', const Color(0xFFEF4444), t == TransactionType.expense, () { type.value = TransactionType.expense; categoryId = null; setState(() {}); }),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Category dropdown
                Consumer(
                  builder: (_, ref, __) {
                    final cats = ref.watch(categoriesProvider(type.value));
                    return cats.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text('Error: $e'),
                      data: (list) {
                        if (list.isEmpty) return const Text('Tidak ada kategori');
                        return DropdownButtonFormField<String>(
                          value: categoryId,
                          decoration: InputDecoration(
                            labelText: 'Kategori',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                          ),
                          items: list.map((c) => DropdownMenuItem(value: c.id, child: Text('${c.icon ?? ''} ${c.name}'))).toList(),
                          onChanged: (v) => setState(() => categoryId = v),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Amount input
                TextField(
                  controller: amount,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Jumlah',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 12),
                // Date picker
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(context: ctx, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 30)));
                    if (picked != null) setState(() => date = picked);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Theme.of(ctx).colorScheme.outline),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 18, color: Theme.of(ctx).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 10),
                        Text(_formatDate(date), style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Description
                TextField(
                  controller: desc,
                  decoration: InputDecoration(
                    labelText: 'Catatan (opsional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 20),
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (categoryId == null || amount.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi kategori dan jumlah')));
                        return;
                      }
                      Navigator.pop(ctx);
                      try {
                        await ref.read(financeNotifierProvider.notifier).createTransaction(
                          type: type.value,
                          categoryId: categoryId!,
                          amount: double.tryParse(amount.text.replaceAll('.', '')) ?? 0,
                          transactionDate: date,
                          description: desc.text.isEmpty ? null : desc.text,
                        );
                        ref.invalidate(monthlyTrendProvider);
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaksi ${type.value == TransactionType.income ? 'pemasukan' : 'pengeluaran'} berhasil ditambahkan'), backgroundColor: const Color(0xFF10B981)));
                      } catch (e) {
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Simpan Transaksi'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _typeBtn(String label, Color color, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withAlpha(20) : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? color : Colors.transparent, width: 2),
          ),
          child: Center(
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: selected ? color : Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════
  String _formatCurrency(double v) {
    if (v >= 1000000) {
      return 'Rp ${(v / 1000000).toStringAsFixed(1)} jt';
    }
    return 'Rp ${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUMMARY CARD WIDGET
// ═══════════════════════════════════════════════════════════════════════════

/// Calculate card width based on screen size (responsive)
double _getCardWidth(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  const sidebarWidth = 260.0;
  const padding = 48.0;
  
  if (screenWidth > 900) {
    // Desktop: 4 cards per row
    return (screenWidth - sidebarWidth - padding - 48) / 4;
  } else if (screenWidth > 600) {
    // Tablet: 2 cards per row
    return (screenWidth - padding - 16) / 2;
  } else {
    // Mobile (iPhone 12 mini = 375): 1 card per row
    return screenWidth - padding;
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double value;
  final double trend;
  final IconData icon;
  final Color iconColor;
  final bool isPremium;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
    required this.iconColor,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPositiveTrend = trend >= 0;
    final trendColor = isPositiveTrend ? const Color(0xFF059669) : const Color(0xFFDC2626);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: _getCardWidth(context),
      child: Container(
        decoration: BoxDecoration(
          gradient: isPremium 
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark 
                      ? [const Color(0xFF291F00), const Color(0xFF1A1400)]
                      : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
                )
              : null,
          color: isPremium ? null : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPremium 
                ? const Color(0xFFF59E0B).withAlpha(80)
                : Theme.of(context).colorScheme.outlineVariant.withAlpha(40),
            width: isPremium ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isPremium 
                  ? const Color(0xFFF59E0B).withAlpha(20)
                  : Colors.black.withAlpha(8),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: isPremium 
                            ? const Color(0xFFD97706)
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: iconColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _formatValue(value),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    isPositiveTrend ? Icons.trending_up : Icons.trending_down,
                    size: 14,
                    color: trendColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${trend.abs().toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: trendColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'vs bulan lalu',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatValue(double v) {
    if (v >= 1000000000) {
      return 'Rp ${(v / 1000000000).toStringAsFixed(1)} M';
    }
    if (v >= 1000000) {
      return 'Rp ${(v / 1000000).toStringAsFixed(1)} jt';
    }
    return 'Rp ${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }
}

/// Helper class for daily trend data
class _DailyTrendData {
  final String day;
  final DateTime date;
  final double income;
  final double expense;
  
  const _DailyTrendData({
    required this.day,
    required this.date,
    required this.income,
    required this.expense,
  });
}

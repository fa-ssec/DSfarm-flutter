/// Breeding Analytics Screen
/// 
/// Screen untuk menampilkan statistik dan analitik breeding.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/breeding_analytics_service.dart';
import '../../../providers/farm_provider.dart';

/// Provider untuk analytics service
final breedingAnalyticsProvider = Provider((ref) {
  return BreedingAnalyticsService(Supabase.instance.client);
});

/// Provider untuk farm stats
final farmBreedingStatsProvider = FutureProvider<FarmBreedingStats?>((ref) async {
  final farm = ref.watch(currentFarmProvider);
  if (farm == null) return null;
  
  final service = ref.watch(breedingAnalyticsProvider);
  return service.getFarmStats(farm.id);
});

/// Provider untuk dam stats
final damStatsProvider = FutureProvider<List<DamStats>>((ref) async {
  final farm = ref.watch(currentFarmProvider);
  if (farm == null) return [];
  
  final service = ref.watch(breedingAnalyticsProvider);
  return service.getDamStats(farm.id);
});

class BreedingAnalyticsScreen extends ConsumerWidget {
  const BreedingAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farmStatsAsync = ref.watch(farmBreedingStatsProvider);
    final damStatsAsync = ref.watch(damStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analitik Breeding'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            farmStatsAsync.when(
              loading: () => const _SummaryCardsLoading(),
              error: (e, _) => Text('Error: $e'),
              data: (stats) => stats == null 
                  ? const Text('Pilih farm terlebih dahulu')
                  : _SummaryCards(stats: stats),
            ),
            
            const SizedBox(height: 24),
            
            // Success Rate Chart
            const Text(
              'Success Rate per Induk',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            damStatsAsync.when(
              loading: () => const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('Error: $e'),
              data: (damStats) => damStats.isEmpty
                  ? const _EmptyChart()
                  : _SuccessRateChart(damStats: damStats),
            ),
            
            const SizedBox(height: 24),
            
            // Rankings Table
            const Text(
              'Ranking Performa Induk',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            damStatsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (damStats) => damStats.isEmpty
                  ? const Text('Belum ada data breeding')
                  : _RankingsTable(damStats: damStats),
            ),
          ],
        ),
      ),
    );
  }
}

/// Summary Cards
class _SummaryCards extends StatelessWidget {
  final FarmBreedingStats stats;

  const _SummaryCards({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.favorite,
            iconColor: Colors.pink,
            title: 'Total Breeding',
            value: '${stats.totalBreedings}',
            subtitle: '${stats.activeBreedings} aktif',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle,
            iconColor: Colors.green,
            title: 'Success Rate',
            value: stats.successRatePercent,
            subtitle: '${stats.successfulBreedings} berhasil',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.pets,
            iconColor: Colors.orange,
            title: 'Avg Litter',
            value: stats.avgLitterSize.toStringAsFixed(1),
            subtitle: '${stats.totalBorn} total lahir',
          ),
        ),
      ],
    );
  }
}

class _SummaryCardsLoading extends StatelessWidget {
  const _SummaryCardsLoading();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (_) => Expanded(
        child: Card(
          child: Container(
            height: 100,
            padding: const EdgeInsets.all(16),
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ),
      ))..insert(1, const SizedBox(width: 12))..insert(3, const SizedBox(width: 12)),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Success Rate Bar Chart
class _SuccessRateChart extends StatelessWidget {
  final List<DamStats> damStats;

  const _SuccessRateChart({required this.damStats});

  @override
  Widget build(BuildContext context) {
    // Take top 8 for chart
    final data = damStats.take(8).toList();

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${data[group.x.toInt()].damCode}\n${rod.toY.toStringAsFixed(0)}%',
                  const TextStyle(color: Colors.white, fontSize: 12),
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
                  if (index < 0 || index >= data.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[index].damCode.length > 6 
                          ? '${data[index].damCode.substring(0, 6)}...'
                          : data[index].damCode,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
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
            final stats = entry.value;
            final rate = stats.successRate * 100;
            
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: rate,
                  color: _getColorForRate(rate),
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
          gridData: FlGridData(
            show: true,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey[200]!,
              strokeWidth: 1,
            ),
          ),
        ),
      ),
    );
  }

  Color _getColorForRate(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 60) return Colors.lightGreen;
    if (rate >= 40) return Colors.orange;
    return Colors.red;
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'Belum ada data breeding',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

/// Rankings Table
class _RankingsTable extends StatelessWidget {
  final List<DamStats> damStats;

  const _RankingsTable({required this.damStats});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                SizedBox(width: 30, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Induk', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Breeding', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(child: Text('Success', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(child: Text('Avg Anak', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              ],
            ),
          ),
          // Rows
          ...damStats.take(10).toList().asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final stats = entry.value;
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontWeight: rank <= 3 ? FontWeight.bold : FontWeight.normal,
                        color: rank == 1 ? Colors.amber[700] 
                             : rank == 2 ? Colors.grey[600]
                             : rank == 3 ? Colors.brown
                             : null,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      stats.damCode,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${stats.totalBreedings}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getColorForRate(stats.successRate * 100).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        stats.successRatePercent,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _getColorForRate(stats.successRate * 100),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      stats.avgLitterSize.toStringAsFixed(1),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getColorForRate(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 60) return Colors.lightGreen;
    if (rate >= 40) return Colors.orange;
    return Colors.red;
  }
}

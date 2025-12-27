/// Livestock List Screen
/// 
/// Screen untuk melihat dan mengelola indukan/pejantan.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/livestock.dart';
import '../../../providers/livestock_provider.dart';
import '../widgets/livestock_detail_modal.dart';
import 'create_livestock_screen.dart';

class LivestockListScreen extends ConsumerStatefulWidget {
  const LivestockListScreen({super.key});

  @override
  ConsumerState<LivestockListScreen> createState() => _LivestockListScreenState();
}

class _LivestockListScreenState extends ConsumerState<LivestockListScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indukan'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: '♀️ Betina'),
            Tab(text: '♂️ Jantan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LivestockTab(filter: null),
          _LivestockTab(filter: Gender.female),
          _LivestockTab(filter: Gender.male),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateLivestockScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _LivestockTab extends ConsumerWidget {
  final Gender? filter;

  const _LivestockTab({this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livestocksAsync = ref.watch(livestockNotifierProvider);

    return livestocksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Error: $error'),
            ElevatedButton(
              onPressed: () => ref.refresh(livestockNotifierProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (livestocks) {
        // Apply filter
        final filtered = filter == null
            ? livestocks
            : livestocks.where((l) => l.gender == filter).toList();

        if (filtered.isEmpty) {
          return _buildEmptyState(context, filter);
        }

        // Responsive layout
        return LayoutBuilder(
          builder: (context, constraints) {
            // Web/Desktop: Table view (≥600px)
            if (constraints.maxWidth >= 600) {
              return _buildTableView(context, ref, filtered);
            }
            // Mobile: Card list
            return _buildCardList(context, ref, filtered);
          },
        );
      },
    );
  }

  Widget _buildTableView(BuildContext context, WidgetRef ref, List<Livestock> filtered) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                const Expanded(flex: 2, child: Text('ID INDUKAN', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey))),
                const Expanded(flex: 2, child: Text('TANGGAL LAHIR', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey))),
                const Expanded(flex: 1, child: Text('BOBOT', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey))),
                const Expanded(flex: 2, child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey))),
              ],
            ),
          ),
          // Table rows
          ...filtered.map((livestock) => _TableRow(
            livestock: livestock,
            onTap: () => _showDetail(context, ref, livestock),
          )),
        ],
      ),
    );
  }

  Widget _buildCardList(BuildContext context, WidgetRef ref, List<Livestock> filtered) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final livestock = filtered[index];
        return _LivestockCard(
          livestock: livestock,
          onTap: () => _showDetail(context, ref, livestock),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, Gender? filter) {
    final label = filter == null 
        ? 'indukan' 
        : filter == Gender.female 
            ? 'induk betina' 
            : 'pejantan';
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Belum ada $label',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan $label pertama untuk mulai',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, WidgetRef ref, Livestock livestock) {
    showLivestockDetailModal(context, ref, livestock);
  }
}

class _LivestockCard extends StatelessWidget {
  final Livestock livestock;
  final VoidCallback onTap;

  const _LivestockCard({required this.livestock, required this.onTap});

  Color _getStatusColor() {
    switch (livestock.status) {
      case LivestockStatus.siapKawin:
        return const Color(0xFF9C27B0); // Purple
      case LivestockStatus.bunting:
      case LivestockStatus.menyusui:
        return const Color(0xFFE91E63); // Pink
      case LivestockStatus.pejantanAktif:
        return const Color(0xFF2196F3); // Blue
      case LivestockStatus.betinaMuda:
      case LivestockStatus.pejantanMuda:
        return const Color(0xFF4CAF50); // Green
      case LivestockStatus.istirahat:
        return const Color(0xFF9E9E9E); // Grey
      case LivestockStatus.sold:
        return const Color(0xFF607D8B); // Blue Grey
      case LivestockStatus.deceased:
        return const Color(0xFFF44336); // Red
      case LivestockStatus.culled:
        return const Color(0xFFFF9800); // Orange
    }
  }

  IconData _getStatusIcon() {
    switch (livestock.status) {
      case LivestockStatus.siapKawin:
        return Icons.favorite;
      case LivestockStatus.bunting:
        return Icons.pregnant_woman;
      case LivestockStatus.menyusui:
        return Icons.child_care;
      case LivestockStatus.pejantanAktif:
        return Icons.bolt;
      case LivestockStatus.betinaMuda:
      case LivestockStatus.pejantanMuda:
        return Icons.pets;
      case LivestockStatus.istirahat:
        return Icons.pause_circle;
      case LivestockStatus.sold:
        return Icons.attach_money;
      case LivestockStatus.deceased:
        return Icons.error;
      case LivestockStatus.culled:
        return Icons.highlight_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    final genderColor = livestock.isFemale ? const Color(0xFFE91E63) : const Color(0xFF2196F3);
    final statusColor = _getStatusColor();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Row 1: Gender+Code and Weight
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        livestock.genderIcon,
                        style: TextStyle(fontSize: 16, color: genderColor),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        livestock.code,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: genderColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    livestock.weight != null ? '${livestock.weight} kg' : '-',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Row 2: Age and Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    livestock.ageFormatted,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(),
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          livestock.status.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
}

/// Table row for web/desktop view
class _TableRow extends StatelessWidget {
  final Livestock livestock;
  final VoidCallback onTap;

  const _TableRow({required this.livestock, required this.onTap});

  Color _getStatusColor() {
    switch (livestock.status) {
      case LivestockStatus.siapKawin:
        return const Color(0xFF9C27B0); // Purple
      case LivestockStatus.bunting:
      case LivestockStatus.menyusui:
        return const Color(0xFFE91E63); // Pink
      case LivestockStatus.pejantanAktif:
        return const Color(0xFF2196F3); // Blue
      case LivestockStatus.betinaMuda:
      case LivestockStatus.pejantanMuda:
        return const Color(0xFF4CAF50); // Green
      case LivestockStatus.istirahat:
        return const Color(0xFF9E9E9E); // Grey
      case LivestockStatus.sold:
        return const Color(0xFF607D8B); // Blue Grey
      case LivestockStatus.deceased:
        return const Color(0xFFF44336); // Red
      case LivestockStatus.culled:
        return const Color(0xFFFF9800); // Orange
    }
  }

  IconData _getStatusIcon() {
    switch (livestock.status) {
      case LivestockStatus.siapKawin:
        return Icons.favorite;
      case LivestockStatus.bunting:
        return Icons.pregnant_woman;
      case LivestockStatus.menyusui:
        return Icons.child_care;
      case LivestockStatus.pejantanAktif:
        return Icons.bolt;
      case LivestockStatus.betinaMuda:
      case LivestockStatus.pejantanMuda:
        return Icons.pets;
      case LivestockStatus.istirahat:
        return Icons.pause_circle;
      case LivestockStatus.sold:
        return Icons.attach_money;
      case LivestockStatus.deceased:
        return Icons.error;
      case LivestockStatus.culled:
        return Icons.highlight_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    final genderColor = livestock.isFemale ? const Color(0xFFE91E63) : const Color(0xFF2196F3);
    final statusColor = _getStatusColor();
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[800]!)),
        ),
        child: Row(
          children: [
            // ID Indukan
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Text(
                    livestock.genderIcon,
                    style: TextStyle(fontSize: 14, color: genderColor),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    livestock.code,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: genderColor,
                    ),
                  ),
                ],
              ),
            ),
            // Tanggal Lahir
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    livestock.birthDate != null
                        ? _formatDate(livestock.birthDate!)
                        : '-',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    livestock.ageFormatted,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            // Bobot
            Expanded(
              flex: 1,
              child: Text(
                livestock.weight != null ? '${livestock.weight} kg' : '-',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            // Status
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(),
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        livestock.status.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

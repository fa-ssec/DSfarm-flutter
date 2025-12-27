/// Offspring Detail Modal
/// 
/// Modal bottom sheet dengan tabs untuk menampilkan detail anakan.

library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/health_record.dart';
import '../../../models/offspring.dart';
import '../../../models/weight_record.dart';
import '../../../providers/health_provider.dart';
import '../../../providers/offspring_provider.dart';
import '../../../providers/weight_record_provider.dart';

/// Helper function to show offspring detail modal
void showOffspringDetailModal(
  BuildContext context, 
  WidgetRef ref, 
  Offspring offspring,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _OffspringDetailModal(offspring: offspring),
  );
}

class _OffspringDetailModal extends ConsumerStatefulWidget {
  final Offspring offspring;

  const _OffspringDetailModal({required this.offspring});

  @override
  ConsumerState<_OffspringDetailModal> createState() => _OffspringDetailModalState();
}

class _OffspringDetailModalState extends ConsumerState<_OffspringDetailModal> 
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

  void _showSilsilahPopup(BuildContext context, Offspring offspring) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
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
                  const Icon(Icons.account_tree, color: Color(0xFF4CAF50)),
                  const SizedBox(width: 12),
                  const Text(
                    'Silsilah',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Current offspring
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF4CAF50)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            offspring.genderIcon,
                            style: TextStyle(
                              fontSize: 24,
                              color: offspring.gender == Gender.male 
                                  ? const Color(0xFF2196F3) 
                                  : const Color(0xFFE91E63),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  offspring.displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  offspring.code,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'SAAT INI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Parents
                    Row(
                      children: [
                        // Mother
                        Expanded(
                          child: _buildParentCard(
                            icon: '♀',
                            iconColor: const Color(0xFFE91E63),
                            label: 'Induk',
                            code: offspring.damCode,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Father
                        Expanded(
                          child: _buildParentCard(
                            icon: '♂',
                            iconColor: const Color(0xFF2196F3),
                            label: 'Pejantan',
                            code: offspring.sireCode,
                          ),
                        ),
                      ],
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

  Widget _buildParentCard({
    required String icon,
    required Color iconColor,
    required String label,
    required String? code,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: TextStyle(fontSize: 28, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            code ?? '-',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offspring = widget.offspring;
    final genderColor = offspring.gender == Gender.male 
        ? const Color(0xFF2196F3) 
        : const Color(0xFFE91E63);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: genderColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        offspring.genderIcon,
                        style: TextStyle(
                          fontSize: 24,
                          color: genderColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offspring.displayName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: genderColor,
                          ),
                        ),
                        Text(
                          'Kode: ${offspring.code}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Tab Bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: const Color(0xFF4CAF50),
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: const Color(0xFF4CAF50),
                indicatorWeight: 2,
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 18),
                        SizedBox(width: 6),
                        Text('Informasi'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.show_chart, size: 18),
                        SizedBox(width: 6),
                        Text('Pertumbuhan'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite_border, size: 18),
                        SizedBox(width: 6),
                        Text('Kesehatan'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _InformasiTab(offspring: offspring),
                  _PertumbuhanTab(offspring: offspring),
                  _KesehatanTab(offspring: offspring),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tab 1: Informasi
class _InformasiTab extends ConsumerWidget {
  final Offspring offspring;

  const _InformasiTab({required this.offspring});

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  Color _getStatusColor(OffspringStatus status) {
    switch (status) {
      case OffspringStatus.infarm:
        return Colors.green;
      case OffspringStatus.weaned:
        return Colors.blue;
      case OffspringStatus.readySell:
        return Colors.orange;
      case OffspringStatus.sold:
        return Colors.grey;
      case OffspringStatus.deceased:
        return Colors.red;
      case OffspringStatus.promoted:
        return Colors.purple;
    }
  }

  void _showPromoteDialog(BuildContext context, WidgetRef ref, Offspring offspring) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promosi ke Indukan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Anakan ini akan dipromosikan menjadi indukan:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    offspring.genderIcon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offspring.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Umur: ${offspring.ageFormatted}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Data seperti tanggal lahir, jenis kelamin, dan ras akan disalin ke indukan baru.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              Navigator.pop(context); // Close detail modal
              
              try {
                // Create new livestock from offspring
                await ref.read(offspringNotifierProvider.notifier)
                    .promoteToLivestock(offspring.id);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${offspring.displayName} berhasil dipromosikan ke indukan!'),
                      backgroundColor: const Color(0xFF9C27B0),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal promosi: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C27B0),
            ),
            child: const Text('Promosikan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Dasar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Kesehatan', value: 'Sehat'),
                  if (offspring.name != null)
                    _InfoRow(label: 'Nama', value: offspring.name!),
                  _InfoRow(label: 'Jenis Kelamin', value: offspring.gender.displayName),
                  _InfoRow(label: 'Lahir', value: _formatDate(offspring.birthDate)),
                  _InfoRow(label: 'Umur', value: offspring.ageFormatted),
                  if (offspring.weaningDate != null)
                    _InfoRow(label: 'Sapih', value: _formatDate(offspring.weaningDate)),
                  _InfoRow(label: 'Berat', value: offspring.weight != null 
                      ? '${offspring.weight?.toStringAsFixed(2)} kg' 
                      : '-'),
                  _InfoRow(label: 'Kandang', value: offspring.housingCode ?? '-'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Parents Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Silsilah',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Induk', value: offspring.damCode ?? '-'),
                  _InfoRow(label: 'Pejantan', value: offspring.sireCode ?? '-'),
                  if (offspring.breedName != null)
                    _InfoRow(label: 'Ras', value: offspring.breedName!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Quick Actions
          _buildQuickActions(context, ref),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aksi Cepat',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (offspring.status == OffspringStatus.infarm)
                  OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await ref.read(offspringNotifierProvider.notifier)
                          .updateStatus(offspring.id, OffspringStatus.readySell);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Status diubah ke Siap Jual')),
                        );
                      }
                    },
                    icon: const Icon(Icons.sell, size: 18),
                    label: const Text('Siap Jual'),
                  ),
                if (offspring.status == OffspringStatus.readySell)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Show sell dialog
                    },
                    icon: const Icon(Icons.attach_money, size: 18),
                    label: const Text('Jual'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                // Promotion button - show for ready to sell or 3+ months old
                if (offspring.effectiveStatus == OffspringStatus.readySell || 
                    offspring.ageInDays >= 90)
                  ElevatedButton.icon(
                    onPressed: () => _showPromoteDialog(context, ref, offspring),
                    icon: const Icon(Icons.upgrade, size: 18),
                    label: const Text('Promosi ke Indukan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C27B0),
                      foregroundColor: Colors.white,
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/lineage?offspringId=${offspring.id}');
                  },
                  icon: const Icon(Icons.account_tree, size: 18),
                  label: const Text('Silsilah'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Tab 2: Pertumbuhan
class _PertumbuhanTab extends ConsumerWidget {
  final Offspring offspring;

  const _PertumbuhanTab({required this.offspring});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For now, show empty state since weight records are tied to livestock, not offspring
    // TODO: Add weight tracking for offspring
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current weight card
          if (offspring.weight != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.monitor_weight, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Berat Saat Ini',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '${offspring.weight?.toStringAsFixed(2)} kg',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          
          // Empty state for weight history
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.show_chart, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text(
                      'Riwayat berat belum tersedia',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fitur ini akan segera hadir',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab 3: Kesehatan
class _KesehatanTab extends ConsumerWidget {
  final Offspring offspring;

  const _KesehatanTab({required this.offspring});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(healthByOffspringProvider(offspring.id));

    return recordsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (records) {
        if (records.isEmpty) {
          return _buildEmptyState(context, ref);
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAddButton(context, ref),
              const SizedBox(height: 16),
              _buildRecordList(context, ref, records),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.health_and_safety, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Riwayat Kesehatan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Catat vaksinasi, penyakit, dan pengobatan di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddHealthDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Catatan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showAddHealthDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Catatan Kesehatan'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE91E63),
          side: const BorderSide(color: Color(0xFFE91E63)),
        ),
      ),
    );
  }

  Widget _buildRecordList(BuildContext context, WidgetRef ref, List<HealthRecord> records) {
    final sortedRecords = List<HealthRecord>.from(records)
      ..sort((a, b) => b.recordDate.compareTo(a.recordDate));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medical_services, size: 20, color: Color(0xFFE91E63)),
                const SizedBox(width: 8),
                const Text(
                  'Riwayat Kesehatan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...sortedRecords.asMap().entries.map((entry) {
              final index = entry.key;
              final record = entry.value;
              final isLast = index == sortedRecords.length - 1;
              
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline indicator
                    SizedBox(
                      width: 24,
                      child: Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getTypeColor(record.type).withAlpha(30),
                              border: Border.all(
                                color: _getTypeColor(record.type),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                record.type.icon,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: Colors.grey[300],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getTypeColor(record.type).withAlpha(10),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getTypeColor(record.type).withAlpha(30),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        record.title,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDate(record.recordDate),
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18),
                                  color: Colors.grey[400],
                                  onPressed: () => _confirmDelete(context, ref, record.id),
                                ),
                              ],
                            ),
                            if (record.medicine != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.medication, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    record.medicine!,
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ],
                            if (record.notes != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                record.notes!,
                                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(HealthRecordType type) {
    switch (type) {
      case HealthRecordType.vaccination:
        return Colors.blue;
      case HealthRecordType.treatment:
        return Colors.orange;
      case HealthRecordType.illness:
        return Colors.red;
      case HealthRecordType.checkup:
        return Colors.green;
      case HealthRecordType.deworming:
        return Colors.purple;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: const Text('Yakin ingin menghapus catatan kesehatan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(healthNotifierProvider.notifier).delete(id);
              ref.invalidate(healthByOffspringProvider(offspring.id));
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddHealthDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final medicineController = TextEditingController();
    final notesController = TextEditingController();
    var selectedType = HealthRecordType.vaccination;
    var selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Catatan Kesehatan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<HealthRecordType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Jenis',
                    border: OutlineInputBorder(),
                  ),
                  items: HealthRecordType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text('${type.icon} ${type.displayName}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => selectedType = value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul',
                    border: OutlineInputBorder(),
                    hintText: 'Contoh: Vaksin RHD',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: medicineController,
                  decoration: const InputDecoration(
                    labelText: 'Obat/Vaksin (opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tanggal'),
                  subtitle: Text(_formatDate(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: offspring.birthDate,
                      lastDate: DateTime.now(),
                    );
                    if (date != null) setState(() => selectedDate = date);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Judul harus diisi')),
                  );
                  return;
                }
                
                Navigator.pop(context);
                await ref.read(healthNotifierProvider.notifier).create(
                  offspringId: offspring.id,
                  type: selectedType,
                  title: titleController.text,
                  recordDate: selectedDate,
                  medicine: medicineController.text.isNotEmpty ? medicineController.text : null,
                  notes: notesController.text.isNotEmpty ? notesController.text : null,
                );
                ref.invalidate(healthByOffspringProvider(offspring.id));
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Catatan kesehatan ditambahkan'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper widget for info rows
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

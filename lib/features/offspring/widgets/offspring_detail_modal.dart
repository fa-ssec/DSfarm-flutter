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

/// Helper function to show offspring detail modal (from the side like Indukan)
void showOffspringDetailModal(
  BuildContext context, 
  WidgetRef ref, 
  Offspring offspring,
) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Offspring Detail',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: _OffspringDetailPanel(offspring: offspring),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final slideAnimation = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      
      return SlideTransition(position: slideAnimation, child: child);
    },
  );
}

class _OffspringDetailPanel extends ConsumerStatefulWidget {
  final Offspring offspring;

  const _OffspringDetailPanel({required this.offspring});

  @override
  ConsumerState<_OffspringDetailPanel> createState() => _OffspringDetailPanelState();
}

class _OffspringDetailPanelState extends ConsumerState<_OffspringDetailPanel> 
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
    final screenWidth = MediaQuery.of(context).size.width;
    // Panel width: 600px on desktop, 95% on mobile (same as Indukan)
    final panelWidth = screenWidth > 600 ? 600.0 : screenWidth * 0.95;

    return Container(
      width: panelWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 20,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Close button row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detail Anakan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                    letterSpacing: 0.5,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 22),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    padding: const EdgeInsets.all(6),
                  ),
                ),
              ],
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
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    Navigator.pop(context);
                    showEditOffspringPanel(context, offspring);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    // Show confirmation dialog first
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Hapus Anakan?'),
                        content: Text('Apakah Anda yakin ingin menghapus ${offspring.displayName}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    );
                    
                    if (shouldDelete == true && context.mounted) {
                      Navigator.pop(context); // Close the detail panel
                      
                      // Flag to track if deletion was cancelled
                      bool undoPressed = false;
                      
                      // Show SnackBar with Undo action for 5 seconds
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${offspring.displayName} akan dihapus...'),
                          duration: const Duration(seconds: 5),
                          action: SnackBarAction(
                            label: 'URUNGKAN',
                            textColor: Colors.yellow,
                            onPressed: () {
                              undoPressed = true;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${offspring.displayName} tidak jadi dihapus'),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ),
                      ).closed.then((reason) async {
                        // Only delete if undo was NOT pressed
                        if (!undoPressed && reason != SnackBarClosedReason.action) {
                          try {
                            await ref.read(offspringNotifierProvider.notifier).delete(offspring.id);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal menghapus: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      });
                    }
                  },
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
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Offspring offspring) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Anakan?'),
        content: Text('Apakah Anda yakin ingin menghapus ${offspring.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      await ref.read(offspringNotifierProvider.notifier).delete(offspring.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${offspring.displayName} dihapus')),
        );
      }
    }
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
    // Watch weight records to get latest weight
    final weightRecordsAsync = ref.watch(offspringWeightRecordNotifierProvider(offspring.id));
    // Watch health records to get health status
    final healthRecordsAsync = ref.watch(healthByOffspringProvider(offspring.id));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Biometrik
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Biometrik',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Jenis Kelamin', value: offspring.gender.displayName),
                  _InfoRow(label: 'Lahir', value: _formatDate(offspring.birthDate)),
                  _InfoRow(label: 'Umur', value: offspring.ageFormatted),
                  if (offspring.weaningDate != null)
                    _InfoRow(label: 'Sapih', value: _formatDate(offspring.weaningDate)),
                  // Get latest weight from weight_records
                  weightRecordsAsync.when(
                    loading: () => const _InfoRow(label: 'Berat', value: '...'),
                    error: (_, __) => _InfoRow(
                      label: 'Berat', 
                      value: offspring.weight != null 
                          ? '${offspring.weight?.toStringAsFixed(2)} kg' 
                          : '-',
                    ),
                    data: (records) {
                      if (records.isNotEmpty) {
                        final latestWeight = records.first.weight;
                        return _InfoRow(
                          label: 'Berat', 
                          value: '${latestWeight.toStringAsFixed(2)} kg',
                        );
                      }
                      return _InfoRow(
                        label: 'Berat', 
                        value: offspring.weight != null 
                            ? '${offspring.weight?.toStringAsFixed(2)} kg' 
                            : '-',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Lokasi & Status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lokasi & Status',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Kandang', value: offspring.housingCode ?? '-'),
                  _InfoRow(label: 'Status', value: offspring.status.displayName),
                  // Get health status from health_records
                  healthRecordsAsync.when(
                    loading: () => const _InfoRow(label: 'Kesehatan', value: '...'),
                    error: (_, __) => const _InfoRow(label: 'Kesehatan', value: 'Sehat'),
                    data: (records) {
                      if (records.isNotEmpty) {
                        final recentIllness = records.where((r) => 
                          r.type == HealthRecordType.illness &&
                          DateTime.now().difference(r.recordDate).inDays <= 30
                        ).toList();
                        if (recentIllness.isNotEmpty) {
                          return _InfoRow(
                            label: 'Kesehatan', 
                            value: '⚠️ ${recentIllness.first.title}',
                          );
                        }
                      }
                      return const _InfoRow(label: 'Kesehatan', value: 'Sehat');
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Silsilah
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
    final recordsAsync = ref.watch(offspringWeightRecordNotifierProvider(offspring.id));

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
              // Chart
              _buildChart(records),
              const SizedBox(height: 16),
              // Add button
              _buildAddButton(context, ref),
              const SizedBox(height: 16),
              // Log list
              _buildLogList(context, ref, records),
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
            Icon(Icons.show_chart, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Data Berat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan data berat untuk melihat grafik pertumbuhan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddWeightDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Data Berat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<WeightRecord> records) {
    // Sort by date ascending for chart
    final sortedRecords = List<WeightRecord>.from(records)
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    if (sortedRecords.length < 2) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Berat Saat Ini',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${sortedRecords.first.weight} kg',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tambahkan lebih banyak data untuk melihat grafik',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    // Build line chart data
    final spots = sortedRecords.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weight);
    }).toList();

    final minWeight = sortedRecords.map((r) => r.weight).reduce((a, b) => a < b ? a : b);
    final maxWeight = sortedRecords.map((r) => r.weight).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Grafik Pertumbuhan Berat',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxWeight == minWeight ? 1 : (maxWeight - minWeight) / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          value.toStringAsFixed(1),
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < sortedRecords.length) {
                            final date = sortedRecords[index].recordedAt;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${date.day}/${date.month}',
                                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: const Color(0xFF4CAF50),
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF4CAF50),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF4CAF50).withAlpha(30),
                      ),
                    ),
                  ],
                  minY: minWeight - 0.5,
                  maxY: maxWeight + 0.5,
                ),
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
        onPressed: () => _showAddWeightDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Data Berat'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF4CAF50),
          side: const BorderSide(color: Color(0xFF4CAF50)),
        ),
      ),
    );
  }

  Widget _buildLogList(BuildContext context, WidgetRef ref, List<WeightRecord> records) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.timeline, size: 20, color: Color(0xFF4CAF50)),
                SizedBox(width: 8),
                Text(
                  'Riwayat Pengukuran',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...records.asMap().entries.map((entry) {
              final index = entry.key;
              final record = entry.value;
              final isFirst = index == 0;
              final isLast = index == records.length - 1;
              
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
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isFirst ? const Color(0xFF4CAF50) : Colors.white,
                              border: Border.all(
                                color: const Color(0xFF4CAF50),
                                width: 2,
                              ),
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: const Color(0xFF4CAF50).withAlpha(100),
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
                          color: isFirst 
                              ? const Color(0xFF4CAF50).withAlpha(15) 
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isFirst 
                                ? const Color(0xFF4CAF50).withAlpha(50) 
                                : Colors.grey[200]!,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    record.formattedDate,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isFirst ? const Color(0xFF2E7D32) : Colors.grey[700],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    record.formattedWeight,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Hapus Data?'),
                                        content: Text('Hapus data berat ${record.formattedWeight} pada ${record.formattedDate}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Batal'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                            child: const Text('Hapus'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      ref.read(offspringWeightRecordNotifierProvider(offspring.id).notifier).delete(record.id);
                                    }
                                  },
                                  child: Icon(Icons.close, size: 18, color: Colors.grey[400]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Umur: ${record.ageFormatted}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            if (record.notes != null && record.notes!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '"${record.notes}"',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey[700],
                                  ),
                                ),
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

  String _formatAge(int days) {
    final months = days ~/ 30;
    final remainingDays = days % 30;
    if (months > 0 && remainingDays > 0) {
      return '${months}bln ${remainingDays}hr';
    } else if (months > 0) {
      return '${months}bln';
    } else {
      return '${remainingDays}hr';
    }
  }

  void _showAddWeightDialog(BuildContext context, WidgetRef ref) {
    final weightController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    int? calculateAgeDays() {
      return selectedDate.difference(offspring.birthDate).inDays;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final ageDays = calculateAgeDays();
          
          return AlertDialog(
            title: const Text('Tambah Data Berat'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Berat (kg)',
                      hintText: '0.5',
                      suffixText: 'kg',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: offspring.birthDate,
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Pengukuran',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                          const Icon(Icons.calendar_today, size: 20),
                        ],
                      ),
                    ),
                  ),
                  if (ageDays != null) ...[ 
                    const SizedBox(height: 8),
                    Text(
                      'Umur saat pengukuran: ${_formatAge(ageDays)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Keterangan (Opsional)',
                      hintText: 'Contoh: Setelah sapih, sebelum jual, dll.',
                      border: OutlineInputBorder(),
                    ),
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
                onPressed: () {
                  final weight = double.tryParse(weightController.text);
                  if (weight == null || weight <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Masukkan berat yang valid')),
                    );
                    return;
                  }
                  
                  ref.read(offspringWeightRecordNotifierProvider(offspring.id).notifier).create(
                    weight: weight,
                    ageDays: calculateAgeDays(),
                    recordedAt: selectedDate,
                    notes: notesController.text.trim().isEmpty 
                        ? null 
                        : notesController.text.trim(),
                  );
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data berat berhasil ditambahkan'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                ),
                child: const Text('Simpan'),
              ),
            ],
          );
        },
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

/// Helper function to show edit offspring panel from side
void showEditOffspringPanel(BuildContext context, Offspring offspring) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Edit Offspring',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: _EditOffspringPanel(offspring: offspring),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final slideAnimation = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      
      return SlideTransition(position: slideAnimation, child: child);
    },
  );
}

/// Edit Offspring Panel
class _EditOffspringPanel extends ConsumerStatefulWidget {
  final Offspring offspring;
  
  const _EditOffspringPanel({required this.offspring});

  @override
  ConsumerState<_EditOffspringPanel> createState() => _EditOffspringPanelState();
}

class _EditOffspringPanelState extends ConsumerState<_EditOffspringPanel> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late TextEditingController _notesController;
  
  late DateTime? _birthDate;
  late Gender _selectedGender;
  late OffspringStatus _selectedStatus;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final offspring = widget.offspring;
    _nameController = TextEditingController(text: offspring.name ?? '');
    _weightController = TextEditingController(text: offspring.weight?.toString() ?? '');
    _notesController = TextEditingController(text: offspring.notes ?? '');
    _birthDate = offspring.birthDate;
    _selectedGender = offspring.gender;
    _selectedStatus = offspring.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Pilih tanggal';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    setState(() => _errorMessage = null);
    
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final weight = _weightController.text.isEmpty 
          ? null 
          : double.tryParse(_weightController.text);
      
      // Build updated offspring object
      final updatedOffspring = widget.offspring.copyWith(
        name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
        gender: _selectedGender,
        birthDate: _birthDate,
        status: _selectedStatus,
        weight: weight,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      
      await ref.read(offspringNotifierProvider.notifier).update(updatedOffspring);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.offspring.displayName} berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final offspring = widget.offspring;
    final screenWidth = MediaQuery.of(context).size.width;
    final panelWidth = screenWidth > 600 ? 480.0 : screenWidth * 0.92;
    final colorScheme = Theme.of(context).colorScheme;
    final genderColor = offspring.gender == Gender.male 
        ? const Color(0xFF3B82F6) 
        : const Color(0xFFEC4899);

    return Container(
      width: panelWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 30,
            offset: const Offset(-8, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant.withAlpha(76)),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: genderColor.withAlpha(38),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      offspring.genderIcon,
                      style: TextStyle(fontSize: 20, color: genderColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit ${offspring.displayName}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Kode: ${offspring.code}',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error message
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Text(_errorMessage!, style: TextStyle(color: Colors.red[700])),
                      ),

                    // Name
                    const Text('Nama (Opsional)', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.pets),
                        border: OutlineInputBorder(),
                        hintText: 'Contoh: Kelinci Putih',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Gender
                    const Text('Jenis Kelamin', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _GenderOption(
                            gender: Gender.male,
                            isSelected: _selectedGender == Gender.male,
                            onTap: () => setState(() => _selectedGender = Gender.male),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _GenderOption(
                            gender: Gender.female,
                            isSelected: _selectedGender == Gender.female,
                            onTap: () => setState(() => _selectedGender = Gender.female),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Status
                    const Text('Status', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<OffspringStatus>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.info_outline),
                        border: OutlineInputBorder(),
                      ),
                      items: OffspringStatus.values.map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.displayName),
                      )).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedStatus = value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Birth Date
                    const Text('Tanggal Lahir', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: colorScheme.outline),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.cake, color: colorScheme.onSurfaceVariant),
                            const SizedBox(width: 12),
                            Text(_formatDate(_birthDate)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Weight
                    const Text('Berat (kg)', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.scale),
                        border: OutlineInputBorder(),
                        suffixText: 'kg',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    const Text('Catatan', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 48),
                          child: Icon(Icons.notes),
                        ),
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
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

class _GenderOption extends StatelessWidget {
  final Gender gender;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.gender,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = gender == Gender.female ? Colors.pink : Colors.blue;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? color.withAlpha(25) : null,
        ),
        child: Column(
          children: [
            Text(
              gender == Gender.male ? '♂' : '♀',
              style: TextStyle(fontSize: 24, color: isSelected ? color : Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              gender == Gender.male ? 'Jantan' : 'Betina',
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

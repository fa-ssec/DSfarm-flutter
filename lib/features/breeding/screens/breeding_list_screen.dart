/// Breeding List Screen
/// 
/// Screen untuk melihat dan mengelola breeding records.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/breeding_record.dart';
import '../../../models/livestock.dart';
import '../../../providers/breeding_provider.dart';
import '../../../providers/livestock_provider.dart';
import '../../../animal_modules/base/animal_config_factory.dart';
import '../../../providers/farm_provider.dart';
import '../../../widgets/shimmer_widgets.dart';
import 'breeding_analytics_screen.dart';
import 'breeding_calendar_screen.dart';

class BreedingListScreen extends ConsumerWidget {
  const BreedingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breedingAsync = ref.watch(breedingNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Breeding'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'analytics':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BreedingAnalyticsScreen()),
                  );
                  break;
                case 'calendar':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BreedingCalendarScreen()),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'analytics',
                child: Row(
                  children: [
                    Icon(Icons.bar_chart, size: 20),
                    SizedBox(width: 12),
                    Text('Analitik'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'calendar',
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, size: 20),
                    SizedBox(width: 12),
                    Text('Kalender'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: breedingAsync.when(
        loading: () => const ShimmerList(itemCount: 5),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () => ref.refresh(breedingNotifierProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (records) {
          if (records.isEmpty) {
            return _buildEmptyState(context, ref);
          }
          return _buildList(context, ref, records);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.favorite),
        label: const Text('Kawinkan'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'Belum ada data breeding',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Catat perkawinan pertama untuk mulai tracking',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreateDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Catat Perkawinan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, List<BreedingRecord> records) {
    // Group by status
    final active = records.where((r) => 
      r.status == BreedingStatus.mated || 
      r.status == BreedingStatus.palpated ||
      r.status == BreedingStatus.pregnant
    ).toList();
    
    final completed = records.where((r) => 
      r.status == BreedingStatus.birthed || 
      r.status == BreedingStatus.weaned
    ).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (active.isNotEmpty) ...[
          _SectionHeader(title: 'Aktif', count: active.length),
          ...active.map((r) => _BreedingCard(
            record: r,
            onTap: () => _showDetail(context, ref, r),
          )),
          const SizedBox(height: 16),
        ],
        if (completed.isNotEmpty) ...[
          _SectionHeader(title: 'Selesai', count: completed.length),
          ...completed.map((r) => _BreedingCard(
            record: r,
            onTap: () => _showDetail(context, ref, r),
          )),
        ],
      ],
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    String? selectedDamId;
    String? selectedSireId;
    DateTime matingDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        final femalesAsync = ref.watch(femaleLivestocksProvider);
        final malesAsync = ref.watch(maleLivestocksProvider);
        final farm = ref.watch(currentFarmProvider);
        final config = farm != null 
            ? AnimalConfigFactory.getConfig(farm.animalType) 
            : null;

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Catat Perkawinan'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dam selection
                    femalesAsync.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const Text('Error loading females'),
                      data: (females) => DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: config?.damTerm ?? 'Induk Betina',
                        ),
                        items: females.map((f) => DropdownMenuItem(
                          value: f.id,
                          child: Text(f.displayName),
                        )).toList(),
                        onChanged: (v) => selectedDamId = v,
                        validator: (v) => v == null ? 'Pilih induk' : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sire selection
                    malesAsync.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const Text('Error loading males'),
                      data: (males) => DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: config?.sireTerm ?? 'Pejantan',
                        ),
                        items: males.map((m) => DropdownMenuItem(
                          value: m.id,
                          child: Text(m.displayName),
                        )).toList(),
                        onChanged: (v) => selectedSireId = v,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Mating date
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: matingDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => matingDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: config?.matingTerm ?? 'Tanggal Kawin',
                        ),
                        child: Text('${matingDate.day}/${matingDate.month}/${matingDate.year}'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate() && selectedDamId != null) {
                    Navigator.pop(context);
                    
                    // Calculate expected birth date using config
                    DateTime? expectedBirth;
                    if (config != null) {
                      expectedBirth = config.calculateExpectedBirth(matingDate);
                    }
                    
                    await ref.read(breedingNotifierProvider.notifier).create(
                      damId: selectedDamId!,
                      sireId: selectedSireId,
                      matingDate: matingDate,
                      expectedBirthDate: expectedBirth,
                    );
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Perkawinan berhasil dicatat')),
                      );
                    }
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDetail(BuildContext context, WidgetRef ref, BreedingRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Header
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.favorite, color: Colors.red, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${record.damDisplayName} × ${record.sireDisplayName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(record.status).withAlpha(25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            record.status.displayName,
                            style: TextStyle(
                              color: _getStatusColor(record.status),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Details
              _DetailRow(label: 'Kawin', value: _formatDate(record.matingDate)),
              if (record.expectedBirthDate != null)
                _DetailRow(label: 'Perkiraan Lahir', value: _formatDate(record.expectedBirthDate!)),
              if (record.palpationDate != null)
                _DetailRow(
                  label: 'Palpasi',
                  value: '${_formatDate(record.palpationDate!)} - ${record.isPalpationPositive == true ? "Positif" : "Negatif"}',
                ),
              if (record.actualBirthDate != null)
                _DetailRow(label: 'Lahir', value: _formatDate(record.actualBirthDate!)),
              if (record.birthCount != null)
                _DetailRow(label: 'Jumlah Lahir', value: '${record.aliveCount} hidup, ${record.deadCount ?? 0} mati'),
              if (record.weaningDate != null)
                _DetailRow(label: 'Sapih', value: '${_formatDate(record.weaningDate!)} (${record.weanedCount} ekor)'),
              
              const SizedBox(height: 24),

              // Actions
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (record.status == BreedingStatus.mated)
                    OutlinedButton(
                      onPressed: () => _showPalpationDialog(context, ref, record),
                      child: const Text('Catat Palpasi'),
                    ),
                  if (record.status == BreedingStatus.pregnant)
                    ElevatedButton(
                      onPressed: () => _showBirthDialog(context, ref, record),
                      child: const Text('Catat Kelahiran'),
                    ),
                  if (record.status == BreedingStatus.birthed)
                    OutlinedButton(
                      onPressed: () => _showWeanDialog(context, ref, record),
                      child: const Text('Catat Penyapihan'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPalpationDialog(BuildContext context, WidgetRef ref, BreedingRecord record) {
    bool isPositive = true;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Hasil Palpasi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Positif'),
                      value: true,
                      groupValue: isPositive,
                      onChanged: (v) => setState(() => isPositive = v!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Negatif'),
                      value: false,
                      groupValue: isPositive,
                      onChanged: (v) => setState(() => isPositive = v!),
                    ),
                  ),
                ],
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
                Navigator.pop(context);
                await ref.read(breedingNotifierProvider.notifier).updatePalpation(
                  id: record.id,
                  palpationDate: DateTime.now(),
                  isPositive: isPositive,
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBirthDialog(BuildContext context, WidgetRef ref, BreedingRecord record) {
    final aliveController = TextEditingController(text: '0');
    final deadController = TextEditingController(text: '0');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Catat Kelahiran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: aliveController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Lahir Hidup'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: deadController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Lahir Mati'),
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
              Navigator.pop(context);
              final alive = int.tryParse(aliveController.text) ?? 0;
              final dead = int.tryParse(deadController.text) ?? 0;
              await ref.read(breedingNotifierProvider.notifier).updateBirth(
                id: record.id,
                birthDate: DateTime.now(),
                aliveCount: alive,
                deadCount: dead,
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showWeanDialog(BuildContext context, WidgetRef ref, BreedingRecord record) {
    final weanedController = TextEditingController(text: '${record.aliveCount ?? 0}');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Catat Penyapihan'),
        content: TextField(
          controller: weanedController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Jumlah Disapih'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              Navigator.pop(context);
              await ref.read(breedingNotifierProvider.notifier).updateWeaning(
                id: record.id,
                weaningDate: DateTime.now(),
                weanedCount: int.tryParse(weanedController.text) ?? 0,
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(BreedingStatus status) {
    switch (status) {
      case BreedingStatus.mated:
        return Colors.orange;
      case BreedingStatus.palpated:
        return Colors.blue;
      case BreedingStatus.pregnant:
        return Colors.pink;
      case BreedingStatus.birthed:
        return Colors.green;
      case BreedingStatus.weaned:
        return Colors.teal;
      case BreedingStatus.failed:
        return Colors.grey;
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreedingCard extends StatelessWidget {
  final BreedingRecord record;
  final VoidCallback onTap;

  const _BreedingCard({required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.favorite, color: Colors.red),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${record.damDisplayName} × ${record.sireDisplayName}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withAlpha(25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            record.status.displayName,
                            style: TextStyle(fontSize: 10, color: _getStatusColor()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${record.daysSinceMating} hari lalu',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (record.status) {
      case BreedingStatus.mated:
        return Colors.orange;
      case BreedingStatus.palpated:
        return Colors.blue;
      case BreedingStatus.pregnant:
        return Colors.pink;
      case BreedingStatus.birthed:
        return Colors.green;
      case BreedingStatus.weaned:
        return Colors.teal;
      case BreedingStatus.failed:
        return Colors.grey;
    }
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
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

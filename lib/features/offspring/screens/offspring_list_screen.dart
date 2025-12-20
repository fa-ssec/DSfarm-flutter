/// Offspring List Screen
/// 
/// Screen untuk melihat dan mengelola anakan.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/offspring.dart';
import '../../../providers/offspring_provider.dart';

class OffspringListScreen extends ConsumerStatefulWidget {
  const OffspringListScreen({super.key});

  @override
  ConsumerState<OffspringListScreen> createState() => _OffspringListScreenState();
}

class _OffspringListScreenState extends ConsumerState<OffspringListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Anakan'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Di Farm'),
            Tab(text: 'Siap Jual'),
            Tab(text: 'Terjual'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OffspringTab(filter: null),
          _OffspringTab(filter: OffspringStatus.infarm),
          _OffspringTab(filter: OffspringStatus.readySell),
          _OffspringTab(filter: OffspringStatus.sold),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add offspring
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tambah anakan via Breeding Record')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _OffspringTab extends ConsumerWidget {
  final OffspringStatus? filter;

  const _OffspringTab({this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offspringsAsync = ref.watch(offspringNotifierProvider);

    return offspringsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Error: $error'),
            ElevatedButton(
              onPressed: () => ref.refresh(offspringNotifierProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (offsprings) {
        // Apply filter
        final filtered = filter == null
            ? offsprings
            : offsprings.where((o) => o.status == filter).toList();

        if (filtered.isEmpty) {
          return _buildEmptyState(filter);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final offspring = filtered[index];
            return _OffspringCard(
              offspring: offspring,
              onTap: () => _showDetail(context, ref, offspring),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(OffspringStatus? filter) {
    final label = filter == null
        ? 'anakan'
        : filter == OffspringStatus.infarm
            ? 'anakan di farm'
            : filter == OffspringStatus.readySell
                ? 'anakan siap jual'
                : 'anakan terjual';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.child_care, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Belum ada $label',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Anakan akan muncul setelah terdaftar di Breeding Record',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, WidgetRef ref, Offspring offspring) {
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
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.orange.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        offspring.genderIcon,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offspring.displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Kode: ${offspring.code}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(offspring.status).withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      offspring.status.displayName,
                      style: TextStyle(
                        color: _getStatusColor(offspring.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailRow(label: 'Umur', value: offspring.ageFormatted),
              _DetailRow(label: 'Gender', value: offspring.gender.displayName),
              if (offspring.damCode != null)
                _DetailRow(label: 'Induk', value: offspring.damCode!),
              if (offspring.sireCode != null)
                _DetailRow(label: 'Pejantan', value: offspring.sireCode!),
              if (offspring.housingCode != null)
                _DetailRow(label: 'Kandang', value: offspring.housingCode!),
              if (offspring.weight != null)
                _DetailRow(label: 'Berat', value: '${offspring.weight} kg'),
              if (offspring.isWeaned)
                _DetailRow(label: 'Sapih', value: 'Sudah'),
              const SizedBox(height: 24),
              
              // Quick Actions
              Wrap(
                spacing: 8,
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
                      icon: const Icon(Icons.sell),
                      label: const Text('Siap Jual'),
                    ),
                  if (offspring.status == OffspringStatus.readySell)
                    ElevatedButton.icon(
                      onPressed: () => _showSellDialog(context, ref, offspring),
                      icon: const Icon(Icons.payments),
                      label: const Text('Jual'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSellDialog(BuildContext context, WidgetRef ref, Offspring offspring) {
    final priceController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Jual Anakan'),
        content: TextField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Harga Jual',
            prefixText: 'Rp ',
          ),
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
              await ref.read(offspringNotifierProvider.notifier).updateStatus(
                offspring.id,
                OffspringStatus.sold,
                salePrice: double.tryParse(priceController.text),
                saleDate: DateTime.now(),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Anakan berhasil dijual')),
                );
              }
            },
            child: const Text('Jual'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OffspringStatus status) {
    switch (status) {
      case OffspringStatus.infarm:
        return Colors.blue;
      case OffspringStatus.weaned:
        return Colors.teal;
      case OffspringStatus.readySell:
        return Colors.orange;
      case OffspringStatus.sold:
        return Colors.green;
      case OffspringStatus.deceased:
        return Colors.grey;
      case OffspringStatus.promoted:
        return Colors.purple;
    }
  }
}

class _OffspringCard extends StatelessWidget {
  final Offspring offspring;
  final VoidCallback onTap;

  const _OffspringCard({required this.offspring, required this.onTap});

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
                  color: Colors.orange.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    offspring.genderIcon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          offspring.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withAlpha(25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            offspring.status.displayName,
                            style: TextStyle(
                              fontSize: 10,
                              color: _getStatusColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${offspring.ageFormatted} • ${offspring.damCode ?? "Induk tidak diketahui"}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
    switch (offspring.status) {
      case OffspringStatus.infarm:
        return Colors.blue;
      case OffspringStatus.weaned:
        return Colors.teal;
      case OffspringStatus.readySell:
        return Colors.orange;
      case OffspringStatus.sold:
        return Colors.green;
      case OffspringStatus.deceased:
        return Colors.grey;
      case OffspringStatus.promoted:
        return Colors.purple;
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
            width: 100,
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

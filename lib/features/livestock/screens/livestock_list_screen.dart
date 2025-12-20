/// Livestock List Screen
/// 
/// Screen untuk melihat dan mengelola indukan/pejantan.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/livestock.dart';
import '../../../providers/livestock_provider.dart';
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
                      color: livestock.isFemale 
                          ? Colors.pink.withAlpha(25) 
                          : Colors.blue.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        livestock.genderIcon,
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
                          livestock.displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Kode: ${livestock.code}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailRow(label: 'Gender', value: livestock.gender.displayName),
              _DetailRow(label: 'Umur', value: livestock.ageFormatted),
              if (livestock.breedName != null)
                _DetailRow(label: 'Ras', value: livestock.breedName!),
              if (livestock.housingCode != null)
                _DetailRow(label: 'Kandang', value: livestock.housingCode!),
              _DetailRow(label: 'Generasi', value: 'F${livestock.generation}'),
              if (livestock.weight != null)
                _DetailRow(label: 'Berat', value: '${livestock.weight} kg'),
              _DetailRow(label: 'Status', value: livestock.status.displayName),
              if (livestock.notes != null)
                _DetailRow(label: 'Catatan', value: livestock.notes!),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Edit
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDelete(context, ref, livestock);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      icon: const Icon(Icons.delete),
                      label: const Text('Hapus'),
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

  void _confirmDelete(BuildContext context, WidgetRef ref, Livestock livestock) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Indukan?'),
        content: Text('Apakah Anda yakin ingin menghapus ${livestock.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(livestockNotifierProvider.notifier).delete(livestock.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${livestock.displayName} dihapus')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _LivestockCard extends StatelessWidget {
  final Livestock livestock;
  final VoidCallback onTap;

  const _LivestockCard({required this.livestock, required this.onTap});

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
                  color: livestock.isFemale 
                      ? Colors.pink.withAlpha(25) 
                      : Colors.blue.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    livestock.genderIcon,
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
                          livestock.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (livestock.breedName != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              livestock.breedName!,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${livestock.ageFormatted} • ${livestock.housingCode ?? "Belum ada kandang"}',
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

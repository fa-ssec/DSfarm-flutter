/// Housing List Screen (Grid View)
/// 
/// Screen untuk melihat kandang dalam format grid yang compact.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/housing.dart';
import '../../../providers/housing_provider.dart';
import '../../../providers/livestock_provider.dart';
import 'create_housing_screen.dart';

class HousingListScreen extends ConsumerWidget {
  const HousingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final housingsAsync = ref.watch(housingNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kandang')),
      body: housingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (housings) => housings.isEmpty
            ? _buildEmptyState(context)
            : _buildGridView(context, ref, housings),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateHousingScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Belum ada kandang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Tambahkan kandang untuk mulai', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildGridView(BuildContext context, WidgetRef ref, List<Housing> housings) {
    // Group by block (from code prefix, e.g., "AA-01" -> "AA")
    final grouped = <String, List<Housing>>{};
    for (final h in housings) {
      final parts = h.code.split('-');
      final block = parts.length >= 2 ? parts.first : 'Lainnya';
      grouped.putIfAbsent(block, () => []).add(h);
    }

    // Get levels per block
    Map<String, Set<String>> blockLevels = {};
    for (final entry in grouped.entries) {
      blockLevels[entry.key] = entry.value
          .where((h) => h.level != null && h.level!.isNotEmpty)
          .map((h) => h.level!)
          .toSet();
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(housingNotifierProvider),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: grouped.length,
        itemBuilder: (context, index) {
          final block = grouped.keys.elementAt(index);
          final items = grouped[block]!..sort((a, b) => a.code.compareTo(b.code));
          final levels = blockLevels[block] ?? {};
          final available = items.where((h) => (h.currentOccupancy ?? 0) < h.capacity).length;

          return _BlockSection(
            block: block,
            housings: items,
            levels: levels.toList(),
            availableCount: available,
            onHousingTap: (h) => _showHousingDetail(context, ref, h),
          );
        },
      ),
    );
  }

  void _showHousingDetail(BuildContext context, WidgetRef ref, Housing housing) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _HousingDetailSheet(housing: housing),
    );
  }
}

class _BlockSection extends StatelessWidget {
  final String block;
  final List<Housing> housings;
  final List<String> levels;
  final int availableCount;
  final Function(Housing) onHousingTap;

  const _BlockSection({
    required this.block,
    required this.housings,
    required this.levels,
    required this.availableCount,
    required this.onHousingTap,
  });

  Color _levelColor(String level) {
    switch (level.toLowerCase()) {
      case 'bawah': return Colors.green;
      case 'tengah': return Colors.orange;
      case 'atas': return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Block name + levels + count
            Row(
              children: [
                Text(
                  '${housings.length}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Blok $block',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (levels.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          children: levels.map((l) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _levelColor(l).withAlpha(30),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              l,
                              style: TextStyle(fontSize: 10, color: _levelColor(l)),
                            ),
                          )).toList(),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$availableCount',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[600],
                      ),
                    ),
                    Text('tersedia', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Grid of housing cards
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: housings.map((h) => _HousingCard(
                housing: h,
                onTap: () => onHousingTap(h),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _HousingCard extends StatelessWidget {
  final Housing housing;
  final VoidCallback onTap;

  const _HousingCard({required this.housing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final occupancy = housing.currentOccupancy ?? 0;
    final isFull = occupancy >= housing.capacity;
    final color = isFull ? Colors.purple : Colors.green;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 72,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          children: [
            // Dot indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.home, size: 16, color: color),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isFull ? Colors.purple : Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Code
            Text(
              housing.code,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            // Occupancy
            Text(
              '$occupancy/${housing.capacity}',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _HousingDetailSheet extends ConsumerWidget {
  final Housing housing;

  const _HousingDetailSheet({required this.housing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get livestock in this housing
    final livestockAsync = ref.watch(livestockNotifierProvider);
    final occupants = livestockAsync.valueOrNull
        ?.where((l) => l.housingId == housing.id)
        .toList() ?? [];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.home_work, color: Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(housing.code, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Kapasitas: ${housing.currentOccupancy ?? 0}/${housing.capacity}'),
                  ],
                ),
              ),
              if (housing.level != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(housing.level!, style: const TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Occupants
          Text(
            'Ternak di Kandang Ini:',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          if (occupants.isEmpty)
            Text('Kosong', style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic))
          else
            ...occupants.map((l) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: l.gender.value == 'female' ? Colors.pink[50] : Colors.blue[50],
                child: Text(l.gender.value == 'female' ? '♀' : '♂'),
              ),
              title: Text(l.code),
              subtitle: l.name != null ? Text(l.name!) : null,
              trailing: Text(l.status.displayName),
            )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Lineage Screen
/// 
/// Screen untuk menampilkan pohon silsilah ternak.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/lineage_service.dart';
import '../../../widgets/lineage_tree_widget.dart';

/// Provider untuk lineage service
final lineageServiceProvider = Provider((ref) {
  return LineageService(Supabase.instance.client);
});

/// Provider untuk fetch offspring lineage
final offspringLineageProvider = FutureProvider.family<LineageNode, String>((ref, offspringId) async {
  final service = ref.watch(lineageServiceProvider);
  return service.buildOffspringLineage(offspringId);
});

/// Provider untuk fetch livestock lineage
final livestockLineageProvider = FutureProvider.family<LineageNode, String>((ref, livestockId) async {
  final service = ref.watch(lineageServiceProvider);
  return service.buildLivestockLineage(livestockId);
});

class LineageScreen extends ConsumerWidget {
  final String? offspringId;
  final String? livestockId;

  const LineageScreen({
    super.key,
    this.offspringId,
    this.livestockId,
  }) : assert(offspringId != null || livestockId != null, 'Either offspringId or livestockId must be provided');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine which provider to use
    final asyncLineage = offspringId != null
        ? ref.watch(offspringLineageProvider(offspringId!))
        : ref.watch(livestockLineageProvider(livestockId!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Silsilah Ternak'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Bantuan',
            onPressed: () => _showHelp(context),
          ),
        ],
      ),
      body: asyncLineage.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memuat silsilah...'),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(
                  offspringId != null 
                      ? offspringLineageProvider(offspringId!)
                      : livestockLineageProvider(livestockId!),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (lineage) => Column(
          children: [
            // Legend
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegendItem(color: Colors.blue, label: 'Jantan'),
                  const SizedBox(width: 16),
                  _LegendItem(color: Colors.pink, label: 'Betina'),
                  const SizedBox(width: 16),
                  _LegendItem(color: Colors.grey, label: 'Tidak Diketahui'),
                ],
              ),
            ),
            
            // Tree
            Expanded(
              child: lineage.hasParents
                  ? LineageTreeWidget(rootNode: lineage)
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LineageTreeWidget(rootNode: lineage),
                          const SizedBox(height: 24),
                          const Text(
                            'Belum ada data silsilah',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Data induk dan pejantan tidak tersedia',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
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

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cara Membaca Silsilah'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Ternak utama ada di sebelah kiri'),
            SizedBox(height: 8),
            Text('• Garis ke kanan menunjukkan orang tua'),
            SizedBox(height: 8),
            Text('• Atas = Pejantan (Ayah)'),
            Text('• Bawah = Induk (Ibu)'),
            SizedBox(height: 8),
            Text('• Scroll horizontal untuk lihat lebih jauh'),
            SizedBox(height: 8),
            Text('• Maksimal 3 generasi ditampilkan'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }
}

/// Legend item widget
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

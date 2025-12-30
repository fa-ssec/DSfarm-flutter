/// Offspring List Screen
/// 
/// Screen untuk melihat dan mengelola anakan.
/// Redesigned to match reference with card grid, filter tabs, view toggle.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/dashboard_shell.dart';
import '../../../models/offspring.dart';
import '../../../providers/offspring_provider.dart';
import '../widgets/offspring_detail_modal.dart';
import 'batch_sell_screen.dart';

class OffspringListScreen extends ConsumerStatefulWidget {
  const OffspringListScreen({super.key});

  @override
  ConsumerState<OffspringListScreen> createState() => _OffspringListScreenState();
}

class _OffspringListScreenState extends ConsumerState<OffspringListScreen> {
  String _filter = 'all'; // all, infarm, readySell, sold
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final offspringsAsync = ref.watch(offspringNotifierProvider);

    return DashboardShell(
      selectedIndex: 2, // Anakan
      child: offspringsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (offsprings) {
          // Count by status
          final allCount = offsprings.length;
          final infarmCount = offsprings.where((o) => o.effectiveStatus == OffspringStatus.infarm).length;
          final readySellCount = offsprings.where((o) => o.effectiveStatus == OffspringStatus.readySell).length;
          final soldCount = offsprings.where((o) => o.status == OffspringStatus.sold).length;
          
          // Apply filter
          final filtered = _filter == 'all'
              ? offsprings
              : _filter == 'infarm'
                  ? offsprings.where((o) => o.effectiveStatus == OffspringStatus.infarm).toList()
                  : _filter == 'readySell'
                      ? offsprings.where((o) => o.effectiveStatus == OffspringStatus.readySell).toList()
                      : offsprings.where((o) => o.status == OffspringStatus.sold).toList();

          return Column(
            children: [
              // ═══════════════════════════════════════════
              // HEADER
              // ═══════════════════════════════════════════
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Anakan', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text('$allCount ekor anakan', style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showAddOptions(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Jual Batch'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Filter tabs and view toggle row
                    Row(
                      children: [
                        // Filter pills
                        _FilterPill(
                          label: 'Semua',
                          count: allCount,
                          isSelected: _filter == 'all',
                          onTap: () => setState(() => _filter = 'all'),
                        ),
                        const SizedBox(width: 8),
                        _FilterPill(
                          label: 'Di Farm',
                          count: infarmCount,
                          isSelected: _filter == 'infarm',
                          onTap: () => setState(() => _filter = 'infarm'),
                        ),
                        const SizedBox(width: 8),
                        _FilterPill(
                          label: 'Siap Jual',
                          count: readySellCount,
                          isSelected: _filter == 'readySell',
                          onTap: () => setState(() => _filter = 'readySell'),
                        ),
                        const SizedBox(width: 8),
                        _FilterPill(
                          label: 'Terjual',
                          count: soldCount,
                          isSelected: _filter == 'sold',
                          onTap: () => setState(() => _filter = 'sold'),
                        ),
                        const Spacer(),
                        // View toggle
                        Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              _ViewToggle(
                                icon: Icons.grid_view_rounded,
                                isSelected: _isGridView,
                                onTap: () => setState(() => _isGridView = true),
                              ),
                              _ViewToggle(
                                icon: Icons.view_list_rounded,
                                isSelected: !_isGridView,
                                onTap: () => setState(() => _isGridView = false),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // ═══════════════════════════════════════════
              // CONTENT
              // ═══════════════════════════════════════════
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState(context)
                    : _isGridView
                        ? _buildGridView(context, filtered)
                        : _buildListView(context, filtered),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const BatchSellScreen()));
  }

  Widget _buildGridView(BuildContext context, List<Offspring> filtered) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 4 
            : constraints.maxWidth > 900 ? 3 
            : constraints.maxWidth > 600 ? 2 
            : 1;
        
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) => _OffspringCard(
            offspring: filtered[index],
            onTap: () => showOffspringDetailModal(context, ref, filtered[index]),
          ),
        );
      },
    );
  }

  Widget _buildListView(BuildContext context, List<Offspring> filtered) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _OffspringListItem(
        offspring: filtered[index],
        onTap: () => showOffspringDetailModal(context, ref, filtered[index]),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = _filter == 'all' ? 'anakan' 
        : _filter == 'infarm' ? 'anakan di farm' 
        : _filter == 'readySell' ? 'anakan siap jual' 
        : 'anakan terjual';
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care, size: 64, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text('Belum ada $label', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text('Anakan akan muncul setelah breeding record', style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FILTER PILL
// ═══════════════════════════════════════════════════════════════════════════
class _FilterPill extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1F2937) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF1F2937) : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// VIEW TOGGLE
// ═══════════════════════════════════════════════════════════════════════════
class _ViewToggle extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewToggle({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// OFFSPRING CARD (Grid View)
// ═══════════════════════════════════════════════════════════════════════════
class _OffspringCard extends StatelessWidget {
  final Offspring offspring;
  final VoidCallback onTap;

  const _OffspringCard({required this.offspring, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFemale = offspring.gender.value == 'female';
    final genderColor = isFemale ? const Color(0xFFEC4899) : const Color(0xFF3B82F6);
    final genderBgColor = isFemale ? const Color(0xFFFCE7F3) : const Color(0xFFDBEAFE);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gender icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: genderBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    offspring.genderIcon,
                    style: TextStyle(fontSize: 24, color: genderColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ID and Status
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            offspring.displayName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(status: offspring.effectiveStatus),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Induk
                    Text(
                      'Induk: ${offspring.damCode ?? '-'}',
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    // Umur
                    Text(
                      'Umur: ${offspring.ageFormatted}',
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    // Berat
                    Text(
                      'Berat: ${offspring.weight != null ? '${offspring.weight} kg' : '-'}',
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// OFFSPRING LIST ITEM (List View)
// ═══════════════════════════════════════════════════════════════════════════
class _OffspringListItem extends StatelessWidget {
  final Offspring offspring;
  final VoidCallback onTap;

  const _OffspringListItem({required this.offspring, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFemale = offspring.gender.value == 'female';
    final genderColor = isFemale ? const Color(0xFFEC4899) : const Color(0xFF3B82F6);
    final genderBgColor = isFemale ? const Color(0xFFFCE7F3) : const Color(0xFFDBEAFE);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Gender icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: genderBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    offspring.genderIcon,
                    style: TextStyle(fontSize: 20, color: genderColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            offspring.displayName, 
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(status: offspring.effectiveStatus),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${offspring.damCode ?? '-'} • ${offspring.ageFormatted} • ${offspring.weight != null ? '${offspring.weight} kg' : '-'}',
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STATUS BADGE
// ═══════════════════════════════════════════════════════════════════════════
class _StatusBadge extends StatelessWidget {
  final OffspringStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case OffspringStatus.infarm:
        bgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF1D4ED8);
      case OffspringStatus.weaned:
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF047857);
      case OffspringStatus.readySell:
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFB45309);
      case OffspringStatus.sold:
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF047857);
      case OffspringStatus.deceased:
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFB91C1C);
      case OffspringStatus.promoted:
        bgColor = const Color(0xFFE0E7FF);
        textColor = const Color(0xFF4338CA);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }
}

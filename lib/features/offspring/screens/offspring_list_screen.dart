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
import '../../../providers/health_provider.dart';
import '../widgets/offspring_detail_modal.dart';
import 'batch_sell_screen.dart';

class OffspringListScreen extends ConsumerStatefulWidget {
  const OffspringListScreen({super.key});

  @override
  ConsumerState<OffspringListScreen> createState() => _OffspringListScreenState();
}

class _OffspringListScreenState extends ConsumerState<OffspringListScreen> {
  final MenuController _menuController = MenuController();
  
  Set<OffspringStatus> _selectedStatuses = {}; // Default empty = Active Only (implicit)
  Set<Gender> _selectedGenders = {};
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
          // Apply Advanced Filter
          var filtered = offsprings.where((o) {
            final effective = o.effectiveStatus;
            
            final matchesGender = _selectedGenders.isEmpty || _selectedGenders.contains(o.gender);
            
            // Status Logic: Empty = Active Only. Selected = Explicit Match.
            final matchesStatus = _selectedStatuses.isEmpty 
                ? effective.isActive 
                : _selectedStatuses.contains(effective);
                
            return matchesGender && matchesStatus;
          }).toList();
          
          final totalActive = _selectedStatuses.length + _selectedGenders.length;

          // Calculate stats
          final allCount = offsprings.length;
          final activeCount = offsprings.where((o) => o.effectiveStatus.isActive).length;
          final soldCount = offsprings.where((o) => o.effectiveStatus == OffspringStatus.sold).length;
          final deceasedCount = offsprings.where((o) => o.effectiveStatus == OffspringStatus.deceased).length;
          final promotedCount = offsprings.where((o) => o.effectiveStatus == OffspringStatus.promoted).length;
          final exitedCount = soldCount + deceasedCount + promotedCount;


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
                    // ═══════════════════════════════════════════
                    // STAT CARDS ROW
                    // ═══════════════════════════════════════════
                    Row(
                      children: [
                        // Di Farm Card
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => setState(() => _selectedStatuses.clear()),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('DI FARM', style: TextStyle(fontSize: 12, color: Colors.green[600], fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                                          Icon(Icons.home_rounded, color: Colors.green[400], size: 24),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text('$activeCount', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                                          const SizedBox(width: 6),
                                          Text('Ekor', style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text('Active offspring', style: TextStyle(fontSize: 12, color: Colors.green[500])),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Keluar Card
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => setState(() => _selectedStatuses = {OffspringStatus.sold, OffspringStatus.deceased, OffspringStatus.promoted}),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('KELUAR', style: TextStyle(fontSize: 12, color: Colors.orange[600], fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                                          Icon(Icons.exit_to_app_rounded, color: Colors.orange[400], size: 24),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text('$exitedCount', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                                          const SizedBox(width: 6),
                                          Text('Ekor', style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 4,
                                        children: [
                                          Text('Terjual: $soldCount', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                                          Text('|', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                                          Text('Mati: $deceasedCount', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Total Card
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => setState(() => _selectedStatuses = OffspringStatus.values.toSet()),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('TOTAL', style: TextStyle(fontSize: 12, color: Colors.blue[600], fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                                          Icon(Icons.access_time_rounded, color: Colors.blue[400], size: 24),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text('$allCount', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                                          const SizedBox(width: 6),
                                          Text('Record', style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text('All time history', style: TextStyle(fontSize: 12, color: Colors.blue[500])),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ═══════════════════════════════════════════
                    // CONTROLS ROW: View Toggle | Filter | Buttons
                    // ═══════════════════════════════════════════
                    Row(
                      children: [
                        // View toggle
                        Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
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
                        const SizedBox(width: 8),
                        // Filter Button
                        MenuAnchor(
                          controller: _menuController,
                          alignmentOffset: const Offset(0, 8),
                          builder: (context, controller, child) {
                            return OutlinedButton.icon(
                              onPressed: () {
                                if (controller.isOpen) {
                                  controller.close();
                                } else {
                                  controller.open();
                                }
                              },
                              icon: const Icon(Icons.filter_list, size: 18),
                              label: Text('Filter ${totalActive > 0 ? '($totalActive)' : ''}'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.onSurface,
                                side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            );
                          },
                          menuChildren: [
                            _FilterMenu(
                              allOffspring: offsprings,
                              selectedGenders: _selectedGenders,
                              selectedStatuses: _selectedStatuses,
                              onGendersChanged: (val) => setState(() => _selectedGenders = val),
                              onStatusesChanged: (val) => setState(() => _selectedStatuses = val),
                              onReset: () {
                                setState(() {
                                  _selectedGenders.clear();
                                  _selectedStatuses.clear();
                                });
                              },
                              onClose: () => _menuController.close(),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Jual Batch Button
                        ElevatedButton.icon(
                          onPressed: () => _showAddOptions(context),
                          icon: const Icon(Icons.sell_outlined, size: 18),
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
    showBatchSellPanel(context);
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
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 240, // Same as livestock
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0, // Adjusted to prevent overflow
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Table Header
          Container(
            color: const Color(0xFFF9FAFB),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = MediaQuery.of(context).size.width < 600;
                if (isMobile) {
                  // Mobile: 3 columns
                  return Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'ID', 
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600], letterSpacing: 0.5),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'UMUR', 
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600], letterSpacing: 0.5),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'STATUS', 
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600], letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  );
                }
                // Desktop: 5 columns
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'ID ANAKAN', 
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600], letterSpacing: 0.5),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'KELAMIN', 
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600], letterSpacing: 0.5),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'UMUR', 
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600], letterSpacing: 0.5),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'BERAT', 
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600], letterSpacing: 0.5),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'STATUS', 
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600], letterSpacing: 0.5),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          // Table Body
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
              itemBuilder: (context, index) => _OffspringListItem(
                offspring: filtered[index],
                onTap: () => showOffspringDetailModal(context, ref, filtered[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care, size: 64, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text('Belum ada data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text('Coba reset filter atau tambahkan data baru', style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _FilterMenu extends StatelessWidget {
  final List<Offspring> allOffspring;
  final Set<Gender> selectedGenders;
  final Set<OffspringStatus> selectedStatuses;
  final Function(Set<Gender>) onGendersChanged;
  final Function(Set<OffspringStatus>) onStatusesChanged;
  final VoidCallback onReset;
  final VoidCallback onClose;

  const _FilterMenu({
    required this.allOffspring,
    required this.selectedGenders,
    required this.selectedStatuses,
    required this.onGendersChanged,
    required this.onStatusesChanged,
    required this.onReset,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Calculate Counts (using effectiveStatus)
    final genderCounts = <Gender, int>{};
    final statusCounts = <OffspringStatus, int>{};

    for (var o in allOffspring) {
      genderCounts[o.gender] = (genderCounts[o.gender] ?? 0) + 1;
      statusCounts[o.effectiveStatus] = (statusCounts[o.effectiveStatus] ?? 0) + 1;
    }

    return Container(
      width: 320,
      constraints: const BoxConstraints(maxHeight: 480),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFF9FAFB),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 const Text('Filter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                 Row(
                   children: [
                     if (selectedGenders.isNotEmpty || selectedStatuses.isNotEmpty)
                       TextButton(
                         onPressed: onReset,
                         style: TextButton.styleFrom(
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                           foregroundColor: Colors.red[600],
                           textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                         ),
                         child: const Text('Reset Semua'),
                       ),
                     IconButton(
                       icon: const Icon(Icons.close, size: 20),
                       onPressed: onClose,
                       padding: EdgeInsets.zero,
                       constraints: const BoxConstraints(),
                       splashRadius: 24,
                     ),
                   ],
                 ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- GENDER ---
                  _buildSectionHeader('Jenis Kelamin'),
                  _buildCheckboxTile(
                    title: 'Betina',
                    count: genderCounts[Gender.female] ?? 0,
                    value: selectedGenders.contains(Gender.female),
                    onChanged: (val) {
                      final newSet = Set<Gender>.from(selectedGenders);
                      if (val == true) {
                        newSet.add(Gender.female);
                      } else {
                        newSet.remove(Gender.female);
                      }
                      onGendersChanged(newSet);
                    },
                  ),
                  _buildCheckboxTile(
                    title: 'Jantan',
                    count: genderCounts[Gender.male] ?? 0,
                    value: selectedGenders.contains(Gender.male),
                    onChanged: (val) {
                      final newSet = Set<Gender>.from(selectedGenders);
                      if (val == true) {
                        newSet.add(Gender.male);
                      } else {
                        newSet.remove(Gender.male);
                      }
                      onGendersChanged(newSet);
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),

                  // --- STATUS ---
                  _buildSectionHeader('Status'),
                   // Show all statuses
                   ...OffspringStatus.values.map((status) {
                     return _buildCheckboxTile(
                      title: status.displayName,
                      count: statusCounts[status] ?? 0,
                      value: selectedStatuses.contains(status),
                      onChanged: (val) {
                        final newSet = Set<OffspringStatus>.from(selectedStatuses);
                        if (val == true) {
                          newSet.add(status);
                        } else {
                          newSet.remove(status);
                        }
                        onStatusesChanged(newSet);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          
          // ACTIVE FILTER CHIPS FOOTER (If any selected)
          if (selectedGenders.isNotEmpty || selectedStatuses.isNotEmpty) ...[
             const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
             Container(
               padding: const EdgeInsets.all(16),
               color: const Color(0xFFF9FAFB),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text('Filter Aktif (${selectedGenders.length + selectedStatuses.length}):', 
                     style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF4B5563))
                   ),
                   const SizedBox(height: 8),
                   Wrap(
                     spacing: 8,
                     runSpacing: 8,
                     children: [
                       ...selectedGenders.map((gender) => _buildChip(
                         label: gender == Gender.male ? 'Jantan' : 'Betina',
                         onDeleted: () {
                           final newSet = Set<Gender>.from(selectedGenders)..remove(gender);
                           onGendersChanged(newSet);
                         },
                       )),
                       ...selectedStatuses.map((status) => _buildChip(
                         label: status.displayName,
                         onDeleted: () {
                           final newSet = Set<OffspringStatus>.from(selectedStatuses)..remove(status);
                           onStatusesChanged(newSet);
                         },
                       )),
                     ],
                   ),
                 ],
               ),
             ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF374151)),
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required int count,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // More compact
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: value,
                  onChanged: onChanged,
                  activeColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)))),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(), 
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip({required String label, required VoidCallback onDeleted}) {
    return Chip(
      label: Text(label),
      onDeleted: onDeleted,
      backgroundColor: const Color(0xFFE5E7EB),
      labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
      deleteIconColor: const Color(0xFF6B7280),
      padding: const EdgeInsets.all(0),
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
    );
  }
}


// ═══════════════════════════════════════════════════════════════════════════
// FILTER PILL
// ═══════════════════════════════════════════════════════════════════════════


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
class _OffspringCard extends ConsumerWidget {
  final Offspring offspring;
  final VoidCallback onTap;

  const _OffspringCard({required this.offspring, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFemale = offspring.gender.value == 'female';
    final genderColor = isFemale ? const Color(0xFFEC4899) : const Color(0xFF3B82F6);
    final genderBgColor = isFemale ? const Color(0xFFFCE7F3) : const Color(0xFFDBEAFE);
    
    // Check if new (created within last 1 minute)
    final isNew = DateTime.now().difference(offspring.createdAt).inMinutes < 1;
    
    // Get latest health record
    final healthAsync = ref.watch(healthByOffspringProvider(offspring.id));
    final latestHealthTitle = healthAsync.maybeWhen(
      data: (records) => records.isNotEmpty ? records.first.title : 'Sehat',
      orElse: () => '-',
    );

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Gender icon + Code + Badge + Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gender icon
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: genderBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        offspring.genderIcon,
                        style: TextStyle(fontSize: 16, color: genderColor, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Code and Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                offspring.code,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isNew) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'BARU',
                                  style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        _StatusBadge(status: offspring.effectiveStatus),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Details in table-like rows - wrapped in Expanded to fill remaining space
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDetailRow(context, 'Induk', offspring.damCode ?? '-', null),
                    _buildDetailRow(context, 'Umur', offspring.ageFormatted, null),
                    _buildDetailRow(context, 'Berat', offspring.weight != null ? '${offspring.weight} kg' : '-', null),
                    _buildDetailRow(context, 'Kesehatan', latestHealthTitle, Colors.orange[700]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, Color? valueColor) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? colorScheme.onSurface)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// OFFSPRING LIST ITEM (Table Row)
// ═══════════════════════════════════════════════════════════════════════════
class _OffspringListItem extends StatelessWidget {
  final Offspring offspring;
  final VoidCallback onTap;

  const _OffspringListItem({required this.offspring, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isFemale = offspring.gender.value == 'female';
    final genderColor = isFemale ? const Color(0xFFEC4899) : const Color(0xFF3B82F6);
    
    // Check if new (created within last 1 minute)
    final isNew = DateTime.now().difference(offspring.createdAt).inMinutes < 1;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = MediaQuery.of(context).size.width < 600;
            
            if (isMobile) {
              // Mobile: 3 columns - ID, Age, Status
              return Row(
                children: [
                  // ID
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            offspring.displayName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isNew) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'BARU',
                              style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Age
                  Expanded(
                    flex: 1,
                    child: Text(
                      offspring.ageFormatted,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
                  // Status
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _StatusBadge(status: offspring.effectiveStatus),
                    ),
                  ),
                ],
              );
            }
            
            // Desktop: 5 columns
            return Row(
              children: [
                // ID
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Text(
                        offspring.displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isNew) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'BARU',
                            style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Gender
                Expanded(
                  flex: 1,
                  child: Text(
                    isFemale ? '♀' : '♂',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: genderColor,
                    ),
                  ),
                ),
                // Umur
                Expanded(
                  flex: 2,
                  child: Text(
                    offspring.ageFormatted,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
                // Berat
                Expanded(
                  flex: 2,
                  child: Text(
                    offspring.weight != null ? '${offspring.weight} kg' : '-',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
                // Status
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _StatusBadge(status: offspring.effectiveStatus),
                  ),
                ),
              ],
            );
          },
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

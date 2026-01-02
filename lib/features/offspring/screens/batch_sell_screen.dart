/// Batch Sell Screen
/// 
/// Screen untuk jual banyak anakan sekaligus.

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/offspring.dart';
import '../../../providers/offspring_provider.dart';
import '../../../core/utils/currency_formatter.dart';

/// Helper function to show the batch sell panel from the side
void showBatchSellPanel(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width > 600 
                ? 600.0 
                : MediaQuery.of(context).size.width * 0.95,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(-5, 0),
                ),
              ],
            ),
            child: const _BatchSellPanel(),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      );
    },
  );
}

// Legacy class for backward compatibility
class BatchSellScreen extends ConsumerStatefulWidget {
  const BatchSellScreen({super.key});

  @override
  ConsumerState<BatchSellScreen> createState() => _BatchSellScreenState();
}

class _BatchSellScreenState extends ConsumerState<BatchSellScreen> {
  @override
  Widget build(BuildContext context) {
    // Redirect to panel instead
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pop(context);
      showBatchSellPanel(context);
    });
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

/// The actual panel widget
class _BatchSellPanel extends ConsumerStatefulWidget {
  const _BatchSellPanel();

  @override
  ConsumerState<_BatchSellPanel> createState() => _BatchSellPanelState();
}

class _BatchSellPanelState extends ConsumerState<_BatchSellPanel> {
  final Map<String, double> _prices = {};
  final Set<String> _selected = {};
  bool _isLoading = false;
  
  // Buyer info controllers
  final _buyerNameController = TextEditingController();
  final _buyerContactController = TextEditingController();
  final _notesController = TextEditingController();

  double get _totalPrice => _selected.fold(0.0, (sum, id) => sum + (_prices[id] ?? 0));
  int get _selectedCount => _selected.length;
  
  @override
  void dispose() {
    _buyerNameController.dispose();
    _buyerContactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSell() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal 1 anakan')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(offspringNotifierProvider.notifier);
      
      // Build description with buyer info
      final descParts = <String>['Penjualan batch'];
      if (_buyerNameController.text.isNotEmpty) {
        descParts.add('Pembeli: ${_buyerNameController.text}');
      }
      if (_buyerContactController.text.isNotEmpty) {
        descParts.add('Kontak: ${_buyerContactController.text}');
      }
      if (_notesController.text.isNotEmpty) {
        descParts.add('Catatan: ${_notesController.text}');
      }
      final description = descParts.join(' | ');
      
      for (final id in _selected) {
        await notifier.sellOffspring(
          offspringId: id,
          salePrice: _prices[id] ?? 0,
          description: description,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_selectedCount anakan berhasil dijual!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final offspringsAsync = ref.watch(offspringNotifierProvider);
    final currencyFormat = NumberFormat('#,###', 'id');

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
          ),
          child: Row(
            children: [
              // Close button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                tooltip: 'Tutup',
              ),
              const SizedBox(width: 8),
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jual Anakan (Batch)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Pilih anakan yang akan dijual',
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: offspringsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (offsprings) {
              // Filter only ready-to-sell
              final sellable = offsprings
                  .where((o) => o.status == OffspringStatus.readySell)
                  .toList();

              if (sellable.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.child_care, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'Tidak ada anakan siap jual',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ubah status ke "Siap Jual" terlebih dahulu',
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sellable.length,
                itemBuilder: (context, index) {
                  final o = sellable[index];
                  final isSelected = _selected.contains(o.id);
                  final isFemale = o.gender.value == 'female';
                  final genderColor = isFemale ? const Color(0xFFEC4899) : const Color(0xFF3B82F6);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: isSelected ? 2 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? genderColor : colorScheme.outlineVariant,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selected.remove(o.id);
                          } else {
                            _selected.add(o.id);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Checkbox
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        _selected.add(o.id);
                                      } else {
                                        _selected.remove(o.id);
                                      }
                                    });
                                  },
                                  activeColor: genderColor,
                                ),
                                // Gender icon
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: genderColor.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      o.genderIcon,
                                      style: TextStyle(fontSize: 16, color: genderColor),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        o.code,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${o.ageFormatted}${o.weight != null ? ' • ${o.weight}kg' : ''}',
                                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (isSelected) ...[
                              const SizedBox(height: 12),
                              TextField(
                                keyboardType: TextInputType.number,
                                inputFormatters: [ThousandsSeparatorInputFormatter()],
                                decoration: InputDecoration(
                                  labelText: 'Harga Jual',
                                  prefixText: 'Rp ',
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                                onChanged: (val) {
                                  _prices[o.id] = parseFormattedPrice(val) ?? 0;
                                  setState(() {});
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Bottom summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Buyer info fields
                if (_selected.isNotEmpty) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _buyerNameController,
                          decoration: InputDecoration(
                            labelText: 'Pembeli',
                            prefixIcon: const Icon(Icons.person_outline, size: 20),
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _buyerContactController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Kontak',
                            prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Catatan (opsional)',
                      prefixIcon: const Icon(Icons.notes_outlined, size: 20),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_selectedCount ekor dipilih',
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                        ),
                        Text(
                          'Rp ${currencyFormat.format(_totalPrice)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _isLoading || _selected.isEmpty ? null : _handleSell,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.sell, size: 18),
                      label: Text(_isLoading ? 'Menjual...' : 'Jual Sekarang'),
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
        ),
      ],
    );
  }
}

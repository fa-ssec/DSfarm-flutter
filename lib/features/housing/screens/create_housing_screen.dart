/// Create Housing Screen (Unified)
/// 
/// Form untuk menambah 1 atau banyak kandang sekaligus.

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/housing_provider.dart';

class CreateHousingScreen extends ConsumerStatefulWidget {
  const CreateHousingScreen({super.key});

  @override
  ConsumerState<CreateHousingScreen> createState() => _CreateHousingScreenState();
}

/// Input formatter for uppercase letters only
class _UpperCaseLettersFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), ''),
      selection: newValue.selection,
    );
  }
}

class _CreateHousingScreenState extends ConsumerState<CreateHousingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _blockController = TextEditingController();
  final _countController = TextEditingController(text: '1');
  final _capacityController = TextEditingController(text: '1');
  final _levelController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _blockController.dispose();
    _countController.dispose();
    _capacityController.dispose();
    _levelController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Preview text showing what will be created
  String get _previewText {
    final block = _blockController.text.trim().toUpperCase();
    final count = int.tryParse(_countController.text) ?? 1;
    
    if (block.isEmpty) return '';
    
    if (count == 1) {
      return 'Akan dibuat: $block-01';
    } else {
      return 'Akan dibuat: $block-01 sampai $block-${count.toString().padLeft(2, '0')} ($count kandang)';
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final block = _blockController.text.trim().toUpperCase();
      final count = int.tryParse(_countController.text) ?? 1;
      final capacity = int.tryParse(_capacityController.text) ?? 1;
      final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

      // Create batch
      final level = _levelController.text.trim().isEmpty ? null : _levelController.text.trim().toUpperCase();
      
      await ref.read(housingNotifierProvider.notifier).createBatch(
        blockCode: block,
        count: count,
        capacity: capacity,
        level: level,
        notes: notes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$count kandang berhasil ditambahkan!'),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Kandang')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Block Code
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _blockController,
                      inputFormatters: [_UpperCaseLettersFormatter()],
                      decoration: const InputDecoration(
                        labelText: 'Blok Kandang *',
                        hintText: 'AA, TEST',
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (v) => v?.trim().isEmpty == true ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _countController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Jumlah *',
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 1) return 'Min 1';
                        if (n > 100) return 'Max 100';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              // Preview
              if (_previewText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _previewText,
                    style: TextStyle(color: Colors.green[700], fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),

              // Capacity & Level
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _capacityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Kapasitas/Kandang *',
                        helperText: 'Maks kelinci per kandang',
                      ),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 1) return 'Min 1';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _levelController,
                      inputFormatters: [
                        _UpperCaseLettersFormatter(),
                        LengthLimitingTextInputFormatter(5),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Lokasi',
                        hintText: 'A, T, B (maks 5)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (Opsional)',
                  hintText: 'Catatan tambahan...',
                ),
              ),
              const SizedBox(height: 16),

              // Info box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kode kandang menggunakan format: [Blok]-[Nomor]',
                      style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Contoh: A-01, B-02, Indoor-03',
                      style: TextStyle(color: Colors.blue[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

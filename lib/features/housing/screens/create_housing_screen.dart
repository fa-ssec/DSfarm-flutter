/// Create Housing Screen
/// 
/// Form untuk menambah kandang baru.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/housing.dart';
import '../../../providers/housing_provider.dart';

class CreateHousingScreen extends ConsumerStatefulWidget {
  const CreateHousingScreen({super.key});

  @override
  ConsumerState<CreateHousingScreen> createState() => _CreateHousingScreenState();
}

class _CreateHousingScreenState extends ConsumerState<CreateHousingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _blockController = TextEditingController();
  final _capacityController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  
  HousingType _selectedType = HousingType.individual;
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _blockController.dispose();
    _capacityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(housingNotifierProvider.notifier).create(
        code: _codeController.text.trim(),
        name: _nameController.text.trim().isEmpty 
            ? null 
            : _nameController.text.trim(),
        block: _blockController.text.trim().isEmpty 
            ? null 
            : _blockController.text.trim(),
        capacity: int.tryParse(_capacityController.text) ?? 1,
        type: _selectedType,
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kandang ${_codeController.text} berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kandang'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Code
              TextFormField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Kode Kandang *',
                  hintText: 'Contoh: K-001, A-01',
                  prefixIcon: Icon(Icons.tag),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kode kandang tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Name (optional)
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nama (Opsional)',
                  hintText: 'Contoh: Kandang Induk 1',
                  prefixIcon: Icon(Icons.label_outline),
                ),
              ),
              const SizedBox(height: 16),

              // Block
              TextFormField(
                controller: _blockController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Blok (Opsional)',
                  hintText: 'Contoh: A, B, Blok Utara',
                  prefixIcon: Icon(Icons.grid_view),
                ),
              ),
              const SizedBox(height: 16),

              // Type
              DropdownButtonFormField<HousingType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipe Kandang',
                  prefixIcon: Icon(Icons.category),
                ),
                items: HousingType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Capacity
              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kapasitas',
                  hintText: 'Jumlah maksimal hewan',
                  prefixIcon: Icon(Icons.people),
                  suffixText: 'ekor',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final num = int.tryParse(value);
                    if (num == null || num < 1) {
                      return 'Kapasitas minimal 1';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  hintText: 'Catatan tambahan...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.notes),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // Submit
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
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

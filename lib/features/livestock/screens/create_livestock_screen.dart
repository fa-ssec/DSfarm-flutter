/// Create Livestock Screen
/// 
/// Form untuk menambah indukan/pejantan baru.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/livestock.dart';
import '../../../models/housing.dart';
import '../../../providers/livestock_provider.dart';
import '../../../providers/housing_provider.dart';

class CreateLivestockScreen extends ConsumerStatefulWidget {
  const CreateLivestockScreen({super.key});

  @override
  ConsumerState<CreateLivestockScreen> createState() => _CreateLivestockScreenState();
}

class _CreateLivestockScreenState extends ConsumerState<CreateLivestockScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  
  Gender _selectedGender = Gender.female;
  AcquisitionType _selectedAcquisition = AcquisitionType.purchased;
  String? _selectedHousingId;
  DateTime? _birthDate;
  DateTime? _acquisitionDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _weightController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _birthDate = picked;
        } else {
          _acquisitionDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Pilih tanggal';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(livestockNotifierProvider.notifier).create(
        code: _codeController.text.trim(),
        gender: _selectedGender,
        housingId: _selectedHousingId,
        name: _nameController.text.trim().isEmpty 
            ? null 
            : _nameController.text.trim(),
        birthDate: _birthDate,
        acquisitionDate: _acquisitionDate,
        acquisitionType: _selectedAcquisition,
        purchasePrice: _priceController.text.isEmpty 
            ? null 
            : double.tryParse(_priceController.text),
        weight: _weightController.text.isEmpty 
            ? null 
            : double.tryParse(_weightController.text),
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedGender == Gender.female ? "Induk" : "Pejantan"} ${_codeController.text} berhasil ditambahkan!'),
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final housingsAsync = ref.watch(availableHousingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Indukan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Gender Selection
              const Text(
                'Gender',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _GenderOption(
                      gender: Gender.female,
                      isSelected: _selectedGender == Gender.female,
                      onTap: () => setState(() => _selectedGender = Gender.female),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GenderOption(
                      gender: Gender.male,
                      isSelected: _selectedGender == Gender.male,
                      onTap: () => setState(() => _selectedGender = Gender.male),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Code
              TextFormField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Kode *',
                  hintText: _selectedGender == Gender.female ? 'I-001' : 'P-001',
                  prefixIcon: const Icon(Icons.tag),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kode tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Name
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nama (Opsional)',
                  hintText: 'Contoh: Putih, Si Gendut',
                  prefixIcon: Icon(Icons.pets),
                ),
              ),
              const SizedBox(height: 16),

              // Housing
              DropdownButtonFormField<String>(
                value: _selectedHousingId,
                decoration: const InputDecoration(
                  labelText: 'Kandang',
                  prefixIcon: Icon(Icons.home_work),
                ),
                hint: const Text('Pilih kandang'),
                items: housingsAsync.when(
                  loading: () => [],
                  error: (_, __) => [],
                  data: (housings) => housings.map((h) {
                    return DropdownMenuItem(
                      value: h.id,
                      child: Text(h.displayName),
                    );
                  }).toList(),
                ),
                onChanged: (value) => setState(() => _selectedHousingId = value),
              ),
              const SizedBox(height: 16),

              // Birth Date
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Lahir',
                    prefixIcon: Icon(Icons.cake),
                  ),
                  child: Text(_formatDate(_birthDate)),
                ),
              ),
              const SizedBox(height: 16),

              // Acquisition Type
              DropdownButtonFormField<AcquisitionType>(
                value: _selectedAcquisition,
                decoration: const InputDecoration(
                  labelText: 'Asal',
                  prefixIcon: Icon(Icons.shopping_cart),
                ),
                items: AcquisitionType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedAcquisition = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Acquisition Date
              if (_selectedAcquisition == AcquisitionType.purchased)
                InkWell(
                  onTap: () => _selectDate(context, false),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Pembelian',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(_formatDate(_acquisitionDate)),
                  ),
                ),
              if (_selectedAcquisition == AcquisitionType.purchased)
                const SizedBox(height: 16),

              // Purchase Price
              if (_selectedAcquisition == AcquisitionType.purchased)
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga Beli',
                    prefixIcon: Icon(Icons.attach_money),
                    prefixText: 'Rp ',
                  ),
                ),
              if (_selectedAcquisition == AcquisitionType.purchased)
                const SizedBox(height: 16),

              // Weight
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Berat (Opsional)',
                  prefixIcon: Icon(Icons.scale),
                  suffixText: 'kg',
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 24),
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

class _GenderOption extends StatelessWidget {
  final Gender gender;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.gender,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = gender == Gender.female ? Colors.pink : Colors.blue;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? color.withAlpha(25) : null,
        ),
        child: Column(
          children: [
            Text(
              gender.icon,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 4),
            Text(
              gender.displayName,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

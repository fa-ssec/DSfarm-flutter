/// Housing Provider
/// 
/// Riverpod providers for housing state management.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/housing.dart';
import '../repositories/housing_repository.dart';
import '../providers/farm_provider.dart';

/// Repository provider
final housingRepositoryProvider = Provider<HousingRepository>((ref) {
  return HousingRepository();
});

/// Provider for housings of current farm
final housingsProvider = FutureProvider<List<Housing>>((ref) async {
  final farm = ref.watch(currentFarmProvider);
  if (farm == null) return [];
  
  final repository = ref.watch(housingRepositoryProvider);
  return repository.getByFarm(farm.id);
});

/// Provider for housings grouped by block
final housingsGroupedProvider = FutureProvider<Map<String, List<Housing>>>((ref) async {
  final farm = ref.watch(currentFarmProvider);
  if (farm == null) return {};
  
  final repository = ref.watch(housingRepositoryProvider);
  return repository.getByFarmGroupedByBlock(farm.id);
});

/// Provider for available housings (for dropdown selection)
final availableHousingsProvider = FutureProvider<List<Housing>>((ref) async {
  final farm = ref.watch(currentFarmProvider);
  if (farm == null) return [];
  
  final repository = ref.watch(housingRepositoryProvider);
  return repository.getAvailable(farm.id);
});

/// Notifier for housing CRUD operations
class HousingNotifier extends StateNotifier<AsyncValue<List<Housing>>> {
  final HousingRepository _repository;
  final String? _farmId;

  HousingNotifier(this._repository, this._farmId) 
      : super(_farmId == null ? const AsyncValue.data([]) : const AsyncValue.loading()) {
    if (_farmId != null) loadHousings();
  }

  Future<void> loadHousings() async {
    if (_farmId == null) {
      state = const AsyncValue.data([]);
      return;
    }
    
    state = const AsyncValue.loading();
    try {
      final housings = await _repository.getByFarm(_farmId);
      state = AsyncValue.data(housings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Housing> create({
    required String code,
    String? name,
    String? blockId,
    String? position,
    int? column,
    int? row,
    String? level,
    int capacity = 1,
    HousingType type = HousingType.individual,
    String? notes,
  }) async {
    if (_farmId == null) throw Exception('No farm selected');
    
    final housing = await _repository.create(
      farmId: _farmId,
      code: code,
      name: name,
      blockId: blockId,
      position: position,
      column: column,
      row: row,
      level: level,
      capacity: capacity,
      type: type,
      notes: notes,
    );
    
    await loadHousings();
    return housing;
  }

  Future<void> update(Housing housing) async {
    await _repository.update(housing);
    await loadHousings();
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    await loadHousings();
  }

  /// Create multiple housings with same settings
  /// Code format: BLOK-NN (e.g., A-01, A-02)
  /// Fills gaps in numbering per block
  Future<void> createBatch({
    required String blockCode,
    required int count,
    int capacity = 1,
    String? level,
    String? notes,
  }) async {
    if (_farmId == null) throw Exception('No farm selected');
    
    final block = blockCode.toUpperCase();
    final codePrefix = '$block-';
    
    // Get existing housings in this block
    final existingHousings = state.valueOrNull ?? [];
    final blockHousings = existingHousings.where(
      (h) => h.code.toUpperCase().startsWith(codePrefix)
    ).toList();
    
    // Extract used numbers
    final usedNumbers = <int>{};
    for (final h in blockHousings) {
      final parts = h.code.split('-');
      if (parts.length >= 2) {
        final num = int.tryParse(parts.last);
        if (num != null) usedNumbers.add(num);
      }
    }
    
    // Find available numbers (gaps first, then new numbers)
    final availableNumbers = <int>[];
    int maxNumber = usedNumbers.isEmpty ? 0 : usedNumbers.reduce((a, b) => a > b ? a : b);
    
    // First, fill gaps
    for (int i = 1; i <= maxNumber && availableNumbers.length < count; i++) {
      if (!usedNumbers.contains(i)) {
        availableNumbers.add(i);
      }
    }
    
    // Then, add new sequential numbers
    int nextNum = maxNumber + 1;
    while (availableNumbers.length < count) {
      availableNumbers.add(nextNum++);
    }
    
    // Create housings
    for (int i = 0; i < count; i++) {
      final num = availableNumbers[i];
      final code = '$codePrefix${num.toString().padLeft(2, '0')}';
      
      await _repository.create(
        farmId: _farmId,
        code: code,
        name: null,
        position: code,
        level: level,
        capacity: capacity,
        notes: notes,
      );
    }
    
    await loadHousings();
  }

  /// Delete multiple housings at once
  Future<void> deleteBatch(List<String> ids) async {
    for (final id in ids) {
      await _repository.delete(id);
    }
    await loadHousings();
  }
}

/// Provider for HousingNotifier
final housingNotifierProvider = StateNotifierProvider<HousingNotifier, AsyncValue<List<Housing>>>((ref) {
  final repository = ref.watch(housingRepositoryProvider);
  final farm = ref.watch(currentFarmProvider);
  return HousingNotifier(repository, farm?.id);
});

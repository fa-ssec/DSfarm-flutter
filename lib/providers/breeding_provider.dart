/// Breeding Record Provider
/// 
/// Riverpod providers for breeding record state management.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/breeding_record.dart';
import '../repositories/breeding_repository.dart';
import '../providers/farm_provider.dart';

/// Repository provider
final breedingRepositoryProvider = Provider<BreedingRecordRepository>((ref) {
  return BreedingRecordRepository();
});

/// Provider for all breeding records of current farm
final breedingRecordsProvider = FutureProvider<List<BreedingRecord>>((ref) async {
  final farm = ref.watch(currentFarmProvider);
  if (farm == null) return [];
  
  final repository = ref.watch(breedingRepositoryProvider);
  return repository.getByFarm(farm.id);
});

/// Provider for active breeding records (mated, pregnant)
final activeBreedingsProvider = FutureProvider<List<BreedingRecord>>((ref) async {
  final records = await ref.watch(breedingRecordsProvider.future);
  return records.where((r) => 
    r.status == BreedingStatus.mated || 
    r.status == BreedingStatus.palpated ||
    r.status == BreedingStatus.pregnant
  ).toList();
});

/// Provider for breeding records by dam
final breedingsByDamProvider = FutureProvider.family<List<BreedingRecord>, String>((ref, damId) async {
  final repository = ref.watch(breedingRepositoryProvider);
  return repository.getByDam(damId);
});

/// Notifier for breeding record CRUD operations
class BreedingNotifier extends StateNotifier<AsyncValue<List<BreedingRecord>>> {
  final BreedingRecordRepository _repository;
  final String? _farmId;

  BreedingNotifier(this._repository, this._farmId) : super(const AsyncValue.loading()) {
    if (_farmId != null) loadBreedings();
  }

  Future<void> loadBreedings() async {
    if (_farmId == null) {
      state = const AsyncValue.data([]);
      return;
    }
    
    state = const AsyncValue.loading();
    try {
      final breedings = await _repository.getByFarm(_farmId);
      state = AsyncValue.data(breedings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<BreedingRecord> create({
    required String damId,
    required DateTime matingDate,
    String? sireId,
    DateTime? expectedBirthDate,
    String? notes,
  }) async {
    if (_farmId == null) throw Exception('No farm selected');
    
    final breeding = await _repository.create(
      farmId: _farmId,
      damId: damId,
      matingDate: matingDate,
      sireId: sireId,
      expectedBirthDate: expectedBirthDate,
      notes: notes,
    );
    
    await loadBreedings();
    return breeding;
  }

  Future<void> updatePalpation({
    required String id,
    required DateTime palpationDate,
    required bool isPositive,
    DateTime? expectedBirthDate,
  }) async {
    await _repository.updatePalpation(
      id: id,
      palpationDate: palpationDate,
      isPositive: isPositive,
      expectedBirthDate: expectedBirthDate,
    );
    await loadBreedings();
  }

  Future<void> updateBirth({
    required String id,
    required DateTime actualBirthDate,
    required int birthCount,
    required int aliveCount,
    int? deadCount,
  }) async {
    await _repository.updateBirth(
      id: id,
      actualBirthDate: actualBirthDate,
      birthCount: birthCount,
      aliveCount: aliveCount,
      deadCount: deadCount,
    );
    await loadBreedings();
  }

  Future<void> updateWeaning({
    required String id,
    required DateTime weaningDate,
    required int weanedCount,
  }) async {
    await _repository.updateWeaning(
      id: id,
      weaningDate: weaningDate,
      weanedCount: weanedCount,
    );
    await loadBreedings();
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    await loadBreedings();
  }
}

/// Provider for BreedingNotifier
final breedingNotifierProvider = StateNotifierProvider<BreedingNotifier, AsyncValue<List<BreedingRecord>>>((ref) {
  final repository = ref.watch(breedingRepositoryProvider);
  final farm = ref.watch(currentFarmProvider);
  return BreedingNotifier(repository, farm?.id);
});

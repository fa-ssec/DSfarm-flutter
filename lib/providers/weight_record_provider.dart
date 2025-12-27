/// Weight Record Provider
/// 
/// Riverpod providers untuk weight records state management.

library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/weight_record.dart';
import '../repositories/weight_record_repository.dart';

/// Repository provider
final weightRecordRepositoryProvider = Provider<WeightRecordRepository>((ref) {
  return WeightRecordRepository();
});

/// Provider for weight records of a specific livestock
final weightRecordsProvider = FutureProvider.family<List<WeightRecord>, String>((ref, livestockId) async {
  final repository = ref.watch(weightRecordRepositoryProvider);
  return repository.getByLivestock(livestockId);
});

/// Notifier for weight record operations
class WeightRecordNotifier extends StateNotifier<AsyncValue<List<WeightRecord>>> {
  final WeightRecordRepository _repository;
  final String _livestockId;
  final Ref _ref;

  WeightRecordNotifier(this._repository, this._livestockId, this._ref) 
      : super(const AsyncValue.loading()) {
    loadRecords();
  }

  Future<void> loadRecords() async {
    state = const AsyncValue.loading();
    try {
      final records = await _repository.getByLivestock(_livestockId);
      state = AsyncValue.data(records);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> create({
    required double weight,
    int? ageDays,
    required DateTime recordedAt,
    String? notes,
  }) async {
    await _repository.create(
      livestockId: _livestockId,
      weight: weight,
      ageDays: ageDays,
      recordedAt: recordedAt,
      notes: notes,
    );
    await loadRecords();
    // Also invalidate the livestock provider to refresh weight display
    _ref.invalidate(weightRecordsProvider(_livestockId));
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    await loadRecords();
  }
}

/// Provider for WeightRecordNotifier
final weightRecordNotifierProvider = StateNotifierProvider.family<
    WeightRecordNotifier, 
    AsyncValue<List<WeightRecord>>, 
    String
>((ref, livestockId) {
  final repository = ref.watch(weightRecordRepositoryProvider);
  return WeightRecordNotifier(repository, livestockId, ref);
});

/// Weight Record Repository
/// 
/// Repository untuk operasi CRUD weight records ke Supabase.

library;

import '../core/services/supabase_service.dart';
import '../models/weight_record.dart';

class WeightRecordRepository {
  static const _tableName = 'weight_records';

  /// Get all weight records for a livestock, ordered by date descending
  Future<List<WeightRecord>> getByLivestock(String livestockId) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .select()
        .eq('livestock_id', livestockId)
        .order('recorded_at', ascending: false);

    return (response as List)
        .map((json) => WeightRecord.fromJson(json))
        .toList();
  }

  /// Get all weight records for an offspring, ordered by date descending
  Future<List<WeightRecord>> getByOffspring(String offspringId) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .select()
        .eq('offspring_id', offspringId)
        .order('recorded_at', ascending: false);

    return (response as List)
        .map((json) => WeightRecord.fromJson(json))
        .toList();
  }

  /// Create a new weight record (for livestock or offspring)
  Future<WeightRecord> create({
    String? livestockId,
    String? offspringId,
    required double weight,
    int? ageDays,
    required DateTime recordedAt,
    String? notes,
  }) async {
    assert(livestockId != null || offspringId != null, 
        'Either livestockId or offspringId must be provided');

    final data = {
      'livestock_id': livestockId,
      'offspring_id': offspringId,
      'weight': weight,
      'age_days': ageDays,
      'recorded_at': recordedAt.toIso8601String(),
      'notes': notes,
    };

    final response = await SupabaseService.client
        .from(_tableName)
        .insert(data)
        .select()
        .single();

    // Update the entity's current weight
    if (livestockId != null) {
      await _updateLivestockWeight(livestockId, weight);
    } else if (offspringId != null) {
      await _updateOffspringWeight(offspringId, weight);
    }

    return WeightRecord.fromJson(response);
  }

  /// Delete a weight record
  Future<void> delete(String id) async {
    await SupabaseService.client
        .from(_tableName)
        .delete()
        .eq('id', id);
  }

  /// Update livestock's current weight to the most recent record
  Future<void> _updateLivestockWeight(String livestockId, double weight) async {
    await SupabaseService.client
        .from('livestocks')
        .update({'weight': weight, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', livestockId);
  }

  /// Update offspring's current weight to the most recent record
  Future<void> _updateOffspringWeight(String offspringId, double weight) async {
    await SupabaseService.client
        .from('offsprings')
        .update({'weight': weight, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', offspringId);
  }
}

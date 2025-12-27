/// Breeding Record Repository
/// 
/// Handles all database operations for BreedingRecord entity.

library;

import '../core/services/supabase_service.dart';
import '../models/breeding_record.dart';

class BreedingRecordRepository {
  static const String _tableName = 'breeding_records';

  /// Get all breeding records for a farm
  Future<List<BreedingRecord>> getByFarm(String farmId) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .select('''
          *,
          dam:dam_id(code, name),
          sire:sire_id(code, name)
        ''')
        .eq('farm_id', farmId)
        .order('mating_date', ascending: false);

    return (response as List)
        .map((json) => BreedingRecord.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get breeding records by status
  Future<List<BreedingRecord>> getByStatus(String farmId, BreedingStatus status) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .select('''
          *,
          dam:dam_id(code, name),
          sire:sire_id(code, name)
        ''')
        .eq('farm_id', farmId)
        .eq('status', status.value)
        .order('mating_date', ascending: false);

    return (response as List)
        .map((json) => BreedingRecord.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get breeding records for a specific dam
  Future<List<BreedingRecord>> getByDam(String damId) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .select('''
          *,
          dam:dam_id(code, name),
          sire:sire_id(code, name)
        ''')
        .eq('dam_id', damId)
        .order('mating_date', ascending: false);

    return (response as List)
        .map((json) => BreedingRecord.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get a single breeding record by ID
  Future<BreedingRecord?> getById(String id) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .select('''
          *,
          dam:dam_id(code, name),
          sire:sire_id(code, name)
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return BreedingRecord.fromJson(response);
  }

  /// Create a new breeding record
  Future<BreedingRecord> create({
    required String farmId,
    required String damId,
    required DateTime matingDate,
    String? sireId,
    DateTime? expectedBirthDate,
    String? notes,
  }) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .insert({
          'farm_id': farmId,
          'dam_id': damId,
          'sire_id': sireId,
          'mating_date': matingDate.toIso8601String().split('T').first,
          'expected_birth_date': expectedBirthDate?.toIso8601String().split('T').first,
          'status': 'mated',
          'notes': notes,
        })
        .select('''
          *,
          dam:dam_id(code, name),
          sire:sire_id(code, name)
        ''')
        .single();

    return BreedingRecord.fromJson(response);
  }

  /// Update palpation result
  Future<BreedingRecord> updatePalpation({
    required String id,
    required DateTime palpationDate,
    required bool isPositive,
    DateTime? expectedBirthDate,
  }) async {
    final updates = <String, dynamic>{
      'palpation_date': palpationDate.toIso8601String().split('T').first,
      'is_palpation_positive': isPositive,
      'status': isPositive ? 'pregnant' : 'failed',
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    if (expectedBirthDate != null) {
      updates['expected_birth_date'] = expectedBirthDate.toIso8601String().split('T').first;
    }

    final response = await SupabaseService.client
        .from(_tableName)
        .update(updates)
        .eq('id', id)
        .select('''
          *,
          dam:dam_id(code, name),
          sire:sire_id(code, name)
        ''')
        .single();

    return BreedingRecord.fromJson(response);
  }

  /// Update birth information
  Future<BreedingRecord> updateBirth({
    required String id,
    required DateTime actualBirthDate,
    required int birthCount,
    required int aliveCount,
    int? deadCount,
    int? maleBorn,
    int? femaleBorn,
  }) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .update({
          'actual_birth_date': actualBirthDate.toIso8601String().split('T').first,
          'birth_count': birthCount,
          'alive_count': aliveCount,
          'dead_count': deadCount ?? (birthCount - aliveCount),
          'male_born': maleBorn,
          'female_born': femaleBorn,
          'status': 'birthed',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select('''
          *,
          dam:dam_id(code, name),
          sire:sire_id(code, name)
        ''')
        .single();

    return BreedingRecord.fromJson(response);
  }

  /// Update weaning information
  Future<BreedingRecord> updateWeaning({
    required String id,
    required DateTime weaningDate,
    required int weanedCount,
    int? maleWeaned,
    int? femaleWeaned,
  }) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .update({
          'weaning_date': weaningDate.toIso8601String().split('T').first,
          'weaned_count': weanedCount,
          'male_weaned': maleWeaned,
          'female_weaned': femaleWeaned,
          'status': 'weaned',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select('''
          *,
          dam:dam_id(code, name),
          sire:sire_id(code, name)
        ''')
        .single();

    return BreedingRecord.fromJson(response);
  }

  /// Delete breeding record
  Future<void> delete(String id) async {
    await SupabaseService.client
        .from(_tableName)
        .delete()
        .eq('id', id);
  }
}

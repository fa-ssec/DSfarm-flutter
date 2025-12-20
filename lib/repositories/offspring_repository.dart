/// Offspring Repository
/// 
/// Handles all database operations for Offspring entity.

library;

import '../core/services/supabase_service.dart';
import '../models/offspring.dart';

class OffspringRepository {
  static const String _tableName = 'offsprings';

  /// Get all offspring for a farm
  Future<List<Offspring>> getByFarm(String farmId) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .select('''
          *,
          housings:housing_id(code),
          breeds:breed_id(name),
          breeding_records:breeding_record_id(
            dam:dam_id(code, name),
            sire:sire_id(code, name)
          )
        ''')
        .eq('farm_id', farmId)
        .order('birth_date', ascending: false);

    return (response as List)
        .map((json) => Offspring.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get offspring by status
  Future<List<Offspring>> getByStatus(String farmId, OffspringStatus status) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .select('''
          *,
          housings:housing_id(code),
          breeds:breed_id(name)
        ''')
        .eq('farm_id', farmId)
        .eq('status', status.value)
        .order('birth_date', ascending: false);

    return (response as List)
        .map((json) => Offspring.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get offspring for a breeding record
  Future<List<Offspring>> getByBreedingRecord(String breedingRecordId) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .select('''
          *,
          housings:housing_id(code),
          breeds:breed_id(name)
        ''')
        .eq('breeding_record_id', breedingRecordId)
        .order('code');

    return (response as List)
        .map((json) => Offspring.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get a single offspring by ID
  Future<Offspring?> getById(String id) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .select('''
          *,
          housings:housing_id(code),
          breeds:breed_id(name),
          breeding_records:breeding_record_id(
            dam:dam_id(code, name),
            sire:sire_id(code, name)
          )
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Offspring.fromJson(response);
  }

  /// Create a new offspring
  Future<Offspring> create({
    required String farmId,
    required String code,
    required Gender gender,
    required DateTime birthDate,
    String? breedingRecordId,
    String? housingId,
    String? name,
    String? breedId,
    double? weight,
    String? notes,
  }) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .insert({
          'farm_id': farmId,
          'breeding_record_id': breedingRecordId,
          'housing_id': housingId,
          'code': code,
          'name': name,
          'gender': gender.value,
          'birth_date': birthDate.toIso8601String().split('T').first,
          'breed_id': breedId,
          'status': 'infarm',
          'weight': weight,
          'notes': notes,
        })
        .select()
        .single();

    return Offspring.fromJson(response);
  }

  /// Update an existing offspring
  Future<Offspring> update(Offspring offspring) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .update(offspring.toJson()..['updated_at'] = DateTime.now().toIso8601String())
        .eq('id', offspring.id)
        .select()
        .single();

    return Offspring.fromJson(response);
  }

  /// Update offspring status
  Future<void> updateStatus(String id, OffspringStatus status, {
    double? salePrice,
    DateTime? saleDate,
  }) async {
    final updates = <String, dynamic>{
      'status': status.value,
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    if (salePrice != null) updates['sale_price'] = salePrice;
    if (saleDate != null) updates['sale_date'] = saleDate.toIso8601String().split('T').first;

    await SupabaseService.client
        .from(_tableName)
        .update(updates)
        .eq('id', id);
  }

  /// Mark offspring as weaned
  Future<void> markAsWeaned(String id, DateTime weaningDate) async {
    await SupabaseService.client
        .from(_tableName)
        .update({
          'weaning_date': weaningDate.toIso8601String().split('T').first,
          'status': OffspringStatus.weaned.value,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }

  /// Delete offspring
  Future<void> delete(String id) async {
    await SupabaseService.client
        .from(_tableName)
        .delete()
        .eq('id', id);
  }

  /// Get offspring count by status for a farm
  Future<Map<OffspringStatus, int>> getCountByStatus(String farmId) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .select('status')
        .eq('farm_id', farmId);

    final list = response as List;
    final counts = <OffspringStatus, int>{};
    
    for (final status in OffspringStatus.values) {
      counts[status] = list.where((e) => e['status'] == status.value).length;
    }
    
    return counts;
  }
}

/// Housing Repository
/// 
/// Handles all database operations for Housing entity.

library;

import '../core/services/supabase_service.dart';
import '../models/housing.dart';

class HousingRepository {
  static const String _tableName = 'housings';

  /// Get all housings for a farm
  Future<List<Housing>> getByFarm(String farmId) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .select()
        .eq('farm_id', farmId)
        .order('block')
        .order('code');

    return (response as List)
        .map((json) => Housing.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get housings grouped by block
  Future<Map<String, List<Housing>>> getByFarmGroupedByBlock(String farmId) async {
    final housings = await getByFarm(farmId);
    final grouped = <String, List<Housing>>{};
    
    for (final housing in housings) {
      final block = housing.block ?? 'Tanpa Blok';
      grouped.putIfAbsent(block, () => []);
      grouped[block]!.add(housing);
    }
    
    return grouped;
  }

  /// Get a single housing by ID
  Future<Housing?> getById(String id) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Housing.fromJson(response);
  }

  /// Create a new housing
  Future<Housing> create({
    required String farmId,
    required String code,
    String? name,
    String? block,
    int capacity = 1,
    HousingType type = HousingType.individual,
    String? notes,
  }) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .insert({
          'farm_id': farmId,
          'code': code,
          'name': name,
          'block': block,
          'capacity': capacity,
          'housing_type': type.value,
          'status': 'active',
          'notes': notes,
        })
        .select()
        .single();

    return Housing.fromJson(response);
  }

  /// Update an existing housing
  Future<Housing> update(Housing housing) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .update({
          'code': housing.code,
          'name': housing.name,
          'block': housing.block,
          'capacity': housing.capacity,
          'housing_type': housing.type.value,
          'status': housing.status.value,
          'notes': housing.notes,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', housing.id)
        .select()
        .single();

    return Housing.fromJson(response);
  }

  /// Delete a housing
  Future<void> delete(String id) async {
    await SupabaseService.client
        .from(_tableName)
        .delete()
        .eq('id', id);
  }

  /// Get housing count for a farm
  Future<int> getCount(String farmId) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .select('id')
        .eq('farm_id', farmId);

    return (response as List).length;
  }

  /// Get available housings (with space) for a farm
  Future<List<Housing>> getAvailable(String farmId) async {
    // This would need a more complex query with occupancy count
    // For now, return all active housings
    final response = await SupabaseService.client
        .from(_tableName)
        .select()
        .eq('farm_id', farmId)
        .eq('status', 'active')
        .order('block')
        .order('code');

    return (response as List)
        .map((json) => Housing.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

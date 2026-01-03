/// Housing Repository
/// 
/// Handles all database operations for Housing entity.

library;

import '../core/services/supabase_service.dart';
import '../models/housing.dart';

class HousingRepository {
  static const String _tableName = 'housings';

  /// Get all housings for a farm with occupancy count
  Future<List<Housing>> getByFarm(String farmId) async {
    // First get housings
    final response = await SupabaseService.client
        .from(_tableName)
        .select('*, blocks(code)')
        .eq('farm_id', farmId)
        .order('position')
        .order('code');

    final housings = (response as List)
        .map((json) => Housing.fromJson(json as Map<String, dynamic>))
        .toList();

    // Then get occupancy counts for all housings
    final occupancyCounts = await _getOccupancyCounts(farmId);

    // Merge occupancy data
    return housings.map((h) => h.copyWith(
      currentOccupancy: occupancyCounts[h.id] ?? 0,
    )).toList();
  }

  /// Get occupancy counts for all housings in a farm
  Future<Map<String, int>> _getOccupancyCounts(String farmId) async {
    final response = await SupabaseService.client
        .from('livestocks')
        .select('housing_id')
        .eq('farm_id', farmId)
        .not('status', 'in', '(terjual,mati,afkir)');

    final counts = <String, int>{};
    for (final row in response as List) {
      final housingId = row['housing_id'] as String?;
      if (housingId != null) {
        counts[housingId] = (counts[housingId] ?? 0) + 1;
      }
    }
    return counts;
  }

  /// Get housings grouped by block
  Future<Map<String, List<Housing>>> getByFarmGroupedByBlock(String farmId) async {
    final housings = await getByFarm(farmId);
    final grouped = <String, List<Housing>>{};
    
    for (final housing in housings) {
      final block = housing.blockCode ?? 'Tanpa Blok';
      grouped.putIfAbsent(block, () => []);
      grouped[block]!.add(housing);
    }
    
    return grouped;
  }

  /// Get a single housing by ID with occupancy
  Future<Housing?> getById(String id) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .select('*, blocks(code)')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    
    final housing = Housing.fromJson(response);
    
    // Get occupancy count
    final countResponse = await SupabaseService.client
        .from('livestocks')
        .select('id')
        .eq('housing_id', id)
        .not('status', 'in', '(terjual,mati,afkir)');
    
    return housing.copyWith(currentOccupancy: (countResponse as List).length);
  }

  /// Create a new housing
  Future<Housing> create({
    required String farmId,
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
    final response = await SupabaseService.client
        .from(_tableName)
        .insert({
          'farm_id': farmId,
          'code': code,
          'name': name,
          'block_id': blockId,
          'position': position,
          'column_num': column,
          'row_num': row,
          'level': level,
          'capacity': capacity,
          'housing_type': type.value,
          'status': 'active',
          'notes': notes,
        })
        .select('*, blocks(code)')
        .single();

    return Housing.fromJson(response).copyWith(currentOccupancy: 0);
  }

  /// Update an existing housing
  Future<Housing> update(Housing housing) async {
    final response = await SupabaseService.client
        .from(_tableName)
        .update({
          'code': housing.code,
          'name': housing.name,
          'block_id': housing.blockId,
          'position': housing.position,
          'column_num': housing.column,
          'row_num': housing.row,
          'level': housing.level,
          'capacity': housing.capacity,
          'housing_type': housing.type.value,
          'status': housing.status.value,
          'notes': housing.notes,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', housing.id)
        .select('*, blocks(code)')
        .single();

    return Housing.fromJson(response).copyWith(
      currentOccupancy: housing.currentOccupancy,
    );
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
    final housings = await getByFarm(farmId);
    
    // Filter to only those with available space
    return housings.where((h) => h.hasSpace).toList();
  }
  
  /// Check if housing has available capacity
  Future<bool> hasCapacity(String housingId) async {
    final housing = await getById(housingId);
    if (housing == null) return false;
    return housing.hasSpace;
  }
}

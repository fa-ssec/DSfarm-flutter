/// Lineage Service
/// 
/// Service untuk membangun silsilah (pedigree) ternak.
/// Mendukung sampai 3 generasi ke atas.

library;

import 'package:supabase_flutter/supabase_flutter.dart';

/// Node dalam pohon silsilah
class LineageNode {
  final String id;
  final String code;
  final String? name;
  final String type; // 'livestock' atau 'offspring'
  final String gender; // 'male', 'female', 'unknown'
  final String? breed;
  final DateTime? birthDate;
  final LineageNode? dam;  // Induk (mother)
  final LineageNode? sire; // Pejantan (father)

  const LineageNode({
    required this.id,
    required this.code,
    this.name,
    required this.type,
    required this.gender,
    this.breed,
    this.birthDate,
    this.dam,
    this.sire,
  });

  /// Display name (nama atau code)
  String get displayName => name ?? code;

  /// Gender icon
  String get genderIcon {
    switch (gender) {
      case 'male': return '♂️';
      case 'female': return '♀️';
      default: return '❓';
    }
  }

  /// Check if has parents
  bool get hasParents => dam != null || sire != null;

  /// Total depth of tree (untuk sizing)
  int get depth {
    int damDepth = dam?.depth ?? 0;
    int sireDepth = sire?.depth ?? 0;
    return 1 + (damDepth > sireDepth ? damDepth : sireDepth);
  }

  @override
  String toString() => 'LineageNode($code, dam: ${dam?.code}, sire: ${sire?.code})';
}

/// Service untuk build lineage tree
class LineageService {
  final SupabaseClient _client;

  LineageService(this._client);

  /// Build lineage tree untuk offspring
  /// [maxDepth] = berapa generasi ke atas (default 3)
  Future<LineageNode> buildOffspringLineage(String offspringId, {int maxDepth = 3}) async {
    // 1. Fetch offspring
    final offspringData = await _client
        .from('offsprings')
        .select('''
          id, code, name, gender, birth_date,
          breeds(name),
          breeding_records(
            dam_id,
            sire_id
          )
        ''')
        .eq('id', offspringId)
        .single();

    // 2. Build node untuk offspring ini
    final breedingRecord = offspringData['breeding_records'];
    final damId = breedingRecord?['dam_id'] as String?;
    final sireId = breedingRecord?['sire_id'] as String?;

    // 3. Recursively fetch parents
    LineageNode? damNode;
    LineageNode? sireNode;

    if (maxDepth > 0) {
      if (damId != null) {
        damNode = await _buildLivestockNode(damId, maxDepth - 1);
      }
      if (sireId != null) {
        sireNode = await _buildLivestockNode(sireId, maxDepth - 1);
      }
    }

    return LineageNode(
      id: offspringData['id'] as String,
      code: offspringData['code'] as String,
      name: offspringData['name'] as String?,
      type: 'offspring',
      gender: offspringData['gender'] as String? ?? 'unknown',
      breed: offspringData['breeds']?['name'] as String?,
      birthDate: offspringData['birth_date'] != null 
          ? DateTime.parse(offspringData['birth_date'] as String)
          : null,
      dam: damNode,
      sire: sireNode,
    );
  }

  /// Build lineage tree untuk livestock (indukan/pejantan)
  Future<LineageNode> buildLivestockLineage(String livestockId, {int maxDepth = 3}) async {
    return _buildLivestockNode(livestockId, maxDepth);
  }

  /// Internal: Build node untuk livestock
  Future<LineageNode> _buildLivestockNode(String livestockId, int depth) async {
    // Fetch livestock data
    final data = await _client
        .from('livestocks')
        .select('''
          id, code, name, gender, birth_date, acquisition_type,
          breeds(name),
          metadata
        ''')
        .eq('id', livestockId)
        .single();

    LineageNode? damNode;
    LineageNode? sireNode;

    // Jika livestock lahir di farm (bukan purchased), coba cari parentnya
    if (depth > 0 && data['acquisition_type'] == 'born') {
      // Check metadata untuk parent IDs
      final metadata = data['metadata'] as Map<String, dynamic>?;
      final parentDamId = metadata?['parent_dam_id'] as String?;
      final parentSireId = metadata?['parent_sire_id'] as String?;

      if (parentDamId != null) {
        try {
          damNode = await _buildLivestockNode(parentDamId, depth - 1);
        } catch (_) {
          // Parent tidak ditemukan, skip
        }
      }
      if (parentSireId != null) {
        try {
          sireNode = await _buildLivestockNode(parentSireId, depth - 1);
        } catch (_) {
          // Parent tidak ditemukan, skip
        }
      }
    }

    return LineageNode(
      id: data['id'] as String,
      code: data['code'] as String,
      name: data['name'] as String?,
      type: 'livestock',
      gender: data['gender'] as String? ?? 'unknown',
      breed: data['breeds']?['name'] as String?,
      birthDate: data['birth_date'] != null 
          ? DateTime.parse(data['birth_date'] as String)
          : null,
      dam: damNode,
      sire: sireNode,
    );
  }
}

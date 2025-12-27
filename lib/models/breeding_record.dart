/// Breeding Record Model
/// 
/// Tracks breeding events from mating to birth.
/// Links dam (mother), sire (father), and resulting offspring.

library;

class BreedingRecord {
  final String id;
  final String farmId;
  final String damId;         // Female parent
  final String? sireId;       // Male parent (optional for unknown)
  final DateTime matingDate;
  final DateTime? palpationDate;
  final bool? isPalpationPositive;
  final DateTime? expectedBirthDate;
  final DateTime? actualBirthDate;
  final int? birthCount;      // Total born
  final int? aliveCount;      // Born alive
  final int? deadCount;       // Born dead
  final int? maleBorn;        // Male born alive
  final int? femaleBorn;      // Female born alive
  final DateTime? weaningDate;
  final int? weanedCount;
  final int? maleWeaned;      // Male weaned
  final int? femaleWeaned;    // Female weaned
  final BreedingStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Denormalized for display
  final String? damCode;
  final String? damName;
  final String? sireCode;
  final String? sireName;

  const BreedingRecord({
    required this.id,
    required this.farmId,
    required this.damId,
    this.sireId,
    required this.matingDate,
    this.palpationDate,
    this.isPalpationPositive,
    this.expectedBirthDate,
    this.actualBirthDate,
    this.birthCount,
    this.aliveCount,
    this.deadCount,
    this.maleBorn,
    this.femaleBorn,
    this.weaningDate,
    this.weanedCount,
    this.maleWeaned,
    this.femaleWeaned,
    this.status = BreedingStatus.mated,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.damCode,
    this.damName,
    this.sireCode,
    this.sireName,
  });

  /// Display name for dam
  String get damDisplayName => damName ?? damCode ?? 'Unknown';

  /// Display name for sire
  String get sireDisplayName => sireName ?? sireCode ?? 'Unknown';

  /// Days since mating
  int get daysSinceMating => DateTime.now().difference(matingDate).inDays;

  /// Days until expected birth (negative if overdue)
  int? get daysUntilBirth {
    if (expectedBirthDate == null) return null;
    return expectedBirthDate!.difference(DateTime.now()).inDays;
  }

  /// Weaning success rate (weanedCount / aliveCount)
  double? get weaningRate {
    if (weanedCount == null || aliveCount == null || aliveCount == 0) {
      return null;
    }
    return weanedCount! / aliveCount!;
  }

  /// Create from JSON (Supabase response)
  factory BreedingRecord.fromJson(Map<String, dynamic> json) {
    return BreedingRecord(
      id: json['id'] as String,
      farmId: json['farm_id'] as String,
      damId: json['dam_id'] as String,
      sireId: json['sire_id'] as String?,
      matingDate: DateTime.parse(json['mating_date'] as String),
      palpationDate: json['palpation_date'] != null 
          ? DateTime.parse(json['palpation_date'] as String) 
          : null,
      isPalpationPositive: json['is_palpation_positive'] as bool?,
      expectedBirthDate: json['expected_birth_date'] != null 
          ? DateTime.parse(json['expected_birth_date'] as String) 
          : null,
      actualBirthDate: json['actual_birth_date'] != null 
          ? DateTime.parse(json['actual_birth_date'] as String) 
          : null,
      birthCount: json['birth_count'] as int?,
      aliveCount: json['alive_count'] as int?,
      deadCount: json['dead_count'] as int?,
      maleBorn: json['male_born'] as int?,
      femaleBorn: json['female_born'] as int?,
      weaningDate: json['weaning_date'] != null 
          ? DateTime.parse(json['weaning_date'] as String) 
          : null,
      weanedCount: json['weaned_count'] as int?,
      maleWeaned: json['male_weaned'] as int?,
      femaleWeaned: json['female_weaned'] as int?,
      status: BreedingStatus.fromString(json['status'] as String? ?? 'mated'),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      damCode: json['dam']?['code'] as String?,
      damName: json['dam']?['name'] as String?,
      sireCode: json['sire']?['code'] as String?,
      sireName: json['sire']?['name'] as String?,
    );
  }

  /// Convert to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'farm_id': farmId,
      'dam_id': damId,
      'sire_id': sireId,
      'mating_date': matingDate.toIso8601String().split('T').first,
      'palpation_date': palpationDate?.toIso8601String().split('T').first,
      'is_palpation_positive': isPalpationPositive,
      'expected_birth_date': expectedBirthDate?.toIso8601String().split('T').first,
      'actual_birth_date': actualBirthDate?.toIso8601String().split('T').first,
      'birth_count': birthCount,
      'alive_count': aliveCount,
      'dead_count': deadCount,
      'male_born': maleBorn,
      'female_born': femaleBorn,
      'weaning_date': weaningDate?.toIso8601String().split('T').first,
      'weaned_count': weanedCount,
      'male_weaned': maleWeaned,
      'female_weaned': femaleWeaned,
      'status': status.value,
      'notes': notes,
    };
  }

  /// Create copy with updated fields
  BreedingRecord copyWith({
    String? id,
    String? farmId,
    String? damId,
    String? sireId,
    DateTime? matingDate,
    DateTime? palpationDate,
    bool? isPalpationPositive,
    DateTime? expectedBirthDate,
    DateTime? actualBirthDate,
    int? birthCount,
    int? aliveCount,
    int? deadCount,
    int? maleBorn,
    int? femaleBorn,
    DateTime? weaningDate,
    int? weanedCount,
    int? maleWeaned,
    int? femaleWeaned,
    BreedingStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? damCode,
    String? damName,
    String? sireCode,
    String? sireName,
  }) {
    return BreedingRecord(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      damId: damId ?? this.damId,
      sireId: sireId ?? this.sireId,
      matingDate: matingDate ?? this.matingDate,
      palpationDate: palpationDate ?? this.palpationDate,
      isPalpationPositive: isPalpationPositive ?? this.isPalpationPositive,
      expectedBirthDate: expectedBirthDate ?? this.expectedBirthDate,
      actualBirthDate: actualBirthDate ?? this.actualBirthDate,
      birthCount: birthCount ?? this.birthCount,
      aliveCount: aliveCount ?? this.aliveCount,
      deadCount: deadCount ?? this.deadCount,
      maleBorn: maleBorn ?? this.maleBorn,
      femaleBorn: femaleBorn ?? this.femaleBorn,
      weaningDate: weaningDate ?? this.weaningDate,
      weanedCount: weanedCount ?? this.weanedCount,
      maleWeaned: maleWeaned ?? this.maleWeaned,
      femaleWeaned: femaleWeaned ?? this.femaleWeaned,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      damCode: damCode ?? this.damCode,
      damName: damName ?? this.damName,
      sireCode: sireCode ?? this.sireCode,
      sireName: sireName ?? this.sireName,
    );
  }

  @override
  String toString() => 'BreedingRecord(id: $id, dam: $damCode, status: $status)';
}

/// Breeding status enum
enum BreedingStatus {
  mated('mated', 'Kawin'),
  palpated('palpated', 'Sudah Palpasi'),
  pregnant('pregnant', 'Bunting'),
  birthed('birthed', 'Sudah Melahirkan'),
  weaned('weaned', 'Sudah Sapih'),
  failed('failed', 'Gagal');

  final String value;
  final String displayName;

  const BreedingStatus(this.value, this.displayName);

  static BreedingStatus fromString(String value) {
    return BreedingStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BreedingStatus.mated,
    );
  }
}

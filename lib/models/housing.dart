/// Housing Model (Kandang)
/// 
/// Represents a housing unit for livestock.
/// Can be individual cage or colony depending on animal type.

library;

class Housing {
  final String id;
  final String farmId;
  final String code;       // e.g., "K-001", "A-01"
  final String? name;
  final String? block;     // Block/area grouping
  final int capacity;
  final HousingType type;
  final HousingStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Computed properties (not stored in DB)
  final int? currentOccupancy;

  const Housing({
    required this.id,
    required this.farmId,
    required this.code,
    this.name,
    this.block,
    this.capacity = 1,
    this.type = HousingType.individual,
    this.status = HousingStatus.active,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.currentOccupancy,
  });

  /// Display name (use name if available, otherwise code)
  String get displayName => name ?? code;

  /// Check if housing has available space
  bool get hasSpace => (currentOccupancy ?? 0) < capacity;

  /// Available space count
  int get availableSpace => capacity - (currentOccupancy ?? 0);

  /// Occupancy percentage
  double get occupancyPercentage {
    if (capacity == 0) return 0;
    return ((currentOccupancy ?? 0) / capacity) * 100;
  }

  /// Create from JSON (Supabase response)
  factory Housing.fromJson(Map<String, dynamic> json) {
    return Housing(
      id: json['id'] as String,
      farmId: json['farm_id'] as String,
      code: json['code'] as String,
      name: json['name'] as String?,
      block: json['block'] as String?,
      capacity: json['capacity'] as int? ?? 1,
      type: HousingType.fromString(json['housing_type'] as String? ?? 'individual'),
      status: HousingStatus.fromString(json['status'] as String? ?? 'active'),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      currentOccupancy: json['current_occupancy'] as int?,
    );
  }

  /// Convert to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'farm_id': farmId,
      'code': code,
      'name': name,
      'block': block,
      'capacity': capacity,
      'housing_type': type.value,
      'status': status.value,
      'notes': notes,
    };
  }

  /// Create copy with updated fields
  Housing copyWith({
    String? id,
    String? farmId,
    String? code,
    String? name,
    String? block,
    int? capacity,
    HousingType? type,
    HousingStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? currentOccupancy,
  }) {
    return Housing(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      code: code ?? this.code,
      name: name ?? this.name,
      block: block ?? this.block,
      capacity: capacity ?? this.capacity,
      type: type ?? this.type,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentOccupancy: currentOccupancy ?? this.currentOccupancy,
    );
  }

  @override
  String toString() => 'Housing(id: $id, code: $code, capacity: $capacity)';
}

/// Housing type enum
enum HousingType {
  individual('individual', 'Individual'),
  colony('colony', 'Koloni'),
  pond('pond', 'Kolam');

  final String value;
  final String displayName;

  const HousingType(this.value, this.displayName);

  static HousingType fromString(String value) {
    return HousingType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => HousingType.individual,
    );
  }
}

/// Housing status enum
enum HousingStatus {
  active('active', 'Aktif'),
  maintenance('maintenance', 'Perawatan'),
  inactive('inactive', 'Tidak Aktif');

  final String value;
  final String displayName;

  const HousingStatus(this.value, this.displayName);

  static HousingStatus fromString(String value) {
    return HousingStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => HousingStatus.active,
    );
  }
}

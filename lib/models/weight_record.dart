/// Weight Record Model
/// 
/// Model untuk menyimpan riwayat pengukuran berat ternak.

library;

class WeightRecord {
  final String id;
  final String livestockId;
  final double weight;
  final int? ageDays;
  final DateTime recordedAt;
  final String? notes;
  final DateTime? createdAt;

  const WeightRecord({
    required this.id,
    required this.livestockId,
    required this.weight,
    this.ageDays,
    required this.recordedAt,
    this.notes,
    this.createdAt,
  });

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    return WeightRecord(
      id: json['id'] as String,
      livestockId: json['livestock_id'] as String,
      weight: (json['weight'] as num).toDouble(),
      ageDays: json['age_days'] as int?,
      recordedAt: DateTime.parse(json['recorded_at'] as String),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'livestock_id': livestockId,
    'weight': weight,
    'age_days': ageDays,
    'recorded_at': recordedAt.toIso8601String(),
    'notes': notes,
  };

  /// Format umur saat pengukuran
  String get ageFormatted {
    if (ageDays == null) return '-';
    
    final months = ageDays! ~/ 30;
    final days = ageDays! % 30;
    
    if (months > 0 && days > 0) {
      return '${months}bln ${days}hr';
    } else if (months > 0) {
      return '${months}bln';
    } else {
      return '${days}hr';
    }
  }

  /// Format tanggal pengukuran
  String get formattedDate {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${recordedAt.day.toString().padLeft(2, '0')} ${months[recordedAt.month - 1]} ${recordedAt.year}';
  }

  /// Format berat
  String get formattedWeight => '$weight kg';
}

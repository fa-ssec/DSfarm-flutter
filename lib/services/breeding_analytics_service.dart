/// Breeding Analytics Service
/// 
/// Service untuk kalkulasi statistik dan analitik breeding.

library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/breeding_record.dart';

/// Statistik breeding per induk (dam)
class DamStats {
  final String damId;
  final String damCode;
  final int totalBreedings;
  final int successfulBreedings;  // yang melahirkan (birthCount > 0)
  final int failedBreedings;
  final int totalBorn;
  final int totalWeaned;

  const DamStats({
    required this.damId,
    required this.damCode,
    required this.totalBreedings,
    required this.successfulBreedings,
    required this.failedBreedings,
    required this.totalBorn,
    required this.totalWeaned,
  });

  /// Success rate (successful / total)
  double get successRate => 
      totalBreedings > 0 ? successfulBreedings / totalBreedings : 0;

  /// Weaning rate (weaned / born)
  double get weaningRate => 
      totalBorn > 0 ? totalWeaned / totalBorn : 0;

  /// Average litter size
  double get avgLitterSize => 
      successfulBreedings > 0 ? totalBorn / successfulBreedings : 0;

  /// Success rate as percentage string
  String get successRatePercent => '${(successRate * 100).toStringAsFixed(0)}%';

  /// Weaning rate as percentage string
  String get weaningRatePercent => '${(weaningRate * 100).toStringAsFixed(0)}%';
}

/// Statistik breeding per pejantan (sire)
class SireStats {
  final String sireId;
  final String sireCode;
  final int totalBreedings;
  final int successfulBreedings;
  final int totalBorn;

  const SireStats({
    required this.sireId,
    required this.sireCode,
    required this.totalBreedings,
    required this.successfulBreedings,
    required this.totalBorn,
  });

  double get successRate => 
      totalBreedings > 0 ? successfulBreedings / totalBreedings : 0;

  double get avgLitterSize => 
      successfulBreedings > 0 ? totalBorn / successfulBreedings : 0;

  String get successRatePercent => '${(successRate * 100).toStringAsFixed(0)}%';
}

/// Statistik breeding keseluruhan farm
class FarmBreedingStats {
  final int totalBreedings;
  final int successfulBreedings;
  final int failedBreedings;
  final int totalBorn;
  final int totalWeaned;
  final int activeBreedings;  // yang masih berjalan (mated, pregnant)

  const FarmBreedingStats({
    required this.totalBreedings,
    required this.successfulBreedings,
    required this.failedBreedings,
    required this.totalBorn,
    required this.totalWeaned,
    required this.activeBreedings,
  });

  double get successRate => 
      totalBreedings > 0 ? successfulBreedings / totalBreedings : 0;

  double get weaningRate => 
      totalBorn > 0 ? totalWeaned / totalBorn : 0;

  double get avgLitterSize => 
      successfulBreedings > 0 ? totalBorn / successfulBreedings : 0;

  String get successRatePercent => '${(successRate * 100).toStringAsFixed(0)}%';
  String get weaningRatePercent => '${(weaningRate * 100).toStringAsFixed(0)}%';
}

/// Breeding Calendar Event
class BreedingEvent {
  final String id;
  final DateTime date;
  final BreedingEventType type;
  final String title;
  final String? damCode;
  final String? sireCode;
  final String? breedingId;

  const BreedingEvent({
    required this.id,
    required this.date,
    required this.type,
    required this.title,
    this.damCode,
    this.sireCode,
    this.breedingId,
  });
}

enum BreedingEventType {
  mating('Kawin', '🔴'),
  palpation('Palpasi', '🟡'),
  expectedBirth('Perkiraan Lahir', '🟠'),
  birth('Lahir', '🟢'),
  weaning('Sapih', '🔵');

  final String label;
  final String icon;
  const BreedingEventType(this.label, this.icon);
}

/// Service untuk breeding analytics
class BreedingAnalyticsService {
  final SupabaseClient _client;

  BreedingAnalyticsService(this._client);

  /// Get statistik keseluruhan farm
  Future<FarmBreedingStats> getFarmStats(String farmId) async {
    final response = await _client
        .from('breeding_records')
        .select('*')
        .eq('farm_id', farmId);

    final records = (response as List)
        .map((json) => BreedingRecord.fromJson(json as Map<String, dynamic>))
        .toList();

    int total = records.length;
    int successful = records.where((r) => 
        r.status == BreedingStatus.birthed || 
        r.status == BreedingStatus.weaned).length;
    int failed = records.where((r) => r.status == BreedingStatus.failed).length;
    int active = records.where((r) => 
        r.status == BreedingStatus.mated || 
        r.status == BreedingStatus.palpated ||
        r.status == BreedingStatus.pregnant).length;
    int born = records.fold(0, (sum, r) => sum + (r.aliveCount ?? 0));
    int weaned = records.fold(0, (sum, r) => sum + (r.weanedCount ?? 0));

    return FarmBreedingStats(
      totalBreedings: total,
      successfulBreedings: successful,
      failedBreedings: failed,
      totalBorn: born,
      totalWeaned: weaned,
      activeBreedings: active,
    );
  }

  /// Get statistik per induk (dam)
  Future<List<DamStats>> getDamStats(String farmId) async {
    final response = await _client
        .from('breeding_records')
        .select('''
          dam_id,
          status,
          alive_count,
          weaned_count,
          dam:dam_id(code)
        ''')
        .eq('farm_id', farmId);

    // Group by dam_id
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final record in response as List) {
      final damId = record['dam_id'] as String;
      grouped.putIfAbsent(damId, () => []).add(record as Map<String, dynamic>);
    }

    // Calculate stats per dam
    return grouped.entries.map((entry) {
      final damId = entry.key;
      final records = entry.value;
      final damCode = records.first['dam']?['code'] as String? ?? 'Unknown';

      int total = records.length;
      int successful = records.where((r) {
        final status = r['status'] as String?;
        return status == 'birthed' || status == 'weaned';
      }).length;
      int failed = records.where((r) => r['status'] == 'failed').length;
      int born = records.fold(0, (sum, r) => sum + ((r['alive_count'] as int?) ?? 0));
      int weaned = records.fold(0, (sum, r) => sum + ((r['weaned_count'] as int?) ?? 0));

      return DamStats(
        damId: damId,
        damCode: damCode,
        totalBreedings: total,
        successfulBreedings: successful,
        failedBreedings: failed,
        totalBorn: born,
        totalWeaned: weaned,
      );
    }).toList()
      ..sort((a, b) => b.successRate.compareTo(a.successRate)); // Sort by success rate
  }

  /// Get statistik per pejantan (sire)
  Future<List<SireStats>> getSireStats(String farmId) async {
    final response = await _client
        .from('breeding_records')
        .select('''
          sire_id,
          status,
          alive_count,
          sire:sire_id(code)
        ''')
        .eq('farm_id', farmId)
        .not('sire_id', 'is', null);

    // Group by sire_id
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final record in response as List) {
      final sireId = record['sire_id'] as String?;
      if (sireId != null) {
        grouped.putIfAbsent(sireId, () => []).add(record as Map<String, dynamic>);
      }
    }

    // Calculate stats per sire
    return grouped.entries.map((entry) {
      final sireId = entry.key;
      final records = entry.value;
      final sireCode = records.first['sire']?['code'] as String? ?? 'Unknown';

      int total = records.length;
      int successful = records.where((r) {
        final status = r['status'] as String?;
        return status == 'birthed' || status == 'weaned';
      }).length;
      int born = records.fold(0, (sum, r) => sum + ((r['alive_count'] as int?) ?? 0));

      return SireStats(
        sireId: sireId,
        sireCode: sireCode,
        totalBreedings: total,
        successfulBreedings: successful,
        totalBorn: born,
      );
    }).toList()
      ..sort((a, b) => b.successRate.compareTo(a.successRate));
  }

  /// Get breeding events untuk calendar
  Future<List<BreedingEvent>> getCalendarEvents(String farmId, DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    final response = await _client
        .from('breeding_records')
        .select('''
          id,
          mating_date,
          palpation_date,
          expected_birth_date,
          actual_birth_date,
          weaning_date,
          dam:dam_id(code),
          sire:sire_id(code)
        ''')
        .eq('farm_id', farmId);

    final events = <BreedingEvent>[];

    for (final record in response as List) {
      final id = record['id'] as String;
      final damCode = record['dam']?['code'] as String?;
      final sireCode = record['sire']?['code'] as String?;

      // Mating date
      if (record['mating_date'] != null) {
        final date = DateTime.parse(record['mating_date'] as String);
        if (_isInMonth(date, startOfMonth, endOfMonth)) {
          events.add(BreedingEvent(
            id: '${id}_mating',
            date: date,
            type: BreedingEventType.mating,
            title: 'Kawin: $damCode',
            damCode: damCode,
            sireCode: sireCode,
            breedingId: id,
          ));
        }
      }

      // Expected birth date
      if (record['expected_birth_date'] != null) {
        final date = DateTime.parse(record['expected_birth_date'] as String);
        if (_isInMonth(date, startOfMonth, endOfMonth)) {
          events.add(BreedingEvent(
            id: '${id}_expected',
            date: date,
            type: BreedingEventType.expectedBirth,
            title: 'Perkiraan lahir: $damCode',
            damCode: damCode,
            sireCode: sireCode,
            breedingId: id,
          ));
        }
      }

      // Actual birth date
      if (record['actual_birth_date'] != null) {
        final date = DateTime.parse(record['actual_birth_date'] as String);
        if (_isInMonth(date, startOfMonth, endOfMonth)) {
          events.add(BreedingEvent(
            id: '${id}_birth',
            date: date,
            type: BreedingEventType.birth,
            title: 'Lahir: $damCode',
            damCode: damCode,
            sireCode: sireCode,
            breedingId: id,
          ));
        }
      }

      // Weaning date
      if (record['weaning_date'] != null) {
        final date = DateTime.parse(record['weaning_date'] as String);
        if (_isInMonth(date, startOfMonth, endOfMonth)) {
          events.add(BreedingEvent(
            id: '${id}_weaning',
            date: date,
            type: BreedingEventType.weaning,
            title: 'Sapih: $damCode',
            damCode: damCode,
            sireCode: sireCode,
            breedingId: id,
          ));
        }
      }
    }

    // Sort by date
    events.sort((a, b) => a.date.compareTo(b.date));
    return events;
  }

  bool _isInMonth(DateTime date, DateTime start, DateTime end) {
    return !date.isBefore(start) && !date.isAfter(end);
  }

  /// Get fertility rate untuk livestock tertentu
  Future<DamStats?> getLivestockBreedingStats(String livestockId) async {
    final response = await _client
        .from('breeding_records')
        .select('''
          status,
          alive_count,
          weaned_count,
          dam:dam_id(code)
        ''')
        .eq('dam_id', livestockId);

    if ((response as List).isEmpty) return null;

    final records = response;
    final damCode = records.first['dam']?['code'] as String? ?? 'Unknown';

    int total = records.length;
    int successful = records.where((r) {
      final status = r['status'] as String?;
      return status == 'birthed' || status == 'weaned';
    }).length;
    int failed = records.where((r) => r['status'] == 'failed').length;
    int born = records.fold(0, (sum, r) => sum + ((r['alive_count'] as int?) ?? 0));
    int weaned = records.fold(0, (sum, r) => sum + ((r['weaned_count'] as int?) ?? 0));

    return DamStats(
      damId: livestockId,
      damCode: damCode,
      totalBreedings: total,
      successfulBreedings: successful,
      failedBreedings: failed,
      totalBorn: born,
      totalWeaned: weaned,
    );
  }
}

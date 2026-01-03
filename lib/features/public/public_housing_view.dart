/// Public Housing View Page
/// 
/// Public page (no auth required) for viewing housing details
/// when scanned via QR code.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/housing.dart';
import '../../models/livestock.dart';

/// Provider for housing by ID (for public view - uses direct Supabase query)
final publicHousingProvider = FutureProvider.family<Housing?, String>((ref, housingId) async {
  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('housings')
      .select('*, blocks(code)')
      .eq('id', housingId)
      .maybeSingle();
  
  if (response == null) return null;
  return Housing.fromJson(response);
});

/// Provider for livestock in housing using direct Supabase query
final publicLivestockInHousingProvider = FutureProvider.family<List<Livestock>, String>((ref, housingId) async {
  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('livestocks')
      .select('''
        *,
        breeds:breed_id(id, code, name)
      ''')
      .eq('housing_id', housingId)
      .not('status', 'in', '(terjual,mati)');
  
  return (response as List).map((json) => Livestock.fromJson(json)).toList();
});

/// Breeding stats for a female livestock
class BreedingStats {
  final int totalMatings;        // Total times mated
  final int successfulBreedings; // Breedings that resulted in birth
  final DateTime? lastBreedingDate;
  final double successRate;      // successfulBreedings / totalMatings
  
  const BreedingStats({
    required this.totalMatings,
    required this.successfulBreedings,
    this.lastBreedingDate,
    required this.successRate,
  });
  
  factory BreedingStats.empty() => const BreedingStats(
    totalMatings: 0,
    successfulBreedings: 0,
    lastBreedingDate: null,
    successRate: 0,
  );
  
  factory BreedingStats.fromRecords(List<Map<String, dynamic>> records) {
    if (records.isEmpty) return BreedingStats.empty();
    
    final totalMatings = records.length;
    final successfulBreedings = records.where((r) => 
      r['actual_birth_date'] != null || 
      r['status'] == 'birthed' || 
      r['status'] == 'weaned'
    ).length;
    
    // Sort by mating_date descending to get last
    records.sort((a, b) => (b['mating_date'] as String).compareTo(a['mating_date'] as String));
    final lastMatingDateStr = records.first['mating_date'] as String?;
    final lastBreedingDate = lastMatingDateStr != null ? DateTime.tryParse(lastMatingDateStr) : null;
    
    return BreedingStats(
      totalMatings: totalMatings,
      successfulBreedings: successfulBreedings,
      lastBreedingDate: lastBreedingDate,
      successRate: totalMatings > 0 ? (successfulBreedings / totalMatings) * 100 : 0,
    );
  }
}

/// Provider for breeding stats by livestock ID
final publicBreedingStatsProvider = FutureProvider.family<BreedingStats, String>((ref, livestockId) async {
  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('breeding_records')
      .select('id, mating_date, actual_birth_date, status')
      .eq('dam_id', livestockId)
      .order('mating_date', ascending: false);
  
  return BreedingStats.fromRecords((response as List).cast<Map<String, dynamic>>());
});

class PublicHousingViewPage extends ConsumerWidget {
  final String housingId;
  
  const PublicHousingViewPage({super.key, required this.housingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final housingAsync = ref.watch(publicHousingProvider(housingId));
    final livestockAsync = ref.watch(publicLivestockInHousingProvider(housingId));
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.home_work_rounded, size: 24),
            SizedBox(width: 10),
            Text('DSFarm', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: false,
      ),
      body: housingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Kandang tidak ditemukan', style: TextStyle(fontSize: 18, color: Colors.grey[700])),
              const SizedBox(height: 8),
              Text('ID: $housingId', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
        ),
        data: (housing) {
          if (housing == null) {
            return const Center(child: Text('Kandang tidak ditemukan'));
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Housing Info Card - get livestock count from provider
                livestockAsync.when(
                  loading: () => _buildHousingInfoCard(context, housing, 0),
                  error: (_, __) => _buildHousingInfoCard(context, housing, 0),
                  data: (livestock) => _buildHousingInfoCard(context, housing, livestock.length),
                ),
                const SizedBox(height: 24),
                
                // Livestock List
                Text(
                  'Ternak di Kandang Ini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                
                livestockAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                  data: (livestock) {
                    if (livestock.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.pets, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text('Belum ada ternak', style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    return Column(
                      children: livestock.map((l) => _LivestockDetailCard(livestock: l)).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildHousingInfoCard(BuildContext context, Housing housing, int livestockCount) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E3A5F)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        housing.displayName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        housing.type.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withAlpha(180),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _infoChip(
                  icon: Icons.layers,
                  label: 'Kapasitas',
                  value: '${housing.capacity} ekor',
                ),
                const SizedBox(width: 12),
                _infoChip(
                  icon: Icons.groups,
                  label: 'Terisi',
                  value: '$livestockCount ekor',
                ),
                const SizedBox(width: 12),
                _infoChip(
                  icon: Icons.check_circle,
                  label: 'Status',
                  value: housing.status.displayName,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _infoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white.withAlpha(150), size: 14),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(150)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card for displaying livestock details in public view
/// Shows weight, health, and breeding info (expandable)
class _LivestockDetailCard extends ConsumerWidget {
  final Livestock livestock;
  
  const _LivestockDetailCard({required this.livestock});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFemale = livestock.gender == Gender.female;
    final genderColor = isFemale ? const Color(0xFFEC4899) : const Color(0xFF3B82F6);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: ID + Gender + Status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: genderColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isFemale ? '♀' : '♂',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: genderColor),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ID',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              livestock.code,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${livestock.breedName ?? _extractBreedFromCode(livestock.code)} • ${livestock.ageFormatted}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(livestock.status).withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _formatStatus(livestock.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(livestock.status),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            
            // Info Grid: Weight, Health
            Row(
              children: [
                // Weight
                Expanded(
                  child: _infoTile(
                    icon: Icons.monitor_weight_outlined,
                    label: 'Berat',
                    value: livestock.weight != null 
                        ? '${livestock.weight!.toStringAsFixed(1)} kg' 
                        : '-',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                // Health Status (use notes as proxy or show healthy)
                Expanded(
                  child: _infoTile(
                    icon: Icons.favorite_outline,
                    label: 'Kesehatan',
                    value: 'Sehat', // Default for public view
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            
            // Breeding info for females
            if (isFemale) ...[
              const SizedBox(height: 12),
              _BreedingStatsSection(livestock: livestock),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ],
      ),
    );
  }
  
  bool _isBreedingStatus(String status) {
    return ['bunting', 'menyusui', 'siap_kawin'].contains(status);
  }
  
  String _getBreedingInfo(String status) {
    switch (status) {
      case 'bunting':
        return 'Sedang bunting';
      case 'menyusui':
        return 'Sedang menyusui anak';
      case 'siap_kawin':
        return 'Siap untuk dikawinkan';
      default:
        return '';
    }
  }
  
  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').split(' ').map((w) => 
      w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}'
    ).join(' ');
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pejantan_aktif':
      case 'siap_kawin':
        return const Color(0xFF3B82F6);
      case 'bunting':
        return const Color(0xFFEC4899);
      case 'menyusui':
        return const Color(0xFFF59E0B);
      case 'istirahat':
        return const Color(0xFF9CA3AF);
      default:
        return const Color(0xFF10B981);
    }
  }
  
  /// Extract breed code from livestock code (e.g., "REX-J02" -> "REX")
  String _extractBreedFromCode(String code) {
    final parts = code.split('-');
    if (parts.isNotEmpty) {
      return parts.first;
    }
    return code;
  }
}

/// Widget for displaying breeding stats for female livestock
class _BreedingStatsSection extends ConsumerWidget {
  final Livestock livestock;
  
  const _BreedingStatsSection({required this.livestock});
  
  // Minimum breeding age in days (4 months)
  static const int _minBreedingAgeDays = 120;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breedingStatsAsync = ref.watch(publicBreedingStatsProvider(livestock.id));
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF2F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCE7F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.child_friendly, color: Color(0xFFEC4899), size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Riwayat Breeding',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFBE185D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Check if ready to breed (age >= 4 months)
          if (livestock.ageInDays != null && livestock.ageInDays! < _minBreedingAgeDays) ...[
            // Young rabbit - show when ready
            _buildInfoRow(
              icon: Icons.schedule,
              label: 'Status',
              value: 'Belum siap kawin',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Siap kawin',
              value: _formatReadyDate(),
            ),
          ] else ...[
            // Old enough - show breeding stats
            breedingStatsAsync.when(
              loading: () => const Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (_, __) => _buildInfoRow(
                icon: Icons.info_outline,
                label: 'Status',
                value: 'Data tidak tersedia',
              ),
              data: (stats) {
                if (stats.totalMatings == 0) {
                  // Never bred
                  return Column(
                    children: [
                      _buildInfoRow(
                        icon: Icons.info_outline,
                        label: 'Status',
                        value: 'Belum pernah breeding',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: Icons.check_circle_outline,
                        label: 'Kesiapan',
                        value: 'Siap untuk dikawinkan',
                      ),
                    ],
                  );
                } else {
                  // Has breeding history
                  return Column(
                    children: [
                      _buildInfoRow(
                        icon: Icons.repeat,
                        label: 'Total kawin',
                        value: '${stats.totalMatings}x',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: Icons.check_circle,
                        label: 'Berhasil melahirkan',
                        value: '${stats.successfulBreedings}x',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: Icons.percent,
                        label: 'Tingkat keberhasilan',
                        value: '${stats.successRate.toStringAsFixed(0)}%',
                      ),
                      if (stats.lastBreedingDate != null) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          icon: Icons.history,
                          label: 'Breeding terakhir',
                          value: _formatDate(stats.lastBreedingDate!),
                        ),
                      ],
                    ],
                  );
                }
              },
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFDB2777)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFFBE185D),
            ),
          ),
        ),
      ],
    );
  }
  
  String _formatReadyDate() {
    if (livestock.birthDate == null) return '-';
    final readyDate = livestock.birthDate!.add(const Duration(days: _minBreedingAgeDays));
    return '${readyDate.day}/${readyDate.month}/${readyDate.year}';
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Sync Queue Service
/// 
/// Handles automatic synchronization of pending operations when device comes back online.

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'offline_cache_service.dart';
import '../repositories/finance_repository.dart';
import '../models/finance.dart';

class SyncQueueService {
  static StreamSubscription<bool>? _connectivitySubscription;
  static bool _isSyncing = false;
  
  static final _syncStatusController = StreamController<SyncStatus>.broadcast();
  static Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  
  static SyncStatus _currentStatus = SyncStatus.idle;
  static SyncStatus get currentStatus => _currentStatus;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Start listening for connectivity changes
  static void startListening() {
    _connectivitySubscription = OfflineCacheService.connectivityStream.listen((isOnline) {
      if (isOnline) {
        print('SyncQueueService: Back online - starting sync');
        syncPendingOperations();
      }
    });
    print('SyncQueueService: Started listening for connectivity');
  }
  
  /// Stop listening
  static void stopListening() {
    _connectivitySubscription?.cancel();
    _syncStatusController.close();
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // SYNC OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Sync all pending operations
  static Future<SyncResult> syncPendingOperations() async {
    if (_isSyncing) {
      print('SyncQueueService: Already syncing, skipping');
      return SyncResult(success: 0, failed: 0, pending: OfflineCacheService.pendingCount);
    }
    
    if (!OfflineCacheService.isOnline) {
      print('SyncQueueService: Still offline, skipping sync');
      return SyncResult(success: 0, failed: 0, pending: OfflineCacheService.pendingCount);
    }
    
    _isSyncing = true;
    _updateStatus(SyncStatus.syncing);
    
    final operations = OfflineCacheService.getPendingOperations();
    print('SyncQueueService: Found ${operations.length} pending operations');
    
    int successCount = 0;
    int failedCount = 0;
    
    for (final op in operations) {
      try {
        await _processOperation(op);
        await OfflineCacheService.removePendingOperation(op['id'] as String);
        successCount++;
        print('SyncQueueService: Synced operation ${op['id']}');
      } catch (e) {
        failedCount++;
        print('SyncQueueService: Failed to sync ${op['id']}: $e');
      }
    }
    
    _isSyncing = false;
    _updateStatus(failedCount > 0 ? SyncStatus.error : SyncStatus.idle);
    
    print('SyncQueueService: Sync complete - Success: $successCount, Failed: $failedCount');
    return SyncResult(success: successCount, failed: failedCount, pending: failedCount);
  }
  
  static Future<void> _processOperation(Map<String, dynamic> op) async {
    final type = op['type'] as String;
    final entity = op['entity'] as String;
    final data = Map<String, dynamic>.from(op['data'] as Map);
    
    switch (entity) {
      case 'finance':
        await _syncFinanceOperation(type, data);
        break;
      case 'livestock':
        await _syncLivestockOperation(type, data);
        break;
      case 'offspring':
        await _syncOffspringOperation(type, data);
        break;
      default:
        throw Exception('Unknown entity: $entity');
    }
  }
  
  static Future<void> _syncFinanceOperation(String type, Map<String, dynamic> data) async {
    final repository = FinanceRepository();
    
    switch (type) {
      case 'create':
        await repository.createTransaction(
          farmId: data['farm_id'] as String,
          type: data['type'] == 'income' ? TransactionType.income : TransactionType.expense,
          categoryId: data['category_id'] as String,
          amount: (data['amount'] as num).toDouble(),
          transactionDate: DateTime.parse(data['transaction_date'] as String),
          description: data['description'] as String?,
          referenceId: data['reference_id'] as String?,
          referenceType: data['reference_type'] as String?,
        );
        break;
      case 'delete':
        await repository.deleteTransaction(data['id'] as String);
        break;
      default:
        throw Exception('Unknown operation type: $type');
    }
  }
  
  static Future<void> _syncLivestockOperation(String type, Map<String, dynamic> data) async {
    // TODO: Implement livestock sync
    print('SyncQueueService: Livestock sync not yet implemented');
  }
  
  static Future<void> _syncOffspringOperation(String type, Map<String, dynamic> data) async {
    // TODO: Implement offspring sync
    print('SyncQueueService: Offspring sync not yet implemented');
  }
  
  static void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    _syncStatusController.add(status);
  }
}

enum SyncStatus { idle, syncing, error }

class SyncResult {
  final int success;
  final int failed;
  final int pending;
  
  SyncResult({required this.success, required this.failed, required this.pending});
  
  bool get hasErrors => failed > 0;
  bool get hasPending => pending > 0;
}

/// Provider for sync status
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  return SyncQueueService.syncStatusStream;
});

/// Provider for pending count
final pendingOperationsCountProvider = Provider<int>((ref) {
  return OfflineCacheService.pendingCount;
});

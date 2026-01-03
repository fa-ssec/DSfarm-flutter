/// Offline Cache Service
/// 
/// Handles local data caching with Hive for offline support.
/// Provides cache-first strategy with automatic sync.

import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../models/finance.dart';

class OfflineCacheService {
  static const String _financeBoxName = 'finance_transactions';
  static const String _pendingOpsBoxName = 'pending_operations';
  static const String _metadataBoxName = 'cache_metadata';
  
  static Box<Map>? _financeBox;
  static Box<Map>? _pendingOpsBox;
  static Box<dynamic>? _metadataBox;
  
  static StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  static final _connectivityController = StreamController<bool>.broadcast();
  
  /// Stream of connectivity status
  static Stream<bool> get connectivityStream => _connectivityController.stream;
  
  static bool _isOnline = true;
  static bool get isOnline => _isOnline;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Initialize Hive and open boxes
  static Future<void> init() async {
    await Hive.initFlutter();
    
    _financeBox = await Hive.openBox<Map>(_financeBoxName);
    _pendingOpsBox = await Hive.openBox<Map>(_pendingOpsBoxName);
    _metadataBox = await Hive.openBox(_metadataBoxName);
    
    // Start connectivity monitoring
    _startConnectivityMonitoring();
    
    print('OfflineCacheService: Initialized');
  }
  
  static void _startConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final wasOnline = _isOnline;
      _isOnline = results.isNotEmpty && !results.contains(ConnectivityResult.none);
      
      if (_isOnline != wasOnline) {
        _connectivityController.add(_isOnline);
        print('OfflineCacheService: Connectivity changed - Online: $_isOnline');
        
        if (_isOnline && wasOnline == false) {
          // Just came back online - trigger sync
          _triggerSync();
        }
      }
    });
    
    // Check initial connectivity
    Connectivity().checkConnectivity().then((results) {
      _isOnline = results.isNotEmpty && !results.contains(ConnectivityResult.none);
      _connectivityController.add(_isOnline);
    });
  }
  
  static void _triggerSync() {
    print('OfflineCacheService: Triggering sync for pending operations');
    // Will be called by SyncQueueService
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // FINANCE CACHE
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Cache finance transactions for a farm
  static Future<void> cacheFinanceTransactions(String farmId, List<FinanceTransaction> transactions) async {
    if (_financeBox == null) return;
    
    final data = transactions.map((tx) => _transactionToMap(tx)).toList();
    await _financeBox!.put('farm_$farmId', {'transactions': data, 'cachedAt': DateTime.now().toIso8601String()});
    
    print('OfflineCacheService: Cached ${transactions.length} transactions for farm $farmId');
  }
  
  /// Get cached finance transactions
  static List<FinanceTransaction>? getCachedFinanceTransactions(String farmId) {
    if (_financeBox == null) return null;
    
    final cached = _financeBox!.get('farm_$farmId');
    if (cached == null) return null;
    
    final data = cached['transactions'] as List?;
    if (data == null) return null;
    
    print('OfflineCacheService: Retrieved ${data.length} cached transactions for farm $farmId');
    return data.map((m) => _mapToTransaction(Map<String, dynamic>.from(m))).toList();
  }
  
  /// Check if cache is stale (older than 5 minutes)
  static bool isCacheStale(String farmId, {Duration maxAge = const Duration(minutes: 5)}) {
    if (_financeBox == null) return true;
    
    final cached = _financeBox!.get('farm_$farmId');
    if (cached == null) return true;
    
    final cachedAtStr = cached['cachedAt'] as String?;
    if (cachedAtStr == null) return true;
    
    final cachedAt = DateTime.tryParse(cachedAtStr);
    if (cachedAt == null) return true;
    
    return DateTime.now().difference(cachedAt) > maxAge;
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // LIVESTOCK CACHE
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const String _livestockBoxName = 'livestock_cache';
  static Box<Map>? _livestockBox;
  
  /// Initialize livestock box (called in init)
  static Future<void> _initLivestockBox() async {
    _livestockBox = await Hive.openBox<Map>(_livestockBoxName);
  }
  
  /// Cache livestock for a farm
  static Future<void> cacheLivestock(String farmId, List<Map<String, dynamic>> livestock) async {
    _livestockBox ??= await Hive.openBox<Map>(_livestockBoxName);
    await _livestockBox!.put('farm_$farmId', {'data': livestock, 'cachedAt': DateTime.now().toIso8601String()});
    print('OfflineCacheService: Cached ${livestock.length} livestock for farm $farmId');
  }
  
  /// Get cached livestock
  static List<Map<String, dynamic>>? getCachedLivestock(String farmId) {
    if (_livestockBox == null) return null;
    final cached = _livestockBox!.get('farm_$farmId');
    if (cached == null) return null;
    final data = cached['data'] as List?;
    if (data == null) return null;
    print('OfflineCacheService: Retrieved ${data.length} cached livestock for farm $farmId');
    return data.map((m) => Map<String, dynamic>.from(m)).toList();
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // OFFSPRING CACHE
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const String _offspringBoxName = 'offspring_cache';
  static Box<Map>? _offspringBox;
  
  /// Cache offspring for a farm
  static Future<void> cacheOffspring(String farmId, List<Map<String, dynamic>> offspring) async {
    _offspringBox ??= await Hive.openBox<Map>(_offspringBoxName);
    await _offspringBox!.put('farm_$farmId', {'data': offspring, 'cachedAt': DateTime.now().toIso8601String()});
    print('OfflineCacheService: Cached ${offspring.length} offspring for farm $farmId');
  }
  
  /// Get cached offspring
  static List<Map<String, dynamic>>? getCachedOffspring(String farmId) {
    if (_offspringBox == null) return null;
    final cached = _offspringBox!.get('farm_$farmId');
    if (cached == null) return null;
    final data = cached['data'] as List?;
    if (data == null) return null;
    print('OfflineCacheService: Retrieved ${data.length} cached offspring for farm $farmId');
    return data.map((m) => Map<String, dynamic>.from(m)).toList();
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // PENDING OPERATIONS QUEUE
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Add operation to pending queue (for offline writes)
  static Future<void> addPendingOperation({
    required String type, // 'create', 'update', 'delete'
    required String entity, // 'finance', 'livestock', etc
    required Map<String, dynamic> data,
  }) async {
    if (_pendingOpsBox == null) return;
    
    final opId = DateTime.now().millisecondsSinceEpoch.toString();
    await _pendingOpsBox!.put(opId, {
      'id': opId,
      'type': type,
      'entity': entity,
      'data': data,
      'createdAt': DateTime.now().toIso8601String(),
    });
    
    print('OfflineCacheService: Added pending $type operation for $entity');
  }
  
  /// Get all pending operations
  static List<Map<String, dynamic>> getPendingOperations() {
    if (_pendingOpsBox == null) return [];
    
    return _pendingOpsBox!.values
        .map((m) => Map<String, dynamic>.from(m))
        .toList()
      ..sort((a, b) => (a['createdAt'] as String).compareTo(b['createdAt'] as String));
  }
  
  /// Remove pending operation after successful sync
  static Future<void> removePendingOperation(String opId) async {
    await _pendingOpsBox?.delete(opId);
    print('OfflineCacheService: Removed pending operation $opId');
  }
  
  /// Get pending operations count
  static int get pendingCount => _pendingOpsBox?.length ?? 0;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════
  
  static Map<String, dynamic> _transactionToMap(FinanceTransaction tx) {
    return {
      'id': tx.id,
      'farm_id': tx.farmId,
      'type': tx.type.name,
      'category_id': tx.categoryId,
      'category_name': tx.categoryName,
      'amount': tx.amount,
      'transaction_date': tx.transactionDate.toIso8601String(),
      'description': tx.description,
      'reference_id': tx.referenceId,
      'reference_type': tx.referenceType,
      'created_at': tx.createdAt.toIso8601String(),
      'updated_at': tx.updatedAt?.toIso8601String(),
    };
  }
  
  static FinanceTransaction _mapToTransaction(Map<String, dynamic> m) {
    return FinanceTransaction(
      id: m['id'] as String,
      farmId: m['farm_id'] as String,
      type: m['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      categoryId: m['category_id'] as String,
      categoryName: m['category_name'] as String?,
      amount: (m['amount'] as num).toDouble(),
      transactionDate: DateTime.parse(m['transaction_date'] as String),
      description: m['description'] as String?,
      referenceId: m['reference_id'] as String?,
      referenceType: m['reference_type'] as String?,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: m['updated_at'] != null ? DateTime.parse(m['updated_at'] as String) : null,
    );
  }
  
  /// Clear all cache
  static Future<void> clearAll() async {
    await _financeBox?.clear();
    await _pendingOpsBox?.clear();
    await _metadataBox?.clear();
    print('OfflineCacheService: Cleared all cache');
  }
  
  /// Dispose resources
  static void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
  }
}

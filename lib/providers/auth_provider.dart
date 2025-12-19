/// Auth Provider
/// 
/// Riverpod provider untuk mengelola state autentikasi.
/// Mendengarkan perubahan auth state dari Supabase.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/supabase_service.dart';

/// Provider untuk stream auth state changes
/// 
/// Ini akan otomatis update ketika user login/logout
final authStateProvider = StreamProvider<User?>((ref) {
  return SupabaseService.authStateChanges.map((state) => state.session?.user);
});

/// Provider untuk current user (synchronous access)
final currentUserProvider = Provider<User?>((ref) {
  return SupabaseService.currentUser;
});

/// Provider untuk check apakah user sudah login
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull != null;
});

/// Notifier untuk handle auth actions (login, register, logout)
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    // Set initial state dari current session
    final user = SupabaseService.currentUser;
    state = AsyncValue.data(user);
  }

  /// Login dengan email dan password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await SupabaseService.signInWithEmail(
        email: email,
        password: password,
      );
      state = AsyncValue.data(response.user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Register user baru
  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await SupabaseService.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );
      state = AsyncValue.data(response.user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Logout
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await SupabaseService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider untuk AuthNotifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier();
});

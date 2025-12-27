/// Error Handler
/// 
/// Global error handling untuk user-friendly error messages.

library;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  /// Convert error ke pesan yang user-friendly
  static String getUserFriendlyMessage(dynamic error) {
    if (error == null) return 'Terjadi kesalahan tidak diketahui';

    final message = error.toString().toLowerCase();

    // Network errors
    if (message.contains('socketexception') ||
        message.contains('network') ||
        message.contains('connection')) {
      return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
    }

    // Timeout errors
    if (message.contains('timeout')) {
      return 'Koneksi timeout. Coba lagi nanti.';
    }

    // Supabase Auth errors
    if (error is AuthException) {
      return _handleAuthError(error);
    }

    // Supabase Postgrest errors
    if (error is PostgrestException) {
      return _handlePostgrestError(error);
    }

    // Generic errors
    if (message.contains('not found') || message.contains('404')) {
      return 'Data tidak ditemukan';
    }

    if (message.contains('unauthorized') || message.contains('401')) {
      return 'Sesi telah berakhir. Silakan login kembali.';
    }

    if (message.contains('forbidden') || message.contains('403')) {
      return 'Anda tidak memiliki akses ke data ini';
    }

    if (message.contains('server') || message.contains('500')) {
      return 'Terjadi kesalahan di server. Coba lagi nanti.';
    }

    // Default: show original message but shortened
    final errorMessage = error.toString();
    if (errorMessage.length > 100) {
      return '${errorMessage.substring(0, 100)}...';
    }
    return errorMessage;
  }

  /// Handle Supabase Auth errors
  static String _handleAuthError(AuthException error) {
    switch (error.message.toLowerCase()) {
      case 'invalid login credentials':
        return 'Email atau password salah';
      case 'email not confirmed':
        return 'Email belum dikonfirmasi. Cek inbox Anda.';
      case 'user already registered':
        return 'Email sudah terdaftar';
      case 'password should be at least 6 characters':
        return 'Password minimal 6 karakter';
      default:
        return error.message;
    }
  }

  /// Handle Supabase Postgrest errors
  static String _handlePostgrestError(PostgrestException error) {
    // Check for unique constraint violation
    if (error.code == '23505') {
      return 'Data sudah ada. Gunakan nama/kode yang berbeda.';
    }

    // Check for foreign key violation
    if (error.code == '23503') {
      return 'Data tidak dapat dihapus karena masih digunakan.';
    }

    // Check for not null violation
    if (error.code == '23502') {
      return 'Data tidak lengkap. Pastikan semua field terisi.';
    }

    // RLS policy violation
    if (error.message.contains('policy')) {
      return 'Anda tidak memiliki akses ke data ini.';
    }

    return error.message;
  }

  /// Show error snackbar
  static void showErrorSnackbar(BuildContext context, dynamic error, {VoidCallback? onRetry}) {
    final message = getUserFriendlyMessage(error);
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 4),
        action: onRetry != null
            ? SnackBarAction(
                label: 'Coba Lagi',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Build error widget with retry button
  static Widget buildErrorWidget({
    required dynamic error,
    required VoidCallback onRetry,
    IconData? icon,
    double iconSize = 48,
  }) {
    final message = getUserFriendlyMessage(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: iconSize,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state widget
  static Widget buildEmptyState({
    required String title,
    String? subtitle,
    IconData? icon,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action,
            ],
          ],
        ),
      ),
    );
  }
}

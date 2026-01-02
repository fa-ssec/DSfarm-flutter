/// DSFarm Design System - Colors
/// 
/// Gunakan warna dari sini agar konsisten di seluruh aplikasi.
/// Contoh: color: AppColors.income

import 'package:flutter/material.dart';

class AppColors {
  // ═══════════════════════════════════════════════════════════════
  // BRAND COLORS
  // ═══════════════════════════════════════════════════════════════
  
  /// Warna utama brand - hijau tua
  static const primary = Color(0xFF059669);
  
  /// Warna sekunder - biru
  static const secondary = Color(0xFF3B82F6);
  
  /// Warna aksen premium - emas
  static const gold = Color(0xFFF59E0B);
  static const goldLight = Color(0xFFFEF3C7);
  static const goldDark = Color(0xFFD97706);

  // ═══════════════════════════════════════════════════════════════
  // SEMANTIC COLORS (Warna dengan arti)
  // ═══════════════════════════════════════════════════════════════
  
  /// Pemasukan/Income - hijau
  static const income = Color(0xFF059669);
  static const incomeLight = Color(0xFFD1FAE5);
  
  /// Pengeluaran/Expense - merah
  static const expense = Color(0xFFDC2626);
  static const expenseLight = Color(0xFFFEE2E2);
  
  /// Sukses - hijau
  static const success = Color(0xFF10B981);
  static const successLight = Color(0xFFD1FAE5);
  
  /// Warning - kuning
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF3C7);
  
  /// Error - merah
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEE2E2);
  
  /// Info - biru
  static const info = Color(0xFF3B82F6);
  static const infoLight = Color(0xFFDBEAFE);

  // ═══════════════════════════════════════════════════════════════
  // NEUTRAL COLORS (Abu-abu)
  // ═══════════════════════════════════════════════════════════════
  
  static const neutral50 = Color(0xFFFAFAFA);
  static const neutral100 = Color(0xFFF4F4F5);
  static const neutral200 = Color(0xFFE4E4E7);
  static const neutral300 = Color(0xFFD4D4D8);
  static const neutral400 = Color(0xFFA1A1AA);
  static const neutral500 = Color(0xFF71717A);
  static const neutral600 = Color(0xFF52525B);
  static const neutral700 = Color(0xFF3F3F46);
  static const neutral800 = Color(0xFF27272A);
  static const neutral900 = Color(0xFF18181B);

  // ═══════════════════════════════════════════════════════════════
  // GRADIENTS
  // ═══════════════════════════════════════════════════════════════
  
  /// Gradient untuk card premium (Laba Bersih)
  static const premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
  );
  
  /// Gradient premium untuk dark mode
  static const premiumGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF291F00), Color(0xFF1A1400)],
  );
  
  /// Gradient untuk chart income
  static LinearGradient incomeChartGradient = LinearGradient(
    colors: [income.withAlpha(80), income.withAlpha(10)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

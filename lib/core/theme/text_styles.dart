/// DSFarm Design System - Text Styles
/// 
/// Gunakan style dari sini agar font konsisten.
/// Contoh: style: AppTextStyles.heading1

import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  // ═══════════════════════════════════════════════════════════════
  // HEADINGS (Judul)
  // ═══════════════════════════════════════════════════════════════
  
  /// Judul paling besar - untuk nama halaman
  static const heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.2,
  );
  
  /// Judul sedang - untuk section
  static const heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  
  /// Judul kecil - untuk card title
  static const heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ═══════════════════════════════════════════════════════════════
  // BODY TEXT (Teks biasa)
  // ═══════════════════════════════════════════════════════════════
  
  /// Teks body besar
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  /// Teks body normal
  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  /// Teks body kecil
  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // ═══════════════════════════════════════════════════════════════
  // LABELS (Label dan Caption)
  // ═══════════════════════════════════════════════════════════════
  
  /// Label untuk form/input
  static const label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  
  /// Caption kecil
  static const caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );
  
  /// Label uppercase untuk card header
  static const labelUppercase = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    height: 1.2,
  );

  // ═══════════════════════════════════════════════════════════════
  // SPECIAL STYLES
  // ═══════════════════════════════════════════════════════════════
  
  /// Angka besar (untuk summary cards)
  static const numberLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    height: 1.1,
  );
  
  /// Kode transaksi (monospace)
  static const transactionCode = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontFamily: 'monospace',
    letterSpacing: 0.5,
  );
  
  /// Amount/Nominal uang
  static const amount = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  
  /// Percentage badge
  static const percentage = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
  );
}

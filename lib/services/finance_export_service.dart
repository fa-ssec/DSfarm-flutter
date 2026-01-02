/// Finance Export Service
/// 
/// Mengexport transaksi keuangan ke PDF atau Excel

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../models/finance.dart';

class FinanceExportService {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  
  static final _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
  
  // ═══════════════════════════════════════════════════════════════
  // EXPORT TO PDF
  // ═══════════════════════════════════════════════════════════════
  
  /// Generate and share PDF report
  static Future<void> exportToPdf({
    required List<FinanceTransaction> transactions,
    required String farmName,
  }) async {
    final pdf = pw.Document();
    
    // Calculate totals
    final income = transactions
        .where((t) => t.isIncome)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final expense = transactions
        .where((t) => !t.isIncome)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final profit = income - expense;
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Laporan Keuangan', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Text(farmName, style: const pw.TextStyle(fontSize: 14)),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Tanggal: ${_dateFormat.format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 20),
          
          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Total Pemasukan', income, PdfColors.green),
                _buildSummaryItem('Total Pengeluaran', expense, PdfColors.red),
                _buildSummaryItem('Laba Bersih', profit, profit >= 0 ? PdfColors.green : PdfColors.red),
              ],
            ),
          ),
          pw.SizedBox(height: 30),
          
          // Transactions table
          pw.Text('Daftar Transaksi', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellPadding: const pw.EdgeInsets.all(8),
            headers: ['Kode', 'Tanggal', 'Kategori', 'Jenis', 'Nominal'],
            data: transactions.map((tx) {
              final prefix = tx.isIncome ? 'IN' : 'EX';
              final ym = '${tx.transactionDate.year.toString().substring(2)}${tx.transactionDate.month.toString().padLeft(2, '0')}';
              final code = '$prefix-$ym-${tx.id.substring(0, 4).toUpperCase()}';
              return [
                code,
                _dateFormat.format(tx.transactionDate),
                tx.categoryName ?? '-',
                tx.isIncome ? 'Pemasukan' : 'Pengeluaran',
                '${tx.isIncome ? '+' : '-'}${_currencyFormat.format(tx.amount)}',
              ];
            }).toList(),
          ),
        ],
      ),
    );
    
    // Print/Share PDF
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'laporan_keuangan_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }
  
  static pw.Widget _buildSummaryItem(String label, double value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 5),
        pw.Text(
          _currencyFormat.format(value),
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: color),
        ),
      ],
    );
  }
  
  // ═══════════════════════════════════════════════════════════════
  // EXPORT TO EXCEL
  // ═══════════════════════════════════════════════════════════════
  
  /// Generate and share Excel file
  static Future<void> exportToExcel({
    required List<FinanceTransaction> transactions,
    required String farmName,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Transaksi'];
    
    // Calculate totals
    final income = transactions
        .where((t) => t.isIncome)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final expense = transactions
        .where((t) => !t.isIncome)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final profit = income - expense;
    
    // Headers - Farm info
    sheet.appendRow([TextCellValue('Laporan Keuangan - $farmName')]);
    sheet.appendRow([TextCellValue('Tanggal Export: ${_dateFormat.format(DateTime.now())}')]);
    sheet.appendRow([TextCellValue('')]);
    
    // Summary
    sheet.appendRow([TextCellValue('RINGKASAN')]);
    sheet.appendRow([TextCellValue('Total Pemasukan'), TextCellValue(_currencyFormat.format(income))]);
    sheet.appendRow([TextCellValue('Total Pengeluaran'), TextCellValue(_currencyFormat.format(expense))]);
    sheet.appendRow([TextCellValue('Laba Bersih'), TextCellValue(_currencyFormat.format(profit))]);
    sheet.appendRow([TextCellValue('')]);
    
    // Transaction headers
    sheet.appendRow([
      TextCellValue('Kode'),
      TextCellValue('Tanggal'),
      TextCellValue('Kategori'),
      TextCellValue('Jenis'),
      TextCellValue('Nominal'),
      TextCellValue('Keterangan'),
    ]);
    
    // Transaction data
    for (final tx in transactions) {
      final prefix = tx.isIncome ? 'IN' : 'EX';
      final ym = '${tx.transactionDate.year.toString().substring(2)}${tx.transactionDate.month.toString().padLeft(2, '0')}';
      final code = '$prefix-$ym-${tx.id.substring(0, 4).toUpperCase()}';
      
      sheet.appendRow([
        TextCellValue(code),
        TextCellValue(_dateFormat.format(tx.transactionDate)),
        TextCellValue(tx.categoryName ?? '-'),
        TextCellValue(tx.isIncome ? 'Pemasukan' : 'Pengeluaran'),
        DoubleCellValue(tx.isIncome ? tx.amount : -tx.amount),
        TextCellValue(tx.description ?? ''),
      ]);
    }
    
    // Remove default sheet
    excel.delete('Sheet1');
    
    // Save and share
    final bytes = excel.save();
    if (bytes != null) {
      final dir = await getTemporaryDirectory();
      final filename = 'laporan_keuangan_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Laporan Keuangan $farmName',
      );
    }
  }
}

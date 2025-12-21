/// PDF Generator Service
/// 
/// Generate PDF reports for DSFarm.

library;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

import '../../models/offspring.dart';
import '../../models/finance.dart';

class PdfGenerator {
  static final _currencyFormat = NumberFormat('#,###', 'id');
  static final _dateFormat = DateFormat('dd MMM yyyy', 'id');

  /// Generate Sales Report PDF
  static pw.Document generateSalesReport({
    required String farmName,
    required List<Offspring> soldOffsprings,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final pdf = pw.Document();

    // Calculate totals
    double totalRevenue = soldOffsprings.fold(0.0, (sum, o) => sum + (o.salePrice ?? 0));
    int totalCount = soldOffsprings.length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(farmName, 'Laporan Penjualan'),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          pw.SizedBox(height: 20),
          
          // Date range
          pw.Text(
            'Periode: ${_dateFormat.format(startDate)} - ${_dateFormat.format(endDate)}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 16),

          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.green50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Total Terjual'),
                    pw.Text('$totalCount ekor', 
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Total Pendapatan'),
                    pw.Text('Rp ${_currencyFormat.format(totalRevenue)}', 
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Table
          pw.Text('Detail Penjualan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _tableCell('No', isHeader: true),
                  _tableCell('Kode', isHeader: true),
                  _tableCell('Gender', isHeader: true),
                  _tableCell('Tgl Jual', isHeader: true),
                  _tableCell('Harga', isHeader: true),
                ],
              ),
              // Data rows
              ...soldOffsprings.asMap().entries.map((entry) {
                final i = entry.key;
                final o = entry.value;
                return pw.TableRow(
                  children: [
                    _tableCell('${i + 1}'),
                    _tableCell(o.code),
                    _tableCell(o.gender.value == 'male' ? 'Jantan' : 'Betina'),
                    _tableCell(o.saleDate != null ? _dateFormat.format(o.saleDate!) : '-'),
                    _tableCell('Rp ${_currencyFormat.format(o.salePrice ?? 0)}'),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );

    return pdf;
  }

  /// Generate Finance Summary PDF
  static pw.Document generateFinanceSummary({
    required String farmName,
    required List<FinanceTransaction> transactions,
    required Map<String, dynamic> summary,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final pdf = pw.Document();

    final income = (summary['income'] as num?)?.toDouble() ?? 0;
    final expense = (summary['expense'] as num?)?.toDouble() ?? 0;
    final balance = income - expense;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(farmName, 'Laporan Keuangan'),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          pw.SizedBox(height: 20),
          
          // Date range
          pw.Text(
            'Periode: ${_dateFormat.format(startDate)} - ${_dateFormat.format(endDate)}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 16),

          // Summary boxes
          pw.Row(
            children: [
              pw.Expanded(child: _summaryBox('Pemasukan', income, PdfColors.green)),
              pw.SizedBox(width: 12),
              pw.Expanded(child: _summaryBox('Pengeluaran', expense, PdfColors.red)),
              pw.SizedBox(width: 12),
              pw.Expanded(child: _summaryBox('Saldo', balance, PdfColors.blue)),
            ],
          ),
          pw.SizedBox(height: 24),

          // Recent transactions
          pw.Text('Riwayat Transaksi', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _tableCell('Tanggal', isHeader: true),
                  _tableCell('Kategori', isHeader: true),
                  _tableCell('Keterangan', isHeader: true),
                  _tableCell('Jumlah', isHeader: true),
                ],
              ),
              ...transactions.take(20).map((t) {
                final isIncome = t.type == TransactionType.income;
                return pw.TableRow(
                  children: [
                    _tableCell(_dateFormat.format(t.transactionDate)),
                    _tableCell(t.categoryName ?? '-'),
                    _tableCell(t.description ?? '-'),
                    _tableCell(
                      '${isIncome ? '+' : '-'} Rp ${_currencyFormat.format(t.amount)}',
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );

    return pdf;
  }

  // Helper widgets
  static pw.Widget _buildHeader(String farmName, String reportTitle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('🐰 $farmName', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Text(reportTitle, style: pw.TextStyle(fontSize: 16, color: PdfColors.grey600)),
          ],
        ),
        pw.Divider(thickness: 2),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 16),
      child: pw.Text(
        'Halaman ${context.pageNumber}/${context.pagesCount} | Generated by DSFarm',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
      ),
    );
  }

  static pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      alignment: pw.Alignment.centerLeft,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: 10,
        ),
      ),
    );
  }

  static pw.Widget _summaryBox(String label, double amount, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: color.shade(0.9),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: color),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 4),
          pw.Text(
            'Rp ${_currencyFormat.format(amount)}',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

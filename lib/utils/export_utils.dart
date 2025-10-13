// lib/utils/export_utils.dart
import 'dart:typed_data';
import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html; // untuk Flutter Web
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pdf;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;

import '../models/expense.dart';
import '../services/expense_service.dart';

class ExportPdf {
  /// Export SEMUA expense dari service → PDF
  static Future<void> exportAll({String filename = 'expenses.pdf'}) async {
    final list = ExpenseService.instance.expenses;
    await exportFromList(list, filename: filename);
  }

  /// Export LIST tertentu (mis. hasil filter) → PDF
  static Future<void> exportFromList(
    List<Expense> list, {
    String filename = 'expenses.pdf',
  }) async {
    final bytes = await _buildPdfBytes(list);
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: filename,
    );
  }

  // =================== Builder PDF ===================
  static Future<Uint8List> _buildPdfBytes(List<Expense> list) async {
    final doc = pw.Document();
    final total = list.fold<double>(0.0, (s, e) => s + e.amount);

    // ringkasan per kategori
    final byCategory = <String, double>{};
    for (final e in list) {
      byCategory[e.category] = (byCategory[e.category] ?? 0.0) + e.amount;
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: pdf.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        footer: (ctx) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${ctx.pageNumber} / ${ctx.pagesCount}',
            style: const pw.TextStyle(
              fontSize: 10,
              color: pdf.PdfColors.grey700,
            ),
          ),
        ),
        build: (ctx) => [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Expense Report',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: pdf.PdfColors.blue800,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    _formatDateTime(DateTime.now()),
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: pdf.PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              pw.Text(
                'Total: ${_rp(total)}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: pdf.PdfColors.blue700,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),

          // Ringkasan kategori
          if (byCategory.isNotEmpty) ...[
            pw.Text(
              'Summary by Category',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            pw.Wrap(
              spacing: 6,
              runSpacing: 6,
              children: byCategory.entries
                  .map((e) => _chip('${e.key}: ${_rp(e.value)}'))
                  .toList(),
            ),
            pw.SizedBox(height: 12),
          ],

          // Tabel transaksi
          pw.Text(
            'Transactions',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          _expenseTable(list),
        ],
      ),
    );

    return doc.save();
  }

  // =================== Widgets bantu PDF ===================
  static pw.Widget _chip(String text) => pw.Container(
        decoration: pw.BoxDecoration(
          color: pdf.PdfColors.white,
          borderRadius: pw.BorderRadius.circular(12),
          border: pw.Border.all(color: pdf.PdfColors.blue300, width: 0.8),
        ),
        padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
      );

  static pw.Widget _expenseTable(List<Expense> list) {
    final headers = <String>['Title', 'Amount', 'Category', 'Date', 'Description'];

    final data = list.map((e) {
      return <String>[
        e.title,
        _rp(e.amount),
        e.category,
        _formatDate(e.date),
        (e.description).replaceAll('\n', ' '),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerDecoration:
          const pw.BoxDecoration(color: pdf.PdfColor.fromInt(0xFFEFF5FF)),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: pdf.PdfColors.blue900,
      ),
      headerAlignment: pw.Alignment.centerLeft,
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignment: pw.Alignment.centerLeft,
      border: pw.TableBorder.all(color: pdf.PdfColors.grey300, width: 0.4),
      headerHeight: 24,
      cellHeight: 22,
      columnWidths: const {
        0: pw.FlexColumnWidth(2.3),
        1: pw.FlexColumnWidth(1.2),
        2: pw.FlexColumnWidth(1.3),
        3: pw.FlexColumnWidth(1.1),
        4: pw.FlexColumnWidth(2.5),
      },
      rowDecoration: const pw.BoxDecoration(color: pdf.PdfColors.white),
      oddRowDecoration:
          const pw.BoxDecoration(color: pdf.PdfColor.fromInt(0xFFF9FBFF)),
    );
  }

  // =================== Formatter ===================
  static String _rp(double v) => 'Rp ${v.toStringAsFixed(0)}';
  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  static String _formatDateTime(DateTime d) =>
      '${_formatDate(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

// ====================================================================
// ====================== FITUR TAMBAHAN: EXPORT CSV ===================
// ====================================================================

class ExportCsv {
  /// Export SEMUA data expense → CSV file
  static Future<void> exportAll({String filename = 'expenses.csv'}) async {
    final list = ExpenseService.instance.expenses;
    await exportFromList(list, filename: filename);
  }

  /// Export dari LIST tertentu → CSV file
  static Future<void> exportFromList(
    List<Expense> list, {
    String filename = 'expenses.csv',
  }) async {
    final csvString = _buildCsv(list);
    final csvBytes = utf8.encode(csvString);

    if (kIsWeb) {
      // 🧭 WEB: langsung download ke browser
      final blob = html.Blob([csvBytes], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // 📱 ANDROID/iOS/DESKTOP: simpan ke dokumen app
      final dir = await getApplicationDocumentsDirectory();
      final filePath = path.join(dir.path, filename);
      final file = io.File(filePath);
      await file.writeAsBytes(csvBytes);
      print('✅ CSV saved: $filePath');
    }
  }

  /// Export & langsung SHARE CSV ke aplikasi lain (mobile only)
  static Future<void> shareAll({String filename = 'expenses.csv'}) async {
    final list = ExpenseService.instance.expenses;
    final csvString = _buildCsv(list);
    final dir = await getApplicationDocumentsDirectory();
    final filePath = path.join(dir.path, filename);
    final file = io.File(filePath);
    await file.writeAsString(csvString);
    await Share.shareXFiles([XFile(file.path)], text: 'Here is my exported expense data.');
  }

  // =================== Builder CSV ===================
  static String _buildCsv(List<Expense> list) {
    final buffer = StringBuffer();
    final headers = ['Title', 'Amount', 'Category', 'Date', 'Description'];
    buffer.writeln(headers.join(','));

    for (final e in list) {
      final row = [
        _escapeCsv(e.title),
        e.amount.toStringAsFixed(0),
        _escapeCsv(e.category),
        _formatDate(e.date),
        _escapeCsv(e.description),
      ];
      buffer.writeln(row.join(','));
    }

    return utf8.decode(utf8.encode(buffer.toString()));
  }

  // =================== Helper ===================
  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      value = value.replaceAll('"', '""');
      return '"$value"';
    }
    return value;
  }

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';

import 'package:excel/excel.dart' as xl;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:leadmanagementsystem/models/visitor_detail_model.dart';

/// Builds PDF and Excel reports of visitor details (card images excluded).
class VisitorReportService {
  static const _reportTitle = 'Visitor Details Report';
  static const _brand = 'RGC RMS';

  static const _headers = [
    '#',
    'Company',
    'Person Name',
    'Designation',
    'Contact No(s).',
    'Email',
    'Office Address',
    'Comments',
    'Added On',
  ];

  // Comments longer than this are moved to a "Detailed Notes" section in the
  // PDF, because a single table row can't be split across pages.
  static const _maxInlineComment = 600;

  static final _dateFmt = DateFormat('dd MMM yyyy, hh:mm a');
  static final _fileStamp = DateFormat('yyyyMMdd_HHmm');

  static String _dash(String v) => v.trim().isEmpty ? '-' : v.trim();
  static String _date(DateTime? d) => d == null ? '-' : _dateFmt.format(d);

  static List<String> _row(VisitorDetail v, int index) => [
        '$index',
        _dash(v.companyName),
        _dash(v.personName),
        _dash(v.designation),
        v.contacts.isEmpty ? '-' : v.contacts.join('\n'),
        _dash(v.email),
        _dash(v.officeAddress),
        _dash(v.comments),
        _date(v.createdAt),
      ];

  static Future<File> _save(List<int> bytes, String ext) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/Visitor_Report_${_fileStamp.format(DateTime.now())}.$ext');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  // ═════════════════════════════════════════════
  // PDF
  // ═════════════════════════════════════════════

  static const _green = PdfColor.fromInt(0xFF00A569);
  static const _greenDark = PdfColor.fromInt(0xFF007A4D);
  static const _greenTint = PdfColor.fromInt(0xFFEFFAF5);
  static const _ink = PdfColor.fromInt(0xFF111827);
  static const _muted = PdfColor.fromInt(0xFF6B7280);
  static const _line = PdfColor.fromInt(0xFFE5E7EB);
  static const _zebra = PdfColor.fromInt(0xFFF9FAFB);

  /// Generates the PDF and opens it. [filterNote] describes an active search.
  static Future<void> exportPdf(List<VisitorDetail> visitors,
      {String? filterNote}) async {
    final bytes = await buildPdf(visitors, filterNote: filterNote);
    final file = await _save(bytes, 'pdf');
    await OpenFile.open(file.path);
  }

  static Future<List<int>> buildPdf(List<VisitorDetail> visitors,
      {String? filterNote}) async {
    final theme = pw.ThemeData.withFont(
      base: pw.Font.ttf(
          await rootBundle.load('assets/fonts/Lato/Lato-Regular.ttf')),
      bold:
          pw.Font.ttf(await rootBundle.load('assets/fonts/Lato/Lato-Bold.ttf')),
      italic: pw.Font.ttf(
          await rootBundle.load('assets/fonts/Lato/Lato-Italic.ttf')),
    );
    final generated = _dateFmt.format(DateTime.now());

    // Long comments become footnotes so rows always fit on a page.
    final notes = <int, String>{};
    final rows = <List<String>>[];
    for (var i = 0; i < visitors.length; i++) {
      final r = _row(visitors[i], i + 1);
      if (visitors[i].comments.trim().length > _maxInlineComment) {
        notes[i + 1] = visitors[i].comments.trim();
        r[7] = 'See Detailed Notes (#${i + 1})';
      }
      rows.add(r);
    }

    final doc = pw.Document(
      theme: theme,
      title: _reportTitle,
      author: _brand,
      creator: _brand,
    );

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.fromLTRB(28, 24, 28, 20),
      header: (ctx) => _pdfHeader(ctx, generated),
      footer: _pdfFooter,
      build: (ctx) => [
        _summary(visitors, filterNote),
        pw.SizedBox(height: 14),
        if (visitors.isEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Center(
                child: pw.Text('No visitor records to display.',
                    style: const pw.TextStyle(color: _muted))),
          )
        else
          _table(rows),
        if (notes.isNotEmpty) ..._notesSection(notes, visitors),
      ],
    ));

    return doc.save();
  }

  static pw.Widget _pdfHeader(pw.Context ctx, String generated) {
    if (ctx.pageNumber == 1) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 14),
        padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: const pw.BoxDecoration(
          gradient: pw.LinearGradient(colors: [_greenDark, _green]),
          borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(_brand.toUpperCase(),
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 9,
                        letterSpacing: 2,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 3),
                pw.Text(_reportTitle,
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Generated on',
                    style: const pw.TextStyle(
                        color: PdfColors.white, fontSize: 8)),
                pw.SizedBox(height: 2),
                pw.Text(generated,
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ],
        ),
      );
    }
    // Compact running header on continuation pages.
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.only(bottom: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _green, width: 1.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('$_brand  |  $_reportTitle',
              style: pw.TextStyle(
                  color: _greenDark,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold)),
          pw.Text(generated,
              style: const pw.TextStyle(color: _muted, fontSize: 8)),
        ],
      ),
    );
  }

  static pw.Widget _pdfFooter(pw.Context ctx) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.only(top: 5),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _line, width: 0.8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Confidential - for internal use only',
              style: pw.TextStyle(
                  color: _muted,
                  fontSize: 7.5,
                  fontStyle: pw.FontStyle.italic)),
          pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: const pw.TextStyle(color: _muted, fontSize: 7.5)),
        ],
      ),
    );
  }

  static pw.Widget _summary(List<VisitorDetail> v, String? filterNote) {
    final companies = v
        .map((e) => e.companyName.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet()
        .length;
    final withPhone = v.where((e) => e.contacts.isNotEmpty).length;
    final withEmail = v.where((e) => e.email.trim().isNotEmpty).length;

    pw.Widget tile(String label, int value, {bool last = false}) => pw.Expanded(
          child: pw.Container(
            margin: pw.EdgeInsets.only(right: last ? 0 : 8),
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: pw.BoxDecoration(
              color: _greenTint,
              border: pw.Border.all(color: _line, width: 0.8),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('$value',
                    style: pw.TextStyle(
                        fontSize: 18,
                        color: _greenDark,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 2),
                pw.Text(label,
                    style: const pw.TextStyle(fontSize: 8.5, color: _muted)),
              ],
            ),
          ),
        );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(children: [
          tile('Total Visitors', v.length),
          tile('Unique Companies', companies),
          tile('With Contact Number', withPhone),
          tile('With Email Address', withEmail, last: true),
        ]),
        if (filterNote != null && filterNote.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Text('Filter applied: $filterNote',
              style: pw.TextStyle(
                  fontSize: 8.5,
                  color: _muted,
                  fontStyle: pw.FontStyle.italic)),
        ],
      ],
    );
  }

  static pw.Widget _table(List<List<String>> rows) {
    return pw.TableHelper.fromTextArray(
      headers: _headers,
      data: rows,
      headerCount: 1,
      headerStyle: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: _green),
      headerAlignment: pw.Alignment.centerLeft,
      headerAlignments: {0: pw.Alignment.center},
      headerPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 7),
      cellStyle: const pw.TextStyle(fontSize: 8, color: _ink, lineSpacing: 1.5),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      cellAlignment: pw.Alignment.topLeft,
      cellAlignments: {0: pw.Alignment.topCenter},
      rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
      oddRowDecoration: const pw.BoxDecoration(color: _zebra),
      border: const pw.TableBorder(
        horizontalInside: pw.BorderSide(color: _line, width: 0.6),
        bottom: pw.BorderSide(color: _line, width: 0.6),
        left: pw.BorderSide(color: _line, width: 0.6),
        right: pw.BorderSide(color: _line, width: 0.6),
      ),
      columnWidths: const {
        0: pw.FixedColumnWidth(24),
        1: pw.FlexColumnWidth(1.5),
        2: pw.FlexColumnWidth(1.3),
        3: pw.FlexColumnWidth(1.1),
        4: pw.FlexColumnWidth(1.2),
        5: pw.FlexColumnWidth(1.6),
        6: pw.FlexColumnWidth(1.8),
        7: pw.FlexColumnWidth(2.1),
        8: pw.FlexColumnWidth(1.05),
      },
    );
  }

  static List<pw.Widget> _notesSection(
      Map<int, String> notes, List<VisitorDetail> visitors) {
    return [
      pw.SizedBox(height: 18),
      pw.Text('Detailed Notes',
          style: pw.TextStyle(
              fontSize: 13, color: _greenDark, fontWeight: pw.FontWeight.bold)),
      pw.Container(
          margin: const pw.EdgeInsets.only(top: 4, bottom: 8),
          height: 1.2,
          width: 60,
          color: _green),
      for (final e in notes.entries) ...[
        pw.Text('#${e.key}  ${visitors[e.key - 1].title}',
            style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 3),
        // Paragraph (not wrapped in a container) so it can span pages.
        pw.Paragraph(
            text: e.value,
            style: const pw.TextStyle(fontSize: 8.5, lineSpacing: 2),
            textAlign: pw.TextAlign.left,
            margin: const pw.EdgeInsets.only(bottom: 10)),
      ],
    ];
  }

  // ═════════════════════════════════════════════
  // Excel
  // ═════════════════════════════════════════════

  /// Generates the .xlsx file and opens it.
  static Future<void> exportExcel(List<VisitorDetail> visitors,
      {String? filterNote}) async {
    final file =
        await _save(buildExcel(visitors, filterNote: filterNote), 'xlsx');
    await OpenFile.open(file.path);
  }

  static List<int> buildExcel(List<VisitorDetail> visitors,
      {String? filterNote}) {
    const sheetName = 'Visitors';
    final excel = xl.Excel.createExcel();
    excel.rename(excel.getDefaultSheet() ?? 'Sheet1', sheetName);
    final sheet = excel[sheetName];
    final lastCol = _headers.length - 1;

    final green = xl.ExcelColor.fromHexString('#00A569');
    final greenDark = xl.ExcelColor.fromHexString('#007A4D');
    final zebra = xl.ExcelColor.fromHexString('#F1FBF6');
    final borderColor = xl.ExcelColor.fromHexString('#D1D5DB');
    final muted = xl.ExcelColor.fromHexString('#6B7280');
    final thin = xl.Border(
        borderStyle: xl.BorderStyle.Thin, borderColorHex: borderColor);

    xl.CellIndex at(int col, int row) =>
        xl.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row);

    void bannerRow(int row, String text, xl.CellStyle style, double height) {
      sheet.merge(at(0, row), at(lastCol, row));
      sheet.updateCell(at(0, row), xl.TextCellValue(text), cellStyle: style);
      sheet.setRowHeight(row, height);
    }

    // Title + meta
    bannerRow(
      0,
      '$_brand  -  $_reportTitle',
      xl.CellStyle(
        bold: true,
        fontSize: 16,
        fontColorHex: xl.ExcelColor.white,
        backgroundColorHex: greenDark,
        horizontalAlign: xl.HorizontalAlign.Center,
        verticalAlign: xl.VerticalAlign.Center,
      ),
      32,
    );
    final meta = StringBuffer(
        'Generated on ${_dateFmt.format(DateTime.now())}   |   Total visitors: ${visitors.length}');
    if (filterNote != null && filterNote.isNotEmpty) {
      meta.write('   |   Filter: $filterNote');
    }
    bannerRow(
      1,
      meta.toString(),
      xl.CellStyle(
        italic: true,
        fontSize: 10,
        fontColorHex: muted,
        horizontalAlign: xl.HorizontalAlign.Center,
        verticalAlign: xl.VerticalAlign.Center,
      ),
      20,
    );

    // Header row
    const headerRow = 3;
    final headerStyle = xl.CellStyle(
      bold: true,
      fontSize: 11,
      fontColorHex: xl.ExcelColor.white,
      backgroundColorHex: green,
      horizontalAlign: xl.HorizontalAlign.Center,
      verticalAlign: xl.VerticalAlign.Center,
      textWrapping: xl.TextWrapping.WrapText,
      leftBorder: thin,
      rightBorder: thin,
      topBorder: thin,
      bottomBorder: thin,
    );
    for (var c = 0; c <= lastCol; c++) {
      sheet.updateCell(at(c, headerRow), xl.TextCellValue(_headers[c]),
          cellStyle: headerStyle);
    }
    sheet.setRowHeight(headerRow, 26);

    // Data rows (zebra striped, wrapped, top aligned)
    xl.CellStyle dataStyle(bool odd, {bool center = false}) => xl.CellStyle(
          fontSize: 10,
          backgroundColorHex: odd ? zebra : xl.ExcelColor.white,
          verticalAlign: xl.VerticalAlign.Top,
          horizontalAlign:
              center ? xl.HorizontalAlign.Center : xl.HorizontalAlign.Left,
          textWrapping: xl.TextWrapping.WrapText,
          leftBorder: thin,
          rightBorder: thin,
          topBorder: thin,
          bottomBorder: thin,
        );
    final even = dataStyle(false), odd = dataStyle(true);
    final evenC = dataStyle(false, center: true),
        oddC = dataStyle(true, center: true);

    for (var i = 0; i < visitors.length; i++) {
      final r = headerRow + 1 + i;
      final values = _row(visitors[i], i + 1);
      final isOdd = i.isOdd;
      sheet.updateCell(at(0, r), xl.IntCellValue(i + 1),
          cellStyle: isOdd ? oddC : evenC);
      for (var c = 1; c <= lastCol; c++) {
        sheet.updateCell(at(c, r), xl.TextCellValue(values[c]),
            cellStyle: isOdd ? odd : even);
      }
    }

    const widths = [6.0, 28.0, 24.0, 22.0, 20.0, 30.0, 38.0, 50.0, 20.0];
    for (var c = 0; c < widths.length; c++) {
      sheet.setColumnWidth(c, widths[c]);
    }

    final bytes = excel.encode();
    if (bytes == null) throw Exception('Failed to encode Excel file');
    return _fixSheetDimensions(bytes);
  }

  /// The `excel` package always writes `<dimension ref="A1"/>`. Desktop Excel
  /// ignores it, but many mobile viewers trust it and show only cell A1, so
  /// the sheet looks empty. Rewrite it to the real used range.
  static List<int> _fixSheetDimensions(List<int> xlsx) {
    final src = ZipDecoder().decodeBytes(xlsx);
    final out = Archive();
    final cellRef = RegExp(r'<c r="([A-Z]+)(\d+)"');
    final dimension = RegExp(r'<dimension ref="[^"]*"\s*/>');

    int colNum(String letters) =>
        letters.codeUnits.fold(0, (n, u) => n * 26 + (u - 64));

    for (final f in src.files) {
      if (!f.isFile) continue;
      List<int> data = f.content as List<int>;
      if (f.name.startsWith('xl/worksheets/') && f.name.endsWith('.xml')) {
        final xml = utf8.decode(data);
        String maxCol = 'A';
        var maxRow = 1;
        for (final m in cellRef.allMatches(xml)) {
          final col = m.group(1)!;
          final row = int.parse(m.group(2)!);
          if (colNum(col) > colNum(maxCol)) maxCol = col;
          if (row > maxRow) maxRow = row;
        }
        data = utf8.encode(
            xml.replaceFirst(dimension, '<dimension ref="A1:$maxCol$maxRow"/>'));
      }
      out.addFile(ArchiveFile(f.name, data.length, data));
    }
    final fixed = ZipEncoder().encode(out);
    if (fixed == null) throw Exception('Failed to encode Excel file');
    return fixed;
  }
}

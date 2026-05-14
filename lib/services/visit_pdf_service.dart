import 'dart:io';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:leadmanagementsystem/models/visit_report_model.dart';

class VisitPdfService {
  static const PdfColor _primary = PdfColor(0, 0.647, 0.412);
  static const PdfColor _lightGreen = PdfColor(0.878, 0.973, 0.937);
  static const PdfColor _darkGrey = PdfColor(0.2, 0.2, 0.2);
  static const PdfColor _midGrey = PdfColor(0.5, 0.5, 0.5);
  static const PdfColor _lightGrey = PdfColor(0.95, 0.95, 0.95);

  static String _safe(String? v) =>
      (v != null && v.isNotEmpty) ? v : '-';

  static String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      return DateFormat('dd MMM yyyy, hh:mm a')
          .format(DateTime.parse(dateStr).toLocal());
    } catch (_) {
      return dateStr;
    }
  }

  static double _deg2rad(double d) => d * pi / 180;

  static double _haversine({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const r = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _totalDistance(VisitData visit) {
    final points = <dynamic>[
      ...(visit.checkIn ?? []).where((c) => c.lat != null && c.long != null),
    ];
    if (visit.checkOut?.lat != null && visit.checkOut?.long != null) {
      points.add(visit.checkOut);
    }
    if (points.length < 2) return 0.0;
    double total = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      total += _haversine(
        lat1: double.parse(points[i].lat!),
        lon1: double.parse(points[i].long!),
        lat2: double.parse(points[i + 1].lat!),
        lon2: double.parse(points[i + 1].long!),
      );
    }
    return total;
  }

  // ─────────────────────────────────────────────
  // Public entry point
  // ─────────────────────────────────────────────

  static Future<void> generateAndOpen({
    required List<VisitData> visits,
    required String reportTitle,
  }) async {
    final pdf = pw.Document();
    final generated =
        DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 32),
        header: (_) => _pageHeader(reportTitle, generated, visits.length),
        footer: (ctx) => _pageFooter(ctx),
        build: (_) => [
          pw.SizedBox(height: 16),
          ...visits.asMap().entries.map((e) => _visitCard(e.value, e.key + 1)),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/visit_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    OpenFile.open(file.path);
  }

  // ─────────────────────────────────────────────
  // Page header / footer
  // ─────────────────────────────────────────────

  static pw.Widget _pageHeader(
      String title, String generated, int count) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _primary, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'RGC RMS',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: _primary,
                ),
              ),
              pw.Text(
                title,
                style: pw.TextStyle(fontSize: 11, color: _darkGrey),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Generated: $generated',
                style: pw.TextStyle(fontSize: 8, color: _midGrey),
              ),
              pw.Text(
                'Total Records: $count',
                style: pw.TextStyle(fontSize: 8, color: _midGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _pageFooter(pw.Context ctx) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _lightGrey, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Confidential — RGC RMS Visit Reports',
            style: pw.TextStyle(fontSize: 7, color: _midGrey),
          ),
          pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: pw.TextStyle(fontSize: 7, color: _midGrey),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Visit card
  // ─────────────────────────────────────────────

  static pw.Widget _visitCard(VisitData visit, int index) {
    final isClosed =
        visit.checkOut?.time != null && visit.checkOut!.time!.isNotEmpty;
    final checkIns = visit.checkIn ?? [];
    final dist = _totalDistance(visit);

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _cardHeader(index, isClosed, visit.createdAt),

          if (visit.userDetail != null) ...[
            _sectionLabel('USER INFORMATION'),
            _userSection(visit.userDetail!),
          ],

          _sectionLabel('VISIT DETAILS'),
          _visitSection(visit),

          if (checkIns.isNotEmpty) ...[
            _sectionLabel(
                'CHECK-IN HISTORY  (${checkIns.length} record${checkIns.length > 1 ? "s" : ""})'),
            _checkInSection(checkIns),
          ],

          _sectionLabel('CHECK-OUT'),
          _checkOutSection(visit.checkOut, isClosed),

          _summaryBar(dist, isClosed),
        ],
      ),
    );
  }

  static pw.Widget _cardHeader(
      int index, bool isClosed, String? createdAt) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: pw.BoxDecoration(
        color: _primary,
        borderRadius: const pw.BorderRadius.only(
          topLeft: pw.Radius.circular(6),
          topRight: pw.Radius.circular(6),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Visit Report  #$index',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.Row(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: pw.BoxDecoration(
                  color:
                      isClosed ? PdfColors.red400 : PdfColors.green400,
                  borderRadius: pw.BorderRadius.circular(3),
                ),
                child: pw.Text(
                  isClosed ? 'CLOSED' : 'OPEN',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Text(
                'Created: ${_formatDate(createdAt)}',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _sectionLabel(String text) {
    return pw.Container(
      width: double.infinity,
      padding:
          const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      color: _lightGreen,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: _primary,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Section bodies
  // ─────────────────────────────────────────────

  static pw.Widget _userSection(UserDetail u) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _fieldRow('Name', _safe(u.name), 'Role', _safe(u.role)),
          _fieldRow('Email', _safe(u.email), 'Status', _safe(u.status)),
          _fieldRow(
              'Company', _safe(u.company), 'Region', _safe(u.region)),
          _fieldRow('Area', _safe(u.area), '', ''),
        ],
      ),
    );
  }

  static pw.Widget _visitSection(VisitData v) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _fieldRow('Site', _safe(v.site), 'Town / Phase',
              _safe(v.townPahse)),
          _fieldRow('Block', _safe(v.block), 'GCO', _safe(v.gco)),
          _fieldRow('Key Person Name', _safe(v.keyPN),
              'Key Person Contact', _safe(v.keyPC)),
          _fieldRow('Architect', _safe(v.architect), 'Call Result',
              _safe(v.callResult)),
          _fieldRow('Created At', _formatDate(v.createdAt), 'Last Updated',
              _formatDate(v.updatedAt)),
        ],
      ),
    );
  }

  static pw.Widget _checkInSection(List<CheckIn> checkIns) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: checkIns.asMap().entries.map((entry) {
          final i = entry.key;
          final ci = entry.value;
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 18,
                  height: 18,
                  alignment: pw.Alignment.center,
                  decoration: const pw.BoxDecoration(
                    color: _primary,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Text(
                    '${i + 1}',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        _safe(ci.time),
                        style:
                            pw.TextStyle(fontSize: 10, color: _darkGrey),
                      ),
                      if (ci.lat != null && ci.long != null)
                        pw.Text(
                          'Lat: ${ci.lat}   Long: ${ci.long}',
                          style: pw.TextStyle(
                              fontSize: 8, color: _midGrey),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  static pw.Widget _checkOutSection(CheckIn? co, bool isClosed) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(12),
      child: isClosed && co != null
          ? pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  _safe(co.time),
                  style: pw.TextStyle(fontSize: 10, color: _darkGrey),
                ),
                if (co.lat != null && co.long != null)
                  pw.Text(
                    'Lat: ${co.lat}   Long: ${co.long}',
                    style: pw.TextStyle(fontSize: 8, color: _midGrey),
                  ),
              ],
            )
          : pw.Text(
              'Not checked out yet',
              style: pw.TextStyle(
                fontSize: 10,
                color: _midGrey,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
    );
  }

  static pw.Widget _summaryBar(double dist, bool isClosed) {
    return pw.Container(
      padding:
          const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(
        color: _lightGrey,
        borderRadius: const pw.BorderRadius.only(
          bottomLeft: pw.Radius.circular(6),
          bottomRight: pw.Radius.circular(6),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Distance Covered: ${dist.toStringAsFixed(2)} km',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),
          pw.Text(
            'Status: ${isClosed ? "Visit Closed" : "Visit Open"}',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: isClosed ? PdfColors.red600 : PdfColors.green700,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Shared layout helper
  // ─────────────────────────────────────────────

  static pw.Widget _fieldRow(
      String l1, String v1, String l2, String v2) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.RichText(
              text: pw.TextSpan(children: [
                pw.TextSpan(
                  text: '$l1: ',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: _midGrey,
                  ),
                ),
                pw.TextSpan(
                  text: v1,
                  style: pw.TextStyle(fontSize: 9, color: _darkGrey),
                ),
              ]),
            ),
          ),
          if (l2.isNotEmpty) ...[
            pw.SizedBox(width: 14),
            pw.Expanded(
              child: pw.RichText(
                text: pw.TextSpan(children: [
                  pw.TextSpan(
                    text: '$l2: ',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: _midGrey,
                    ),
                  ),
                  pw.TextSpan(
                    text: v2,
                    style: pw.TextStyle(fontSize: 9, color: _darkGrey),
                  ),
                ]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

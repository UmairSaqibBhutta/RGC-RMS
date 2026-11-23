import 'dart:convert';

import 'package:archive/archive.dart';

/// Cell styles available to [XlsxWriter] (indexes into styles.xml cellXfs).
enum XlsxStyle {
  normal, // 0
  title, // 1  bold 16, white on dark green, centered
  meta, // 2  italic grey, centered
  header, // 3  bold white on green, bordered, wrapped
  cell, // 4  bordered, wrapped, top-left
  cellAlt, // 5  same as cell, zebra fill
  cellCenter, // 6  bordered, centered
  cellCenterAlt, // 7  same, zebra fill
}

/// Minimal, standards-compliant single-sheet .xlsx writer.
///
/// Written by hand (instead of the `excel` package) because that package
/// produces workbooks some mobile viewers open as an empty sheet, and it does
/// not strip characters that are illegal in XML, which makes Excel discard the
/// sheet data when "repairing" the file.
class XlsxWriter {
  final String sheetName;
  final List<double> columnWidths;

  /// Number of top rows kept visible while scrolling (0 = none).
  int frozenRows = 0;

  final Map<int, Map<int, _Cell>> _rows = {};
  final Map<int, double> _rowHeights = {};
  final List<String> _merges = [];

  XlsxWriter({required this.sheetName, required this.columnWidths});

  /// [row] and [col] are 0-based. [value] is a String or num.
  void setCell(int row, int col, Object value,
      {XlsxStyle style = XlsxStyle.normal}) {
    _rows.putIfAbsent(row, () => {})[col] = _Cell(value, style);
  }

  void setRowHeight(int row, double points) => _rowHeights[row] = points;

  void merge(int row, int fromCol, int toCol) =>
      _merges.add('${ref(fromCol, row)}:${ref(toCol, row)}');

  static String colName(int col) {
    var n = col + 1, s = '';
    while (n > 0) {
      final m = (n - 1) % 26;
      s = String.fromCharCode(65 + m) + s;
      n = (n - 1) ~/ 26;
    }
    return s;
  }

  static String ref(int col, int row) => '${colName(col)}${row + 1}';

  /// Removes characters that are not allowed in XML 1.0, then escapes.
  static String esc(String input) {
    final b = StringBuffer();
    for (final r in input.replaceAll('\r\n', '\n').runes) {
      final ok = r == 0x9 ||
          r == 0xA ||
          r == 0xD ||
          (r >= 0x20 && r <= 0xD7FF) ||
          (r >= 0xE000 && r <= 0xFFFD) ||
          (r >= 0x10000 && r <= 0x10FFFF);
      if (!ok) continue;
      switch (r) {
        case 0x26:
          b.write('&amp;');
        case 0x3C:
          b.write('&lt;');
        case 0x3E:
          b.write('&gt;');
        case 0x22:
          b.write('&quot;');
        default:
          b.writeCharCode(r);
      }
    }
    return b.toString();
  }

  List<int> encode() {
    // Shared strings
    final strings = <String>[];
    final index = <String, int>{};
    var stringRefs = 0;

    final sheetData = StringBuffer('<sheetData>');
    var maxRow = 0, maxCol = 0;
    for (final r in (_rows.keys.toList()..sort())) {
      final cells = _rows[r]!;
      final h = _rowHeights[r];
      sheetData.write('<row r="${r + 1}"');
      if (h != null) sheetData.write(' ht="$h" customHeight="1"');
      sheetData.write('>');
      for (final c in (cells.keys.toList()..sort())) {
        final cell = cells[c]!;
        final s = cell.style.index;
        if (r > maxRow) maxRow = r;
        if (c > maxCol) maxCol = c;
        final v = cell.value;
        if (v is num) {
          sheetData.write('<c r="${ref(c, r)}" s="$s"><v>$v</v></c>');
        } else {
          final text = esc(v.toString());
          final i = index.putIfAbsent(text, () {
            strings.add(text);
            return strings.length - 1;
          });
          stringRefs++;
          sheetData.write('<c r="${ref(c, r)}" s="$s" t="s"><v>$i</v></c>');
        }
      }
      sheetData.write('</row>');
    }
    sheetData.write('</sheetData>');

    final cols = StringBuffer('<cols>');
    for (var i = 0; i < columnWidths.length; i++) {
      cols.write('<col min="${i + 1}" max="${i + 1}" '
          'width="${columnWidths[i]}" customWidth="1"/>');
    }
    cols.write('</cols>');

    final pane = frozenRows > 0
        ? '<pane ySplit="$frozenRows" topLeftCell="A${frozenRows + 1}" '
            'activePane="bottomLeft" state="frozen"/>'
            '<selection pane="bottomLeft" activeCell="A${frozenRows + 1}" '
            'sqref="A${frozenRows + 1}"/>'
        : '';

    final merges = _merges.isEmpty
        ? ''
        : '<mergeCells count="${_merges.length}">'
            '${_merges.map((m) => '<mergeCell ref="$m"/>').join()}'
            '</mergeCells>';

    final sheet = '$_xmlHead'
        '<worksheet xmlns="$_ns" xmlns:r="$_nsR">'
        '<dimension ref="A1:${ref(maxCol, maxRow)}"/>'
        '<sheetViews><sheetView tabSelected="1" workbookViewId="0">$pane'
        '</sheetView></sheetViews>'
        '<sheetFormatPr defaultRowHeight="15"/>'
        '$cols$sheetData$merges'
        '<pageMargins left="0.4" right="0.4" top="0.5" bottom="0.5" '
        'header="0.3" footer="0.3"/>'
        '<pageSetup paperSize="9" orientation="landscape"/>'
        '</worksheet>';

    final sst = StringBuffer('$_xmlHead<sst xmlns="$_ns" '
        'count="$stringRefs" uniqueCount="${strings.length}">');
    for (final s in strings) {
      sst.write('<si><t xml:space="preserve">$s</t></si>');
    }
    sst.write('</sst>');

    final now = '${DateTime.now().toUtc().toIso8601String().split('.').first}Z';
    final name = esc(sheetName);

    final files = <String, String>{
      '[Content_Types].xml': '$_xmlHead'
          '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
          '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
          '<Default Extension="xml" ContentType="application/xml"/>'
          '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
          '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
          '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>'
          '<Override PartName="/xl/sharedStrings.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"/>'
          '<Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>'
          '<Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>'
          '</Types>',
      '_rels/.rels': '$_xmlHead'
          '<Relationships xmlns="$_nsPkgRel">'
          '<Relationship Id="rId1" Type="$_nsDocRel/officeDocument" Target="xl/workbook.xml"/>'
          '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>'
          '<Relationship Id="rId3" Type="$_nsDocRel/extended-properties" Target="docProps/app.xml"/>'
          '</Relationships>',
      'docProps/core.xml': '$_xmlHead'
          '<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" '
          'xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" '
          'xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
          '<dc:title>$name</dc:title><dc:creator>RGC RMS</dc:creator>'
          '<dcterms:created xsi:type="dcterms:W3CDTF">$now</dcterms:created>'
          '<dcterms:modified xsi:type="dcterms:W3CDTF">$now</dcterms:modified>'
          '</cp:coreProperties>',
      'docProps/app.xml': '$_xmlHead'
          '<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties">'
          '<Application>Microsoft Excel</Application></Properties>',
      'xl/workbook.xml': '$_xmlHead'
          '<workbook xmlns="$_ns" xmlns:r="$_nsR">'
          '<bookViews><workbookView activeTab="0"/></bookViews>'
          '<sheets><sheet name="$name" sheetId="1" r:id="rId1"/></sheets>'
          '</workbook>',
      'xl/_rels/workbook.xml.rels': '$_xmlHead'
          '<Relationships xmlns="$_nsPkgRel">'
          '<Relationship Id="rId1" Type="$_nsDocRel/worksheet" Target="worksheets/sheet1.xml"/>'
          '<Relationship Id="rId2" Type="$_nsDocRel/styles" Target="styles.xml"/>'
          '<Relationship Id="rId3" Type="$_nsDocRel/sharedStrings" Target="sharedStrings.xml"/>'
          '</Relationships>',
      'xl/styles.xml': _styles,
      'xl/sharedStrings.xml': sst.toString(),
      'xl/worksheets/sheet1.xml': sheet,
    };

    final archive = Archive();
    files.forEach((path, xml) {
      final bytes = utf8.encode(xml);
      archive.addFile(ArchiveFile(path, bytes.length, bytes));
    });
    final out = ZipEncoder().encode(archive);
    if (out == null) throw Exception('Failed to build Excel file');
    return out;
  }

  static const _xmlHead =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n';
  static const _ns = 'http://schemas.openxmlformats.org/spreadsheetml/2006/main';
  static const _nsR =
      'http://schemas.openxmlformats.org/officeDocument/2006/relationships';
  static const _nsDocRel =
      'http://schemas.openxmlformats.org/officeDocument/2006/relationships';
  static const _nsPkgRel =
      'http://schemas.openxmlformats.org/package/2006/relationships';

  // Order of <xf> entries in cellXfs must match XlsxStyle.
  static const _styles = '$_xmlHead'
      '<styleSheet xmlns="$_ns">'
      '<fonts count="4">'
      '<font><sz val="10"/><color rgb="FF111827"/><name val="Calibri"/><family val="2"/></font>'
      '<font><b/><sz val="16"/><color rgb="FFFFFFFF"/><name val="Calibri"/><family val="2"/></font>'
      '<font><i/><sz val="10"/><color rgb="FF6B7280"/><name val="Calibri"/><family val="2"/></font>'
      '<font><b/><sz val="11"/><color rgb="FFFFFFFF"/><name val="Calibri"/><family val="2"/></font>'
      '</fonts>'
      '<fills count="5">'
      '<fill><patternFill patternType="none"/></fill>'
      '<fill><patternFill patternType="gray125"/></fill>'
      '<fill><patternFill patternType="solid"><fgColor rgb="FF007A4D"/><bgColor indexed="64"/></patternFill></fill>'
      '<fill><patternFill patternType="solid"><fgColor rgb="FF00A569"/><bgColor indexed="64"/></patternFill></fill>'
      '<fill><patternFill patternType="solid"><fgColor rgb="FFF1FBF6"/><bgColor indexed="64"/></patternFill></fill>'
      '</fills>'
      '<borders count="2">'
      '<border><left/><right/><top/><bottom/><diagonal/></border>'
      '<border><left style="thin"><color rgb="FFD1D5DB"/></left>'
      '<right style="thin"><color rgb="FFD1D5DB"/></right>'
      '<top style="thin"><color rgb="FFD1D5DB"/></top>'
      '<bottom style="thin"><color rgb="FFD1D5DB"/></bottom><diagonal/></border>'
      '</borders>'
      '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>'
      '<cellXfs count="8">'
      // normal
      '<xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>'
      // title
      '<xf numFmtId="0" fontId="1" fillId="2" borderId="0" xfId="0" applyFont="1" applyFill="1" applyAlignment="1">'
      '<alignment horizontal="center" vertical="center"/></xf>'
      // meta
      '<xf numFmtId="0" fontId="2" fillId="0" borderId="0" xfId="0" applyFont="1" applyAlignment="1">'
      '<alignment horizontal="center" vertical="center"/></xf>'
      // header
      '<xf numFmtId="0" fontId="3" fillId="3" borderId="1" xfId="0" applyFont="1" applyFill="1" applyBorder="1" applyAlignment="1">'
      '<alignment horizontal="center" vertical="center" wrapText="1"/></xf>'
      // cell
      '<xf numFmtId="0" fontId="0" fillId="0" borderId="1" xfId="0" applyBorder="1" applyAlignment="1">'
      '<alignment horizontal="left" vertical="top" wrapText="1"/></xf>'
      // cellAlt
      '<xf numFmtId="0" fontId="0" fillId="4" borderId="1" xfId="0" applyFill="1" applyBorder="1" applyAlignment="1">'
      '<alignment horizontal="left" vertical="top" wrapText="1"/></xf>'
      // cellCenter
      '<xf numFmtId="0" fontId="0" fillId="0" borderId="1" xfId="0" applyBorder="1" applyAlignment="1">'
      '<alignment horizontal="center" vertical="top"/></xf>'
      // cellCenterAlt
      '<xf numFmtId="0" fontId="0" fillId="4" borderId="1" xfId="0" applyFill="1" applyBorder="1" applyAlignment="1">'
      '<alignment horizontal="center" vertical="top"/></xf>'
      '</cellXfs>'
      '<cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>'
      '</styleSheet>';
}

class _Cell {
  final Object value;
  final XlsxStyle style;
  _Cell(this.value, this.style);
}

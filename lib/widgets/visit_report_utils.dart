// import 'dart:io';

// import 'package:excel/excel.dart';
// import 'package:leadmanagementsystem/models/visit_report_model.dart';
// import 'package:open_file/open_file.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:intl/intl.dart';

// class VisitReportUtils {
//   final dateFormatter = DateFormat('dd MMM yyyy');

//   Future<void> exportToExcel(List<VisitReportDetails> visitData) async {
//     final Excel excel = Excel.createExcel();
//     final Sheet sheet = excel['Sheet1'];

//     // Set column headers
//     final headers = [
//       'Visit Date',
//       'Client/Site',
//       'Contact Person',
//       'Contact No.',
//       'Visit Plan',
//       'Visit Report',
//     ].map((text) => TextCellValue(text)).toList();
//     sheet.appendRow(headers);

//     // Populate data rows
//     for (final report in visitData) {
//       final String date = report.visitDate ?? '';
//       final List<VisitDetail> details = report.visitDetail ?? [];

//       for (final detail in details) {
//         final row = [
//           TextCellValue(dateFormatter.format(DateTime.parse(date))),
//           TextCellValue(detail.siteName ?? ''),
//           TextCellValue(detail.contactPerson ?? ''),
//           TextCellValue(detail.contactNumber ?? ''),
//           TextCellValue(detail.visitPlan ?? ''),
//           TextCellValue(detail.visitReport ?? ''),
//         ];
//         sheet.appendRow(row);
//       }
//     }

//     final List<int>? fileBytes = excel.save();
//     if (fileBytes == null) return;

//     final directory = await getApplicationDocumentsDirectory();
//     final String filePath = '${directory.path}/VisitReport.xlsx';
//     final File file = File(filePath);
//     await file.writeAsBytes(fileBytes, flush: true);

//     await OpenFile.open(filePath);
//   }

//   Future<void> exportToPdf(List<VisitReportDetails> visitData) async {
//     final pdf = pw.Document();
//     final dateFormatter = DateFormat('dd MMM yyyy');

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(24),
//         build: (context) {
//           List<pw.Widget> content = [];

//           for (final report in visitData) {
//             final visitDate = report.visitDate != null
//                 ? dateFormatter.format(
//                     DateTime.tryParse(report.visitDate!) ?? DateTime.now())
//                 : 'N/A';
//             final userInfo =
//                 '${report.name ?? 'Unknown'} (${report.role ?? 'User'})';

//             for (final detail in report.visitDetail ?? []) {
//               content.add(
//                 pw.Container(
//                   margin: const pw.EdgeInsets.only(bottom: 16),
//                   padding: const pw.EdgeInsets.all(12),
//                   decoration: pw.BoxDecoration(
//                     border: pw.Border.all(color: PdfColors.grey300),
//                     borderRadius: pw.BorderRadius.circular(10),
//                     color: PdfColors.grey100,
//                   ),
//                   child: pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text("Reporter: $userInfo",
//                           style: pw.TextStyle(
//                               fontSize: 12,
//                               fontWeight: pw.FontWeight.bold,
//                               color: PdfColors.teal800)),
//                       pw.Text("Visit Date: $visitDate",
//                           style: pw.TextStyle(
//                               fontSize: 11,
//                               fontWeight: pw.FontWeight.bold,
//                               color: PdfColors.black)),
//                       pw.SizedBox(height: 10),
//                       _pdfRow("Client/Site", detail.siteName),
//                       _pdfRow("Contact Person", detail.contactPerson),
//                       _pdfRow("Contact No.", detail.contactNumber),
//                       _pdfRow("Visit Plan", detail.visitPlan),
//                       _pdfRow("Visit Report", detail.visitReport),
//                     ],
//                   ),
//                 ),
//               );
//             }
//           }

//           return content;
//         },
//       ),
//     );

//     final String path = (await getApplicationDocumentsDirectory()).path;
//     final file = File('$path/VisitReport.pdf');
//     await file.writeAsBytes(await pdf.save());
//     OpenFile.open(file.path);
//   }

//   pw.Widget _pdfRow(String title, String? value) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(vertical: 2),
//       child: pw.Row(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.Container(
//             width: 110,
//             child: pw.Text("$title:",
//                 style: pw.TextStyle(
//                     fontSize: 10,
//                     fontWeight: pw.FontWeight.bold,
//                     color: PdfColors.black)),
//           ),
//           pw.Expanded(
//             child:
//                 pw.Text(value ?? '-', style: const pw.TextStyle(fontSize: 10)),
//           ),
//         ],
//       ),
//     );
//   }
// }

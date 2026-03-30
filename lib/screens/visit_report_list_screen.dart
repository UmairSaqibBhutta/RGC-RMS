import 'dart:developer';

import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/constants/user_roles.dart';
import 'package:leadmanagementsystem/controllers/report_controller.dart';
import 'package:leadmanagementsystem/controllers/visit_controller.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/visit_detail_model.dart';
import 'package:leadmanagementsystem/screens/add_visit_report_screen.dart';
import 'package:leadmanagementsystem/widgets/custom_button.dart';
import 'package:leadmanagementsystem/widgets/custom_text_field.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class VisitReportListScreen extends StatefulWidget {
  const VisitReportListScreen({super.key});

  @override
  State<VisitReportListScreen> createState() => _VisitReportListScreenState();
}

class _VisitReportListScreenState extends State<VisitReportListScreen> {
  final dateFormatter = DateFormat('dd MMM yyyy');
  final visitCont = Get.put(VisitController());
  final ReportController reportController = Get.put(ReportController());

  String? selectedUserId;
  bool showFilter = false;
  DateTime? firstDate;
  DateTime? lastDate;

  List<VisitReportDetails>? myVisitReportModel = [];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      visitCont.getVisitReport();
      if (loginStorage.getUserRole() == UserRole.CEO) {
        reportController.getAllUsersExceptCeo();
      }
    });

    visitCont.paginationData();

  }

  bool isUserSelectionIncluded = true;
  final siteNameCont = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: mAppbar(
        "Visit Plan / Reports",
        action: loginStorage.getUserRole() == UserRole.CEO
            ? [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        exportToExcel(visitCont.visitReportModel?.data ?? []);
                      },
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: Image.asset(
                          "images/excel.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () {
                        exportToPdf(visitCont.visitReportModel?.data ?? []);
                      },
                      child: SizedBox(
                        height: 35,
                        width: 40,
                        child: Image.asset(
                          "images/pdf.png",
                          fit: BoxFit.contain, // 👈 use same fit mode
                        ),
                      ),
                    ),
                  ],
                )
              ]
            : null,
      ),
      body: GetBuilder(
        init: visitCont,
        builder: (cont) {
          return

            SingleChildScrollView(
              controller: cont.scrollController,
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  if (loginStorage.getUserRole() == UserRole.CEO)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              showFilter = !showFilter;
                            });
                          },
                          child: Image.asset(
                            'images/filter.png',
                            width: 25,
                            height: 25,
                          ),
                        ),
                      ),
                    ),
                  if (loginStorage.getUserRole() == UserRole.CEO && showFilter)
                    Column(
                      children: [
                        GetBuilder<ReportController>(
                          builder: (controller) {
                            final users = controller.allUsersExceptCeo;

                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    decoration: dropdownDecoration(
                                        "Select a User"),
                                    value: selectedUserId,
                                    items: users.map((user) {
                                      final label = '${user.name} (${user
                                          .role})';
                                      return DropdownMenuItem<String>(
                                        value: user.sId,
                                        child: Text(label),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedUserId = value;
                                      });
                                    },
                                  ),
                                  // const SizedBox(height: 16),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Text("Include User"),
                                      Switch(
                                        activeColor: appColor,
                                        value: isUserSelectionIncluded,
                                        onChanged: (value) {
                                          setState(() {
                                            isUserSelectionIncluded =
                                            !isUserSelectionIncluded;
                                          });
                                        },
                                      ),
                                    ],
                                  ),

                                  CustomTextField(
                                    controller: siteNameCont,
                                    hint: "Enter client / site name",
                                    allSidesPadding: 0,
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            side: const BorderSide(
                                                color: appColor),
                                            foregroundColor: appColor,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                          ),
                                          icon: const Icon(Icons.date_range),
                                          label: Text(firstDate == null
                                              ? 'Select First Date'
                                              : 'From: ${DateFormat
                                              .yMMMd()
                                              .format(firstDate!)}'),
                                          onPressed: () async {
                                            final picked = await pickDate(
                                                context: context,
                                                firstDate: DateTime(2024),
                                                lastDate: DateTime(2026),
                                                initialDate: DateTime.now());
                                            if (picked != null) {
                                              setState(() {
                                                firstDate = picked;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            side: const BorderSide(
                                                color: appColor),
                                            foregroundColor: appColor,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                          ),
                                          icon: const Icon(
                                              Icons.date_range_outlined),
                                          label: Text(lastDate == null
                                              ? 'Select Last Date'
                                              : 'To: ${DateFormat
                                              .yMMMd()
                                              .format(lastDate!)}'),
                                          onPressed: () async {
                                            final picked = await pickDate(
                                                context: context,
                                                firstDate: DateTime(2024),
                                                lastDate: DateTime(2026),
                                                initialDate: DateTime.now());
                                            if (picked != null) {
                                              setState(() {
                                                lastDate = picked;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: appColor,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14),
                                          ),
                                          onPressed: () {
                                            visitCont.getVisitReport(
                                              siteName: siteNameCont.text
                                                  .trim(),
                                              userId: isUserSelectionIncluded
                                                  ? selectedUserId
                                                  : null,
                                              firstDate: firstDate
                                                  ?.toIso8601String(),
                                              lastDate: lastDate
                                                  ?.toIso8601String(),
                                            );
                                            log(
                                                "Filters Applied: userId=$selectedUserId, from=$firstDate, to=$lastDate");

                                            // setState(() {
                                            //   showFilter = !showFilter;
                                            // });
                                          },
                                          child: const Text("Apply"),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side:
                                            const BorderSide(
                                                color: Colors.grey),
                                            foregroundColor: Colors.grey[800],
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              selectedUserId = null;
                                              firstDate = null;
                                              lastDate = null;
                                              showFilter = !showFilter;
                                              myVisitReportModel =
                                                  visitCont.visitReportAllModel
                                                      ?.data;
                                            });
                                          },
                                          child: const Text("Cancel"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  GetBuilder<VisitController>(
                    builder: (cont) {
                      if (cont.firstTimeVisitLoading && cont.visitDetailWIthPagination.isEmpty ) return showSpinkit();

                      myVisitReportModel = cont.visitReportModel?.data;

                      if (myVisitReportModel == null ||
                          myVisitReportModel!.isEmpty) {
                        return const Center(
                          child: Text(
                            "No Visit details Found",
                            style: TextStyle(
                                fontSize: 16, color: Colors.black54),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        padding:
                        const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        // itemCount: myVisitReportModel!.length,
                        itemCount: cont.visitDetailWIthPagination.length,
                        itemBuilder: (context, i) {
                          final report = cont.visitDetailWIthPagination[i];
                          final formattedDate = report.visitDate != null
                              ? dateFormatter.format(
                              DateTime.tryParse(report.visitDate!) ??
                                  DateTime.now())
                              : '';

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [

                              if (report.name != null &&
                                  report.role != null &&
                                  report.userId !=
                                      loginStorage.getUserId())
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 8, left: 4),
                                  child: Row(
                                    children: [
                                      const Icon(CupertinoIcons.person_solid,
                                          size: 16, color: appColor),
                                      const SizedBox(width: 6),
                                      Text(
                                        "${report
                                            .name} (${report
                                            .role})",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: appColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (formattedDate.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 8, left: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          size: 16, color: appColor),
                                      const SizedBox(width: 6),
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: appColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ...?report.visitDetail?.map(
                                    (visit) =>
                                    Card(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              16)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            _rowItem("Client/Site",
                                                visit.siteName ?? ""),
                                            _rowItem("Contact Person",
                                                visit.contactPerson ?? ""),
                                            _rowItem(
                                                "Contact No.",
                                                visit.contactNumber ?? ""),
                                            _rowItem("Visit Plan",
                                                visit.visitPlan ?? ""),
                                            if (visit.visitReport?.isNotEmpty ==
                                                true)
                                              _rowItem(
                                                  "Visit Report",
                                                  visit.visitReport!),
                                            const SizedBox(height: 16),
                                            if ((visit.visitReport == null ||
                                                visit.visitReport!.isEmpty) &&
                                                loginStorage.getUserRole() !=
                                                    UserRole.CEO)
                                              Align(
                                                alignment: Alignment
                                                    .centerRight,
                                                child: ElevatedButton.icon(
                                                  icon: const Icon(
                                                      Icons.edit, size: 18),
                                                  label: const Text(
                                                      "Add Visit Report"),
                                                  style: ElevatedButton
                                                      .styleFrom(
                                                    backgroundColor: appColor,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16,
                                                        vertical: 10),
                                                  ),
                                                  onPressed: () {
                                                    if (loginStorage
                                                        .getUserId() ==
                                                        report.userId) {
                                                      _showAddReportBottomSheet(
                                                          context, visit,
                                                          report.sId!);
                                                    }
                                                  },
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  if (cont.hasLoading) Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: showSpinkit(),
                  )
                ],
              ),
            );
        }
      ),
      floatingActionButton: loginStorage.getUserRole() == UserRole.CEO
          ? const SizedBox.shrink()
          : FloatingActionButton(
              backgroundColor: appColor,
              onPressed: () => Get.to(const AddVisitReportScreen()),
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _rowItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(value,
                style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showAddReportBottomSheet(
      BuildContext context, VisitDetail visit, String visitReportId) {
    final TextEditingController reportController =
        TextEditingController(text: visit.visitReport ?? '');
    String previousText = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStatesss) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Add Visit Report",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: reportController,
                        hint: "Enter visit report details...",
                        maxLines: 5,
                        inputType: TextInputType.multiline,
                        suffix: reportController.text.isNotEmpty
                            ? Icons.clear
                            : null,
                        suffixOnTap: () {
                          reportController.clear();
                          setStatesss(() {}); // update suffix
                        },
                        onChanged: (text) {
                          // Update UI for suffix icon
                          if (text.isEmpty || text.length == 1) {
                            setStatesss(() {});
                          }

                          final isDeleting = text.length < previousText.length;

                          // User cleared text completely
                          if (text.isEmpty) {
                            previousText = text;
                            return;
                          }

                          // If user is deleting — do nothing special
                          if (isDeleting) {
                            previousText = text;
                            return;
                          }

                          // If user hits Enter (inserting new line)
                          if (text.endsWith('\n')) {
                            final cursorPosition =
                                reportController.selection.baseOffset;

                            // Prevent adding multiple bullets after same line
                            if (cursorPosition > 1 &&
                                text.substring(
                                        cursorPosition - 2, cursorPosition) ==
                                    '• ') {
                              previousText = text;
                              return;
                            }

                            final newText =
                                '${text.substring(0, cursorPosition)}• ${text.substring(cursorPosition)}';

                            reportController.text = newText;
                            reportController.selection =
                                TextSelection.collapsed(
                                    offset: cursorPosition + 2);
                            previousText = newText;
                            return;
                          }

                          // Insert first bullet at beginning (if not there)
                          if (!text.startsWith('• ') && previousText.isEmpty) {
                            reportController.text = '• $text';
                            reportController.selection =
                                TextSelection.collapsed(
                                    offset: reportController.text.length);
                            previousText = reportController.text;
                            return;
                          }

                          previousText = text; // Always update at end
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        title: "Submit",
                        onTap: () async {
                          if (reportController.text.trim().isEmpty) {
                            Get.snackbar(
                                "Error", "Please enter visit report details");
                            return;
                          }

                          Navigator.pop(context);

                          Map<String, dynamic> body = {
                            "visitReportId": visitReportId,
                            "visitId": visit.sId,
                            "visitReport": reportController.text.trim(),
                          };

                          // alertDialogueWithLoader(context);
                          bool isAdded = await visitCont.addvisitReport(body);
                          // Navigator.pop(context);

                          if (isAdded) {
                            visitCont.getVisitReport();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Future<void> exportToExcel(List<VisitReportDetails> visitData) async {
    final Excel excel = Excel.createExcel();
    final Sheet sheet = excel['Sheet1'];

    // Set column headers
    final headers = [
      'Visit Date',
      'Client/Site',
      'Contact Person',
      'Contact No.',
      'Visit Plan',
      'Visit Report',
    ].map((text) => TextCellValue(text)).toList();
    sheet.appendRow(headers);

    // Populate data rows
    for (final report in visitData) {
      final String date = report.visitDate ?? '';
      final List<VisitDetail> details = report.visitDetail ?? [];

      for (final detail in details) {
        final row = [
          TextCellValue(dateFormatter.format(DateTime.parse(date))),
          TextCellValue(detail.siteName ?? ''),
          TextCellValue(detail.contactPerson ?? ''),
          TextCellValue(detail.contactNumber ?? ''),
          TextCellValue(detail.visitPlan ?? ''),
          TextCellValue(detail.visitReport ?? ''),
        ];
        sheet.appendRow(row);
      }
    }

    final List<int>? fileBytes = excel.save();
    if (fileBytes == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/VisitReport.xlsx';
    final File file = File(filePath);
    await file.writeAsBytes(fileBytes, flush: true);

    await OpenFile.open(filePath);
  }

  Future<void> exportToPdf(List<VisitReportDetails> visitData) async {
    final pdf = pw.Document();
    final dateFormatter = DateFormat('dd MMM yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          List<pw.Widget> content = [];

          for (final report in visitData) {
            final visitDate = report.visitDate != null
                ? dateFormatter.format(
                    DateTime.tryParse(report.visitDate!) ?? DateTime.now())
                : 'N/A';
            final userInfo =
                '${report.name ?? 'Unknown'} (${report.role ?? 'User'})';

            for (final detail in report.visitDetail ?? []) {
              content.add(
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(10),
                    color: PdfColors.grey100,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Reporter: $userInfo",
                          style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.teal800)),
                      pw.Text("Visit Date: $visitDate",
                          style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black)),
                      pw.SizedBox(height: 10),
                      _pdfRow("Client/Site", detail.siteName),
                      _pdfRow("Contact Person", detail.contactPerson),
                      _pdfRow("Contact No.", detail.contactNumber),
                      _pdfRow("Visit Plan", detail.visitPlan),
                      _pdfRow("Visit Report", detail.visitReport),
                    ],
                  ),
                ),
              );
            }
          }

          return content;
        },
      ),
    );

    final String path = (await getApplicationDocumentsDirectory()).path;
    final file = File('$path/VisitReport.pdf');
    await file.writeAsBytes(await pdf.save());
    OpenFile.open(file.path);
  }

  pw.Widget _pdfRow(String title, String? value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 110,
            child: pw.Text("$title:",
                style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black)),
          ),
          pw.Expanded(
            child:
                pw.Text(value ?? '-', style: const pw.TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }
}

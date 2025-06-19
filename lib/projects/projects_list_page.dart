import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/admin_module/add_project_page.dart';
import 'package:leadmanagementsystem/controllers/report_controller.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/project_model.dart';
import 'package:leadmanagementsystem/projects/project_details_page.dart';
import 'package:leadmanagementsystem/projects/projects_widget.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ProjectListPage extends StatefulWidget {
  String? projectId;
  String userId;

  bool findProjectsByUsers;

  ProjectListPage(
      {super.key,
      this.projectId,
      required this.findProjectsByUsers,
      required this.userId});

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  ReportController reportController = Get.put(ReportController());

  @override
  void initState() {
    super.initState();
    projectsController.getProjects(context);
  }

  Map<int, Widget> dataWidget = {
    0: const Text('My Projects'),
    1: const Text('Assign Projects'),
  };

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return widget.findProjectsByUsers == true
        ? GetBuilder(
            init: reportController,
            builder: (controller) {
              return Scaffold(
                appBar: mAppbar("Projects", action: [
                  InkWell(
                    onTap: () {
                      generateProjectPdf();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 30,
                        width: 40,
                        child: Image.asset(
                          "images/pdf.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ]),
                backgroundColor: Colors.white,
                body: SafeArea(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        children: [
                          if (reportController.projectsData.isEmpty)
                            const Center(
                                child:
                                    CircularProgressIndicator(color: appColor))
                          else
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Table(
                                columnWidths: const {
                                  0: FixedColumnWidth(150), // Project Name
                                  1: FixedColumnWidth(120), // Contractor
                                  2: FixedColumnWidth(120), // Consultant
                                  3: FixedColumnWidth(160), // Project Manager
                                  4: FixedColumnWidth(160), // Material Engr
                                  5: FixedColumnWidth(160), // Resident Engr
                                  6: FixedColumnWidth(
                                      160), // Consultant Material Engr
                                  7: FixedColumnWidth(100), // Status
                                  8: FixedColumnWidth(150), // Notes
                                  9: FixedColumnWidth(200), // Description
                                },
                                children: [
                                  buildProjectTableHeader(),
                                  ...buildProjectRows(
                                      reportController.projectsData),
                                ],
                              ),
                            ),
                        ],
                      )
                          .animate()
                          .untint()
                          .scale()
                          .move(delay: 100.ms, duration: 1600.ms),
                    ),
                  ),
                ),
              );
            })
        : Obx(() {
            return Scaffold(
              appBar: mAppbar("Projects"),
              body: projectsController.projectData.isEmpty
                  ? const Center(child: Text("No Project found"))
                  : Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              width: Get.width,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CupertinoSlidingSegmentedControl(
                                    padding: const EdgeInsets.all(10),
                                    children: dataWidget,
                                    groupValue: currentIndex,
                                    onValueChanged: (val) {
                                      currentIndex = val!;
                                      setState(() {});
                                    }),
                              ),
                            ),
                            if (currentIndex == 0)
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount:
                                    projectsController.projectData.length,
                                itemBuilder: (context, index) {
                                  final project =
                                      projectsController.projectData[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        // Handle project detail navigation
                                        Get.to(() => ProjectDetailsPage(
                                              project: project,
                                              updateProject: false,
                                              receverId: '',
                                              token: '',
                                              senderName: '',
                                            ));
                                      },
                                      child: ProjectsWidget(project: project),
                                    ),
                                  );
                                },
                              )
                            else
                              Obx(() {
                                return Column(children: [
                                  for (var l
                                      in projectsController.projectAssignData)
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: InkWell(
                                          onTap: () {
                                            Get.to(ProjectDetailsPage(
                                              updateProject: false,
                                              receverId: '',
                                              token: '',
                                              senderName: '',
                                              project: l,
                                            ));
                                          },
                                          child: ProjectsWidget(project: l)),
                                    )
                                ]);
                              })
                          ],
                        ),
                      ),
                    ),
              backgroundColor: Colors.grey[200],
              floatingActionButton: FloatingActionButton.extended(
                  onPressed: () {
                    Get.to(AddProjectPage(
                      reciverId: '',
                      token: '',
                      senderName: '',
                    ));
                  },
                  backgroundColor: appColor,
                  label: const Text(
                    "Add Project",
                  )),
            );
          });
  }

  TableRow buildProjectTableHeader() {
    return const TableRow(
      decoration: BoxDecoration(
        color: Color(0xFFE0E0E0),
      ),
      children: [
        TableHeaderCell('Project Name'),
        TableHeaderCell('Contractor'),
        TableHeaderCell('Consultant'),
        TableHeaderCell('Project Manager\n(Name Number Email)'),
        TableHeaderCell('Material Engr\n(Name Number Email)'),
        TableHeaderCell('Resident Engr\n(Name Number Email)'),
        TableHeaderCell('Consultant Material Engr\n(Name Number Email)'),
        TableHeaderCell('Project Status'),
        TableHeaderCell('Notes'),
        TableHeaderCell('Description'),
      ],
    );
  }

  List<TableRow> buildProjectRows(List<ProjectData> projects) {
    return projects.map((l) {
      return TableRow(
        children: [
          InkWell(
            onTap: () {
              Get.to(() => ProjectDetailsPage(
                    project: l,
                    updateProject: false,
                    receverId: '',
                    token: '',
                    senderName: '',
                  ));
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(l.title ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(l.contractorName ?? ''),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(l.consultantName ?? ''),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Text('${l.projectManager ?? ''}\n${l.contractorPMPhone ?? ''}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                '${l.contractorMEName ?? ''}\n${l.contractorMEPhone ?? ''}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                '${l.consultantREName ?? ''}\n${l.consultantREPhone ?? ''}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                '${l.consultantMEName ?? ''}\n${l.consultantMEPhone ?? ''}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(l.status ?? ''),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(l.notes ?? ''),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(l.description ?? ''),
          ),
        ],
      );
    }).toList();
  }

  void generateProjectPdf() async {
    final pdf = pw.Document();
    final projects = reportController.projectsData;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a3,
        build: (context) => [
          pw.Center(
            child: pw.Text('Project Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                )),
          ),
          pw.SizedBox(height: 20),

          // Custom Table
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: const pw.FixedColumnWidth(150),
              1: const pw.FixedColumnWidth(120),
              2: const pw.FixedColumnWidth(120),
              3: const pw.FixedColumnWidth(160),
              4: const pw.FixedColumnWidth(160),
              5: const pw.FixedColumnWidth(160),
              6: const pw.FixedColumnWidth(160),
              7: const pw.FixedColumnWidth(100),
              8: const pw.FixedColumnWidth(150),
              9: const pw.FixedColumnWidth(200),
            },
            children: [
              // Header Row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
                children: [
                  for (final title in [
                    'Project Name',
                    'Contractor',
                    'Consultant',
                    'Project Manager',
                    'Material Engr',
                    'Resident Engr',
                    'Consultant Material Engr',
                    'Status',
                    'Notes',
                    'Description'
                  ])
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(title,
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                              fontSize: 10)),
                    ),
                ],
              ),

              // Data Rows
              ...projects.map((project) {
                return pw.TableRow(
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(project.title ?? '',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(project.contractorName ?? '',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(project.consultantName ?? '',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                            '${project.projectManager ?? ''}\n${project.contractorPMPhone ?? ''}',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                            '${project.contractorMEName ?? ''}\n${project.contractorMEPhone ?? ''}',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                            '${project.consultantREName ?? ''}\n${project.consultantREPhone ?? ''}',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                            '${project.consultantMEName ?? ''}\n${project.consultantMEPhone ?? ''}',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(project.status ?? '',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(project.notes ?? '',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(project.description ?? '',
                            style: const pw.TextStyle(fontSize: 9))),
                  ],
                );
              }).toList(),
            ],
          ),

          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text('Generated on ${DateTime.now()}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          ),
        ],
      ),
    );

    final String path = (await getApplicationDocumentsDirectory()).path;
    final file = File('$path/projects.pdf');
    await file.writeAsBytes(await pdf.save());
    OpenFile.open(file.path);
  }
}

class TableHeaderCell extends StatelessWidget {
  final String title;

  const TableHeaderCell(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}

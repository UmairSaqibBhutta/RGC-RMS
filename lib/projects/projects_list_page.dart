import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/admin_module/add_project_page.dart';
import 'package:leadmanagementsystem/controllers/report_controller.dart';
import 'package:leadmanagementsystem/main.dart';
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
                    child: Column(
                      children: [
                        if (reportController.projectsData.isEmpty)
                          const Center(
                              child: CircularProgressIndicator(color: appColor))
                        else
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Table(
                              children: [
                                TableRow(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                  ),
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Title',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Client Name',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Status',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                for (var l in controller.projectsData)
                                  TableRow(
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
                                          child: Text(l.title!),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(l.clientName!),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(l.status!),
                                      ),
                                    ],
                                  ),
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

  void generateProjectPdf() async {
    final pdf = pw.Document();

    final projects = reportController.projectsData;

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Center(
            child: pw.Text('Project Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                )),
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            cellStyle: const pw.TextStyle(fontSize: 12),
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
            headers: ['Title', 'Client Name', 'Status'],
            data: projects
                .map((project) => [
                      project.title ?? '',
                      project.clientName ?? '',
                      project.status ?? ''
                    ])
                .toList(),
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

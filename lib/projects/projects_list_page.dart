import 'package:leadmanagementsystem/utils/dev_log.dart';
import 'dart:io';

import 'package:docx_template/docx_template.dart';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/admin_module/add_project_page.dart';
import 'package:leadmanagementsystem/constants/companies_strings.dart';
import 'package:leadmanagementsystem/controllers/filter_controller.dart';
import 'package:leadmanagementsystem/controllers/filter_variable_controller.dart';
import 'package:leadmanagementsystem/controllers/report_controller.dart';
import 'package:leadmanagementsystem/extensions/string_extensions.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/project_model.dart';
import 'package:leadmanagementsystem/projects/project_details_page.dart';
import 'package:leadmanagementsystem/projects/projects_widget.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/widgets/custom_text_field.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';
import 'package:leadmanagementsystem/widgets/debug_delete_project_tile.dart';
import 'package:leadmanagementsystem/widgets/random_widget.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ProjectListPage extends StatefulWidget {
  String? projectId;
  String userId;
  String? userName;

  bool findProjectsByUsers;

  ProjectListPage(
      {super.key,
      this.projectId,
      required this.findProjectsByUsers,
      required this.userName,
      required this.userId});

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  ReportController reportController = Get.put(ReportController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    projectsController.getProjects(context);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      // Only paginate when not in search or filter mode
      if (searchedProjects.isEmpty &&
          searchCont.text.isEmpty &&
          gvCompanies == null &&
          gvStatues == null) {
        final type = currentIndex == 0
            ? 'my'
            : currentIndex == 1
                ? 'assigned'
                : 'team';
        projectsController.loadMoreProjects(type);
      }
    }
  }

  Map<int, Widget> dataWidget = {
    0: const Text('My Projects'),
    1: const Text('Assigned'),
    2: const Text('Team'),
  };

  List<ProjectData> searchedProjects = [];
  FilterVariableController filterVariableController =
      Get.put(FilterVariableController());
  int currentIndex = 0;
  final searchCont = TextEditingController();
  String? gvCompanies;
  String? gvStatues;

  List<String> statuses = [
    'Lead',
    'Contracted',
    'Pitched',
    'Sent Sample',
    'Negotiating',
    'Closed-Won',
    'Closed-Lost',
    'Temporary Close'
  ];

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
                      generateProjectPdf(reportController.projectsData);
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
                  InkWell(
                    onTap: () {
                      generateProjectExcel(reportController.projectsData);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 30,
                        width: 40,
                        child: Image.asset(
                          "images/excel.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  // InkWell(
                  //   onTap: () {
                  //     generateProjectDocx();
                  //   },
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(8.0),
                  //     child: SizedBox(
                  //       height: 30,
                  //       width: 40,
                  //       child: Image.asset(
                  //         "images/word.png",
                  //         fit: BoxFit.contain,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ]),
                backgroundColor: Colors.white,
                body: SafeArea(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        children: [
                          if (widget.userName.isNotNullOrEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    "Projects of ${widget.userName}",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                      "Date: ${DateTime.now().toString().split(" ")[0]}",
                                      style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                          if (reportController.projectsData.isEmpty)
                            const Center(child: Text("No Projects found"))
                          else
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Table(
                                columnWidths: const {
                                  0: FixedColumnWidth(60), // Sr. No
                                  1: FixedColumnWidth(150), // Project Name
                                  2: FixedColumnWidth(120), // Contractor
                                  3: FixedColumnWidth(120), // Consultant
                                  4: FixedColumnWidth(160), // Project Manager
                                  5: FixedColumnWidth(160), // Material Engr
                                  6: FixedColumnWidth(160), // Resident Engr
                                  7: FixedColumnWidth(
                                      160), // Consultant Material Engr
                                  8: FixedColumnWidth(100), // Status
                                  9: FixedColumnWidth(100), // Status
                                  10: FixedColumnWidth(150), // Notes
                                  11: FixedColumnWidth(200), // Description
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
              appBar: mAppbar("Projects", action: [
                // GetBuilder<FilterVariableController>(
                //   init: filterVariableController,
                //   builder: (filter) {
                //     return InkWell(
                //       onTap: () {
                //         filter.onChanged();
                //       },
                //       child: Image.asset(
                //         'images/filter.png',
                //         width: 25,
                //         height: 25,
                //       ),
                //     );
                //   },
                // ),
                if (searchedProjects.isNotEmpty)
                  InkWell(
                    onTap: () {
                      generateProjectPdf(searchedProjects);
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
                if (searchedProjects.isNotEmpty)
                  InkWell(
                    onTap: () {
                      generateProjectExcel(searchedProjects);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 30,
                        width: 40,
                        child: Image.asset(
                          "images/excel.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(
                  width: 10,
                )
              ]),
              body: projectsController.myProjects.isEmpty
                  ? const Center(child: Text("No Project found"))
                  : Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: [
                            // const FilterUI(),
                            GetBuilder(
                                init: filterVariableController,
                                builder: (controller) {
                                  if (!controller.expand) {
                                    return Column(
                                      children: [
                                        const Text(
                                          "â“˜ Search projects by project creator, title, company, manager, contractor, client, consultant, location, status, notes or budget",
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 16),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: CustomTextField(
                                              controller: searchCont,
                                              hint:
                                                  "Search anything related to project",
                                              onChanged: (p0) {
                                                if (p0.isNotEmpty) {
                                                  searchProject();
                                                } else {
                                                  searchedProjects.clear();

                                                  setState(() {});
                                                }
                                              },
                                              suffix: Icons.clear,
                                              suffixOnTap: () {
                                                searchCont.clear();
                                                searchedProjects.clear();
                                                gvCompanies = null;
                                                gvStatues = null;
                                                setState(() {});
                                              },
                                            )),
                                        const SizedBox(height: 8),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: titleText(
                                            "Company :",
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            if (Company.getRoleBasedCompanies()
                                                .contains(Company.ROOFLINE))
                                              RadioWithImage(
                                                  groupValue: gvCompanies,
                                                  value: '1',
                                                  onChanged: (val) {
                                                    gvCompanies = val;
                                                    // gvStatues = null;

                                                    // searchCont.text = Company
                                                    //     .ROOFLINE
                                                    //     .toLowerCase();
                                                    searchProject();
                                                  },
                                                  image: 'roofline.jpg',
                                                  title: Company.ROOFLINE),
                                            if (Company.getRoleBasedCompanies()
                                                .contains(Company.RADIANT))
                                              RadioWithImage(
                                                  groupValue: gvCompanies,
                                                  value: '2',
                                                  onChanged: (val) {
                                                    gvCompanies = val;
                                                    // searchCont.text = Company
                                                    //     .RADIANT
                                                    //     .toLowerCase();

                                                    searchProject();
                                                  },
                                                  image: 'radiant.png',
                                                  title: Company.RADIANT),
                                            if (Company.getRoleBasedCompanies()
                                                .contains(Company.MAMZ))
                                              RadioWithImage(
                                                  groupValue: gvCompanies,
                                                  value: '3',
                                                  onChanged: (val) {
                                                    gvCompanies = val;
                                                    // searchCont.text = Company
                                                    //     .MAMZ
                                                    //     .toLowerCase();

                                                    searchProject();
                                                  },
                                                  image: 'mamz.png',
                                                  title: Company.MAMZ)
                                          ],
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: titleText(
                                            "Project Status :",
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: [
                                              for (var l in statuses)
                                                CustomRadioButton(
                                                  value: l,
                                                  groupValue: gvStatues,
                                                  title: l,
                                                  onChanged: (v) {
                                                    gvStatues = v;
                                                    // searchCont.text = v!;
                                                    // gvCompanies = null;
                                                    searchProject();
                                                  },
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (searchCont.text.isEmpty)
                                          SizedBox(
                                            width: Get.width,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child:
                                                  CupertinoSlidingSegmentedControl(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      children: dataWidget,
                                                      groupValue: currentIndex,
                                                      onValueChanged: (val) {
                                                        setState(() {
                                                          currentIndex = val!;
                                                        });
                                                      }),
                                            ),
                                          ),
                                        if (searchedProjects.isNotEmpty ||
                                            searchCont.text.isNotEmpty ||
                                            gvCompanies != null ||
                                            gvStatues != null)
                                          ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: searchedProjects.length,
                                            itemBuilder: (context, index) {
                                              final project =
                                                  searchedProjects[index];
                                              return DebugDeleteProjectTile(
                                                projectId: project.sId!,
                                                onDeleted: () => setState(() =>
                                                    searchedProjects.removeWhere(
                                                        (p) =>
                                                            p.sId ==
                                                            project.sId)),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8.0),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      // Handle project detail navigation
                                                      Get.to(() =>
                                                          ProjectDetailsPage(
                                                            projectId:
                                                                project.sId!,
                                                            updateProject:
                                                                false,
                                                            receverId: '',
                                                            token: '',
                                                            senderName: '',
                                                          ));
                                                    },
                                                    child: ProjectsWidget(
                                                        project:
                                                            ProjectCardModel
                                                                .fromProjectData(
                                                                    project)),
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        else if (currentIndex == 0)
                                          ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: projectsController
                                                .myProjects.length,
                                            itemBuilder: (context, index) {
                                              final project = projectsController
                                                  .myProjects[index];
                                              return DebugDeleteProjectTile(
                                                projectId: project.sId!,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8.0),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      // Handle project detail navigation
                                                      Get.to(() =>
                                                          ProjectDetailsPage(
                                                            projectId:
                                                                project.sId!,
                                                            updateProject:
                                                                false,
                                                            receverId: '',
                                                            token: '',
                                                            senderName: '',
                                                          ));
                                                    },
                                                    child: ProjectsWidget(
                                                        project: project),
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        else if (currentIndex == 1)
                                          ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: projectsController
                                                .assignedProjects.length,
                                            itemBuilder: (context, index) {
                                              final project = projectsController
                                                  .assignedProjects[index];
                                              return DebugDeleteProjectTile(
                                                projectId: project.sId!,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8.0),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      // Handle project detail navigation
                                                      Get.to(() =>
                                                          ProjectDetailsPage(
                                                            projectId:
                                                                project.sId!,
                                                            updateProject:
                                                                false,
                                                            receverId: '',
                                                            token: '',
                                                            senderName: '',
                                                          ));
                                                    },
                                                    child: ProjectsWidget(
                                                        project: project),
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        else
                                          Obx(() {
                                            return Column(children: [
                                              for (var l in projectsController
                                                  .teamProjects)
                                                DebugDeleteProjectTile(
                                                  projectId: l.sId!,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: InkWell(
                                                        onTap: () {
                                                          Get.to(
                                                              ProjectDetailsPage(
                                                            updateProject:
                                                                false,
                                                            receverId: '',
                                                            token: '',
                                                            senderName: '',
                                                            projectId: l.sId!,
                                                          ));
                                                        },
                                                        child: ProjectsWidget(
                                                            project: l)),
                                                  ),
                                                )
                                            ]);
                                          })
                                      ],
                                    );
                                  } else {
                                    return GetBuilder(
                                      init: FilterController(),
                                      builder: (controller) {
                                        return ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: controller
                                              .filteredProjectDataList.length,
                                          itemBuilder: (context, index) {
                                            final project = controller
                                                .filteredProjectDataList[index];
                                            return DebugDeleteProjectTile(
                                              projectId: project.sId!,
                                              onDeleted: () {
                                                controller
                                                    .filteredProjectDataList
                                                    .removeWhere((p) =>
                                                        p.sId == project.sId);
                                                controller.update();
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(vertical: 8.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Get.to(() =>
                                                        ProjectDetailsPage(
                                                          projectId:
                                                              project.sId!,
                                                          updateProject: true,
                                                          receverId: '',
                                                          token: '',
                                                          senderName: '',
                                                        ));
                                                  },
                                                  child: ProjectsWidget(
                                                      project: ProjectCardModel
                                                          .fromProjectData(
                                                              project)),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  }
                                }),
                            Obx(() {
                              final isLoading = currentIndex == 0
                                  ? projectsController
                                      .isLoadingMoreMyProjects.value
                                  : currentIndex == 1
                                      ? projectsController
                                          .isLoadingMoreAssigned.value
                                      : projectsController
                                          .isLoadingMoreTeam.value;
                              return isLoading
                                  ? const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      child: Center(child: AppLoader(size: 28)),
                                    )
                                  : const SizedBox.shrink();
                            }),
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

  void searchProject() {
    final lowerQuery = searchCont.text.toLowerCase().trim();
    String company = "";
    switch (gvCompanies) {
      case '1':
        company = Company.ROOFLINE;
        break;
      case '2':
        company = Company.RADIANT;
        break;
      case '3':
        company = Company.MAMZ;
        break;
      default:
        company = "";
    }
    final lowerCompany = company.toLowerCase().trim();
    final lowerStatus = (gvStatues ?? '').toLowerCase().trim();

    log("project search query = $lowerQuery, company = $lowerCompany, status = $lowerStatus");

    setState(() {
      searchedProjects = projectsController.allProjects.where((project) {
        final contractorName = (project.contractorName ?? '').toLowerCase();
        final contractorPMName = (project.contractorPMName ?? '').toLowerCase();
        final notes = (project.notes ?? '').toLowerCase();
        final description = (project.description ?? '').toLowerCase();
        final budget = (project.budget ?? '').toLowerCase();
        final title = (project.title ?? '').toLowerCase();
        final name = (project.name ?? '').toLowerCase();
        final projectManager = (project.projectManager ?? '').toLowerCase();
        final location = (project.location ?? '').toLowerCase();
        final clientName = (project.clientName ?? '').toLowerCase();
        final company = (project.company ?? '').toLowerCase();
        final consultantName = (project.consultantName ?? '').toLowerCase();
        final creatorName = (project.creatorName ?? '').toLowerCase();
        final consultantMEName = (project.consultantMEName ?? '').toLowerCase();
        final status = (project.status ?? '').toLowerCase();

        // âœ… Match text query (optional)
        final matchesQuery = lowerQuery.isEmpty ||
            contractorName.contains(lowerQuery) ||
            contractorPMName.contains(lowerQuery) ||
            notes.contains(lowerQuery) ||
            description.contains(lowerQuery) ||
            budget.contains(lowerQuery) ||
            title.contains(lowerQuery) ||
            name.contains(lowerQuery) ||
            projectManager.contains(lowerQuery) ||
            location.contains(lowerQuery) ||
            clientName.contains(lowerQuery) ||
            company.contains(lowerQuery) ||
            consultantName.contains(lowerQuery) ||
            creatorName.contains(lowerQuery) ||
            consultantMEName.contains(lowerQuery) ||
            status.contains(lowerQuery);

        // âœ… Company filter (only if selected)
        final matchesCompany =
            lowerCompany.isEmpty || company.contains(lowerCompany);

        // âœ… Status filter (only if selected)
        final matchesStatus =
            lowerStatus.isEmpty || status.contains(lowerStatus);

        // âœ… Combine all (ignore null/empty filters)
        return matchesQuery && matchesCompany && matchesStatus;
      }).toList();
    });
  }

  TableRow buildProjectTableHeader() {
    return const TableRow(
      decoration: BoxDecoration(
        color: Color(0xFFE0E0E0),
      ),
      children: [
        TableHeaderCell('Sr. No'),
        TableHeaderCell('Project Name'),
        TableHeaderCell('Contractor'),
        TableHeaderCell('Consultant'),
        TableHeaderCell('Project Manager'), //\n(Name Number Email)
        TableHeaderCell('Material Engr\n(Name Number Email)'),
        TableHeaderCell('Resident Engr\n(Name Number Email)'),
        TableHeaderCell('Consultant Material Engr\n(Name Number Email)'),
        TableHeaderCell('Project Status'),
        TableHeaderCell('Project Estimate'),
        TableHeaderCell('Notes'),
        TableHeaderCell('Description'),
      ],
    );
  }

  List<TableRow> buildProjectRows(List<ProjectData> projects) {
    projects = projectsController.sortProjectsByStatus(projects);
    return projects.asMap().entries.map((entry) {
      final index = entry.key + 1; // Sr. No starts from 1
      final l = entry.value;

      return TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(index.toString()), // Sr. No
          ),
          InkWell(
            onTap: () {
              Get.to(() => ProjectDetailsPage(
                    projectId: l.sId!,
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
            child: Text('${l.projectManager}'),
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
            child: Text(l.tentativeCost ?? ''),
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

  void generateProjectPdf(List<ProjectData> projectsData) async {
    final pdf = pw.Document();
    final projects = projectsController.sortProjectsByStatus(projectsData);

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

          pw.Padding(
            padding: const pw.EdgeInsets.all(8.0),
            child: pw.Text(
              widget.userName.isNotNullOrEmpty
                  ? "Projects of ${widget.userName}"
                  : "Projects",
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),

          // Custom Table with Serial Number
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: const pw.FixedColumnWidth(40), // Serial No.
              1: const pw.FixedColumnWidth(150),
              2: const pw.FixedColumnWidth(120),
              3: const pw.FixedColumnWidth(120),
              4: const pw.FixedColumnWidth(160),
              5: const pw.FixedColumnWidth(160),
              6: const pw.FixedColumnWidth(160),
              7: const pw.FixedColumnWidth(160),
              8: const pw.FixedColumnWidth(100),
              9: const pw.FixedColumnWidth(150),
              10: const pw.FixedColumnWidth(150),
              11: const pw.FixedColumnWidth(200),
            },
            children: [
              // Header Row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('#',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                            fontSize: 10)),
                  ),
                  for (final title in [
                    'Project Name',
                    'Contractor',
                    'Consultant',
                    'Project Manager',
                    'Material Engr',
                    'Resident Engr',
                    'Consultant Material Engr',
                    'Status',
                    'Project Estimate',
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
              ...projects.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final project = entry.value;
                return pw.TableRow(
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(index.toString(),
                            style: const pw.TextStyle(fontSize: 9))),
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
                            '${project.projectManager ?? ''}\n${project.projectManager ?? ''}',
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
                        child: pw.Text(project.tentativeCost ?? '',
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

  void generateProjectExcel(List<ProjectData> projectsData) async {
    final projects = projectsController.sortProjectsByStatus(projectsData);

    final excel = Excel.createExcel();
    final Sheet sheet = excel['Project Report'];

    // Title
    sheet.merge(CellIndex.indexByString("A1"), CellIndex.indexByString("J1"));
    sheet.updateCell(
      CellIndex.indexByString("A1"),
      TextCellValue('Project Report'),
      cellStyle: CellStyle(
        bold: true,
        fontSize: 18,
        horizontalAlign: HorizontalAlign.Center,
      ),
    );

    // User Name
    sheet.merge(CellIndex.indexByString("A2"), CellIndex.indexByString("J2"));
    sheet.updateCell(
      CellIndex.indexByString("A2"),
      widget.userName.isNotNullOrEmpty
          ? TextCellValue('Projects')
          : TextCellValue('Projects of ${widget.userName}'),
      cellStyle: CellStyle(
        bold: true,
        fontSize: 14,
      ),
    );

    // Header Row
    const headers = [
      'Project Name',
      'Contractor',
      'Consultant',
      'Project Manager',
      'Material Engr',
      'Resident Engr',
      'Consultant Material Engr',
      'Status',
      'Project Estimate',
      'Notes',
      'Description',
    ];

    for (int i = 0; i < headers.length; i++) {
      sheet.updateCell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 3),
        TextCellValue(headers[i]),
        cellStyle: CellStyle(
          backgroundColorHex: ExcelColor.fromHexString('#CCCCCC'),
          bold: true,
          horizontalAlign: HorizontalAlign.Center,
        ),
      );
    }

    // Data Rows
    for (int rowIndex = 0; rowIndex < projects.length; rowIndex++) {
      final project = projects[rowIndex];
      final row = rowIndex + 4;

      final data = [
        project.title ?? '',
        project.contractorName ?? '',
        project.consultantName ?? '',
        '${project.projectManager ?? ''}\n${project.projectManager ?? ''}',
        '${project.contractorMEName ?? ''}\n${project.contractorMEPhone ?? ''}',
        '${project.consultantREName ?? ''}\n${project.consultantREPhone ?? ''}',
        '${project.consultantMEName ?? ''}\n${project.consultantMEPhone ?? ''}',
        project.status ?? '',
        project.tentativeCost ?? '',
        project.notes ?? '',
        project.description ?? '',
      ];

      for (int col = 0; col < data.length; col++) {
        sheet.updateCell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
          TextCellValue(data[col]),
        );
      }
    }

    // Generated timestamp
    final lastRow = projects.length + 5;
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: lastRow),
      CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: lastRow),
    );
    sheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: lastRow),
      TextCellValue('Generated on ${DateTime.now()}'),
    );

    // Save file
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/projects.xlsx');
    await file.writeAsBytes(excel.encode()!);

    // Open file
    await OpenFile.open(file.path);
  }

  Future<void> generateProjectDocx() async {
    final bytes =
        (await rootBundle.load('assets/template.docx')).buffer.asUint8List();
    final docx = await DocxTemplate.fromBytes(bytes);
    final projects = reportController.projectsData;

    final List<RowContent> rows = projects.map((p) {
      return RowContent()
        ..add(TextContent('project_name', p.title ?? ''))
        ..add(TextContent('contractor', p.contractorName ?? ''))
        ..add(TextContent('consultant', p.consultantName ?? ''))
        ..add(TextContent('project_manager', p.projectManager ?? ''))
        ..add(TextContent('manager_phone', p.contractorPMPhone ?? ''))
        ..add(TextContent('material_engr', p.contractorMEName ?? ''))
        ..add(TextContent('material_phone', p.contractorMEPhone ?? ''))
        ..add(TextContent('resident_engr', p.consultantREName ?? ''))
        ..add(TextContent('resident_phone', p.consultantREPhone ?? ''))
        ..add(TextContent('consultant_material', p.consultantMEName ?? ''))
        ..add(
            TextContent('consultant_material_phone', p.consultantMEPhone ?? ''))
        ..add(TextContent('status', p.status ?? ''))
        ..add(TextContent('Project Estimate', p.tentativeCost ?? ''))
        ..add(TextContent('notes', p.notes ?? ''))
        ..add(TextContent('description', p.description ?? ''));
    }).toList();

    final c = Content()
      ..add(TextContent('report_title', 'Project Report'))
      ..add(TextContent('user_name', widget.userName ?? ""))
      ..add(TableContent('project_row', rows));

    final generated = await docx.generate(c, tagPolicy: TagPolicy.removeAll);

    if (generated == null) {
      throw Exception('Failed to generate docx');
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/projects_report.docx');
    await file.writeAsBytes(generated);

    // Optionally open it if you're using package like open_file:
    // OpenFile.open(file.path);
  }
}

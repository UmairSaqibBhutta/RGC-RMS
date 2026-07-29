import 'dart:developer';
import 'dart:io';

import 'package:docx_template/docx_template.dart';
import 'package:excel/excel.dart' hide Border;
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
import 'package:leadmanagementsystem/widgets/data_formatter.dart';
import 'package:leadmanagementsystem/widgets/random_widget.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// A single reportable column: a label plus a getter that pulls the
/// matching value out of a [ProjectData]. Used to build report tables,
/// PDF and Excel exports so all three always show the exact same set of
/// fields.
class _ProjectColumn {
  final String label;
  final String? Function(ProjectData) getValue;

  const _ProjectColumn(this.label, this.getValue);
}

/// Formats a raw (usually ISO-8601) date string using the app's shared
/// [DateFormatter], falling back to the raw value if it can't be parsed.
String? _formatReportDate(String? rawDate) {
  if (rawDate == null || rawDate.trim().isEmpty) return null;
  try {
    return DateFormatter.formatDate(rawDate);
  } catch (_) {
    return rawDate;
  }
}

/// Every field on [ProjectData] that is meaningful to show in a report,
/// in display order. Internal identifiers (sId, userId) and the local
/// attachment path are intentionally excluded.
final List<_ProjectColumn> _allProjectColumns = [
  _ProjectColumn('Project Name', (p) => p.title),
  _ProjectColumn('Name', (p) => p.name),
  _ProjectColumn('Description', (p) => p.description),
  _ProjectColumn('Status', (p) => p.status),
  _ProjectColumn('Company', (p) => p.company),
  _ProjectColumn('Location', (p) => p.location),
  _ProjectColumn('Region', (p) => p.region),
  _ProjectColumn('Project Estimate', (p) => p.tentativeCost),
  _ProjectColumn('Budget', (p) => p.budget),
  _ProjectColumn('Price Value', (p) => p.priceValue),
  _ProjectColumn('Project Priority', (p) => p.projectPriority),
  _ProjectColumn('Duration', (p) => p.duration),
  _ProjectColumn('Work Force', (p) => p.workForce),
  _ProjectColumn(
      'Created Date', (p) => _formatReportDate(p.projectCreatedDate)),
  _ProjectColumn('Client Name', (p) => p.clientName),
  _ProjectColumn('Project Manager', (p) => p.projectManager),
  _ProjectColumn('Contractor', (p) => p.contractorName),
  _ProjectColumn('Contractor PM Name', (p) => p.contractorPMName),
  _ProjectColumn('Contractor PM Phone', (p) => p.contractorPMPhone),
  _ProjectColumn('Contractor ME Name', (p) => p.contractorMEName),
  _ProjectColumn('Contractor ME Phone', (p) => p.contractorMEPhone),
  _ProjectColumn('Consultant', (p) => p.consultantName),
  _ProjectColumn('Consultant RE Name', (p) => p.consultantREName),
  _ProjectColumn('Consultant RE Phone', (p) => p.consultantREPhone),
  _ProjectColumn('Consultant ME Name', (p) => p.consultantMEName),
  _ProjectColumn('Consultant ME Phone', (p) => p.consultantMEPhone),
  _ProjectColumn('Consult Name', (p) => p.consultName),
  _ProjectColumn('Consult Phone', (p) => p.consultPhone),
  _ProjectColumn('Owner Name', (p) => p.ownerName),
  _ProjectColumn('Owner Contact', (p) => p.ownerContact),
  _ProjectColumn('Owner ME', (p) => p.ownerMe),
  _ProjectColumn('Person Name', (p) => p.personName),
  _ProjectColumn('Person Contacts', (p) => p.personContacts),
  _ProjectColumn('Procurement Name', (p) => p.precourmentName),
  _ProjectColumn('Procurement Phone', (p) => p.precourmentPhone),
  _ProjectColumn('Account Officer Name', (p) => p.accountOfficerName),
  _ProjectColumn('Account Officer Phone', (p) => p.accountOfficerPhone),
  _ProjectColumn('Role', (p) => p.role),
  _ProjectColumn('Creator Name', (p) => p.creatorName),
  _ProjectColumn('Creator Role', (p) => p.creatorRole),
  _ProjectColumn(
      'Work Scope',
      (p) => (p.workScope == null || p.workScope!.isEmpty)
          ? null
          : p.workScope!
              .map((w) => w.name ?? '')
              .where((n) => n.trim().isNotEmpty)
              .join(', ')),
  _ProjectColumn('Notes', (p) => p.notes),
];

/// Keeps only the columns that have a non-empty value in at least one
/// of the given projects, so an all-empty field (e.g. missing PM name)
/// never gets its own column.
List<_ProjectColumn> _visibleProjectColumns(List<ProjectData> projects) {
  return _allProjectColumns.where((column) {
    return projects.any((p) => (column.getValue(p) ?? '').trim().isNotEmpty);
  }).toList();
}

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
    _reportSearchCont.dispose();
    _reportZoomController.dispose();
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

  // Search box shown on the "projects of a user" report screen.
  final TextEditingController _reportSearchCont = TextEditingController();
  String _reportSearchQuery = '';

  /// Projects for the report screen after applying [_reportSearchQuery],
  /// matched against every reportable field on the project.
  List<ProjectData> get _reportDisplayedProjects {
    final all = reportController.projectsData;
    final query = _reportSearchQuery.trim().toLowerCase();
    if (query.isEmpty) return all;
    return all.where((project) {
      return _allProjectColumns.any(
          (column) => (column.getValue(project) ?? '').toLowerCase().contains(query));
    }).toList();
  }

  // Zoom controls for the report table (pinch-to-zoom + explicit buttons).
  static const double _minReportZoom = 0.5;
  static const double _maxReportZoom = 2.5;
  final TransformationController _reportZoomController =
      TransformationController();
  double _reportZoom = 1.0;

  void _setReportZoom(double zoom) {
    final clamped = zoom.clamp(_minReportZoom, _maxReportZoom);
    setState(() {
      _reportZoom = clamped;
      _reportZoomController.value = Matrix4.identity()..scale(clamped);
    });
  }

  void _zoomReportIn() => _setReportZoom(_reportZoom + 0.25);

  void _zoomReportOut() => _setReportZoom(_reportZoom - 0.25);

  void _resetReportZoom() => _setReportZoom(1.0);

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
              final displayedProjects = _reportDisplayedProjects;
              final columns = _visibleProjectColumns(displayedProjects);
              final sortedProjects =
                  projectsController.sortProjectsByStatus(displayedProjects);
              final hasSearch = _reportSearchQuery.trim().isNotEmpty;

              return Scaffold(
                appBar: mAppbar("Projects", action: [
                  InkWell(
                    onTap: displayedProjects.isEmpty
                        ? null
                        : () => generateProjectPdf(displayedProjects),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Opacity(
                        opacity: displayedProjects.isEmpty ? 0.4 : 1,
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
                  ),
                  InkWell(
                    onTap: displayedProjects.isEmpty
                        ? null
                        : () => generateProjectExcel(displayedProjects),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Opacity(
                        opacity: displayedProjects.isEmpty ? 0.4 : 1,
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
                  ),
                  const SizedBox(width: 8),
                ]),
                backgroundColor: Colors.grey[100],
                body: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.userName.isNotNullOrEmpty
                                  ? "Projects of ${widget.userName}"
                                  : "Projects",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                                "Date: ${DateTime.now().toString().split(" ")[0]}",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[600])),
                            const SizedBox(height: 12),
                            CustomTextField(
                              controller: _reportSearchCont,
                              hint: "Search projects",
                              suffix: _reportSearchCont.text.isNotEmpty
                                  ? Icons.clear
                                  : null,
                              suffixOnTap: () {
                                _reportSearchCont.clear();
                                setState(() => _reportSearchQuery = '');
                              },
                              onChanged: (value) {
                                setState(() => _reportSearchQuery = value);
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    hasSearch
                                        ? "${displayedProjects.length} of ${reportController.projectsData.length} projects match \"${_reportSearchQuery.trim()}\""
                                        : "${displayedProjects.length} project${displayedProjects.length == 1 ? '' : 's'}",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic),
                                  ),
                                ),
                                if (displayedProjects.isNotEmpty)
                                  _buildReportZoomControls(),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: displayedProjects.isEmpty
                            ? Center(
                                child: Text(
                                  reportController.projectsData.isEmpty
                                      ? "No Projects found"
                                      : "No projects match your search",
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(12),
                                child: InteractiveViewer(
                                  transformationController:
                                      _reportZoomController,
                                  constrained: false,
                                  minScale: _minReportZoom,
                                  maxScale: _maxReportZoom,
                                  boundaryMargin: const EdgeInsets.all(200),
                                  onInteractionEnd: (details) {
                                    setState(() {
                                      _reportZoom = _reportZoomController.value
                                          .getMaxScaleOnAxis();
                                    });
                                  },
                                  child: _buildReportTable(
                                          sortedProjects, columns)
                                      .animate()
                                      .fadeIn(duration: 300.ms)
                                      .move(
                                          begin: const Offset(0, 12),
                                          duration: 300.ms),
                                ),
                              ),
                      ),
                    ],
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
                                          "ⓘ Search projects by project creator, title, company, manager, contractor, client, consultant, location, status, notes or budget",
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
                                              suffix: searchCont.text.isNotEmpty
                                                  ? Icons.clear
                                                  : null,
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
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    // Handle project detail navigation
                                                    Get.to(() =>
                                                        ProjectDetailsPage(
                                                          project: project,
                                                          updateProject: false,
                                                          receverId: '',
                                                          token: '',
                                                          senderName: '',
                                                        ));
                                                  },
                                                  child: ProjectsWidget(
                                                      project: project),
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
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    // Handle project detail navigation
                                                    Get.to(() =>
                                                        ProjectDetailsPage(
                                                          project: project,
                                                          updateProject: false,
                                                          receverId: '',
                                                          token: '',
                                                          senderName: '',
                                                        ));
                                                  },
                                                  child: ProjectsWidget(
                                                      project: project),
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
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    // Handle project detail navigation
                                                    Get.to(() =>
                                                        ProjectDetailsPage(
                                                          project: project,
                                                          updateProject: false,
                                                          receverId: '',
                                                          token: '',
                                                          senderName: '',
                                                        ));
                                                  },
                                                  child: ProjectsWidget(
                                                      project: project),
                                                ),
                                              );
                                            },
                                          )
                                        else
                                          Obx(() {
                                            return Column(children: [
                                              for (var l in projectsController
                                                  .teamProjects)
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: InkWell(
                                                      onTap: () {
                                                        Get.to(
                                                            ProjectDetailsPage(
                                                          updateProject: false,
                                                          receverId: '',
                                                          token: '',
                                                          senderName: '',
                                                          project: l,
                                                        ));
                                                      },
                                                      child: ProjectsWidget(
                                                          project: l)),
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
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Get.to(
                                                      () => ProjectDetailsPage(
                                                            project: project,
                                                            updateProject: true,
                                                            receverId: '',
                                                            token: '',
                                                            senderName: '',
                                                          ));
                                                },
                                                child: ProjectsWidget(
                                                    project: project),
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
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
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

        // ✅ Match text query (optional)
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

        // ✅ Company filter (only if selected)
        final matchesCompany =
            lowerCompany.isEmpty || company.contains(lowerCompany);

        // ✅ Status filter (only if selected)
        final matchesStatus =
            lowerStatus.isEmpty || status.contains(lowerStatus);

        // ✅ Combine all (ignore null/empty filters)
        return matchesQuery && matchesCompany && matchesStatus;
      }).toList();
    });
  }

  /// Zoom out / percentage / zoom in / reset controls for the report
  /// table. Kept in sync with pinch-to-zoom via [_reportZoomController].
  Widget _buildReportZoomControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Zoom out',
          visualDensity: VisualDensity.compact,
          onPressed: _reportZoom <= _minReportZoom ? null : _zoomReportOut,
          icon: const Icon(Icons.zoom_out),
        ),
        SizedBox(
          width: 46,
          child: Text(
            '${(_reportZoom * 100).round()}%',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ),
        IconButton(
          tooltip: 'Zoom in',
          visualDensity: VisualDensity.compact,
          onPressed: _reportZoom >= _maxReportZoom ? null : _zoomReportIn,
          icon: const Icon(Icons.zoom_in),
        ),
        IconButton(
          tooltip: 'Reset zoom',
          visualDensity: VisualDensity.compact,
          onPressed: _reportZoom == 1.0 ? null : _resetReportZoom,
          icon: const Icon(Icons.restart_alt),
        ),
      ],
    );
  }

  /// Builds the report table showing only [columns] that actually have
  /// data across [projects], so a field left blank on every project
  /// (e.g. no Project Manager set anywhere) never gets its own column.
  Widget _buildReportTable(
      List<ProjectData> projects, List<_ProjectColumn> columns) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.shade200),
          verticalInside: BorderSide(color: Colors.grey.shade200),
        ),
        columnWidths: {
          0: const FixedColumnWidth(56),
          for (int i = 0; i < columns.length; i++)
            i + 1: const FixedColumnWidth(180),
        },
        children: [
          _buildReportHeaderRow(columns),
          ...projects.asMap().entries.map((entry) =>
              _buildReportDataRow(entry.key + 1, entry.value, columns)),
        ],
      ),
    );
  }

  TableRow _buildReportHeaderRow(List<_ProjectColumn> columns) {
    return TableRow(
      decoration: const BoxDecoration(color: appColor),
      children: [
        _reportHeaderCell('#'),
        for (final column in columns) _reportHeaderCell(column.label),
      ],
    );
  }

  Widget _reportHeaderCell(String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      );

  TableRow _buildReportDataRow(
      int index, ProjectData project, List<_ProjectColumn> columns) {
    return TableRow(
      decoration: BoxDecoration(
        color: index.isEven ? Colors.grey.shade50 : Colors.white,
      ),
      children: [
        _reportDataCell(index.toString()),
        for (final column in columns)
          column.label == 'Project Name'
              ? InkWell(
                  onTap: () {
                    Get.to(() => ProjectDetailsPage(
                          project: project,
                          updateProject: false,
                          receverId: '',
                          token: '',
                          senderName: '',
                        ));
                  },
                  child: _reportDataCell(column.getValue(project) ?? '',
                      isLink: true),
                )
              : _reportDataCell(column.getValue(project) ?? ''),
      ],
    );
  }

  Widget _reportDataCell(String text, {bool isLink = false}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isLink ? appColor : Colors.black87,
            fontWeight: isLink ? FontWeight.w600 : FontWeight.normal,
            decoration: isLink ? TextDecoration.underline : null,
          ),
        ),
      );

  void generateProjectPdf(List<ProjectData> projectsData) async {
    final pdf = pw.Document();
    final projects = projectsController.sortProjectsByStatus(projectsData);
    final columns = _visibleProjectColumns(projectsData);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a3.landscape,
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

          // Table with Serial Number + only the columns that have data.
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: const pw.FixedColumnWidth(30), // Serial No.
              for (int i = 0; i < columns.length; i++)
                i + 1: const pw.FlexColumnWidth(1),
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
                            fontSize: 8)),
                  ),
                  for (final column in columns)
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(column.label,
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                              fontSize: 8)),
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
                            style: const pw.TextStyle(fontSize: 8))),
                    for (final column in columns)
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(column.getValue(project) ?? '',
                              style: const pw.TextStyle(fontSize: 8))),
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
    final columns = _visibleProjectColumns(projectsData);
    final lastColIndex = columns.isEmpty ? 0 : columns.length - 1;

    final excel = Excel.createExcel();
    final Sheet sheet = excel['Project Report'];

    // Title
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: lastColIndex, rowIndex: 0),
    );
    sheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      TextCellValue('Project Report'),
      cellStyle: CellStyle(
        bold: true,
        fontSize: 18,
        horizontalAlign: HorizontalAlign.Center,
      ),
    );

    // User Name
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      CellIndex.indexByColumnRow(columnIndex: lastColIndex, rowIndex: 1),
    );
    sheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      widget.userName.isNotNullOrEmpty
          ? TextCellValue('Projects of ${widget.userName}')
          : TextCellValue('Projects'),
      cellStyle: CellStyle(
        bold: true,
        fontSize: 14,
      ),
    );

    // Header Row — only the columns that actually have data.
    for (int i = 0; i < columns.length; i++) {
      sheet.updateCell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 3),
        TextCellValue(columns[i].label),
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

      for (int col = 0; col < columns.length; col++) {
        sheet.updateCell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
          TextCellValue(columns[col].getValue(project) ?? ''),
        );
      }
    }

    // Generated timestamp
    final lastRow = projects.length + 5;
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: lastRow),
      CellIndex.indexByColumnRow(columnIndex: lastColIndex, rowIndex: lastRow),
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

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/admin_module/add_project_page.dart';
import 'package:leadmanagementsystem/bottom_nav_screen.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/constants/launchers_helper.dart';
import 'package:leadmanagementsystem/constants/user_roles.dart';
import 'package:leadmanagementsystem/controllers/project_controller.dart';
import 'package:leadmanagementsystem/controllers/login_controller.dart';
import 'package:leadmanagementsystem/controllers/update_project_controller.dart';
import 'package:leadmanagementsystem/extensions/string_extensions.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/project_model.dart';
import 'package:leadmanagementsystem/screens/login_screen.dart';
import 'package:leadmanagementsystem/widgets/custom_button.dart';
import 'package:leadmanagementsystem/widgets/custom_decoration_container.dart';
import 'package:leadmanagementsystem/widgets/custom_text_field.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';
import 'package:leadmanagementsystem/widgets/follow_up_form.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

import '../constants/companies_strings.dart';

class ProjectDetailsPage extends StatefulWidget {
  final String projectId;

  String receverId;
  String senderName;
  String token;

  bool updateProject;

  ProjectDetailsPage(
      {super.key,
      required this.projectId,
      required this.updateProject,
      required this.receverId,
      required this.senderName,
      required this.token});

  @override
  _ProjectDetailsPageState createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  bool _isNotesExpanded = false;
  bool _isDescriptionExpanded = false;

  static const int maxTextLength = 100; // The threshold for showing "Show more"

  final projectCont = Get.find<ProjectController>();

  LoginController loginController = Get.find();

  late final UpdateProjectController updateProjectCont;

  /// Snapshot of the currently loaded project, set once per build after the
  /// `project-detail/:id` fetch resolves. See build()'s loading/error gating.
  late ProjectData _project;

  @override
  void initState() {
    super.initState();
    updateProjectCont = Get.isRegistered<UpdateProjectController>()
        ? Get.find()
        : Get.put(UpdateProjectController());
    updateProjectCont.getProjectById(widget.projectId);

    if (loginStorage.getUserRole() != UserRole.NEW_RECRUITS) {
      loginController.getMyAssignableUsers();
    }

    if (loginStorage.getUserRole() != UserRole.CEO) {
      loginController.getHigherRoleUsers();
    }

    projectCont.getAssignedProjectUserList(widget.projectId, context);
  }

  String? name;
  String? role;
  String? recieverId;

  String? assignFcmToken;

  @override
  dispose() {
    super.dispose();

    projectCont.projectselectedUsers.clear();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UpdateProjectController>(
      init: updateProjectCont,
      builder: (cont) {
        final fetchedProject = cont.projectUpdateModel?.updateProjectData;

        if (fetchedProject == null) {
          if (cont.isProjectDetailLoading) {
            return Scaffold(
              appBar: mAppbar('Project Details', leading: _backButton(context)),
              body: pleaseWaitLoader(),
            );
          }
          return Scaffold(
            appBar: mAppbar('Project Details', leading: _backButton(context)),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text(
                      "Project not found",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          updateProjectCont.getProjectById(widget.projectId),
                      style:
                          ElevatedButton.styleFrom(backgroundColor: appColor),
                      child: const Text('Retry',
                          style: TextStyle(color: whiteColor)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        _project = fetchedProject;

        return _buildLoadedScaffold(context);
      },
    );
  }

  Widget _buildLoadedScaffold(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: mAppbar("${_project.title} details",
          leading: _backButton(context),
          action: [
            widget.updateProject == true ||
                    loginStorage.getUserId() == _project.userId
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: () {
                          Get.to(AddProjectPage(
                            projectData: _project,
                            reciverId: widget.receverId,
                            token: widget.token,
                            senderName: widget.senderName,
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: appColor,
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 0),
                        child: const Text('Update Project')),
                  )
                : const SizedBox.shrink()
          ]),
      body: CustomDecorationContainer(
          child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(context),
                _buildProjectStatus(context),
                widget.updateProject == true
                    ? const SizedBox.shrink()
                    : const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
                        child: Text(
                          'Assign To ',
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 18),
                        ),
                      ),
                GetBuilder<ProjectController>(
                  init: projectCont,
                  builder: (projectCont) {
                    if (!projectCont.isAssigneesLoaded) {
                      return showSpinkit();
                    }

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      child: GetBuilder<LoginController>(
                        init: loginController,
                        builder: (controller) {
                          log("Pre-selected Users: ${projectCont.projectselectedUsers}");

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: MultiSelectDialogField(
                              // ✅ Ensure initial value is a list of valid user IDs
                              initialValue: List<String>.from(
                                  projectCont.projectselectedUsers),

                              isDismissible: true,
                              dialogHeight: Get.height * .5,
                              searchable: true,
                              searchHint: "Search",
                              items: controller.assignableUsersList
                                  .where((e) =>
                                      loginStorage.getUserName() != e.name)
                                  .map((e) => MultiSelectItem<String>(
                                      e.sId!, "${e.name} - ${e.role}"))
                                  .toList(),
                              title: const Text("Assign Project To"),
                              selectedColor: appColor,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: Colors.black45, width: 1),
                              ),
                              buttonIcon: const Icon(
                                CupertinoIcons.chevron_down,
                                color: Colors.black54,
                              ),
                              buttonText: const Text(
                                  "Select Users to assign project",
                                  style: TextStyle(color: Colors.black54)),

                              onConfirm: (values) async {
                                log("Selected Users: $values");

                                // ✅ Prevent duplicate selections
                                projectCont.projectselectedUsers.clear();
                                projectCont.projectselectedUsers.addAll(values);

                                projectCont.update(); // ✅ Refresh UI

                                Map<String, dynamic> body = {
                                  'senderUserId': loginStorage.getUserId(),
                                  'senderName': loginStorage.getUserName(),
                                  'receiverUserIds':
                                      projectCont.projectselectedUsers,
                                  'projectId': _project.sId,
                                  'assignStatus': true,
                                };

                                log("Assigning project to: $body");
                                await projectCont.assignProject(context, body);

                                await projectCont.getAssignedProjectUserList(
                                    _project.sId!, context);
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                // widget.updateProject == true
                //     ? const SizedBox.shrink()
                //     : GetBuilder(
                //         init: projectCont,
                //         builder: (project) {
                //           return project.assignmentLoader == true
                //               ? const Center(
                //                   child: CircularProgressIndicator())
                //               : Padding(
                //                   padding: const EdgeInsets.symmetric(
                //                       horizontal: 15.0),
                //                   child: project.assignmentLoader
                //                       ? const CupertinoActivityIndicator(
                //                           color: appColor,
                //                         )
                //                       : project.projectAssign?.projectId !=
                //                                   null &&
                //                               project.projectAssign != null
                //                           ? Padding(
                //                               padding: const EdgeInsets.only(
                //                                   top: 8.0),
                //                               child: Row(
                //                                 children: [
                //                                   const Icon(CupertinoIcons
                //                                       .check_mark_circled),
                //                                   const SizedBox(width: 10),
                //                                   Text(
                //                                     'Project Assigned To ${project.projectAssign?.recieverName}:     ',
                //                                     style: const TextStyle(
                //                                         fontSize: 18,
                //                                         fontWeight:
                //                                             FontWeight.w500),
                //                                   ),
                //                                 ],
                //                               ),
                //                             )
                //                           : Card(
                //                               shape: RoundedRectangleBorder(
                //                                   borderRadius:
                //                                       BorderRadius.circular(
                //                                           10),
                //                                   side: const BorderSide(
                //                                       color: Colors.black45)),
                //                               elevation: 10,
                //                               child: GetBuilder(
                //                                   init: loginController,
                //                                   builder: (controller) {
                //                                     return Padding(
                //                                       padding:
                //                                           const EdgeInsets
                //                                               .all(8.0),
                //                                       child: DropdownButton(
                //                                           underline:
                //                                               const SizedBox
                //                                                   .shrink(),
                //                                           isExpanded: true,
                //                                           hint: Text(
                //                                               '${name ?? 'Select Name'} ${role ?? '&& Role'}' ??
                //                                                   'Select Name'),
                //                                           items: controller
                //                                               .assignableUsersList
                //                                               .map((e) {
                //                                             return DropdownMenuItem(
                //                                                 onTap:
                //                                                     () async {
                //                                                   name =
                //                                                       e.name;
                //                                                   role =
                //                                                       e.role;
                //                                                   assignFcmToken =
                //                                                       e.fcmToken;
                //                                                   recieverId =
                //                                                       e.sId;

                //                                                   Map<String,
                //                                                           dynamic>
                //                                                       body = {
                //                                                     'senderUserId':
                //                                                         loginStorage
                //                                                             .getUserId(),
                //                                                     'senderName':
                //                                                         loginStorage
                //                                                             .getUserName(),
                //                                                     'reciverUserId':
                //                                                         recieverId,
                //                                                     'recieverName':
                //                                                         name,
                //                                                     'projectId': widget
                //                                                         .project
                //                                                         .sId,
                //                                                     "type":
                //                                                         "Project",
                //                                                     'assignStatus':
                //                                                         true,
                //                                                     'senderFcmToken':
                //                                                         assignFcmToken
                //                                                   };

                //                                                   print(
                //                                                       'body--->$body');

                //                                                   await project
                //                                                       .assignTaskOrProject(
                //                                                           context,
                //                                                           body);

                //                                                   project.getRecieveProjectFunction(
                //                                                       widget
                //                                                           .project
                //                                                           .sId!,
                //                                                       context);

                //                                                   setState(
                //                                                       () {});
                //                                                 },
                //                                                 value: e.name,
                //                                                 child: Text(loginStorage
                //                                                             .getUserName() ==
                //                                                         e.name
                //                                                     ? ''
                //                                                     : e.name
                //                                                         .toString()));
                //                                           }).toList(),
                //                                           onChanged: (_) {}),
                //                                     );
                //                                   }),
                //                             ),
                //                 );
                //         }),
                // widget.updateProject == true ||
                //         loginStorage.getUserRole() == UserRole.CEO
                //     ? const SizedBox.shrink()
                //     : requestForUpdateProject(),
                // if (_project.company.isNotNullOrEmpty)
                _buildProjectInfo(context),
                _buildAdditionalInfo(context),
                if (_project.description.isNotNullOrEmpty)
                  _buildExpandableSection(
                      context,
                      "Description",
                      _project.description!,
                      _isDescriptionExpanded, (expanded) {
                    setState(() {
                      _isDescriptionExpanded = expanded;
                    });
                  }),
                if (_project.notes.isNotNullOrEmpty)
                  _buildExpandableSection(
                      context, "Notes", _project.notes!, _isNotesExpanded,
                      (expanded) {
                    setState(() {
                      _isNotesExpanded = expanded;
                    });
                  }),
                if (_project.filePath.isNotNullOrEmpty)
                  const SizedBox(height: 10),
                if (_project.filePath.isNotNullOrEmpty)
                  _buildFileDownloadButton(),
                const SizedBox(height: 12),
                _buildFollowUpsSection(context),
                const SizedBox(height: 12),
                GetBuilder<ProjectController>(
                  init: projectCont,
                  builder: (controller) {
                    return FollowUpForm(
                      isLoading: controller.followUpLoader,
                      onSubmit: (text, image) async {
                        final success = await controller.addProjectFollowUp(
                          projectId: _project.sId!,
                          text: text,
                          image: image,
                        );
                        if (success) {
                          await updateProjectCont
                              .getProjectById(widget.projectId);
                        }
                        return success;
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ).animate().fade().scale().move(delay: 300.ms, duration: 600.ms),
      )),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _project.title!,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Client Name: ${_project.clientName}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        if (Navigator.canPop(context)) {
          Get.back();
        } else {
          Get.offAll(() => const BottomNavScreen());
        }
      },
    );
  }

  Widget _buildFollowUpsSection(BuildContext context) {
    final followUps = _project.followUp ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Follow Ups',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: appColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${followUps.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: appColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (followUps.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE9EAEC)),
              ),
              child: const Text(
                'No follow ups yet.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            )
          else
            for (final followUp in followUps.reversed)
              _buildFollowUpTile(followUp),
        ],
      ),
    );
  }

  Widget _buildFollowUpTile(FollowUp followUp) {
    final name = followUp.user?.name;
    final hasName = name.isNotNullOrEmpty;
    final initial = hasName ? name!.substring(0, 1).toUpperCase() : '?';
    final createdAt = followUp.createdAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: appColor.withValues(alpha: 0.15),
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: appColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasName ? name! : 'Unknown',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (createdAt != null)
                Text(
                  DateFormat('MMM d, h:mm a').format(createdAt),
                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                ),
            ],
          ),
          if (followUp.text.isNotNullOrEmpty) ...[
            const SizedBox(height: 8),
            Text(
              followUp.text!,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ],
          if (followUp.image.isNotNullOrEmpty) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              // Same `baseUrl + <path>` convention used for chat images
              // (see chat_page.dart) — the API returns a bare filename here.
              child: Image.network(
                baseUrl + followUp.image!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? selectName;
  String? recieverIdProject;
  String? fcmToken;

  bool isExpand = false;

  TextEditingController commentController = TextEditingController();

  Widget requestForUpdateProject() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              isExpand = !isExpand;
              setState(() {});
            },
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const Text(
                            'Request for update project',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Icon(isExpand != true
                              ? Icons.arrow_downward
                              : Icons.arrow_upward)
                        ],
                      ),
                    ),
                    isExpand != true
                        ? const SizedBox.shrink()
                        : const SizedBox(height: 8),
                    isExpand != true
                        ? const SizedBox()
                        : GetBuilder(
                            init: loginController,
                            builder: (controller) {
                              return controller.userRegionData.isEmpty
                                  ? const Center(
                                      child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: AppLoader(size: 32),
                                    ))
                                  : Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                                side: const BorderSide(
                                                    color: Colors.black45),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 5),
                                              child: DropdownButton(
                                                  underline: const SizedBox(),
                                                  hint: Text(selectName == null
                                                      ? 'Select a User for Project Update Request'
                                                      : selectName.toString()),
                                                  isExpanded: true,
                                                  items: loginController
                                                      .userRegionData
                                                      .map((e) {
                                                    return DropdownMenuItem(
                                                        onTap: () async {
                                                          selectName = e.name;
                                                          recieverIdProject =
                                                              e.sId;

                                                          fcmToken = e.fcmToken;

                                                          print(
                                                              'selectName--->$selectName');
                                                          setState(() {});
                                                        },
                                                        value:
                                                            e.name.toString(),
                                                        child: Text(
                                                            e.name.toString()));
                                                  }).toList(),
                                                  onChanged: (_) {}),
                                            ),
                                          ),
                                        ),
                                        isExpand != true
                                            ? const SizedBox.shrink()
                                            : const SizedBox(height: 5),
                                        isExpand != true
                                            ? const SizedBox.shrink()
                                            : CustomTextField(
                                                hint: 'Comment',
                                                controller: commentController,
                                                prefixIcon: Icons.text_fields,
                                              ),
                                        controller.loaderData == true
                                            ? const AppLoader(size: 32)
                                            : SizedBox(
                                                width: 160,
                                                child: CustomButton(
                                                  title: 'Send Request',
                                                  fullWidth: false,
                                                  height: 40,
                                                  onTap: () {
                                                    controller
                                                        .sendProjectUpdateNotification(
                                                            recieverIdProject,
                                                            _project.sId,
                                                            commentController
                                                                .text
                                                                .trim(),
                                                            fcmToken!,
                                                            selectName);
                                                  },
                                                ),
                                              )
                                      ],
                                    );
                            }),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _downloadFile(String fileUrl) async {
    UrlLauncherHelper.launchURL(fileUrl);
    // await launchUrl(Uri.parse(fileUrl), mode: LaunchMode.externalApplication);

    print('Downloading file from: $fileUrl');
  }

  Widget _buildProjectStatus(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(CupertinoIcons.flag_fill,
                    size: 28, color: Colors.blue),
                const SizedBox(width: 10),
                const Text(
                  'Status:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Text(
                  _project.status!,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                ),
              ],
            ),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              color: Theme.of(context).primaryColor,
              onPressed: () => _updateProjectStatus(context),
              borderRadius: BorderRadius.circular(20),
              child: const Text(
                'Update',
                style: TextStyle(color: whiteColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          // if (_project.personName != null)
          if (_project.company.isNotNullOrEmpty)
            Stack(
              children: [
                _buildInfoCard(
                  context,
                  "Company",
                  _project.company!,
                  CupertinoIcons.building_2_fill, // Keep as is or change
                  Colors.purple,
                ),
                Positioned(
                    top: 30,
                    right: 40,
                    child: Image.asset(
                      Company.getCompanyLogo(_project.company!),
                      height: 40,
                      width: 40,
                    )),
              ],
            ),
          if (_project.creatorName.isNotNullOrEmpty &&
              _project.creatorRole.isNotNullOrEmpty)
            _buildInfoCard(
              context,
              "Project Created By",
              "${_project.creatorName} - ${_project.creatorRole}",
              Icons.account_circle, // Updated icon for person name
              Colors.teal,
            ),
          if (_project.consultantName.isNotNullOrEmpty)
            _buildInfoCard(
              context,
              "Consultant Name",
              "${_project.consultantName} ",
              Icons.account_circle, // Updated icon for person name
              Colors.teal,
            ),
          if (_project.consultantREName.isNotNullOrEmpty)
            _buildInfoCard(
              context,
              "Consultant RE (Resident Engineer)",
              "${_project.consultantREName} ",
              Icons.engineering, // Changed to match engineering role
              Colors.teal,
            ),
          if (_project.consultantREPhone.isNotNullOrEmpty)
            InkWell(
              onTap: () =>
                  UrlLauncherHelper.makePhoneCall(_project.consultantREPhone!),
              child: _buildInfoCard(
                context,
                "Consultant RE Phone",
                "${_project.consultantREPhone} ",
                Icons.phone,
                Colors.teal,
              ),
            ),
          if (_project.consultantMEName.isNotNullOrEmpty)
            _buildInfoCard(
              context,
              "Consultant ME (Material Engineer)",
              "${_project.consultantMEName} ",
              Icons.engineering, // Changed to match engineering role
              Colors.teal,
            ),
          if (_project.consultantMEPhone.isNotNullOrEmpty)
            InkWell(
              onTap: () =>
                  UrlLauncherHelper.makePhoneCall(_project.consultantMEPhone!),
              child: _buildInfoCard(
                context,
                "Consultant ME Phone",
                "${_project.consultantMEPhone}",
                Icons.phone, // Changed to phone icon
                Colors.teal,
              ),
            ),
          if (_project.contractorName.isNotNullOrEmpty)
            _buildInfoCard(
              context,
              "Contractor Name",
              "${_project.contractorName} ",
              Icons.business, // Changed to business icon
              Colors.teal,
            ),
          if (_project.contractorMEName.isNotNullOrEmpty)
            _buildInfoCard(
              context,
              "Contractor ME (Material Engineer) ",
              "${_project.contractorMEName} ",
              Icons.precision_manufacturing,
              Colors.teal,
            ),
          if (_project.contractorMEPhone.isNotNullOrEmpty)
            InkWell(
              onTap: () =>
                  UrlLauncherHelper.makePhoneCall(_project.contractorMEPhone!),
              child: _buildInfoCard(
                context,
                "Contractor ME Phone",
                "${_project.contractorMEPhone} ",
                Icons.phone,
                Colors.teal,
              ),
            ),
          if (_project.contractorPMName.isNotNullOrEmpty)
            _buildInfoCard(
              context,
              "Contractor PM (Project Manager)",
              "${_project.contractorPMName} ",
              Icons.engineering,
              Colors.teal,
            ),
          if (_project.contractorPMPhone.isNotNullOrEmpty)
            InkWell(
              onTap: () =>
                  UrlLauncherHelper.makePhoneCall(_project.contractorPMPhone!),
              child: _buildInfoCard(
                context,
                "Contractor PM Phone",
                "${_project.contractorPMPhone} ",
                Icons.phone,
                Colors.teal,
              ),
            ),
          if (_project.budget.isNotNullOrEmpty)
            _buildInfoCard(
              context,
              "Budget",
              formatAmount(double.parse(_project.budget!)),
              Icons.currency_rupee,
              Colors.green,
            ),
          if (_project.tentativeCost.isNotNullOrEmpty)
            _buildInfoCard(
              context,
              "Tentative Cost",
              formatAmount(double.parse(_project.tentativeCost!)),
              Icons.currency_rupee,
              Colors.red,
            ),
          if (_project.workForce.isNotNullOrEmpty)
            _buildInfoCard(
              context,
              "Workforce",
              "${_project.workForce} ",
              Icons.group, // Changed to group icon
              Colors.teal,
            ),
          if (_project.precourmentName.isNotNullOrEmpty)
            _buildInfoCard(
              context,
              "Procurement Officer Name",
              "${_project.precourmentName} ",
              Icons.person, // Changed to person icon
              Colors.teal,
            ),
          if (_project.precourmentPhone.isNotNullOrEmpty)
            InkWell(
              onTap: () =>
                  UrlLauncherHelper.makePhoneCall(_project.precourmentPhone!),
              child: _buildInfoCard(
                context,
                "Procurement Officer Phone",
                "${_project.precourmentPhone} ",
                Icons.phone, // Changed to phone icon
                Colors.teal,
              ),
            ),
          if (_project.accountOfficerName.isNotNullOrEmpty)
            _buildInfoCard(
              context,
              "Account Officer Name",
              "${_project.accountOfficerName} ",
              Icons.person, // Changed to person icon
              Colors.teal,
            ),
          if (_project.accountOfficerPhone.isNotNullOrEmpty)
            InkWell(
              onTap: () => UrlLauncherHelper.makePhoneCall(
                  _project.accountOfficerPhone!),
              child: _buildInfoCard(
                context,
                "Account Officer Phone",
                "${_project.accountOfficerPhone} ",
                Icons.phone, // Changed to phone icon
                Colors.teal,
              ),
            ),
          if (_project.duration.isNotNullOrEmpty)
            if (_project.duration != null)
              _buildInfoCard(
                context,
                "Duration",
                _project.duration!,
                Icons.timer, // Changed to timer icon
                Colors.blue,
              ),
          if (_project.location.isNotNullOrEmpty)
            _buildInfoCard(
              context,
              "Location",
              _project.location!,
              Icons.location_on, // Changed to location icon
              Colors.orange,
            ),
          if (_project.workScope!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Card(
                elevation: 20,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 26.0, vertical: 10),
                      child: Text(
                        'WorkScope',
                        style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.w500),
                      ),
                    ),
                    for (var l in _project.workScope!) ...[
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.check, color: appColor),
                            const SizedBox(width: 10),
                            Text(
                              l.name ?? "",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 16),
                            )
                          ],
                        ),
                      )
                    ]
                  ],
                ),
              ),
            ),
          if (_project.priceValue.isNotNullOrEmpty)
            _buildInfoCard(
              context,
              "Products Price",
              formatAmount(double.parse(_project.priceValue!)),
              Icons.currency_rupee,
              Colors.teal,
            ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_project.personName.isNotNullOrEmpty)
            _buildInfoCard(
              context,
              "Contact Person",
              _project.personName!,
              CupertinoIcons.person_solid,
              Colors.blueAccent,
            ),
          if (_project.personContacts.isNotNullOrEmpty)
            GestureDetector(
              onTap: () {
                UrlLauncherHelper.makePhoneCall(_project.personContacts!);
              },
              child: _buildInfoCard(
                context,
                "Contact Phone",
                _project.personContacts!,
                CupertinoIcons.phone_fill,
                Colors.green,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 30, color: iconColor),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection(BuildContext context, String label,
      String text, bool isExpanded, ValueChanged<bool> onExpandToggle) {
    final bool needsExpansion = text.length > maxTextLength;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isExpanded || !needsExpansion
                      ? text
                      : '${text.substring(0, maxTextLength)}...',
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                if (needsExpansion) const SizedBox(height: 5),
                if (needsExpansion)
                  GestureDetector(
                    onTap: () {
                      onExpandToggle(!isExpanded);
                    },
                    child: Text(
                      isExpanded ? 'Show less' : 'Show more',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUpdateStatusButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        child: CupertinoButton(
          color: Theme.of(context).primaryColor,
          onPressed: () => _updateProjectStatus(context),
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          child: const Text('Update Status'),
        ),
      ),
    );
  }

  void _updateProjectStatus(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Select New Status'),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: const Text('Lead'),
            onPressed: () => _setProjectStatus(context, 'Lead'),
          ),
          CupertinoActionSheetAction(
            child: const Text('Pitched'),
            onPressed: () => _setProjectStatus(context, 'Pitched'),
          ),
          CupertinoActionSheetAction(
            child: const Text('Contacted'),
            onPressed: () => _setProjectStatus(context, 'Contacted'),
          ),
          CupertinoActionSheetAction(
            child: const Text('Sent Sample'),
            onPressed: () => _setProjectStatus(context, 'Sent Sample'),
          ),
          CupertinoActionSheetAction(
            child: const Text('Negotiating'),
            onPressed: () => _setProjectStatus(context, 'Negotiating'),
          ),
          CupertinoActionSheetAction(
            child: const Text('Closed - Won'),
            onPressed: () => _setProjectStatus(context, 'Closed-Won'),
          ),
          CupertinoActionSheetAction(
            child: const Text('Closed - Lost'),
            onPressed: () => _setProjectStatus(context, 'Closed-Lost'),
          ),
          CupertinoActionSheetAction(
            child: const Text('Temporary Close'),
            onPressed: () => _setProjectStatus(context, 'Temporary Close'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> _setProjectStatus(BuildContext context, String status) async {
    alertDialogueWithLoader(context);
    bool isUpdated = await projectCont
        .updateProjectStatus({'status': status, "_id": _project.sId});
    if (mounted) Navigator.of(context).pop(); // dismiss loader
    if (isUpdated) {
      await projectCont.getProjects(context);
      await updateProjectCont.getProjectById(widget.projectId);
    }
  }

  _buildFileDownloadButton() {
    return Center(
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: Theme.of(context).primaryColor,
        onPressed: () {
          _downloadFile(_project.filePath!);
        },
        borderRadius: BorderRadius.circular(20),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.cloud_download, color: whiteColor),
            SizedBox(width: 5),
            Text(
              'Download File',
              style: TextStyle(color: whiteColor),
            ),
          ],
        ),
      ),
    );
  }
}

customLoader(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [Circle()],
          ),
        );
      });
}

class Circle extends StatefulWidget {
  const Circle({super.key});

  @override
  State<Circle> createState() => _CircleState();
}

class _CircleState extends State<Circle> {
  @override
  Widget build(BuildContext context) {
    return customCircleLoader();
  }
}

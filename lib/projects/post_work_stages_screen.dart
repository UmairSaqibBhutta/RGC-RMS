import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/controllers/stages_controller.dart';
import 'package:leadmanagementsystem/widgets/custom_button.dart';
import 'package:leadmanagementsystem/widgets/custom_decoration_container.dart';
import 'package:leadmanagementsystem/widgets/custom_text_field.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';

class PostWorkStagesScreen extends StatefulWidget {
  const PostWorkStagesScreen({super.key});

  @override
  State<PostWorkStagesScreen> createState() => _PostWorkStagesScreenState();
}

class _PostWorkStagesScreenState extends State<PostWorkStagesScreen> {
  final stagesCont = Get.put(StagesController());
  int currentTab = 0;

  final Map<int, Widget> tabs = {
    0: const Text('Main Stages'),
    1: const Text('Sub Stages'),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: mAppbar(
        'Post Work Stages',
        action: [
          IconButton(
            icon: const Icon(CupertinoIcons.refresh),
            onPressed: () {
              stagesCont.getMainStages();
              stagesCont.getSubStages();
            },
          ),
        ],
      ),
      body: CustomDecorationContainer(
        child: SafeArea(
          child: GetBuilder<StagesController>(
            init: stagesCont,
            builder: (controller) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CupertinoSlidingSegmentedControl<int>(
                      padding: const EdgeInsets.all(10),
                      children: tabs,
                      groupValue: currentTab,
                      onValueChanged: (val) {
                        setState(() => currentTab = val!);
                      },
                    ),
                  ),
                  Expanded(
                    child: controller.loading.isTrue
                        ? showSpinkit()
                        : currentTab == 0
                            ? _MainStagesTab(controller: controller)
                            : _SubStagesTab(controller: controller),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => currentTab == 0
            ? _showAddMainStageSheet(context)
            : _showAddSubStageSheet(context),
        backgroundColor: appColor,
        child: const Icon(CupertinoIcons.add, color: Colors.white),
      ),
    );
  }

  void _showAddMainStageSheet(BuildContext context) {
    final titleCont = TextEditingController();
    final stageNoCont = TextEditingController();
    bool titleError = false;
    bool stageNoError = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        titleText('Add Main Stage'),
                        IconButton(
                          icon: const Icon(CupertinoIcons.xmark),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hint: 'Stage Title *',
                      controller: titleCont,
                      prefixIcon: CupertinoIcons.list_bullet,
                      prefixColor: appColor,
                    ),
                    if (titleError)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: formErrorText(error: 'Title is required'),
                      ),
                    CustomTextField(
                      hint: 'Stage Number *',
                      controller: stageNoCont,
                      prefixIcon: CupertinoIcons.number,
                      prefixColor: appColor,
                      inputType: TextInputType.number,
                    ),
                    if (stageNoError)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: formErrorText(error: 'Stage number is required'),
                      ),
                    const SizedBox(height: 12),
                    Obx(() => CustomButton(
                          title: 'Add Main Stage',
                          onTap: stagesCont.addLoading.isTrue
                              ? null
                              : () async {
                                  setModalState(() {
                                    titleError = titleCont.text.trim().isEmpty;
                                    stageNoError =
                                        stageNoCont.text.trim().isEmpty;
                                  });
                                  if (titleError || stageNoError) return;

                                  final success = await stagesCont.addMainStage(
                                    title: titleCont.text.trim(),
                                    stageNo: int.parse(stageNoCont.text.trim()),
                                  );
                                  if (success && ctx.mounted) {
                                    Navigator.pop(ctx);
                                  }
                                },
                          child: stagesCont.addLoading.isTrue
                              ? const AppLoader(
                                  size: 20,
                                  strokeWidth: 2,
                                  color: Colors.white,
                                  trackColor: Colors.white24,
                                )
                              : null,
                        )),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddSubStageSheet(BuildContext context) {
    final titleCont = TextEditingController();
    String? selectedMainStageId;
    bool titleError = false;
    bool mainStageError = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        titleText('Add Sub Stage'),
                        IconButton(
                          icon: const Icon(CupertinoIcons.xmark),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text(
                              'Select Main Stage *',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 14,
                              ),
                            ),
                            value: selectedMainStageId,
                            items: stagesCont.mainStages
                                .map((stage) => DropdownMenuItem<String>(
                                      value: stage.id,
                                      child: Text(
                                          '${stage.stageNo}. ${stage.title}'),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              setModalState(() {
                                selectedMainStageId = val;
                                mainStageError = false;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    if (mainStageError)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child:
                            formErrorText(error: 'Please select a main stage'),
                      ),
                    CustomTextField(
                      hint: 'Sub Stage Title *',
                      controller: titleCont,
                      prefixIcon: CupertinoIcons.list_bullet_indent,
                      prefixColor: appColor,
                    ),
                    if (titleError)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: formErrorText(error: 'Title is required'),
                      ),
                    const SizedBox(height: 12),
                    Obx(() => CustomButton(
                          title: 'Add Sub Stage',
                          onTap: stagesCont.addLoading.isTrue
                              ? null
                              : () async {
                                  setModalState(() {
                                    titleError = titleCont.text.trim().isEmpty;
                                    mainStageError =
                                        selectedMainStageId == null;
                                  });
                                  if (titleError || mainStageError) return;

                                  final success = await stagesCont.addSubStage(
                                    mainStageId: selectedMainStageId!,
                                    title: titleCont.text.trim(),
                                  );
                                  if (success && ctx.mounted) {
                                    Navigator.pop(ctx);
                                  }
                                },
                          child: stagesCont.addLoading.isTrue
                              ? const AppLoader(
                                  size: 20,
                                  strokeWidth: 2,
                                  color: Colors.white,
                                  trackColor: Colors.white24,
                                )
                              : null,
                        )),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _MainStagesTab extends StatelessWidget {
  final StagesController controller;
  const _MainStagesTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.mainStages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.layers, size: 50, color: Color(0xFF9CA3AF)),
            SizedBox(height: 12),
            Text(
              'No main stages yet',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
            ),
            SizedBox(height: 4),
            Text(
              'Tap + to add a new main stage',
              style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: controller.mainStages.length,
      itemBuilder: (context, index) {
        final stage = controller.mainStages[index];
        return _StageCard(
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: appColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                stage.stageNo.toString(),
                style: const TextStyle(
                  color: appColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          title: stage.title,
          subtitle: 'Stage No. ${stage.stageNo.toString()}',
          icon: CupertinoIcons.layers_alt,
        );
      },
    );
  }
}

class _SubStagesTab extends StatelessWidget {
  final StagesController controller;
  const _SubStagesTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.subStages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.list_bullet_indent,
                size: 50, color: Color(0xFF9CA3AF)),
            SizedBox(height: 12),
            Text(
              'No sub stages yet',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
            ),
            SizedBox(height: 4),
            Text(
              'Tap + to add a new sub stage',
              style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: controller.subStages.length,
      itemBuilder: (context, index) {
        final sub = controller.subStages[index];
        final parentTitle = controller.getMainStageTitle(sub.mainStageId);
        return _StageCard(
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.indigo.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              CupertinoIcons.list_bullet_indent,
              color: Colors.indigo,
              size: 20,
            ),
          ),
          title: sub.title,
          subtitle: 'Under: $parentTitle',
          icon: CupertinoIcons.list_bullet_indent,
        );
      },
    );
  }
}

class _StageCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final IconData icon;

  const _StageCard({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE9EAEC)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

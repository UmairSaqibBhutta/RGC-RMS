import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/controllers/report_controller.dart';
import 'package:leadmanagementsystem/screens/tasks_list_page.dart';
import 'package:leadmanagementsystem/widgets/custom_decoration_container.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AllUsersScreen extends StatefulWidget {
  const AllUsersScreen({super.key});

  @override
  State<AllUsersScreen> createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<AllUsersScreen> {
  ReportController reportController = Get.put(ReportController());
  List<bool> isExpand = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  getFunctionality() async {
    await reportController.getAllUsersService();

    setState(() {
      isExpand =
          List.generate(reportController.usersData.length, (index) => false);
    });
  }

  @override
  void initState() {
    super.initState();
    getFunctionality();
    reportController.getAllUsersService();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ChartData> projectData = [];
  List<ChartData> taskData = [];

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: reportController,
        builder: (controller) {
          if (controller.tasksNumberData != null &&
              controller.tasksNumberData!.taskNumber != null &&
              controller.tasksNumberData!.projectsNumber != null) {
            projectData = [
              ChartData(
                  'Projects',
                  controller.tasksNumberData?.projectsNumber?.toDouble() ?? 0.0,
                  const Color(0xFFff9a00)),
            ];
            taskData = [
              ChartData(
                  'Tasks',
                  controller.tasksNumberData?.taskNumber?.toDouble() ?? 0.0,
                  const Color(0xFFe76f51)),
            ];
          }

          // Computed inside builder — always uses the latest controller
          // data and the latest _searchQuery from the parent closure.
          final query = _searchQuery.toLowerCase().trim();
          final filteredIndices =
              List.generate(controller.usersData.length, (i) => i).where((i) {
            final name = controller.usersData[i].name?.toLowerCase() ?? '';
            final email = controller.usersData[i].email?.toLowerCase() ?? '';
            return name.contains(query) || email.contains(query);
          }).toList();

          return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                title: const Text(
                  'Reports',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w600),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
              ),
              body: CustomDecorationContainer(
                child: controller.usersData.isEmpty
                    ? pleaseWaitLoader()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: SafeArea(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) =>
                                      setState(() => _searchQuery = value),
                                  decoration: InputDecoration(
                                    hintText: 'Search by name or email...',
                                    prefixIcon: const Icon(Icons.search,
                                        color: appColor),
                                    suffixIcon: _searchQuery.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear,
                                                color: Colors.grey),
                                            onPressed: () => setState(() {
                                              _searchController.clear();
                                              _searchQuery = '';
                                            }),
                                          )
                                        : null,
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 16),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: appColor, width: 1.5),
                                    ),
                                  ),
                                ),
                              ),
                              if (filteredIndices.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(top: 40.0),
                                  child: Center(
                                    child: Text(
                                      'No users found',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              for (int i in filteredIndices) ...[
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 10,
                                    shadowColor: Colors.black54,
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(16),
                                      onTap: () async {
                                        await controller.getTasksNumberService(
                                            controller.usersData[i].sId
                                                .toString(),
                                            context);

                                        // Collapse all other items except the current one
                                        for (int j = 0;
                                            j < isExpand.length;
                                            j++) {
                                          if (i != j) {
                                            isExpand[j] = false;
                                          }
                                        }
                                        // Toggle the current item
                                        isExpand[i] = !isExpand[i];

                                        setState(() {});
                                      },
                                      trailing: Icon(
                                        (i < isExpand.length && isExpand[i])
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        size: 30,
                                        color: appColor,
                                      ),
                                      leading: CircleAvatar(
                                        radius: 25,
                                        backgroundColor:
                                            appColor.withOpacity(0.2),
                                        child: const Icon(CupertinoIcons.person,
                                            color: appColor, size: 30),
                                      ),
                                      title: Text(
                                        controller.usersData[i].name.toString(),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87),
                                      ),
                                      subtitle: Text(
                                        controller.usersData[i].email
                                            .toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  )
                                      .animate()
                                      .slideY(duration: 500.ms)
                                      .fadeIn(duration: 500.ms),
                                ),
                                if (i < isExpand.length && isExpand[i])
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      elevation: 12,
                                      shadowColor: Colors.black54,
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16.0, horizontal: 12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: SfCircularChart(
                                                    onChartTouchInteractionDown:
                                                        (val) {
                                                      controller.getProjectData(
                                                        context,
                                                        controller
                                                            .usersData[i].sId
                                                            .toString(),
                                                        controller
                                                            .usersData[i].name
                                                            .toString(),
                                                      );
                                                    },
                                                    enableMultiSelection: true,
                                                    margin:
                                                        const EdgeInsets.all(
                                                            10),
                                                    legend: const Legend(
                                                      isVisible: true,
                                                      position:
                                                          LegendPosition.bottom,
                                                      overflowMode:
                                                          LegendItemOverflowMode
                                                              .wrap,
                                                    ),
                                                    series: <CircularSeries>[
                                                      DoughnutSeries<ChartData,
                                                          String>(
                                                        enableTooltip: true,
                                                        explodeAll: true,
                                                        legendIconType:
                                                            LegendIconType
                                                                .seriesType,
                                                        explode: true,
                                                        explodeOffset: '1.5',
                                                        dataSource: projectData,
                                                        xValueMapper:
                                                            (ChartData data,
                                                                    _) =>
                                                                data.x,
                                                        yValueMapper:
                                                            (ChartData data,
                                                                    _) =>
                                                                data.y,
                                                        pointColorMapper:
                                                            (ChartData data,
                                                                    _) =>
                                                                data.color,
                                                        dataLabelSettings:
                                                            const DataLabelSettings(
                                                                useSeriesColor:
                                                                    true,
                                                                connectorLineSettings:
                                                                    ConnectorLineSettings(
                                                                  length: '33',
                                                                  type:
                                                                      ConnectorType
                                                                          .curve,
                                                                ),
                                                                isVisible: true,
                                                                showCumulativeValues:
                                                                    true,
                                                                showZeroValue:
                                                                    true),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: SfCircularChart(
                                                    onChartTouchInteractionDown:
                                                        (v) {
                                                      Get.to(TaskListPage(
                                                          isReportView: true,
                                                          getTasksNyIndividualUsers:
                                                              true,
                                                          userId: controller
                                                              .usersData[i].sId
                                                              .toString()));
                                                    },
                                                    enableMultiSelection: true,
                                                    margin:
                                                        const EdgeInsets.all(
                                                            10),
                                                    legend: const Legend(
                                                      isResponsive: true,
                                                      isVisible: true,
                                                      position:
                                                          LegendPosition.bottom,
                                                      overflowMode:
                                                          LegendItemOverflowMode
                                                              .wrap,
                                                    ),
                                                    series: <CircularSeries>[
                                                      DoughnutSeries<ChartData,
                                                          String>(
                                                        enableTooltip: true,
                                                        explodeAll: true,
                                                        legendIconType:
                                                            LegendIconType
                                                                .seriesType,
                                                        explode: true,
                                                        explodeOffset: '1.5',
                                                        dataSource: taskData,
                                                        xValueMapper:
                                                            (ChartData data,
                                                                    _) =>
                                                                data.x,
                                                        yValueMapper:
                                                            (ChartData data,
                                                                    _) =>
                                                                data.y,
                                                        pointColorMapper:
                                                            (ChartData data,
                                                                    _) =>
                                                                data.color,
                                                        dataLabelSettings:
                                                            const DataLabelSettings(
                                                                useSeriesColor:
                                                                    true,
                                                                connectorLineSettings:
                                                                    ConnectorLineSettings(
                                                                  length: '33',
                                                                  type:
                                                                      ConnectorType
                                                                          .curve,
                                                                ),
                                                                isVisible: true,
                                                                showCumulativeValues:
                                                                    true,
                                                                showZeroValue:
                                                                    true),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                              
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ]
                            ],
                          ),
                        ),
                      ),
              ));
        });
  }

  Widget rowProjectsAndTask(String? title, String? length, Function()? onTap) {
    return InkWell(
      onTap: (onTap),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 15),
        child: Row(
          children: [
            SizedBox(
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                color: appColor,
                elevation: 7,
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    length!,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                )),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$title',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, this.color);

  final String x;
  final double y;
  final Color color;
}

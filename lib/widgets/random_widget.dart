import 'package:leadmanagementsystem/utils/dev_log.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/companies_strings.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/constants/size_config.dart';
import 'package:leadmanagementsystem/controllers/filter_controller.dart';
import 'package:leadmanagementsystem/controllers/filter_variable_controller.dart';
import 'package:leadmanagementsystem/widgets/custom_text_field.dart';

class FilterUI extends StatefulWidget {
  const FilterUI({super.key});

  @override
  State<FilterUI> createState() => _FilterUIState();
}

class _FilterUIState extends State<FilterUI> {
  bool expand = false;

  TextEditingController architectCont = TextEditingController();
  TextEditingController budgetCont = TextEditingController();
  TextEditingController projectNameCont = TextEditingController();

  String? groupValue;
  String? groupValue1;

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

  String? status;
  String? company;

  FilterController filterController = Get.put(FilterController());

  FilterVariableController filterVariableController =
      Get.put(FilterVariableController());

  @override
  Widget build(BuildContext context) {
    log("Company.getRoleBasedCompanies() = ${Company.getRoleBasedCompanies()}");
    return GetBuilder(
        init: filterVariableController,
        builder: (con) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: con.expand == false ? 0 : 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (con.expand)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            hint: 'Architect',
                            controller: architectCont,
                          ),
                          CustomTextField(
                            hint: 'Project Title',
                            controller: projectNameCont,
                          ),
                          const SizedBox(height: 10),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              'Project Status',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 18),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (var l in statuses)
                                  CustomRadioButton(
                                    value: l,
                                    groupValue: groupValue,
                                    title: l,
                                    onChanged: (v) {
                                      groupValue = v;
                                      status = v;

                                      print(status);

                                      setState(() {});
                                    },
                                  ),
                              ],
                            ),
                          ),
                          CustomTextField(
                            hint: 'Budget',
                            inputType: TextInputType.number,
                            controller: budgetCont,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              if (Company.getRoleBasedCompanies()
                                  .contains(Company.ROOFLINE))
                                RadioWithImage(
                                    groupValue: groupValue1,
                                    value: '1',
                                    onChanged: (val) {
                                      groupValue1 = val;
                                      company = Company.ROOFLINE;
                                      setState(() {});
                                    },
                                    image: 'roofline.jpg',
                                    title: Company.ROOFLINE),
                              if (Company.getRoleBasedCompanies()
                                  .contains(Company.RADIANT))
                                RadioWithImage(
                                    groupValue: groupValue1,
                                    value: '2',
                                    onChanged: (val) {
                                      groupValue1 = val;
                                      company = Company.RADIANT;

                                      setState(() {});
                                    },
                                    image: 'radiant.png',
                                    title: Company.RADIANT),
                              if (Company.getRoleBasedCompanies()
                                  .contains(Company.MAMZ))
                                RadioWithImage(
                                    groupValue: groupValue1,
                                    value: '3',
                                    onChanged: (val) {
                                      groupValue1 = val;
                                      company = Company.MAMZ;

                                      setState(() {});
                                    },
                                    image: 'mamz.png',
                                    title: Company.MAMZ)
                            ],
                          ),
                          Obx(() {
                            return filterController.loading.value
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: showSpinkit())
                                : Row(
                                    children: [
                                      CustomStatusButton(
                                          title: 'Cancel',
                                          onTap: () async {
                                            con.expand = true;
                                            setState(() {});
                                          },
                                          color: Colors.blueAccent),
                                      CustomStatusButton(
                                          image: 'search.png',
                                          title: 'Search',
                                          onTap: () async {
                                            log("projectNameCont = ${projectNameCont.text}");
                                            await filterController
                                                .getProjectsFilter(
                                                    architectCont.text.trim(),
                                                    status,
                                                    budgetCont.text.trim(),
                                                    projectNameCont.text.trim(),
                                                    company);

                                            con.expand = false;
                                            setState(() {});
                                          },
                                          color: Colors.blueAccent),
                                    ],
                                  );
                          }),
                        ],
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
          );
        });
  }
}

class CustomRadioButton extends StatefulWidget {
  String? value;
  String? groupValue;
  Function(String? val)? onChanged;
  String? title;

  CustomRadioButton(
      {super.key, this.value, this.onChanged, this.groupValue, this.title});

  @override
  State<CustomRadioButton> createState() => _CustomRadioButtonState();
}

class _CustomRadioButtonState extends State<CustomRadioButton> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio(
            value: widget.value!,
            toggleable: true,
            groupValue: widget.groupValue,
            onChanged: (widget.onChanged!)),
        const SizedBox(width: 10),
        Text(
          widget.title!,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        )
      ],
    );
  }
}

class RadioWithImage extends StatefulWidget {
  String? value;
  String? groupValue;
  void Function(String? val)? onChanged;

  String? title;
  String? image;

  RadioWithImage(
      {super.key,
      this.groupValue,
      this.onChanged,
      this.value,
      this.title,
      this.image});

  @override
  State<RadioWithImage> createState() => _RadioWithImageState();
}

class _RadioWithImageState extends State<RadioWithImage> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Radio(
              value: widget.value!,
              groupValue: widget.groupValue,
              onChanged: (widget.onChanged)),
          Padding(
            padding:
                EdgeInsets.only(bottom: widget.image == 'mamz.png' ? 1 : 7),
            child: Image.asset(
              'images/${widget.image}',
              height:
                  widget.image == 'radiant.png' || widget.image == 'mamz.png'
                      ? 50
                      : 50,
              width: widget.image == 'radiant.png' || widget.image == 'mamz.png'
                  ? 50
                  : 50,
            ),
          ),
        ],
      ),
    );
  }
}

class PieChartSample2 extends StatefulWidget {
  PieChartSample2({super.key, required this.statusCounts});

  /// Per-status project counts, keyed by the same status strings used
  /// throughout the app (e.g. 'Lead', 'Closed-Won') â€” from
  /// `getProjectStatusCounts/:userId`, computed server-side across the
  /// user's whole portfolio rather than one paginated page of projects.
  Map<String, int> statusCounts;

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State<PieChartSample2> {
  static const _knownStatusColors = {
    'Lead': leadColor,
    'Contacted': contactedColor,
    'Pitched': pitchedColor,
    'Sent Sample': sentSampleColor,
    'Negotiating': negotiatingColor,
    'Closed-Won': wonColor,
    'Closed-Lost': lostColor,
    'Temporary Close': Color(0xFFFFAB91),
  };

  // Some statuses are stored with a hyphen but read better with a space
  // in the legend/labels.
  static const _displayTitles = {
    'Closed-Won': 'Closed - Won',
    'Closed-Lost': 'Closed - Lost',
  };

  int touchedIndex = -1;

  List<Map<String, dynamic>> pieData = [];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      pieData = [
        for (final entry in _knownStatusColors.entries)
          {
            'title': _displayTitles[entry.key] ?? entry.key,
            'count': widget.statusCounts[entry.key] ?? 0,
            'color': entry.value,
          },
      ];

      // Anything whose status doesn't match one of the buckets above
      // (e.g. newly created projects that haven't had a status set yet)
      // still counts toward the total, so surface it instead of silently
      // dropping it from the chart.
      final unclassifiedCount = widget.statusCounts.entries
          .where((e) => !_knownStatusColors.containsKey(e.key))
          .fold<int>(0, (sum, e) => sum + e.value);
      if (unclassifiedCount > 0) {
        final unmatchedStatuses = widget.statusCounts.keys
            .where((k) => !_knownStatusColors.containsKey(k))
            .toSet();
        log('Pie chart: $unclassifiedCount project(s) with unmatched status: $unmatchedStatuses');
        pieData.add({
          'title': 'Other',
          'count': unclassifiedCount,
          'color': Colors.grey,
        });
      }

      final total = pieData.fold<int>(0, (sum, e) => sum + (e['count'] as int));

      return SizedBox(
        height: kIsWeb ? Get.height / 2 : Get.height / 3,
        child: Stack(
          children: [
            Row(
              children: <Widget>[
                const SizedBox(
                  height: 18,
                ),

                total == 0
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Container(
                          height: 180,
                          width: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF3F4F6),
                            border: Border.all(
                                color: const Color(0xFFE5E7EB), width: 2),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bar_chart_rounded,
                                    size: 40, color: Color(0xFF9CA3AF)),
                                SizedBox(height: 4),
                                Text(
                                  'No data',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF9CA3AF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : AspectRatio(
                        aspectRatio: .8,
                        child: PieChart(
                          swapAnimationCurve: Curves.easeInSine,
                          PieChartData(
                            centerSpaceColor: Colors.white,
                            pieTouchData: PieTouchData(
                              touchCallback:
                                  (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            borderData: FlBorderData(
                              show: true,
                            ),
                            sectionsSpace: 1.5,
                            centerSpaceRadius: 45,
                            sections: showingSections(pieData),
                          ),
                        ),
                      ),
                // const SizedBox(
                //   width: 1,
                // ),

                total == 0
                    ? const Spacer()
                    : const SizedBox.shrink(),

                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    for (var l in pieData)
                      Indicators(
                        color: l['color'],
                        title: l['title'],
                        count: l['count'],
                      )
                  ],
                )
              ],
            ),
            //! arrow line on pie chart
            if (!kIsWeb && !isIOSTablet(context))
              Positioned(
                left: 194,
                top: 40,
                right: 150,
                child: Transform.rotate(
                  angle: 100,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(40)),
                  ),
                ),
              ),
            Positioned(
              right: 70,
              top: -1,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.black)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Row(
                    children: [Text('Total: $total')],
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });
  }

  List<PieChartSectionData> showingSections(
      List<Map<String, dynamic>> pieData) {
    return List.generate(pieData.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      final data = pieData[i];
      final count = data['count'];

      return PieChartSectionData(
        color: data['color'],
        value: double.tryParse(count.toString()),
        title: count.toString(),
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    });
  }
}

class Indicators extends StatefulWidget {
  Color? color;
  String? title;
  int? count;

  Indicators({super.key, this.color, this.title, this.count});

  @override
  State<Indicators> createState() => _IndicatorsState();
}

class _IndicatorsState extends State<Indicators> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Container(
              height: 12,
              width: 12,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: widget.color),
            ),
            const SizedBox(width: 8),
            Text(
              widget.count == null
                  ? widget.title!
                  : '${widget.title} (${widget.count})',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
            )
          ],
        ),
      ),
    );
  }
}

class CustomStatusButton extends StatefulWidget {
  String? image;
  Function()? onTap;
  String? title;
  Color? color;

  CustomStatusButton(
      {super.key, this.color, this.title, this.image, this.onTap});

  @override
  State<CustomStatusButton> createState() => _CustomStatusButtonState();
}

class _CustomStatusButtonState extends State<CustomStatusButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: widget.color!.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.color!.withValues(alpha: 0.35)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.image != null)
                Image.asset(
                  'images/${widget.image!}',
                  height: 18,
                  width: 18,
                ),
              if (widget.image != null) const SizedBox(width: 6),
              Text(
                widget.title!,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: widget.color!.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

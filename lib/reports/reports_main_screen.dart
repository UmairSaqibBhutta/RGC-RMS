import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/reports/all_users_screen.dart';
import 'package:leadmanagementsystem/widgets/custom_decoration_container.dart';

class ReportsMainScreen extends StatefulWidget {
  const ReportsMainScreen({super.key});

  @override
  State<ReportsMainScreen> createState() => _ReportsMainScreenState();
}

class _ReportsMainScreenState extends State<ReportsMainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Reports',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: CustomDecorationContainer(
          child: SafeArea(
        child: Wrap(
          children: [
            reportCard(Icons.pie_chart, () {
              Get.to(const AllUsersScreen());
            }, 'All Users Report'),
          ],
        ),
      )),
    );
  }
}

reportCard(IconData? iconData, Function()? onTap, String? txt) {
  return Column(
    children: [
      InkWell(
        onTap: (onTap),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: Get.width * .45,
            height: 200,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12.withOpacity(.4),
                      offset: const Offset(.3, .5),
                      blurRadius: 11),
                  const BoxShadow(color: Colors.grey, offset: Offset(1, .5)),
                ]),
            child: Center(child: Icon(iconData)),
          ),
        ),
      ),
      const SizedBox(height: 5),
      Text(txt!,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17))
    ],
  );
}

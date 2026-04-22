import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/controllers/visit_controller.dart';
import 'package:leadmanagementsystem/screens/add_visit_screen.dart';

class VisitListScreen extends StatefulWidget {
  const VisitListScreen({super.key});

  @override
  State<VisitListScreen> createState() => _VisitListScreenState();
}

class _VisitListScreenState extends State<VisitListScreen> {
  late VisitController controller;

  @override
  void initState() {
    super.initState();

    /// ✅ Initialize controller properly
    controller = Get.put(VisitController());

    /// ✅ Call API ONCE after widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getVisitReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(const AddVisitScreen());
        },
        backgroundColor: appColor,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text("Visit Reports"),
        backgroundColor: appColor,
      ),
      backgroundColor: Colors.grey.shade100,
      body: GetBuilder<VisitController>(
        builder: (cont) {
          /// ✅ Loading
          if (cont.isReportLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          /// ✅ Empty State
          if (cont.visitList.isEmpty) {
            return const Center(child: Text("No Visits Found"));
          }

          return RefreshIndicator(
            onRefresh: () => cont.getVisitReports(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: cont.visitList.length,
              itemBuilder: (context, index) {
                final visit = cont.visitList[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 👤 USER INFO
                        if (visit.userDetail != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.person,
                                    size: 16, color: appColor),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "${visit.userDetail?.name ?? ""} (${visit.userDetail?.role ?? ""})",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: appColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        /// 📍 SITE
                        _row("Site", visit.site),
                        _row("Town/Phase", visit.townPahse),
                        _row("Block", visit.block),

                        const SizedBox(height: 10),

                        /// 👤 CONTACT
                        _row("GCO", visit.gco),
                        _row("Key Person", visit.keyPN),
                        _row("Contact", visit.keyPC),

                        const SizedBox(height: 10),

                        /// 📊 RESULT
                        _row("Call Result", visit.callResult),

                        const Divider(height: 20),

                        /// ⏱ CHECK IN / OUT
                        Row(
                          children: [
                            Expanded(
                              child: _timeBox(
                                "Check In",
                                visit.checkIn?.time,
                                Icons.login,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _timeBox(
                                "Check Out",
                                visit.checkOut?.time,
                                Icons.logout,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// 🔹 Row Widget
  Widget _row(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          Expanded(
            child: Text(
              (value != null && value.isNotEmpty) ? value : "-",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Time Box
  Widget _timeBox(String title, String? time, IconData icon) {
    final isEmpty = time == null || time.isEmpty;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isEmpty ? Colors.grey.shade200 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isEmpty ? Colors.grey.shade300 : Colors.green,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: appColor),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            isEmpty ? "Not Marked" : time!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isEmpty ? Colors.black54 : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

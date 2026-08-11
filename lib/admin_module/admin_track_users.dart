import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/extensions/string_extensions.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/widgets/custom_snackbar.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';
import 'package:leadmanagementsystem/widgets/data_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminTrackUsers extends StatefulWidget {
  const AdminTrackUsers({super.key});

  @override
  State<AdminTrackUsers> createState() => _AdminTrackUsersState();
}

class _AdminTrackUsersState extends State<AdminTrackUsers> {
  Future<void> _openMap(double latitude, double longitude) async {
    final googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(
          Uri.parse(
            googleMapsUrl,
          ),
          mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open the map.';
    }
  }

  @override
  void initState() {
    super.initState();
    locationController.getAllUsersLocationList();
  }

  final seachCont = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mAppbar("User Locations"),
      body: RefreshIndicator(
        onRefresh: () {
          locationController.getAllUsersLocationList();
          return Future.value(true);
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: GetBuilder(
              init: locationController,
              builder: (locationController) {
                if (locationController.loadUserLocations) {
                  return Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: Get.height * .4,
                      ),
                      showSpinkit()
                    ],
                  ));
                } else if (locationController.usersLocationList.isEmpty) {
                  return const Center(child: Text("No data found"));
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // CustomTextField(
                    //   controller: seachCont,
                    //   hint: "Search",
                    //   prefixIcon: CupertinoIcons.search,
                    //   onChanged: (p0) {
                    //     searchUser(p0);
                    //   },
                    // ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: locationController.usersLocationList.length,
                      itemBuilder: (context, index) {
                        var data = locationController.usersLocationList[index];

                        return Card(
                          elevation: 8,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              // gradient: const LinearGradient(
                              //   colors: [Colors.white, Colors.indigo],
                              //   begin: Alignment.topLeft,
                              //   end: Alignment.bottomRight,
                              // ),
                              // boxShadow: [
                              //   BoxShadow(
                              //     color: Colors.black12,
                              //     offset: Offset(4, 4),
                              //     blurRadius: 8,
                              //   ),
                              // ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundColor: appColor,
                                child: Text(
                                  data.name?[0] ?? "",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              title: Text(
                                data.name ?? "",
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '${data.areaName}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      // color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (data.updatedAt.isNotNullOrEmpty)
                                    Text(
                                      'Last updated: ${DateFormatter.formatDateTime(data.updatedAt!)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: Colors.orangeAccent,
                                ),
                                onPressed: () {
                                  if (data.lat.isNotNullOrEmpty &&
                                      data.long.isNotNullOrEmpty) {
                                    _openMap(double.parse(data.lat!),
                                        double.parse(data.long!));
                                  } else {
                                    CustomSnackbar.error(
                                        "Location not available");
                                  }
                                },
                                child: const Icon(Icons.location_on,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  ],
                );
              }),
        ),
      ),
    );
  }

  void searchUser(String p0) {}
}

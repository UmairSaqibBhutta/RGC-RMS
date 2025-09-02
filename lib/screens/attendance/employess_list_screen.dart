import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/controllers/users_controller.dart';
import 'package:leadmanagementsystem/screens/attendance/user_attendance_screen.dart';
import 'package:leadmanagementsystem/widgets/custom_text_field.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final UsersController usersController = Get.put(UsersController());
  final TextEditingController searchController = TextEditingController();

  List filteredList = [];

  @override
  void initState() {
    super.initState();
    usersController.getUsers().then((_) {
      filteredList = usersController.usersData;
      setState(() {});
    });
  }

  void _filterList(String query) {
    if (query.isEmpty) {
      filteredList = usersController.usersData;
    } else {
      query = query.toLowerCase();
      filteredList = usersController.usersData.where((user) {
        return user.name.toLowerCase().contains(query) ||
            user.role.toLowerCase().contains(query);
        //  ||
        // user..toLowerCase().contains(query);
      }).toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mAppbar("Employee List"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GetBuilder<UsersController>(
          init: usersController,
          builder: (controller) {
            if (controller.getUsersLoading) {
              return showSpinkit();
            }

            return Column(
              children: [
                CustomTextField(
                  controller: searchController,
                  hint: 'Search by name or role',
                  prefixIcon: Icons.search,
                  onChanged: _filterList,
                ),
                const SizedBox(height: 16),
                if (filteredList.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text("No employees found."),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final user = filteredList[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: ListTile(
                            onTap: () {
                              Get.to(UserAttendanceScreen(
                                  userId: user.id, userName: user.name));
                            },
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            title: Text(
                              user.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${user.role}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Joining Date: ${DateFormat.yMMMd().format(user.createdDate)}",
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

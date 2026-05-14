import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:intl/intl.dart';
import 'package:leadmanagementsystem/controllers/project_controller.dart';
import 'package:leadmanagementsystem/controllers/manager_controller.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/users_list_model.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';

class ManagersPage extends StatefulWidget {
  const ManagersPage({super.key});

  @override
  State<ManagersPage> createState() => _ManagersPageState();
}

class _ManagersPageState extends State<ManagersPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final _formKey = GlobalKey<FormState>();

  void _toggleManagerStatus(int index) {
    if (managersCont.managersData[index].status == "Active") {
      managersCont.managersData[index].status = "Deactive";
    } else {
      managersCont.managersData[index].status = "Active";
    }

    setState(() {});
  }

  void _showConfirmationDialog(
      BuildContext context, UserData manager, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(manager.status == "Active"
              ? 'Deactivate Account'
              : 'Activate Account'),
          content: Text(manager.status == "Active"
              ? 'Are you sure you want to deactivate this account?'
              : 'Are you sure you want to activate this account?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onConfirm(); // Perform the action
                Navigator.of(context).pop(); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: appColor,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  final ManagerController managersCont = Get.put(ManagerController());

  @override
  void initState() {
    super.initState();
    managersCont.getManagers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mAppbar("Users"),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search by name or email...',
                  prefixIcon: const Icon(Icons.search, color: appColor),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () => setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          }),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: appColor, width: 1.5),
                  ),
                ),
              ),
            ),
            GetBuilder<ManagerController>(
              init: managersCont,
              builder: (controller) {
                if (controller.getManagersLoading) {
                  return showSpinkit();
                } else if (controller.managersData.isEmpty) {
                  return const Center(child: Text('No managers found'));
                }

                // Computed inside builder — always uses the latest controller
                // data and the latest _searchQuery from the parent closure.
                final query = _searchQuery.toLowerCase().trim();
                final filteredIndices =
                    List.generate(controller.managersData.length, (i) => i)
                        .where((i) {
                  final name =
                      controller.managersData[i].name.toLowerCase();
                  final email =
                      controller.managersData[i].email.toLowerCase();
                  return name.contains(query) || email.contains(query);
                }).toList();

                if (filteredIndices.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 40.0),
                    child: Center(
                      child: Text(
                        'No users found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: filteredIndices.length,
                    itemBuilder: (context, index) {
                      final i = filteredIndices[index];
                      return ManagerCard(
                        manager: controller.managersData[i],
                        onToggleStatus: () => _showConfirmationDialog(
                          context,
                          controller.managersData[i],
                          () => _toggleManagerStatus(i),
                        ),
                      );
                    },
                  ),
                );
              },
            )
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _showAddManagerDialog,
      //   backgroundColor: appColor,
      //   label: const Text("Add Manager"),
      //   icon: const Icon(Icons.add),
      // ),
    );
  }
}

class ManagerCard extends StatefulWidget {
  final UserData manager;
  final VoidCallback onToggleStatus;

  const ManagerCard(
      {super.key, required this.manager, required this.onToggleStatus});

  @override
  _ManagerCardState createState() => _ManagerCardState();
}

class _ManagerCardState extends State<ManagerCard> {
  bool showPassword = false;
  bool isActive = true;

  @override
  void initState() {
    super.initState();

    if (widget.manager.status == "Active") {
      isActive = true;
    } else {
      isActive = false;
    }
  }

  ManagerController managerController = Get.put(ManagerController());
  ProjectController addProjectController = Get.put(ProjectController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ManagerController>(
        init: managerController,
        builder: (controller) {
          return loginStorage.getUserEmail() == widget.manager.email
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      // Additional functionality can be added here if needed
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 3,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15.0),
                        title: Text(
                          widget.manager.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.black87 : Colors.grey[600],
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.manager.email,
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    isActive ? Colors.grey : Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (widget.manager.phone != null)
                              Text(
                                widget.manager.phone ?? "No phone number",
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      isActive ? Colors.grey : Colors.grey[500],
                                ),
                              ),
                            // const SizedBox(height: 6),
                            // Row(
                            //   children: [
                            //     Text(
                            //       showPassword ? widget.manager.password : '********',
                            //       style: TextStyle(
                            //         fontSize: 16,
                            //         color: isActive ? Colors.black87 : Colors.grey[600],
                            //       ),
                            //     ),
                            //     const SizedBox(width: 10),
                            //     InkWell(
                            //       onTap: () {
                            //         setState(() {
                            //           showPassword = !showPassword;
                            //         });
                            //       },
                            //       child: Icon(
                            //         showPassword ? Icons.visibility_off : Icons.visibility,
                            //         color: isActive ? appColor : Colors.grey,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            const SizedBox(height: 6),
                            Text(
                              DateFormat.yMMMd()
                                  .format(widget.manager.createdDate),
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    isActive ? Colors.grey : Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (!isActive)
                              const Text(
                                'Status: Disabled',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'Toggle Status') {
                              widget.onToggleStatus();
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              // PopupMenuItem<String>(
                              //   value: 'Toggle Status',
                              //   child: Text(isActive
                              //       ? 'Deactivate Account'
                              //       : 'Activate Account'),
                              // ),
                              PopupMenuItem(
                                child: const Text('Update Account'),
                                onTap: () {
                                  customRoutes(
                                      context,
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CustomDialog(
                                            manager: widget.manager),
                                      ));
                                },
                              ),
                              PopupMenuItem(
                                child: const Text('Delete Account',
                                    style: TextStyle(color: Colors.red)),
                                onTap: () {
                                  showCupertinoModalPopup(
                                      context: context,
                                      builder: (context) =>
                                          CupertinoActionSheet(
                                            actions: [
                                              CupertinoActionSheetAction(
                                                  onPressed: () async {
                                                    await controller
                                                        .deleteFunction(
                                                            widget.manager.id,
                                                            context);
                                                  },
                                                  child: const Text('Delete'))
                                            ],
                                            cancelButton: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              child: Material(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                child: Ink(
                                                  color: Colors.red,
                                                  child:
                                                      CupertinoActionSheetAction(
                                                          isDefaultAction: true,
                                                          onPressed: () {
                                                            Get.back();
                                                          },
                                                          child: const Text(
                                                            'Cancel',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          )),
                                                ),
                                              ),
                                            ),
                                            title: const Text(
                                                'Are you sure you want to delete this user?'),
                                          ));
                                },
                              )
                            ];
                          },
                        ),
                      ),
                    ),
                  ),
                );
        });
  }
}

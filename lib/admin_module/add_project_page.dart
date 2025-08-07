import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/bottom_nav_screen.dart';
import 'package:leadmanagementsystem/constants/companies_strings.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/controllers/project_controller.dart';
import 'package:leadmanagementsystem/controllers/login_controller.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/project_model.dart';
import 'package:leadmanagementsystem/models/workscope_model.dart';
import 'package:leadmanagementsystem/screens/login_screen.dart';
import 'package:leadmanagementsystem/widgets/custom_button.dart';
import 'package:leadmanagementsystem/widgets/custom_text_field.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';

class AddProjectPage extends StatefulWidget {
  ProjectData? projectData;

  String reciverId;
  String senderName;
  String token;

  AddProjectPage(
      {super.key,
      this.projectData,
      required this.reciverId,
      required this.token,
      required this.senderName});

  @override
  _AddProjectPageState createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  ProjectController projectController = Get.find();

  LoginController loginController = Get.put(LoginController());

  bool isProjectNameError = false;
  bool isDescriptionError = false;
  bool isProjectManagerError = false;
  bool isTimeDurationError = false;
  bool isWorkForceError = false;
  bool isBudgetError = false;
  bool isTentativeCostError = false;
  bool isLocationError = false;
  bool isContactPersonNameError = false;
  bool isContactPersonPhoneError = false;
  bool isPriorityError = false;
  bool isCompanyError = false;
  bool isClientError = false;

  String projectNameErrorString = '';
  String clientNameErrorString = '';
  String descriptionErrorString = '';
  String projectManagerErrorString = '';
  String timeDurationErrorString = '';
  String workForceErrorString = '';
  String budgetErrorString = '';
  String tentativeCostErrorString = '';
  String locationErrorString = '';
  String contactPersonNameErrorString = '';
  String contactPersonPhoneErrorString = '';
  String priorityErrorString = '';
  String companyErrorString = '';

  bool projectDepartment = false;
  bool projectConsultant = false;
  bool precurementOfficer = false;
  bool accountOfficer = false;

  bool mamzB = false;
  bool productB = false;

  List<bool> mamzBool = [];
  List<bool> productsBool = [];
  List<bool> rooflineBool = [];

  List<String> mamzProducts = [
    'Mamz Prime Coat',
    'Mamz Tack Coat',
    'Mamz ChipSeal RS 2',
    'Mamz CrackCure',
    'Mamz AquaShield 50P',
    'Mamz AquaShield RBE',
    'Mamz Ready Cold Asphalt',
    'Mamz Slurry Seal',
    'Mamz BituLasti',
  ];

  List<String> products = [
    // Admixtures
    'ConAd WP 1000 / Powder Admixture',
    'ConAd WP 682 / Liquid Admixture',
    'ConAd SP 551',
    'ConAd SP 587',
    'ConAd SP 687',
    'ConAd ASP 888',

    // Concrete Repairing
    'ConBond SBR',
    'ConBond EP',
    'ConRep FC',
    'ConRep FR Mortar',
    'ConRep FMC',
    'ConRep EP 21',
    'ConPlug 180',

    // Waterproofing
    'ConFlex 511',
    'ConFlex 515',
    'ConSeal CR',
    'ConFlex ACR',
    'ConFlex PU',
    'ConGuard S',
    'ConFix SW 300',
    'ConFix PVC WaterStop',
    'ConFlex PU 600',

    // Grouts
    'ConGrout GP',
    'ConGrout HS',
    'ConGrout EP GP',
    'ConGrout EP HS',

    // Flooring
    'ConFloor HardTop',
    'ConFloor C SLC P',
    'ConFloor EP Screed',
    'ConCote EP 401',
    'ConGuard EP 401',
    'ConCote WB 103',
    'ConCote EP HB',
    'ConFloor EP SL',
    'ConFloor PU SL',

    // ConTile Products
    'ConTile Bond',
    'ConTile Grout',
    'ConTile Grout EP',
  ];

  List<String> rooflineProducts = [
    "PLASTOGRIP RL-500",
    "PLASTOGRIP RL-400",
    "PLASTOGRIP RL-300",
    "PLASTOGRIP RLA-400",
    "PLASTOGRIP RLA-300",
    "PLASTOGRIP RLG-400",
    "PLASTOGRIP RLG-300",
    "ELASTOGRIP RL-150",
    "ELASTOGRIP RL-200",
    "ELASTOGRIP RL-300",
    "ELASTOGRIP RL-300",
    "ELASTOGRIP RL-400"
  ];

  List<String> region = ['Centre', 'North', 'South'];

  String? selectRegion;

  getUpdateProjectData() {
    if (widget.projectData != null) {
      // Set data from projectData to the controller
      projectController.projectNameControl.text = widget.projectData!.name!;
      projectController.clientNameControl.text =
          widget.projectData!.clientName!;
      projectController.descriptionControl.text =
          widget.projectData!.description!;
      projectController.projectManagerCont.text =
          widget.projectData!.projectManager!;
      projectController.timeDurationControl.text =
          widget.projectData!.duration!;
      projectController.workForceControl.text = widget.projectData!.workForce!;
      projectController.budgetCont.text = widget.projectData!.budget!;
      projectController.tentativeCostCont.text =
          widget.projectData!.tentativeCost!;
      projectController.locationCont.text = widget.projectData!.location!;
      projectController.notesCont.text = widget.projectData!.notes!;
      projectController.contactPersonPhoneCont.text =
          widget.projectData!.personContacts!;
      projectController.contactPersonNameCont.text =
          widget.projectData!.personName!;
      projectController.consultReControl.text =
          widget.projectData!.consultantREName!;
      projectController.consultMeControl.text =
          widget.projectData!.consultantMEName!;
      projectController.consultNameCont.text =
          widget.projectData!.consultantName!;
      projectController.consultReNameCont.text =
          widget.projectData!.consultantREName!;
      projectController.consultRePhoneCont.text =
          widget.projectData!.consultantREPhone!;
      projectController.consultantMeNameCont.text =
          widget.projectData!.consultantMEName!;
      projectController.consultantMePhoneCont.text =
          widget.projectData!.consultantMEPhone!;
      projectController.contractorNameCont.text =
          widget.projectData!.contractorName!;
      projectController.contractorReControl.text =
          widget.projectData!.contractorPMName!;
      projectController.contractorReNameCont.text =
          widget.projectData!.contractorPMName!;
      projectController.contractorRePhoneCont.text =
          widget.projectData!.contractorPMPhone!;
      projectController.contractorMeNameCont.text =
          widget.projectData!.contractorMEName!;
      projectController.contractorMePhoneCont.text =
          widget.projectData!.contractorMEPhone!;
      projectController.precurementNameCont.text =
          widget.projectData!.precourmentName!;
      projectController.precurementPhoneCont.text =
          widget.projectData!.precourmentPhone!;
      projectController.accountNameCont.text =
          widget.projectData!.accountOfficerName!;
      projectController.accountPhoneCont.text =
          widget.projectData!.accountOfficerPhone!;
      projectController.projectOwnerNameControl.text =
          widget.projectData!.ownerName!;
      projectController.projectOwnerMeControl.text =
          widget.projectData!.ownerMe!;
      projectController.projectOwnerPhoneControl.text =
          widget.projectData!.ownerContact!;
      projectController.productPriceCont.text = widget.projectData!.priceValue!;

      projectController.company.value = widget.projectData!.company ?? '';
      setState(() {});

      // Handle work scope selections
      for (var element in widget.projectData!.workScope!) {
        if (mamzProducts.contains(element.name)) {
          int index = mamzProducts.indexOf(element.name!);
          if (index >= 0 && index < mamzBool.length) {
            mamzBool[index] = true;
          }
        } else if (products.contains(element.name)) {
          int index = products.indexOf(element.name!);
          if (index >= 0 && index < productsBool.length) {
            productsBool[index] = true;
          }
        } else if (rooflineProducts.contains(element.name)) {
          int index = rooflineProducts.indexOf(element.name!);
          if (index >= 0 && index < rooflineBool.length) {
            rooflineBool[index] = true;
          }
        }
      }

      projectController.priority.value = widget.projectData!.projectPriority!;
    } else {
      // Clear all fields if projectData is null
      projectController.projectNameControl.clear();
      projectController.clientNameControl.clear();
      projectController.descriptionControl.clear();
      projectController.projectManagerCont.clear();
      projectController.timeDurationControl.clear();
      projectController.workForceControl.clear();
      projectController.budgetCont.clear();
      projectController.tentativeCostCont.clear();
      projectController.locationCont.clear();
      projectController.notesCont.clear();
      projectController.contactPersonPhoneCont.clear();
      projectController.contactPersonNameCont.clear();
      projectController.consultReControl.clear();
      projectController.consultMeControl.clear();
      projectController.consultNameCont.clear();
      projectController.consultReNameCont.clear();
      projectController.consultRePhoneCont.clear();
      projectController.consultantMeNameCont.clear();
      projectController.consultantMePhoneCont.clear();
      projectController.contractorNameCont.clear();
      projectController.contractorReControl.clear();
      projectController.contractorReNameCont.clear();
      projectController.contractorRePhoneCont.clear();
      projectController.contractorMeNameCont.clear();
      projectController.contractorMePhoneCont.clear();
      projectController.precurementNameCont.clear();
      projectController.precurementPhoneCont.clear();
      projectController.accountNameCont.clear();
      projectController.accountPhoneCont.clear();
      projectController.projectOwnerNameControl.clear();
      projectController.projectOwnerMeControl.clear();
      projectController.projectOwnerPhoneControl.clear();
      projectController.productPriceCont.clear();

      // Reset all work scope selections
      mamzBool = List.generate(mamzProducts.length, (index) => false);
      productsBool = List.generate(products.length, (index) => false);
      rooflineBool = List.generate(rooflineProducts.length, (index) => false);

      projectController.priority.value = ''; // Clear priority
    }

    setState(() {}); // Update the UI
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    mamzBool = List.generate(mamzProducts.length, (index) => false);
    productsBool = List.generate(products.length, (index) => false);
    rooflineBool = List.generate(rooflineProducts.length, (index) => false);

    getUpdateProjectData();
  }

  bool selectWorkScope = false;

  bool workScopeSelected = false;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: mAppbar(
            widget.projectData != null ? "Update Project" : "Add Project"),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              CustomTextField(
                isRequiredField: true,
                controller: projectController.projectNameControl,
                prefixIcon: CupertinoIcons.textbox,
                hint: 'Project Name',
                prefixColor: Colors.blue,
              ),
              if (isProjectNameError)
                formErrorText(error: projectNameErrorString),
              CustomTextField(
                isRequiredField: true,
                controller: projectController.clientNameControl,
                prefixIcon: CupertinoIcons.person,
                hint: 'Client Name',
                prefixColor: Colors.blue,
              ),
              if (isProjectNameError)
                formErrorText(error: clientNameErrorString),
              CustomExpansion(
                openData: projectConsultant,
                title: 'Consultant',
                onTap: () {
                  projectConsultant = !projectConsultant;
                  setState(() {});
                },
                children: [
                  CustomTextField(
                    controller: projectController.consultNameCont,
                    onChanged: (val) {
                      projectController.consultNameCont.text = val;

                      setState(() {});
                    },
                    hint: 'Consultant Name',
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                      child: Text(
                        'Consultant RE: (Resident Engineer)',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 18),
                      ),
                    ),
                  ),
                  CustomTextField(
                    controller: projectController.consultReNameCont,
                    hint: 'Name',
                  ),
                  CustomTextField(
                    controller: projectController.consultRePhoneCont,
                    hint: 'Phone',
                    inputType: TextInputType.number,
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                      child: Text(
                        'Consultant ME: (Material Engineer)',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 18),
                      ),
                    ),
                  ),
                  CustomTextField(
                    controller: projectController.consultantMeNameCont,
                    hint: 'Name',
                  ),
                  CustomTextField(
                    controller: projectController.consultantMePhoneCont,
                    hint: 'Phone',
                    inputType: TextInputType.number,
                  ),
                ],
              ),
              CustomExpansion(
                openData: projectDepartment,
                title: 'Contractor',
                onTap: () {
                  projectDepartment = !projectDepartment;
                  setState(() {});
                },
                children: [
                  CustomTextField(
                    controller: projectController.contractorNameCont,
                    onChanged: (val) {
                      projectController.contractorNameCont.text = val;
                      setState(() {});
                    },
                    hint: 'Contractor Name',
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                      child: Text(
                        'Contractor PM: (Project Manager)',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 18),
                      ),
                    ),
                  ),
                  CustomTextField(
                    controller:
                        projectController.contractorReNameCont, //! issue
                    hint: 'Name',
                  ),
                  CustomTextField(
                    controller: projectController.contractorRePhoneCont,
                    hint: 'Phone',
                    inputType: TextInputType.number,
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                      child: Text(
                        'Contractor ME: (Material Engineer)',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 18),
                      ),
                    ),
                  ),
                  CustomTextField(
                    controller: projectController.contractorMeNameCont,
                    hint: 'Name',
                  ),
                  CustomTextField(
                    controller: projectController.contractorMePhoneCont,
                    hint: 'Phone',
                    inputType: TextInputType.number,
                  ),
                ],
              ),
              CustomExpansion(
                openData: precurementOfficer,
                title: 'Procurement Officer',
                onTap: () {
                  precurementOfficer = !precurementOfficer;
                  setState(() {});
                },
                children: [
                  CustomTextField(
                    controller: projectController.precurementNameCont,
                    hint: 'Name',
                  ),
                  CustomTextField(
                    controller: projectController.precurementPhoneCont,
                    hint: 'Phone',
                    inputType: TextInputType.number,
                  ),
                ],
              ),
              CustomExpansion(
                openData: accountOfficer,
                title: 'Account Officer',
                onTap: () {
                  accountOfficer = !accountOfficer;
                  setState(() {});
                },
                children: [
                  CustomTextField(
                    controller: projectController.accountNameCont,
                    hint: 'Name',
                  ),
                  CustomTextField(
                    controller: projectController.accountPhoneCont,
                    hint: 'Phone',
                    inputType: TextInputType.number,
                  ),
                ],
              ),
              Stack(
                children: [
                  CustomExpansion(
                    title: 'Work Scope',
                    onTap: () {
                      productB = !productB;
                      setState(() {});
                    },
                    openData: productB,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 8),
                          child: Text(
                            'Mamz Products',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 19),
                          ),
                        ),
                      ),
                      const Divider(),
                      GetBuilder(
                          init: projectController,
                          builder: (controller) {
                            return Wrap(
                              children: [
                                for (int i = 0; i < mamzProducts.length; i++)
                                  ProductsCard(
                                      selected: mamzBool[i],
                                      onTap: () {
                                        mamzBool[i] = !mamzBool[i];

                                        if (mamzBool[i] == true) {
                                          controller.addWorkScope(
                                              WorkScopeModel(
                                                  name: mamzProducts[i]));
                                        } else {
                                          controller.workScope.removeWhere(
                                              (workScope) =>
                                                  workScope.name ==
                                                  mamzProducts[i]);
                                        }
                                        print(
                                            'products--->${json.encode(projectController.workScope)}');

                                        setState(() {});
                                      },
                                      title: mamzProducts[i]),
                              ],
                            );
                          }),
                      const Divider(),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 8),
                          child: Text(
                            'Radiant Products',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 19),
                          ),
                        ),
                      ),
                      const Divider(),
                      Wrap(
                        children: [
                          for (int i = 0; i < products.length; i++)
                            ProductsCard(
                                selected: productsBool[i],
                                onTap: () {
                                  productsBool[i] = !productsBool[i];

                                  if (productsBool[i] == true) {
                                    projectController.addWorkScope(
                                        WorkScopeModel(name: products[i]));
                                  } else {
                                    projectController.workScope.removeWhere(
                                        (workScope) =>
                                            workScope.name == products[i]);
                                  }
                                  print(
                                      'products--->${json.encode(projectController.workScope)}');
                                  setState(() {});
                                },
                                title: products[i]),
                        ],
                      ),
                      const Divider(),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 8),
                          child: Text(
                            'Roofline Products',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 19),
                          ),
                        ),
                      ),
                      const Divider(),
                      Wrap(
                        children: [
                          for (int i = 0; i < rooflineProducts.length; i++)
                            ProductsCard(
                                selected: rooflineBool[i],
                                onTap: () {
                                  rooflineBool[i] = !rooflineBool[i];

                                  if (rooflineBool[i] == true) {
                                    projectController.addWorkScope(
                                        WorkScopeModel(
                                            name: rooflineProducts[i]));
                                  } else {
                                    projectController.workScope.removeWhere(
                                        (workScope) =>
                                            workScope.name ==
                                            rooflineProducts[i]);
                                  }
                                  print(
                                      'products--->${json.encode(projectController.workScope)}');
                                  setState(() {});
                                },
                                title: rooflineProducts[i]),
                        ],
                      ),
                    ],
                  ),
                  const Positioned(
                    right: 0,
                    child: Text('*',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.red)),
                  )
                ],
              ),
              const SizedBox(height: 2),
              if (projectController.workScope.isEmpty &&
                  selectWorkScope == true)
                formErrorText(error: 'Please select workscope'),
              const SizedBox(height: 2),
              CustomTextField(
                controller: projectController.productPriceCont,
                prefixIcon: Icons.attach_money_outlined,
                hint: 'Product Price',
                inputType: TextInputType.number,
                prefixColor: Colors.blue,
              ),
              if (loginStorage.getUserRole() == 'ASM (Area Sales Manager)' ||
                  loginStorage.getUserRole() == 'New Recruits')
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton(
                      isExpanded: true,
                      hint: Text(selectRegion ?? 'Select Region'),
                      items: region.map((e) {
                        return DropdownMenuItem(
                            value: e,
                            onTap: () {
                              selectRegion = e;
                              setState(() {});
                            },
                            child: Text(e));
                      }).toList(),
                      onChanged: (_) {}),
                ),
              CustomTextField(
                controller: projectController.descriptionControl,
                prefixIcon: CupertinoIcons.bubble_left,
                hint: 'Description',
                maxLines: 3,
                prefixColor: Colors.blue,
              ),
              if (isDescriptionError)
                formErrorText(error: descriptionErrorString),
              CustomTextField(
                controller: projectController.projectManagerCont,
                prefixIcon: CupertinoIcons.person,
                hint: 'Project Manager / Architect',
                prefixColor: Colors.blueAccent,
              ),
              if (isProjectManagerError)
                formErrorText(error: projectManagerErrorString),
              CustomTextField(
                controller: projectController.timeDurationControl,
                prefixIcon: CupertinoIcons.time_solid,
                hint: 'Time Duration',
                prefixColor: Colors.blue,
              ),
              if (isTimeDurationError)
                formErrorText(error: timeDurationErrorString),
              CustomTextField(
                controller: projectController.workForceControl,
                prefixIcon: CupertinoIcons.person_2_fill,
                hint: 'Work Force',
                inputType: TextInputType.number,
                prefixColor: Colors.teal,
              ),
              if (isWorkForceError) formErrorText(error: workForceErrorString),
              CustomTextField(
                controller: projectController.budgetCont,
                prefixIcon: CupertinoIcons.money_dollar_circle_fill,
                inputType: TextInputType.number,
                hint: 'Budget',
                prefixColor: Colors.green,
              ),
              if (isBudgetError) formErrorText(error: budgetErrorString),
              CustomTextField(
                controller: projectController.tentativeCostCont,
                prefixIcon: CupertinoIcons.money_dollar_circle,
                inputType: TextInputType.number,
                hint: 'Project Estimate',
                prefixColor: Colors.red,
              ),
              if (isTentativeCostError)
                formErrorText(error: tentativeCostErrorString),
              CustomTextField(
                controller: projectController.locationCont,
                prefixIcon: CupertinoIcons.location_solid,
                hint: 'Location',
                prefixColor: Colors.orange,
              ),
              if (isLocationError) formErrorText(error: locationErrorString),
              CustomTextField(
                controller: projectController.notesCont,
                prefixIcon: CupertinoIcons.pencil,
                hint: 'Notes',
                prefixColor: Colors.black54,
              ),
              CustomTextField(
                controller: projectController.contactPersonNameCont,
                prefixIcon: CupertinoIcons.person_solid,
                hint: 'Contact Person Name',
                prefixColor: Colors.blueAccent,
              ),
              if (isContactPersonNameError)
                formErrorText(error: contactPersonNameErrorString),
              CustomTextField(
                controller: projectController.contactPersonPhoneCont,
                prefixIcon: CupertinoIcons.phone_fill,
                hint: 'Person Contact Phone',
                inputType: TextInputType.phone,
                prefixColor: Colors.green,
              ),
              if (isContactPersonPhoneError)
                formErrorText(error: contactPersonPhoneErrorString),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  value: projectController.priority.value.isEmpty
                      ? null
                      : projectController.priority.value,
                  hint: const Text("Select Project Priority"),
                  isExpanded: true,
                  onChanged: (String? newValue) {
                    setState(() {
                      projectController.priority.value = newValue!;
                    });
                  },
                  items: <String>['Low', 'Medium', 'High']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              if (isPriorityError) formErrorText(error: priorityErrorString),
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
                      hint: Text(projectController.company.value == ''
                          ? "Select Company"
                          : projectController.company.value),
                      isExpanded: true,
                      onChanged: (_) {},
                      items: Company.getRoleBasedCompanies()
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          onTap: () {
                            setState(() {
                              projectController.company.value = value;

                              print(
                                  'company--->${projectController.company.value}');
                            });
                          },
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  const Positioned(
                    right: 0,
                    child: Text('*',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.red)),
                  )
                ],
              ),
              // if (isCompanyError) formErrorText(error: companyErrorString),
              InkWell(
                onTap: projectController.addFileFunction,
                child: Container(
                  height: 100,
                  width: Get.width,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.cloud_upload_fill),
                      if (widget.projectData != null &&
                          widget.projectData!.filePath != null)
                        Align(
                            alignment: Alignment.center,
                            child: Text(
                              widget.projectData!.filePath != null
                                  ? widget.projectData!.filePath!
                                      .split('-')
                                      .last
                                  : 'No file path available',
                              // Fallback text in case filePath is null
                              textAlign: TextAlign.center,
                            ))
                      else
                        Text(projectController.fileName.value.isEmpty
                            ? 'Add File'
                            : projectController.fileName.toString()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              widget.projectData != null
                  ? GetBuilder(
                      init: projectController,
                      builder: (contr) {
                        return CustomButton(
                            title: 'Update Project',
                            onTap: () async {
                              await contr.updateProjectFunction(
                                  widget.projectData!.filePath,
                                  widget.projectData!.sId);

                              loginController.sendProjectUpdateNotification(
                                  widget.reciverId,
                                  widget.projectData!.sId,
                                  'You project ${widget.projectData!.name} is updated',
                                  widget.token,
                                  widget.senderName);
                            },
                            child: contr.assignmentLoader
                                ? customCircleLoader()
                                : null);
                      })
                  : CustomButton(
                      onTap: () async {
                        if (validation()) {
                          if (isFormValid() ||
                              projectController.workScope.isEmpty) {
                            selectWorkScope = true;
                            setState(() {});

                            if (projectController.workScope.isNotEmpty) {
                              bool isProjectAdded =
                                  await projectController.addProject(context);

                              if (isProjectAdded) {
                                projectController.workScope.clear();
                                selectWorkScope = false;

                                await Get.offAll(const BottomNavScreen());
                              }
                            }
                          }
                        }
                      },
                      title: 'Save ',
                      child: projectController.loading.value == true
                          ? customCircleLoader()
                          : null,
                    ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      );
    });
  }

  bool isFormValid() {
    bool isValid = true;
    resetErrors();

    if (projectController.projectNameControl.text.isEmpty) {
      projectNameErrorString = 'Please enter the project name';
      isProjectNameError = true;
      isValid = false;
    }
    if (projectController.clientNameControl.text.isEmpty) {
      clientNameErrorString = 'Please enter the client name';
      isClientError = true;
      isValid = false;
    }

    setState(() {});
    return isValid;
  }

  void resetErrors() {
    isProjectNameError = false;
    isDescriptionError = false;
    isProjectManagerError = false;
    isTimeDurationError = false;
    isWorkForceError = false;
    isBudgetError = false;
    isTentativeCostError = false;
    isLocationError = false;
    isContactPersonNameError = false;
    isContactPersonPhoneError = false;
    isPriorityError = false;
    isCompanyError = false;

    projectNameErrorString = '';
    descriptionErrorString = '';
    projectManagerErrorString = '';
    timeDurationErrorString = '';
    workForceErrorString = '';
    budgetErrorString = '';
    tentativeCostErrorString = '';
    locationErrorString = '';
    contactPersonNameErrorString = '';
    contactPersonPhoneErrorString = '';
    priorityErrorString = '';
    companyErrorString = '';
  }

  bool validation() {
    if (projectController.projectNameControl.text.isEmpty) {
      Get.snackbar('Error', 'Please enter the project name',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } else if (projectController.clientNameControl.text.isEmpty) {
      Get.snackbar('Error', 'Please enter the client name',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } else if (projectController.company.value == '') {
      Get.snackbar('Error', 'Please select the company name',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } else if (projectController.workScope.isEmpty) {
      Get.snackbar('Error', 'Please select the workscope',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } else {
      return true;
    }
  }
}

class CustomExpansion extends StatefulWidget {
  String? title;
  Function()? onTap;

  bool? openData;

  List<Widget>? children;

  CustomExpansion(
      {super.key, this.title, this.onTap, this.openData, this.children});

  @override
  State<CustomExpansion> createState() => _CustomExpansionState();
}

class _CustomExpansionState extends State<CustomExpansion> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (widget.onTap),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8),
        child: Card(
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 13.0, vertical: 10),
                child: Row(
                  children: [
                    Text(
                      widget.title!,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w400),
                    ),
                    const Spacer(),
                    Icon(widget.openData == true
                        ? Icons.arrow_upward
                        : Icons.arrow_downward)
                  ],
                ),
              ),
              widget.openData == true
                  ? Column(children: widget.children!)
                  : const SizedBox.shrink(),
              const SizedBox(
                height: 8,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ProductsCard extends StatefulWidget {
  String? title;
  bool selected;
  Function()? onTap;

  ProductsCard({super.key, this.title, this.onTap, required this.selected});

  @override
  State<ProductsCard> createState() => _ProductsCardState();
}

class _ProductsCardState extends State<ProductsCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (widget.onTap),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Chip(
            backgroundColor: widget.selected ? appColor : Colors.black12,
            label: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.title!,
                style: TextStyle(
                    color: widget.selected ? Colors.white : Colors.black),
              ),
            )),
      ),
    );
  }
}

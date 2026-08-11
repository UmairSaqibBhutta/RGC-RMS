import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/controllers/visit_controller.dart';
import 'package:leadmanagementsystem/widgets/custom_button.dart';
import 'package:leadmanagementsystem/widgets/custom_text_field.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';

class AddVisitScreen extends StatefulWidget {
  const AddVisitScreen({super.key});

  @override
  State<AddVisitScreen> createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitScreen> {
  @override
  initState() {
    super.initState();
  }

  final controller = Get.find<VisitController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mAppbar("Add Visit Report"),
      body: GetBuilder<VisitController>(
        builder: (cont) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CustomTextField(
                  hint: "Town / Phase",
                  controller: cont.townPhaseCont,
                  prefixIcon: Icons.location_city,
                  isRequiredField: true,
                ),
                CustomTextField(
                  hint: "Block",
                  controller: cont.blockCont,
                  prefixIcon: Icons.grid_view,
                ),
                CustomTextField(
                  hint: "Site",
                  controller: cont.siteCont,
                  prefixIcon: Icons.home_work,
                  isRequiredField: true,
                ),
                CustomTextField(
                  hint: "GCO Name",
                  controller: cont.gcoCont,
                  prefixIcon: Icons.person,
                ),
                CustomTextField(
                  hint: "Key Person Name",
                  controller: cont.keyPNCont,
                  prefixIcon: Icons.person_outline,
                ),
                CustomTextField(
                  hint: "Key Person Contact",
                  controller: cont.keyPCCont,
                  prefixIcon: Icons.phone,
                  inputType: TextInputType.phone,
                ),
                CustomTextField(
                  hint: "Architect",
                  controller: cont.architectCont,
                  prefixIcon: Icons.architecture,
                ),
                CustomTextField(
                  hint: "Notes",
                  controller: cont.callResultCont,
                  prefixIcon: Icons.call,
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                cont.isLoading
                    ? showSpinkit()
                    : CustomButton(
                        title: "Submit",
                        onTap: cont.submitData,
                      ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

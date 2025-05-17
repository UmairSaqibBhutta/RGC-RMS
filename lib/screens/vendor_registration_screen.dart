import 'package:flutter/material.dart';
import 'package:leadmanagementsystem/widgets/custom_text_field.dart';


class VendorRegistrationScreen extends StatefulWidget {
  const VendorRegistrationScreen({super.key});

  @override
  State<VendorRegistrationScreen> createState() =>
      _VendorRegistrationScreenState();
}

class _VendorRegistrationScreenState extends State<VendorRegistrationScreen> {
  PageController? pageController;

  double progressValue = 0.0;

  void updateProgress() {
    setState(() {
      progressValue =
          (pageController!.page ?? 0) / 3; // Assuming 3 pages, adjust as needed
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    pageController = PageController(initialPage: 0);
    pageController!.addListener(updateProgress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
      ),
      body: Stack(
        children: [
          PageView(
            controller: pageController,
            children: [
              Expanded(
                child: Column(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          customWidgets(
                              'Vendor Registration', FontWeight.w500, 20),
                          customWidgets(
                              'Complete form below to signup as a vendor',
                              FontWeight.w400,
                              15),
                          const SizedBox(height: 20),
                          CustomTextField(
                            hint: 'Business Name',
                          ),
                          CustomTextField(
                            hint: 'Company Address',
                          ),
                          CustomTextField(
                            hint: 'Address Line 2',
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: CustomTextField(
                                hint: 'City',
                              )),
                              Expanded(
                                  child: CustomTextField(
                                hint: 'Province',
                              )),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: CustomTextField(
                                hint: 'Postal/ZipCode',
                              )),
                              Expanded(
                                  child: CustomTextField(
                                hint: 'Country',
                              )),
                            ],
                          ),
                          CustomTextField(
                            hint: 'Phone Number 1',
                          ),
                          CustomTextField(
                            hint: 'Phone Number 2',
                          ),
                          CustomTextField(
                            hint: 'Email',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Column(
                children: [],
              ),
              const Column(
                children: [],
              ),
            ],
          ),
          LinearProgressIndicator(
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
            value: progressValue,
          )
        ],
      ),
    );
  }
}

customWidgets(String txt, FontWeight? fontWeight, double? size) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2.0),
    child: Text(txt, style: TextStyle(fontWeight: fontWeight, fontSize: size)),
  );
}

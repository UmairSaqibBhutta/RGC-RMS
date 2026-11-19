import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/controllers/visitor_controller.dart';
import 'package:leadmanagementsystem/widgets/custom_button.dart';
import 'package:leadmanagementsystem/models/visitor_detail_model.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';
import 'package:leadmanagementsystem/widgets/responsive_body.dart';

/// Add a visitor, or edit one when [visitor] is provided.
class AddVisitorScreen extends StatefulWidget {
  final VisitorDetail? visitor;
  const AddVisitorScreen({super.key, this.visitor});

  @override
  State<AddVisitorScreen> createState() => _AddVisitorScreenState();
}

class _AddVisitorScreenState extends State<AddVisitorScreen> {
  final controller = Get.find<VisitorController>();

  @override
  void initState() {
    super.initState();
    widget.visitor != null
        ? controller.prefill(widget.visitor!)
        : controller.clearForm();
  }

  bool get _isEdit => widget.visitor != null;

  Future<void> _pick(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
        source: source, imageQuality: 80, maxWidth: 1600, maxHeight: 1600);
    if (picked != null) controller.setCardImage(File(picked.path));
  }

  void _chooseSource() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: appColor),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pick(ImageSource.camera);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library_outlined, color: appColor),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pick(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final ok = await controller.submit(editingId: widget.visitor?.id);
    if (ok && mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: mAppbar(_isEdit ? 'Edit Visitor' : 'Add Visitor'),
      body: GetBuilder<VisitorController>(builder: (c) {
        return Stack(
          children: [
            LayoutBuilder(builder: (context, box) {
              final wide = box.maxWidth >= 760;
              final cardSec = _card('Visiting Card', [_cardPicker(c)]);
              final companySec = _card('Company & Person', [
                _field('Company Name *', c.companyCont,
                    icon: Icons.business_outlined,
                    caps: TextCapitalization.words),
                _field('Person Name *', c.personCont,
                    icon: Icons.person_outline, caps: TextCapitalization.words),
                _field('Designation *', c.designationCont,
                    icon: Icons.badge_outlined, caps: TextCapitalization.words),
              ]);
              final contactSec = _card('Contact', [
                for (int i = 0; i < c.phoneConts.length; i++) _phoneRow(c, i),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: c.addPhoneField,
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text('Add another number'),
                    style: TextButton.styleFrom(foregroundColor: appColor),
                  ),
                ),
                const SizedBox(height: 6),
                _field('Email Address', c.emailCont,
                    icon: Icons.mail_outline, type: TextInputType.emailAddress),
              ]);
              final officeSec = _card('Office', [
                _field('Office Address *', c.addressCont,
                    icon: Icons.location_on_outlined,
                    lines: 3,
                    caps: TextCapitalization.sentences),
              ]);
              return ResponsiveBody(
                maxWidth: 1000,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                  children: [
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Column(children: [cardSec, officeSec])),
                          const SizedBox(width: 16),
                          Expanded(
                              child:
                                  Column(children: [companySec, contactSec])),
                        ],
                      )
                    else ...[cardSec, companySec, contactSec, officeSec],
                  ],
                ),
              );
            }),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: ResponsiveBody(
                    maxWidth: 1000,
                    child: c.isSubmitting
                        ? const SizedBox(
                            height: 50,
                            child: Center(child: AppLoader(size: 28)))
                        : CustomButton(
                            title: _isEdit ? 'Update Visitor' : 'Save Visitor',
                            onTap: _save)),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _cardPicker(VisitorController c) {
    if (c.cardImage == null && c.existingImage == null) {
      return InkWell(
        onTap: _chooseSource,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: appColor.withValues(alpha: .06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: appColor.withValues(alpha: .4)),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_outlined, size: 36, color: appColor),
              SizedBox(height: 8),
              Text('Scan / upload visiting card',
                  style:
                      TextStyle(color: appColor, fontWeight: FontWeight.w600)),
              SizedBox(height: 2),
              Text('Optional', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: c.cardImage != null
              ? Image.file(c.cardImage!,
                  height: 190, width: double.infinity, fit: BoxFit.cover)
              : Image.network(baseUrl + c.existingImage!,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(
                      height: 120,
                      child: Center(child: Icon(Icons.broken_image_outlined)))),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(children: [
            _roundBtn(Icons.edit, _chooseSource),
            // Backend can't remove an existing image, only replace it.
            if (c.cardImage != null) ...[
              const SizedBox(width: 6),
              _roundBtn(Icons.close, () => c.setCardImage(null)),
            ],
          ]),
        ),
      ],
    );
  }

  Widget _roundBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: const BoxDecoration(
              color: Colors.black54, shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
      );

  Widget _phoneRow(VisitorController c, int i) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: _field(
              i == 0 ? 'Contact Number *' : 'Contact Number ${i + 1}',
              c.phoneConts[i],
              icon: Icons.phone_outlined,
              type: TextInputType.phone,
              formatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]'))
              ],
            ),
          ),
          if (c.phoneConts.length > 1)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () => c.removePhoneField(i),
            ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController cont, {
    required IconData icon,
    TextInputType type = TextInputType.text,
    TextCapitalization caps = TextCapitalization.none,
    List<TextInputFormatter>? formatters,
    int lines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: cont,
        keyboardType: lines > 1 ? TextInputType.multiline : type,
        textCapitalization: caps,
        inputFormatters: formatters,
        minLines: lines,
        maxLines: lines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: appColor, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: TextStyle(
                  fontSize: 11,
                  letterSpacing: .8,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

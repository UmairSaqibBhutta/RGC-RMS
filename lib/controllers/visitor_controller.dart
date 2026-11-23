import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/api_urls.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/visitor_detail_model.dart';
import 'package:leadmanagementsystem/widgets/custom_snackbar.dart';

class VisitorController extends GetxController {
  // ---- Form ----
  final companyCont = TextEditingController();
  final personCont = TextEditingController();
  final designationCont = TextEditingController();
  final emailCont = TextEditingController();
  final addressCont = TextEditingController();
  final commentsCont = TextEditingController();
  final List<TextEditingController> phoneConts = [TextEditingController()];

  static const int maxImages = 10;

  /// Newly picked images, not yet uploaded.
  final List<File> newImages = [];

  /// Images already on the server (file names) while editing.
  final List<String> existingImages = [];

  /// Existing images the user removed; sent as `remove_images` on update.
  final List<String> removedImages = [];

  int get imageCount => existingImages.length + newImages.length;
  int get remainingSlots => maxImages - imageCount;

  // ---- List ----
  List<VisitorDetail> _all = [];
  bool isListLoading = false;
  bool isSubmitting = false;
  String searchQuery = '';

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Visitors after applying the search filter (API returns everything).
  List<VisitorDetail> get visitors {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _all;
    return _all.where((v) => v.searchText.contains(q)).toList();
  }

  VisitorDetail? byId(String id) {
    for (final v in _all) {
      if (v.id == id) return v;
    }
    return null;
  }

  // ---- Form helpers ----
  void addPhoneField() {
    if (phoneConts.length >= 5) {
      CustomSnackbar.warning('Maximum 5 contact numbers allowed');
      return;
    }
    phoneConts.add(TextEditingController());
    update();
  }

  void removePhoneField(int i) {
    if (phoneConts.length == 1) return;
    phoneConts.removeAt(i).dispose();
    update();
  }

  /// Adds picked images, keeping the total within [maxImages].
  void addImages(List<File> files) {
    if (files.isEmpty) return;
    final slots = remainingSlots;
    if (slots <= 0) {
      CustomSnackbar.warning('You can add up to $maxImages images');
      return;
    }
    if (files.length > slots) {
      CustomSnackbar.warning('Only $maxImages images allowed, extra ignored');
    }
    newImages.addAll(files.take(slots));
    update();
  }

  void removeNewImage(int i) {
    newImages.removeAt(i);
    update();
  }

  void removeExistingImage(String name) {
    if (existingImages.remove(name)) removedImages.add(name);
    update();
  }

  void prefill(VisitorDetail v) {
    clearForm();
    companyCont.text = v.companyName;
    personCont.text = v.personName;
    designationCont.text = v.designation;
    emailCont.text = v.email;
    addressCont.text = v.officeAddress;
    commentsCont.text = v.comments;
    if (v.contacts.isNotEmpty) {
      phoneConts.first.text = v.contacts.first;
      for (final n in v.contacts.skip(1)) {
        phoneConts.add(TextEditingController(text: n));
      }
    }
    existingImages.addAll(v.images);
  }

  /// Every field is optional, but the form can't be completely empty.
  String? validate() {
    final phones = phoneConts
        .map((c) => c.text.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final email = emailCont.text.trim();

    final isEmpty = companyCont.text.trim().isEmpty &&
        personCont.text.trim().isEmpty &&
        designationCont.text.trim().isEmpty &&
        phones.isEmpty &&
        email.isEmpty &&
        addressCont.text.trim().isEmpty &&
        commentsCont.text.trim().isEmpty &&
        imageCount == 0;
    if (isEmpty) return 'Please attach an image or fill in at least one field';

    if (phones.any((p) => p.replaceAll(RegExp(r'\D'), '').length < 7)) {
      return 'Enter valid contact number(s)';
    }
    if (email.isNotEmpty && !_emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Creates a visitor, or updates [editingId] when provided.
  Future<bool> submit({String? editingId}) async {
    final error = validate();
    if (error != null) {
      CustomSnackbar.error(error);
      return false;
    }
    try {
      isSubmitting = true;
      update();

      final phones = phoneConts
          .map((c) => c.text.trim())
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList();

      final response = await postRequest.customMultipartRepeated(
        url: editingId == null
            ? ApiUrls.addVisitor
            : '${ApiUrls.updateVisitor}/$editingId',
        fields: {
          'company_name': companyCont.text.trim(),
          'person_name': personCont.text.trim(),
          'designation': designationCont.text.trim(),
          'email': emailCont.text.trim(),
          'office_address': addressCont.text.trim(),
          'comments': commentsCont.text.trim(),
        },
        repeatedFields: {
          'contact': phones,
          if (editingId != null && removedImages.isNotEmpty)
            'remove_images': List.of(removedImages),
        },
        files: newImages,
        fileField: 'images',
      );

      if (response == null) {
        CustomSnackbar.error('No response from server');
        return false;
      }
      if (response['status'] != true) {
        CustomSnackbar.error(response['message'] ?? 'Failed to save visitor');
        return false;
      }
      CustomSnackbar.success(response['message'] ?? 'Visitor saved');
      clearForm();
      await getVisitors(showLoader: false);
      return true;
    } catch (e) {
      log('❌ submit visitor: $e');
      CustomSnackbar.error('Something went wrong');
      return false;
    } finally {
      isSubmitting = false;
      update();
    }
  }

  /// Asks for confirmation, then deletes. Returns true when deleted.
  Future<bool> confirmAndDelete(VisitorDetail v) async {
    final name = v.personName.isNotEmpty
        ? v.personName
        : (v.companyName.isNotEmpty ? v.companyName : 'this visitor');
    final ok = await Get.dialog<bool>(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Delete visitor?'),
      content:
          Text('This will permanently remove $name and all saved card images.'),
      actions: [
        TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel')),
        TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete')),
      ],
    ));
    if (ok != true) return false;
    return deleteVisitor(v.id);
  }

  Future<bool> deleteVisitor(String id) async {
    try {
      isSubmitting = true;
      update();
      final response = await postRequest.customPostRequest(
        url: '${ApiUrls.deleteVisitor}/$id',
        body: {},
      );
      if (response == null || response['status'] != true) {
        CustomSnackbar.error(response?['message'] ?? 'Failed to delete');
        return false;
      }
      _all.removeWhere((v) => v.id == id);
      CustomSnackbar.success(response['message'] ?? 'Visitor deleted');
      return true;
    } catch (e) {
      log('❌ delete visitor: $e');
      CustomSnackbar.error('Something went wrong');
      return false;
    } finally {
      isSubmitting = false;
      update();
    }
  }

  void clearForm() {
    companyCont.clear();
    personCont.clear();
    designationCont.clear();
    emailCont.clear();
    addressCont.clear();
    commentsCont.clear();
    for (final c in phoneConts.skip(1)) {
      c.dispose();
    }
    phoneConts
      ..removeRange(1, phoneConts.length)
      ..first.clear();
    newImages.clear();
    existingImages.clear();
    removedImages.clear();
  }

  Future<void> getVisitors({bool showLoader = true}) async {
    try {
      if (showLoader) {
        isListLoading = true;
        update();
      }
      final response =
          await getRequest.customGetRequest(apiPath: ApiUrls.getVisitors);
      if (response == null || response['status'] != true) {
        CustomSnackbar.error(
            response?['message'] ?? 'Failed to fetch visitors');
        return;
      }
      _all = (response['data'] as List? ?? [])
          .map((e) => VisitorDetail.fromJson(e))
          .toList();
    } catch (e) {
      log('❌ getVisitors: $e');
      CustomSnackbar.error('Failed to fetch visitors');
    } finally {
      isListLoading = false;
      update();
    }
  }

  void search(String q) {
    searchQuery = q;
    update();
  }

  @override
  void onClose() {
    companyCont.dispose();
    personCont.dispose();
    designationCont.dispose();
    emailCont.dispose();
    addressCont.dispose();
    commentsCont.dispose();
    for (final c in phoneConts) {
      c.dispose();
    }
    super.onClose();
  }
}

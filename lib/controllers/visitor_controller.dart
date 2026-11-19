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
  final List<TextEditingController> phoneConts = [TextEditingController()];
  File? cardImage;

  /// Existing image (file name) while editing.
  String? existingImage;

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

  void setCardImage(File? f) {
    cardImage = f;
    if (f != null) existingImage = null;
    update();
  }

  void prefill(VisitorDetail v) {
    clearForm();
    companyCont.text = v.companyName;
    personCont.text = v.personName;
    designationCont.text = v.designation;
    emailCont.text = v.email;
    addressCont.text = v.officeAddress;
    if (v.contacts.isNotEmpty) {
      phoneConts.first.text = v.contacts.first;
      for (final n in v.contacts.skip(1)) {
        phoneConts.add(TextEditingController(text: n));
      }
    }
    existingImage = v.hasImage ? v.image : null;
  }

  String? validate() {
    if (companyCont.text.trim().isEmpty) return 'Company name is required';
    if (personCont.text.trim().isEmpty) return 'Person name is required';
    if (designationCont.text.trim().isEmpty) return 'Designation is required';
    final phones =
        phoneConts.map((c) => c.text.trim()).where((e) => e.isNotEmpty);
    if (phones.isEmpty) return 'At least one contact number is required';
    if (phones.any((p) => p.replaceAll(RegExp(r'\D'), '').length < 7)) {
      return 'Enter valid contact number(s)';
    }
    final email = emailCont.text.trim();
    if (email.isNotEmpty && !_emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }
    if (addressCont.text.trim().isEmpty) return 'Office address is required';
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
        },
        repeatedFields: {'contact': phones},
        file: cardImage,
        fileField: 'image',
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
    for (final c in phoneConts.skip(1)) {
      c.dispose();
    }
    phoneConts
      ..removeRange(1, phoneConts.length)
      ..first.clear();
    cardImage = null;
    existingImage = null;
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
    for (final c in phoneConts) {
      c.dispose();
    }
    super.onClose();
  }
}

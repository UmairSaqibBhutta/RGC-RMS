import 'dart:io';

import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/api_urls.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/chat_members_model.dart';

class MyChatController extends GetxController {
  bool loading = false;

  List<Member> members = [];

  updateLoading(bool val) {
    loading = val;
    update();
  }

  getChatMembers() async {
    if (members.isNotEmpty) {
      return;
    }
    final res =
        await getRequest.customGetRequest(apiPath: ApiUrls.getChatMembers);

    List data = res["data"];

    members = data.map((e) => Member.fromJson(e)).toList().cast<Member>();

    update();
  }

  Future<String?> uploadImage(File file) async {
    final res = await postRequest.customFileUpload(
        url: ApiUrls.uploadImage, file: file);

    if (res == null) {
      return null;
    }

    return res["filePath"];
  }
}

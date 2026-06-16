class MainStagesModel {
  bool status;
  List<MainStageData> data;

  MainStagesModel({required this.status, required this.data});

  factory MainStagesModel.fromJson(Map<String, dynamic> json) =>
      MainStagesModel(
        status: json['status'] ?? false,
        data: json['data'] != null
            ? List<MainStageData>.from(
                json['data'].map((x) => MainStageData.fromJson(x)))
            : [],
      );
}

class MainStageData {
  String id;
  String title;
  int stageNo;

  MainStageData({required this.id, required this.title, required this.stageNo});

  factory MainStageData.fromJson(Map<String, dynamic> json) => MainStageData(
        id: json['_id'] ?? '',
        title: json['title'] ?? '',
        stageNo: (json['stage_no'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'stage_no': stageNo,
      };
}

class SubStagesModel {
  bool status;
  List<SubStageData> data;

  SubStagesModel({required this.status, required this.data});

  factory SubStagesModel.fromJson(Map<String, dynamic> json) => SubStagesModel(
        status: json['status'] ?? false,
        data: json['data'] != null
            ? List<SubStageData>.from(
                json['data'].map((x) => SubStageData.fromJson(x)))
            : [],
      );
}

class SubStageData {
  String id;
  String mainStageId;
  String title;

  SubStageData(
      {required this.id, required this.mainStageId, required this.title});

  factory SubStageData.fromJson(Map<String, dynamic> json) => SubStageData(
        id: json['_id'] ?? '',
        mainStageId: json['main_stage_id']?.toString() ?? '',
        title: json['title'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'main_stage_id': mainStageId,
        'title': title,
      };
}

class VisitReportModel {
  bool? status;
  List<VisitReportDetails>? data;

  VisitReportModel({this.status, this.data});

  VisitReportModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <VisitReportDetails>[];
      json['data'].forEach((v) {
        data!.add(VisitReportDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VisitReportDetails {
  String? sId;
  String? userId;
  String? visitDate;
  String? name;
  String? role;

  List<VisitDetail>? visitDetail;

  VisitReportDetails(
      {this.sId, this.userId, this.visitDate, this.visitDetail, this.name, this.role});

  VisitReportDetails.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    visitDate = json['visitDate'];
    name = json['name'];
    role = json['role'];
    if (json['visitDetail'] != null) {
      visitDetail = <VisitDetail>[];
      json['visitDetail'].forEach((v) {
        visitDetail!.add(VisitDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['userId'] = userId;
    data['visitDate'] = visitDate;
    data['name'] = name;
    data['role'] = role;
    if (visitDetail != null) {
      data['visitDetail'] = visitDetail!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VisitDetail {
  String? siteName;
  String? contactPerson;
  String? contactNumber;
  String? visitPlan;
  String? visitReport;

  String? sId;

  VisitDetail(
      {this.siteName,
      this.contactPerson,
      this.contactNumber,
      this.visitPlan,
      this.visitReport,
      this.sId});

  VisitDetail.fromJson(Map<String, dynamic> json) {
    siteName = json['siteName'];
    contactPerson = json['contactPerson'];
    contactNumber = json['contactNumber'];
    visitPlan = json['visitPlan'];
    visitReport = json['visitReport'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['siteName'] = siteName;
    data['contactPerson'] = contactPerson;
    data['contactNumber'] = contactNumber;
    data['visitPlan'] = visitPlan;
    data['visitReport'] = visitReport;
    data['_id'] = sId;
    return data;
  }
}

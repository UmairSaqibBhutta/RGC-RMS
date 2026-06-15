class ProjectPagination {
  final int myProjectsTotalPages;
  final int assignProjectsTotalPages;
  final int teamProjectsTotalPages;

  ProjectPagination.fromJson(Map<String, dynamic> json)
      : myProjectsTotalPages = json['myProjectsTotalPages'] ?? 1,
        assignProjectsTotalPages = json['assignProjectsTotalPages'] ?? 0,
        teamProjectsTotalPages = json['teamProjectsTotalPages'] ?? 1;
}

class ProjectCounts {
  final int myProjectsCount;
  final int assignProjectsCount;
  final int teamProjectsCount;

  ProjectCounts.fromJson(Map<String, dynamic> json)
      : myProjectsCount = json['myProjectsCount'] ?? 0,
        assignProjectsCount = json['assignProjectsCount'] ?? 0,
        teamProjectsCount = json['teamProjectsCount'] ?? 0;
}

class ProjectModel {
  bool? status;
  List<ProjectData>? assignedProjects;
  List<ProjectData>? myProjects;
  List<ProjectData>? teamProjects;
  ProjectPagination? pagination;
  ProjectCounts? counts;

  ProjectModel(
      {this.status,
      this.assignedProjects,
      this.myProjects,
      this.teamProjects,
      this.pagination,
      this.counts});

  ProjectModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    pagination = json['pagination'] != null
        ? ProjectPagination.fromJson(json['pagination'])
        : null;
    counts = json['counts'] != null
        ? ProjectCounts.fromJson(json['counts'])
        : null;
    if (json['assignProjects'] != null) {
      assignedProjects = <ProjectData>[];
      json['assignProjects'].forEach((v) {
        assignedProjects!.add(ProjectData.fromJson(v));
      });
    }
    if (json['projectData'] != null) {
      teamProjects = <ProjectData>[];
      json['projectData'].forEach((v) {
        teamProjects!.add(ProjectData.fromJson(v));
      });
    }

    if (json['myProjects'] != null) {
      myProjects = <ProjectData>[];
      json['myProjects'].forEach((v) {
        myProjects!.add(ProjectData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (assignedProjects != null) {
      data['assignProjects'] =
          assignedProjects!.map((v) => v.toJson()).toList();
    }
    if (myProjects != null) {
      data['myProjects'] = myProjects!.map((v) => v.toJson()).toList();
    }

    if (teamProjects != null) {
      data['projectData'] = teamProjects!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProjectData {
  String? sId;
  String? userId;
  String? name;
  String? consultName;
  String? consultPhone;
  String? ownerMe;
  String? ownerName;
  String? ownerContact;
  String? status;
  String? title;
  String? description;
  String? projectManager;
  String? duration;
  String? workForce;
  String? budget;
  String? company;
  String? projectCreatedDate;
  String? tentativeCost;
  String? location;
  String? notes;
  String? personName;
  String? personContacts;
  String? projectPriority;
  String? contractorName;
  String? contractorPMName;
  String? contractorPMPhone;
  String? region;
  String? role;
  String? contractorMEName;
  String? contractorMEPhone;
  String? clientName;
  String? consultantName;
  String? consultantREName;
  String? consultantREPhone;
  String? consultantMEName;
  String? consultantMEPhone;
  String? precourmentName;
  String? precourmentPhone;
  String? accountOfficerName;
  String? accountOfficerPhone;
  String? priceValue;
  List<WorkScope>? workScope;
  String? filePath;
  String? creatorName;
  String? creatorRole;

  ProjectData(
      {this.sId,
      this.userId,
      this.name,
      this.consultName,
      this.consultPhone,
      this.ownerMe,
      this.ownerName,
      this.ownerContact,
      this.status,
      this.title,
      this.description,
      this.projectManager,
      this.duration,
      this.workForce,
      this.budget,
      this.company,
      this.tentativeCost,
      this.location,
      this.notes,
      this.personName,
      this.personContacts,
      this.projectPriority,
      this.contractorName,
      this.contractorPMName,
      this.contractorPMPhone,
      this.region,
      this.role,
      this.contractorMEName,
      this.contractorMEPhone,
      this.clientName,
      this.consultantName,
      this.projectCreatedDate,
      this.consultantREName,
      this.consultantREPhone,
      this.consultantMEName,
      this.consultantMEPhone,
      this.precourmentName,
      this.precourmentPhone,
      this.accountOfficerName,
      this.accountOfficerPhone,
      this.priceValue,
      this.workScope,
      this.filePath,
      this.creatorName,
      this.creatorRole});

  ProjectData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    name = json['name'];
    consultName = json['consultName'];
    consultPhone = json['consultPhone'];
    ownerMe = json['ownerMe'];
    projectCreatedDate =
        json['projectCreatedDate'] ?? DateTime.now().toIso8601String();
    ownerName = json['ownerName'];
    ownerContact = json['ownerContact'];
    status = json['status'] ?? "";
    title = json['title'];
    description = json['description'];
    projectManager = json['projectManager'];
    duration = json['duration'];
    workForce = json['workForce'];
    budget = json['budget'];
    company = json['company'];
    tentativeCost = json['tentativeCode'];
    location = json['location'];
    notes = json['notes'];
    personName = json['personName'];
    personContacts = json['personContacts'];
    projectPriority = json['projectPriority'];
    contractorName = json['contractorName'];
    contractorPMName = json['contractorREName'];
    contractorPMPhone = json['contractorREPhone'];
    region = json['region'];
    role = json['role'];
    contractorMEName = json['contractorMEName'];
    contractorMEPhone = json['contractorMEPhone'];
    clientName = json['clientName'];
    consultantName = json['consultantName'];
    consultantREName = json['consultantREName'];
    consultantREPhone = json['consultantREPhone'];
    consultantMEName = json['consultantMEName'];
    consultantMEPhone = json['consultantMEPhone'];
    precourmentName = json['precourmentName'];
    precourmentPhone = json['precourmentPhone'];
    accountOfficerName = json['accountOfficerName'];
    accountOfficerPhone = json['accountOfficerPhone'];
    priceValue = json['priceValue'];
    if (json['workScope'] != null) {
      workScope = <WorkScope>[];
      json['workScope'].forEach((v) {
        workScope!.add(WorkScope.fromJson(v));
      });
    } else {
      workScope = [];
    }
    filePath = json['filePath'] ?? '';
    creatorName = json['creatorName'];
    creatorRole = json['creatorRole'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['userId'] = userId;
    data['name'] = name;
    data['consultName'] = consultName;
    data['consultPhone'] = consultPhone;
    data['ownerMe'] = ownerMe;
    data['ownerName'] = ownerName;
    data['ownerContact'] = ownerContact;
    data['status'] = status;
    data['title'] = title;
    data['description'] = description;
    data['projectManager'] = projectManager;
    data['duration'] = duration;
    data['projectCreatedDate'] = projectCreatedDate;
    data['workForce'] = workForce;
    data['budget'] = budget;
    data['company'] = company;
    data['tentativeCode'] = tentativeCost;
    data['location'] = location;
    data['notes'] = notes;
    data['personName'] = personName;
    data['personContacts'] = personContacts;
    data['projectPriority'] = projectPriority;
    data['contractorName'] = contractorName;
    data['contractorREName'] = contractorPMName;
    data['contractorREPhone'] = contractorPMPhone;
    data['region'] = region;
    data['role'] = role;
    data['contractorMEName'] = contractorMEName;
    data['contractorMEPhone'] = contractorMEPhone;
    data['clientName'] = clientName;
    data['consultantName'] = consultantName;
    data['consultantREName'] = consultantREName;
    data['consultantREPhone'] = consultantREPhone;
    data['consultantMEName'] = consultantMEName;
    data['consultantMEPhone'] = consultantMEPhone;
    data['precourmentName'] = precourmentName;
    data['precourmentPhone'] = precourmentPhone;
    data['accountOfficerName'] = accountOfficerName;
    data['accountOfficerPhone'] = accountOfficerPhone;
    data['priceValue'] = priceValue;
    if (workScope != null) {
      data['workScope'] = workScope!.map((v) => v.toJson()).toList();
    }
    data['filePath'] = filePath;
    data['creatorName'] = creatorName;
    data['creatorRole'] = creatorRole;
    return data;
  }
}

class WorkScope {
  String? name;
  String? sId;

  WorkScope({this.name, this.sId});

  WorkScope.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['_id'] = sId;
    return data;
  }
}

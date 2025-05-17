class WorkScopeModel {
  String? name;

  WorkScopeModel({this.name});

  Map<String, dynamic> toJson() {
    return {'name': name};
  }

  factory WorkScopeModel.fromJson(Map<String, dynamic> json) {
    return WorkScopeModel(name: json['name']);
  }
}

class Member {
  String? userId;
  String? name;

  Member({
    this.userId,
    this.name,
  });

  Member.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['name'] = name;
    return data;
  }
}

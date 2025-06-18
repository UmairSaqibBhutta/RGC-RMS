import 'dart:convert';

class ReminderModel {
  final int id;
  final String title;
  final String description;
  final DateTime dateTime;

  ReminderModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'dateTime': dateTime.toIso8601String(),
      };

  factory ReminderModel.fromJson(Map<String, dynamic> json) => ReminderModel(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        dateTime: DateTime.parse(json['dateTime']),
      );

  static String encodeList(List<ReminderModel> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<ReminderModel> decodeList(String data) =>
      (jsonDecode(data) as List).map((e) => ReminderModel.fromJson(e)).toList();
}

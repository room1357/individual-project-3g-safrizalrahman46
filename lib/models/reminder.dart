import 'dart:convert';

class Reminder {
  final String id;
  final String title;
  final String category;
  final DateTime dateTime;
  final String? note;

  Reminder({
    required this.id,
    required this.title,
    required this.category,
    required this.dateTime,
    this.note,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      dateTime: DateTime.parse(json['dateTime']),
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'dateTime': dateTime.toIso8601String(),
        'note': note,
      };
}

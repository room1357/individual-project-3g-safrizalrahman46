class Reminder {
  final String id;
  final String title;
  final String category;
  final double? amount;
  final DateTime dateTime;
  final String? description;
  final String? attachmentPath;

  Reminder({
    required this.id,
    required this.title,
    required this.category,
    required this.dateTime,
    this.amount,
    this.description,
    this.attachmentPath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'amount': amount,
        'dateTime': dateTime.toIso8601String(),
        'description': description,
        'attachmentPath': attachmentPath,
      };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'],
        title: json['title'],
        category: json['category'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        dateTime: DateTime.parse(json['dateTime']),
        description: json['description'],
        attachmentPath: json['attachmentPath'],
      );
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String description;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
  });

  /// Membuat objek [Expense] dari JSON
  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
        id: j['id'] as String,
        title: j['title'] as String,
        amount: (j['amount'] as num).toDouble(),
        category: j['category'] as String,
        date: DateTime.parse(j['date'] as String),
        description: j['description'] as String? ?? '',
      );

  /// Mengubah [Expense] menjadi JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category,
        'date': date.toIso8601String(),
        'description': description,
      };

  /// Format tampilan amount
  String get formattedAmount => 'Rp ${amount.toStringAsFixed(0)}';

  /// Format tampilan tanggal
  String get formattedDate => '${date.day}/${date.month}/${date.year}';

  /// Copy objek dengan perubahan tertentu
  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? description,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }

  /// Untuk debugging: menampilkan isi objek dalam bentuk teks
  @override
  String toString() {
    return 'Expense(id: $id, title: $title, amount: $amount, category: $category, date: $date, description: $description)';
  }

  /// Membandingkan dua objek [Expense] berdasarkan nilai
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense &&
        other.id == id &&
        other.title == title &&
        other.amount == amount &&
        other.category == category &&
        other.date == date &&
        other.description == description;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      amount.hashCode ^
      category.hashCode ^
      date.hashCode ^
      description.hashCode;
}


// class Expense {
//   final String id;
//   final String title;
//   final double amount;
//   final String category;
//   final DateTime date;
//   final String description;

//   Expense({
//     required this.id,
//     required this.title,
//     required this.amount,
//     required this.category,
//     required this.date,
//     required this.description,
//   });

//   factory Expense.fromJson(Map<String, dynamic> j) => Expense(
//         id: j['id'] as String,
//         title: j['title'] as String,
//         amount: (j['amount'] as num).toDouble(),
//         category: j['category'] as String,
//         date: DateTime.parse(j['date'] as String),
//         description: j['description'] as String? ?? '',
//       );

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'title': title,
//         'amount': amount,
//         'category': category,
//         'date': date.toIso8601String(),
//         'description': description,
//       };

//         factory Expense.fromJson(Map<String, dynamic> json) => Expense(
//         id: json['id'],
//         title: json['title'],
//         category: json['category'],
//         amount: (json['amount'] as num).toDouble(),
//         description: json['description'],
//         date: DateTime.parse(json['date']),
//       );

//   // format tampilan
//   String get formattedAmount => 'Rp ${amount.toStringAsFixed(0)}';
//   String get formattedDate => '${date.day}/${date.month}/${date.year}';
// }
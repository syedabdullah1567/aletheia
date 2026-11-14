class ExpenseEntry {
  final String id;
  final double amount;
  final String category; // e.g. Food, Transport
  final String note; // what it was spent on
  final DateTime date;

  const ExpenseEntry({
    required this.id,
    required this.amount,
    required this.category,
    this.note = '',
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'category': category,
        'note': note,
        'date': date.toIso8601String(),
      };

  factory ExpenseEntry.fromMap(Map<dynamic, dynamic> map) => ExpenseEntry(
        id: map['id'] as String,
        amount: (map['amount'] as num).toDouble(),
        category: map['category'] as String? ?? 'Other',
        note: map['note'] as String? ?? '',
        date: DateTime.parse(map['date'] as String),
      );

  ExpenseEntry copyWith({
    double? amount,
    String? category,
    String? note,
    DateTime? date,
  }) =>
      ExpenseEntry(
        id: id,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        note: note ?? this.note,
        date: date ?? this.date,
      );
}

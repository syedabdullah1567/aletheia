class IncomeEntry {
  final String id;
  final double amount;
  final String source; // e.g. Gift, Pocket money, Salary
  final String note;
  final DateTime date;

  const IncomeEntry({
    required this.id,
    required this.amount,
    required this.source,
    this.note = '',
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'source': source,
        'note': note,
        'date': date.toIso8601String(),
      };

  factory IncomeEntry.fromMap(Map<dynamic, dynamic> map) => IncomeEntry(
        id: map['id'] as String,
        amount: (map['amount'] as num).toDouble(),
        source: map['source'] as String? ?? 'Other',
        note: map['note'] as String? ?? '',
        date: DateTime.parse(map['date'] as String),
      );

  IncomeEntry copyWith({
    double? amount,
    String? source,
    String? note,
    DateTime? date,
  }) =>
      IncomeEntry(
        id: id,
        amount: amount ?? this.amount,
        source: source ?? this.source,
        note: note ?? this.note,
        date: date ?? this.date,
      );
}

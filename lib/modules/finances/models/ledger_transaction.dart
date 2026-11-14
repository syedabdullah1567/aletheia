/// borrowed = money came TO me (I owe them more, or I'm being repaid)
/// gave     = money went FROM me (they owe me more, or I'm repaying them)
enum LedgerType { borrowed, gave }

class LedgerTransaction {
  final String id;
  final String personId;
  final double amount; // always positive
  final LedgerType type;
  final String note;
  final DateTime timestamp;

  const LedgerTransaction({
    required this.id,
    required this.personId,
    required this.amount,
    required this.type,
    this.note = '',
    required this.timestamp,
  });

  /// Effect on the person's balance: positive = they owe me more.
  double get signedAmount => type == LedgerType.gave ? amount : -amount;

  Map<String, dynamic> toMap() => {
        'id': id,
        'personId': personId,
        'amount': amount,
        'type': type.name,
        'note': note,
        'timestamp': timestamp.toIso8601String(),
      };

  factory LedgerTransaction.fromMap(Map<dynamic, dynamic> map) =>
      LedgerTransaction(
        id: map['id'] as String,
        personId: map['personId'] as String,
        amount: (map['amount'] as num).toDouble(),
        type: LedgerType.values.firstWhere(
          (t) => t.name == map['type'],
          orElse: () => LedgerType.borrowed,
        ),
        note: map['note'] as String? ?? '',
        timestamp: DateTime.parse(map['timestamp'] as String),
      );

  LedgerTransaction copyWith({
    double? amount,
    LedgerType? type,
    String? note,
    DateTime? timestamp,
  }) =>
      LedgerTransaction(
        id: id,
        personId: personId,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        note: note ?? this.note,
        timestamp: timestamp ?? this.timestamp,
      );
}

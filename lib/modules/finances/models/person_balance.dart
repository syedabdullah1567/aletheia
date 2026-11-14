import 'person.dart';

/// A person plus their computed net balance with me.
/// balance > 0  -> they owe me   (green)
/// balance < 0  -> I owe them    (red)
class PersonBalance {
  static const double _epsilon = 0.005;

  final Person person;
  final double balance;
  final DateTime? lastActivity;

  const PersonBalance({
    required this.person,
    required this.balance,
    this.lastActivity,
  });

  bool get theyOweMe => balance > _epsilon;
  bool get iOweThem => balance < -_epsilon;
  bool get isSettled => !theyOweMe && !iOweThem;

  /// Amount to display (always positive).
  double get absAmount => balance.abs();
}

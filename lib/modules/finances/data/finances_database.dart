import 'package:hive_flutter/hive_flutter.dart';

class FinancesDatabase {
  // Database Structures (id -> entry map)
  Map<String, dynamic> incomeLog = {};
  Map<String, dynamic> expenseLog = {};
  Map<String, dynamic> peopleLog = {};
  Map<String, dynamic> ledgerLog = {};

  // Reference the box
  final _myBox = Hive.box('MyBox');

  static const String _incomeKey = 'FINANCE_INCOME';
  static const String _expenseKey = 'FINANCE_EXPENSES';
  static const String _peopleKey = 'FINANCE_PEOPLE';
  static const String _ledgerKey = 'FINANCE_LEDGER';

  /// Timestamp-based unique id for new entries.
  static String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  void createInitialData() {
    incomeLog = <String, dynamic>{};
    expenseLog = <String, dynamic>{};
    peopleLog = <String, dynamic>{};
    ledgerLog = <String, dynamic>{};
  }

  Map<String, dynamic> _readMap(String key) {
    final raw = _myBox.get(key);
    return raw != null
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};
  }

  void loadData() {
    incomeLog = _readMap(_incomeKey);
    expenseLog = _readMap(_expenseKey);
    peopleLog = _readMap(_peopleKey);
    ledgerLog = _readMap(_ledgerKey);
  }

  void updateDataBase() {
    _myBox.put(_incomeKey, incomeLog);
    _myBox.put(_expenseKey, expenseLog);
    _myBox.put(_peopleKey, peopleLog);
    _myBox.put(_ledgerKey, ledgerLog);
  }
}

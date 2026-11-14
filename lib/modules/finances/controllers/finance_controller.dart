import 'package:flutter/foundation.dart';

import '../data/finances_database.dart';
import '../models/expense_entry.dart';
import '../models/income_entry.dart';
import '../models/ledger_transaction.dart';
import '../models/person.dart';
import '../models/person_balance.dart';
import '../utils/finance_formatters.dart';

enum LedgerFilter { all, iOwe, owedToMe }

class FinanceController extends ChangeNotifier {
  final FinancesDatabase _db = FinancesDatabase();

  FinanceController() {
    _db.loadData();
  }

  void _commit() {
    _db.updateDataBase();
    notifyListeners();
  }

  // ───────────────────────── Income ─────────────────────────

  List<IncomeEntry> get allIncome => _db.incomeLog.values
      .map((v) => IncomeEntry.fromMap(v as Map))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  List<IncomeEntry> incomeForMonth(DateTime month) =>
      allIncome.where((e) => isSameMonth(e.date, month)).toList();

  double totalIncomeForMonth(DateTime month) =>
      incomeForMonth(month).fold(0.0, (sum, e) => sum + e.amount);

  void addIncome({
    required double amount,
    required String source,
    String note = '',
    DateTime? date,
  }) {
    final id = FinancesDatabase.newId();
    _db.incomeLog[id] = IncomeEntry(
      id: id,
      amount: amount,
      source: source,
      note: note,
      date: date ?? DateTime.now(),
    ).toMap();
    _commit();
  }

  void updateIncome(IncomeEntry entry) {
    _db.incomeLog[entry.id] = entry.toMap();
    _commit();
  }

  void deleteIncome(String id) {
    _db.incomeLog.remove(id);
    _commit();
  }

  // ───────────────────────── Expenses ─────────────────────────

  List<ExpenseEntry> get allExpenses => _db.expenseLog.values
      .map((v) => ExpenseEntry.fromMap(v as Map))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  List<ExpenseEntry> expensesForMonth(DateTime month) =>
      allExpenses.where((e) => isSameMonth(e.date, month)).toList();

  double totalExpensesForMonth(DateTime month) =>
      expensesForMonth(month).fold(0.0, (sum, e) => sum + e.amount);

  /// category -> total spent, for one month, largest first.
  Map<String, double> categoryTotalsForMonth(DateTime month) {
    final totals = <String, double>{};
    for (final e in expensesForMonth(month)) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {for (final e in sorted) e.key: e.value};
  }

  /// Every month that has at least one expense, newest first.
  List<DateTime> get monthsWithExpenses {
    final months = allExpenses.map((e) => monthStart(e.date)).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    return months;
  }

  void addExpense({
    required double amount,
    required String category,
    String note = '',
    DateTime? date,
  }) {
    final id = FinancesDatabase.newId();
    _db.expenseLog[id] = ExpenseEntry(
      id: id,
      amount: amount,
      category: category,
      note: note,
      date: date ?? DateTime.now(),
    ).toMap();
    _commit();
  }

  void updateExpense(ExpenseEntry entry) {
    _db.expenseLog[entry.id] = entry.toMap();
    _commit();
  }

  void deleteExpense(String id) {
    _db.expenseLog.remove(id);
    _commit();
  }

  // ───────────────────────── People ─────────────────────────

  List<Person> get people => _db.peopleLog.values
      .map((v) => Person.fromMap(v as Map))
      .toList()
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  Person? personById(String id) {
    final raw = _db.peopleLog[id];
    return raw == null ? null : Person.fromMap(raw as Map);
  }

  /// Returns the existing person with this name (case-insensitive),
  /// or creates a new one.
  Person addPerson(String name) {
    final trimmed = name.trim();
    for (final p in people) {
      if (p.name.toLowerCase() == trimmed.toLowerCase()) return p;
    }
    final id = FinancesDatabase.newId();
    final person = Person(id: id, name: trimmed);
    _db.peopleLog[id] = person.toMap();
    _commit();
    return person;
  }

  void renamePerson(String id, String newName) {
    final person = personById(id);
    if (person == null) return;
    _db.peopleLog[id] = person.copyWith(name: newName.trim()).toMap();
    _commit();
  }

  /// Deletes the person AND all of their transactions.
  void deletePerson(String id) {
    _db.peopleLog.remove(id);
    _db.ledgerLog.removeWhere((_, v) => (v as Map)['personId'] == id);
    _commit();
  }

  // ───────────────────────── Ledger ─────────────────────────

  List<LedgerTransaction> get allTransactions => _db.ledgerLog.values
      .map((v) => LedgerTransaction.fromMap(v as Map))
      .toList()
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  /// Newest first.
  List<LedgerTransaction> transactionsForPerson(String personId) =>
      allTransactions.where((t) => t.personId == personId).toList();

  void addTransaction({
    required String personId,
    required double amount,
    required LedgerType type,
    String note = '',
    DateTime? timestamp,
  }) {
    final id = FinancesDatabase.newId();
    _db.ledgerLog[id] = LedgerTransaction(
      id: id,
      personId: personId,
      amount: amount,
      type: type,
      note: note,
      timestamp: timestamp ?? DateTime.now(),
    ).toMap();
    _commit();
  }

  void updateTransaction(LedgerTransaction transaction) {
    _db.ledgerLog[transaction.id] = transaction.toMap();
    _commit();
  }

  void deleteTransaction(String id) {
    _db.ledgerLog.remove(id);
    _commit();
  }

  /// Net balance with one person. > 0 they owe me, < 0 I owe them.
  double balanceFor(String personId) => transactionsForPerson(personId)
      .fold(0.0, (sum, t) => sum + t.signedAmount);

  /// Everyone I've transacted with, most recent activity first,
  /// optionally filtered to red (I owe) or green (owed to me).
  List<PersonBalance> balances({LedgerFilter filter = LedgerFilter.all}) {
    final txns = allTransactions;
    final result = <PersonBalance>[];

    for (final person in people) {
      final mine = txns.where((t) => t.personId == person.id).toList();
      final balance = mine.fold(0.0, (sum, t) => sum + t.signedAmount);
      final pb = PersonBalance(
        person: person,
        balance: balance,
        lastActivity: mine.isEmpty ? null : mine.first.timestamp,
      );

      switch (filter) {
        case LedgerFilter.all:
          result.add(pb);
        case LedgerFilter.iOwe:
          if (pb.iOweThem) result.add(pb);
        case LedgerFilter.owedToMe:
          if (pb.theyOweMe) result.add(pb);
      }
    }

    result.sort((a, b) {
      final aDate = a.lastActivity ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.lastActivity ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return result;
  }

  /// Total I currently owe across everyone.
  double get totalIOwe =>
      balances().where((b) => b.iOweThem).fold(0.0, (s, b) => s + b.absAmount);

  /// Total others currently owe me.
  double get totalOwedToMe => balances()
      .where((b) => b.theyOweMe)
      .fold(0.0, (s, b) => s + b.absAmount);
}

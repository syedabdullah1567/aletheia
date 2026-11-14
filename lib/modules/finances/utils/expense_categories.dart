import 'package:flutter/material.dart';

class ExpenseCategory {
  final String name;
  final IconData icon;

  const ExpenseCategory(this.name, this.icon);
}

/// Starter categories. Edit freely; names are what gets stored in Hive,
/// so renaming one won't rename it on entries you've already saved.
const List<ExpenseCategory> kExpenseCategories = [
  ExpenseCategory('Food', Icons.restaurant_rounded),
  ExpenseCategory('Transport', Icons.directions_bus_rounded),
  ExpenseCategory('Shopping', Icons.shopping_bag_outlined),
  ExpenseCategory('Bills', Icons.receipt_long_outlined),
  ExpenseCategory('Entertainment', Icons.movie_outlined),
  ExpenseCategory('Health', Icons.medical_services_outlined),
  ExpenseCategory('Education', Icons.school_outlined),
  ExpenseCategory('Other', Icons.more_horiz_rounded),
];

/// Falls back to a generic icon for categories not in the list above.
IconData iconForCategory(String name) {
  for (final c in kExpenseCategories) {
    if (c.name.toLowerCase() == name.toLowerCase()) return c.icon;
  }
  return Icons.category_outlined;
}

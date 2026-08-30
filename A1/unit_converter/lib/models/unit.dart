import 'package:flutter/material.dart' show IconData;

/// A single unit of measure, e.g. "Kilometres".
///
/// Every unit inside a category is described relative to that category's base
/// unit. Metres is the base for length, so a kilometre has a [toBaseFactor] of
/// 1000 and an inch has 0.0254. Temperature does not work this way, which is
/// why [Category] carries a flag for it.
class Unit {
  const Unit({
    required this.name,
    required this.symbol,
    required this.toBaseFactor,
  });

  /// Full name shown in the dropdown, e.g. "Kilometres".
  final String name;

  /// Short form shown next to the result, e.g. "km".
  final String symbol;

  /// How many base units fit into one of this unit.
  final double toBaseFactor;

  @override
  String toString() => '$name ($symbol)';
}

/// A family of units that can be converted between each other.
///
/// You cannot convert kilograms into miles, so the UI keeps the unit lists
/// separated by category and only ever converts within one of them.
class Category {
  const Category({
    required this.name,
    required this.icon,
    required this.units,
    this.isTemperature = false,
  });

  final String name;

  /// Icon shown on the category chip.
  final IconData icon;

  final List<Unit> units;

  /// Temperature conversions need an offset (the freezing point) as well as a
  /// ratio, so they are handled by a dedicated branch in the converter.
  final bool isTemperature;
}

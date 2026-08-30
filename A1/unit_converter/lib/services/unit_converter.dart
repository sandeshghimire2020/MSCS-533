import '../models/unit.dart';

/// Pure conversion maths. Nothing in here touches Flutter, which keeps it easy
/// to unit test on its own.
class UnitConverter {
  const UnitConverter._();

  /// Converts [value] from [from] to [to] inside [category].
  ///
  /// Throws an [ArgumentError] if the two units do not belong to the same
  /// category, because that conversion has no physical meaning.
  static double convert({
    required double value,
    required Unit from,
    required Unit to,
    required Category category,
  }) {
    if (!category.units.contains(from) || !category.units.contains(to)) {
      throw ArgumentError('Both units must belong to ${category.name}.');
    }

    if (category.isTemperature) {
      return _convertTemperature(value, from, to);
    }

    // Everything else is a two step trip: into the base unit, then back out.
    final double inBaseUnits = value * from.toBaseFactor;
    return inBaseUnits / to.toBaseFactor;
  }

  /// Temperature scales have different zero points, so they go through Celsius
  /// rather than a simple multiplication.
  static double _convertTemperature(double value, Unit from, Unit to) {
    final double celsius = switch (from.symbol) {
      '°F' => (value - 32) * 5 / 9,
      'K' => value - 273.15,
      _ => value,
    };

    return switch (to.symbol) {
      '°F' => celsius * 9 / 5 + 32,
      'K' => celsius + 273.15,
      _ => celsius,
    };
  }

  /// Trims a result down to something readable.
  ///
  /// Very small and very large numbers keep scientific notation so they do not
  /// collapse to "0", and trailing zeros are dropped so 5.0 reads as "5".
  static String format(double value) {
    if (value == 0) {
      return '0';
    }

    final double magnitude = value.abs();
    if (magnitude < 0.0001 || magnitude >= 1000000000) {
      return value.toStringAsExponential(4);
    }

    // Six significant-ish digits is plenty for a phone screen.
    final String fixed = value.toStringAsFixed(6);
    return fixed.contains('.')
        ? fixed.replaceFirst(RegExp(r'\.?0+$'), '')
        : fixed;
  }
}

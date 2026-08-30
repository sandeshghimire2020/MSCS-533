import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/data/categories.dart';
import 'package:unit_converter/models/unit.dart';
import 'package:unit_converter/services/unit_converter.dart';

void main() {
  final Category length = kCategories[0];
  final Category weight = kCategories[1];
  final Category temperature = kCategories[2];

  Unit unitNamed(Category category, String name) =>
      category.units.firstWhere((Unit unit) => unit.name == name);

  group('Metric to imperial', () {
    test('1 kilometre is about 0.621 miles', () {
      final double result = UnitConverter.convert(
        value: 1,
        from: unitNamed(length, 'Kilometres'),
        to: unitNamed(length, 'Miles'),
        category: length,
      );

      expect(result, closeTo(0.621371, 0.000001));
    });

    test('1 kilogram is about 2.205 pounds', () {
      final double result = UnitConverter.convert(
        value: 1,
        from: unitNamed(weight, 'Kilograms'),
        to: unitNamed(weight, 'Pounds'),
        category: weight,
      );

      expect(result, closeTo(2.204623, 0.000001));
    });
  });

  group('Temperature', () {
    test('water freezes at 32 F', () {
      final double result = UnitConverter.convert(
        value: 0,
        from: unitNamed(temperature, 'Celsius'),
        to: unitNamed(temperature, 'Fahrenheit'),
        category: temperature,
      );

      expect(result, closeTo(32, 0.0001));
    });

    test('absolute zero is -273.15 C', () {
      final double result = UnitConverter.convert(
        value: 0,
        from: unitNamed(temperature, 'Kelvin'),
        to: unitNamed(temperature, 'Celsius'),
        category: temperature,
      );

      expect(result, closeTo(-273.15, 0.0001));
    });
  });

  test('converting across categories is rejected', () {
    expect(
      () => UnitConverter.convert(
        value: 1,
        from: unitNamed(length, 'Miles'),
        to: unitNamed(weight, 'Pounds'),
        category: length,
      ),
      throwsArgumentError,
    );
  });

  test('formatting drops trailing zeros', () {
    expect(UnitConverter.format(5), '5');
    expect(UnitConverter.format(2.5), '2.5');
  });
}

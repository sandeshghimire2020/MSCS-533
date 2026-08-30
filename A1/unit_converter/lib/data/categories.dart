import 'package:flutter/material.dart';

import '../models/unit.dart';

/// The unit tables the app ships with.
///
/// Factors are the exact internationally agreed definitions (1 in = 0.0254 m,
/// 1 lb = 0.45359237 kg, 1 US gal = 3.785411784 L), so round-tripping a value
/// gives back what you started with.
const List<Category> kCategories = <Category>[
  Category(
    name: 'Length',
    icon: Icons.straighten,
    units: <Unit>[
      Unit(name: 'Millimetres', symbol: 'mm', toBaseFactor: 0.001),
      Unit(name: 'Centimetres', symbol: 'cm', toBaseFactor: 0.01),
      Unit(name: 'Metres', symbol: 'm', toBaseFactor: 1),
      Unit(name: 'Kilometres', symbol: 'km', toBaseFactor: 1000),
      Unit(name: 'Inches', symbol: 'in', toBaseFactor: 0.0254),
      Unit(name: 'Feet', symbol: 'ft', toBaseFactor: 0.3048),
      Unit(name: 'Yards', symbol: 'yd', toBaseFactor: 0.9144),
      Unit(name: 'Miles', symbol: 'mi', toBaseFactor: 1609.344),
    ],
  ),
  Category(
    name: 'Weight',
    icon: Icons.monitor_weight_outlined,
    units: <Unit>[
      Unit(name: 'Milligrams', symbol: 'mg', toBaseFactor: 0.000001),
      Unit(name: 'Grams', symbol: 'g', toBaseFactor: 0.001),
      Unit(name: 'Kilograms', symbol: 'kg', toBaseFactor: 1),
      Unit(name: 'Tonnes', symbol: 't', toBaseFactor: 1000),
      Unit(name: 'Ounces', symbol: 'oz', toBaseFactor: 0.028349523125),
      Unit(name: 'Pounds', symbol: 'lb', toBaseFactor: 0.45359237),
      Unit(name: 'Stones', symbol: 'st', toBaseFactor: 6.35029318),
    ],
  ),
  Category(
    name: 'Temperature',
    icon: Icons.thermostat,
    isTemperature: true,
    units: <Unit>[
      // The factor is unused for temperature, but a const constructor still
      // needs a value, so the base unit's 1 is used as a placeholder.
      Unit(name: 'Celsius', symbol: '°C', toBaseFactor: 1),
      Unit(name: 'Fahrenheit', symbol: '°F', toBaseFactor: 1),
      Unit(name: 'Kelvin', symbol: 'K', toBaseFactor: 1),
    ],
  ),
  Category(
    name: 'Volume',
    icon: Icons.local_drink_outlined,
    units: <Unit>[
      Unit(name: 'Millilitres', symbol: 'mL', toBaseFactor: 0.001),
      Unit(name: 'Litres', symbol: 'L', toBaseFactor: 1),
      Unit(name: 'Cups (US)', symbol: 'cup', toBaseFactor: 0.2365882365),
      Unit(name: 'Pints (US)', symbol: 'pt', toBaseFactor: 0.473176473),
      Unit(name: 'Gallons (US)', symbol: 'gal', toBaseFactor: 3.785411784),
    ],
  ),
];

import 'package:flutter/material.dart';

import 'screens/converter_screen.dart';

void main() {
  runApp(const UnitConverterApp());
}

/// Root of the app. Its only job is to set up theming and hand control to the
/// converter screen.
class UnitConverterApp extends StatelessWidget {
  const UnitConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF00695C),
    );

    return MaterialApp(
      title: 'Unit Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: colorScheme.surface,
      ),
      home: const ConverterScreen(),
    );
  }
}

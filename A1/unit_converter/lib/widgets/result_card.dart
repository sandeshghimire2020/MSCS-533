import 'package:flutter/material.dart';

import '../models/unit.dart';
import '../services/unit_converter.dart';

/// Panel at the bottom of the screen that shows the converted value.
///
/// When there is nothing to show (empty or invalid input) it falls back to a
/// short prompt rather than an empty box.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.sourceText,
    required this.fromUnit,
    required this.toUnit,
    required this.result,
  });

  final String sourceText;
  final Unit fromUnit;
  final Unit toUnit;
  final double? result;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasResult = result != null;

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: <Widget>[
            Text(
              hasResult
                  ? '$sourceText ${fromUnit.symbol}  ='
                  : 'Enter a value to convert',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            if (hasResult) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                '${UnitConverter.format(result!)} ${toUnit.symbol}',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                toUnit.name,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

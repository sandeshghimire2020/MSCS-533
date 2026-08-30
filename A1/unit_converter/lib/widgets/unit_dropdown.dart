import 'package:flutter/material.dart';

import '../models/unit.dart';

/// Labelled dropdown listing every unit in the active category.
///
/// The "From" and "To" pickers are identical apart from their label, so they
/// share this widget instead of being written out twice. A plain
/// [DropdownButton] inside an [InputDecorator] is used rather than
/// `DropdownButtonFormField` so the widget behaves the same across Flutter
/// versions.
class UnitDropdown extends StatelessWidget {
  const UnitDropdown({
    super.key,
    required this.label,
    required this.units,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final List<Unit> units;
  final Unit selected;
  final ValueChanged<Unit> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Unit>(
            value: selected,
            isExpanded: true,
            items: <DropdownMenuItem<Unit>>[
              for (final Unit unit in units)
                DropdownMenuItem<Unit>(
                  value: unit,
                  child: Text('${unit.name} (${unit.symbol})'),
                ),
            ],
            onChanged: (Unit? unit) {
              if (unit != null) {
                onChanged(unit);
              }
            },
          ),
        ),
      ),
    );
  }
}

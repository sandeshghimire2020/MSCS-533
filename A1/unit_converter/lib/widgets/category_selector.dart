import 'package:flutter/material.dart';

import '../models/unit.dart';

/// Horizontal row of chips used to pick the measure family.
class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<Category> categories;
  final Category selected;
  final ValueChanged<Category> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (final Category category in categories)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                avatar: Icon(category.icon, size: 18),
                label: Text(category.name),
                selected: category == selected,
                // Re-selecting the current chip should not reset the screen.
                onSelected: (bool isSelected) {
                  if (isSelected) {
                    onSelected(category);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

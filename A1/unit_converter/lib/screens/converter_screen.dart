import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/categories.dart';
import '../models/unit.dart';
import '../services/unit_converter.dart';
import '../widgets/category_selector.dart';
import '../widgets/result_card.dart';
import '../widgets/unit_dropdown.dart';

/// The single screen of the app: pick a category, pick two units, type a
/// number, read the answer.
class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _inputController =
      TextEditingController(text: '1');

  late Category _category = kCategories.first;
  late Unit _fromUnit = _category.units.first;
  late Unit _toUnit = _category.units[3]; // Metres -> Kilometres to start with.

  /// Null while the text field holds something that is not a number yet.
  double? _result;

  /// Message shown under the field when the input cannot be parsed.
  String? _errorText;

  @override
  void initState() {
    super.initState();
    // Recalculate on every keystroke so the result feels live.
    _inputController.addListener(_recalculate);
    _recalculate();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  /// Parses the text field and stores either a result or an error message.
  void _recalculate() {
    final String raw = _inputController.text.trim();

    if (raw.isEmpty) {
      setState(() {
        _result = null;
        _errorText = null;
      });
      return;
    }

    final double? value = double.tryParse(raw);
    if (value == null) {
      setState(() {
        _result = null;
        _errorText = 'Enter a valid number';
      });
      return;
    }

    setState(() {
      _errorText = null;
      _result = UnitConverter.convert(
        value: value,
        from: _fromUnit,
        to: _toUnit,
        category: _category,
      );
    });
  }

  /// Switching category invalidates the current units, so both are reset.
  void _onCategoryChanged(Category category) {
    setState(() {
      _category = category;
      _fromUnit = category.units.first;
      _toUnit = category.units.length > 1
          ? category.units[1]
          : category.units.first;
    });
    _recalculate();
  }

  /// Swaps the two dropdowns, which is the shortcut people reach for most.
  void _swapUnits() {
    setState(() {
      final Unit previousFrom = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = previousFrom;
    });
    _recalculate();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit Converter'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      // The field is dismissed when the user taps anywhere else on the page.
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                CategorySelector(
                  categories: kCategories,
                  selected: _category,
                  onSelected: _onCategoryChanged,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _inputController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  // Only digits, one decimal point and a leading minus sign
                  // ever reach the parser. Temperatures can be negative.
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^-?\d*\.?\d*'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Value',
                    hintText: 'Enter a number',
                    errorText: _errorText,
                    border: const OutlineInputBorder(),
                    suffixText: _fromUnit.symbol,
                  ),
                ),
                const SizedBox(height: 20),
                UnitDropdown(
                  label: 'From',
                  units: _category.units,
                  selected: _fromUnit,
                  onChanged: (Unit unit) {
                    setState(() => _fromUnit = unit);
                    _recalculate();
                  },
                ),
                // A tidier alternative to two more taps in the dropdowns.
                Align(
                  child: IconButton.filledTonal(
                    onPressed: _swapUnits,
                    icon: const Icon(Icons.swap_vert),
                    tooltip: 'Swap units',
                  ),
                ),
                UnitDropdown(
                  label: 'To',
                  units: _category.units,
                  selected: _toUnit,
                  onChanged: (Unit unit) {
                    setState(() => _toUnit = unit);
                    _recalculate();
                  },
                ),
                const SizedBox(height: 28),
                ResultCard(
                  sourceText: _inputController.text.trim(),
                  fromUnit: _fromUnit,
                  toUnit: _toUnit,
                  result: _result,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:converto/features/convert/domain/conversion_option.dart';
import 'package:converto/features/convert/domain/converter.dart';
import 'package:converto/features/convert/engines/page_ranges.dart';
import 'package:converto/features/convert/presentation/labels.dart';
import 'package:converto/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

Future<OptionValues?> showOptionsSheet(
  BuildContext context, {
  required Converter converter,
  required List<ConversionOption> options,
}) => showModalBottomSheet<OptionValues>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  constraints: const BoxConstraints(maxWidth: 640),
  builder: (_) => OptionsSheet(converter: converter, options: options),
);

class OptionsSheet extends StatefulWidget {
  const OptionsSheet({required this.converter, required this.options, super.key});

  final Converter converter;
  final List<ConversionOption> options;

  @override
  State<OptionsSheet> createState() => _OptionsSheetState();
}

class _OptionsSheetState extends State<OptionsSheet> {
  late final Map<String, Object> _values = defaultValues(widget.options);

  bool get _valid => widget.options.whereType<PageSelectionOption>().every(
    (option) => parsePageRanges('${_values[option.id]}', option.pageCount) != null,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                '${l10n.optionsTitle} · ${targetTitle(l10n, widget.converter)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            for (final option in widget.options) ...[
              _buildOption(context, l10n, option),
              const SizedBox(height: 18),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _valid ? () => Navigator.of(context).pop(_values) : null,
                child: Text(l10n.convertButton(targetTitle(l10n, widget.converter))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, AppLocalizations l10n, ConversionOption option) {
    final label = optionLabel(l10n, option.id);
    switch (option) {
      case ToggleOption():
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          value: _values[option.id]! as bool,
          onChanged: (value) => setState(() => _values[option.id] = value),
        );
      case ChoiceOption():
        final current = _values[option.id]! as String;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final choice in option.choices)
                  ChoiceChip(
                    label: Text(choiceLabel(l10n, option.id, choice)),
                    selected: current == choice,
                    onSelected: (_) => setState(() => _values[option.id] = choice),
                  ),
              ],
            ),
          ],
        );
      case RangeOption():
        final value = (_values[option.id]! as num).toDouble();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(label, style: Theme.of(context).textTheme.titleSmall)),
                Text('${value.round()}${option.unit}'),
              ],
            ),
            Slider(
              min: option.min,
              max: option.max,
              divisions: option.divisions,
              value: value,
              label: '${value.round()}${option.unit}',
              semanticFormatterCallback: (v) => '$label ${v.round()}${option.unit}',
              onChanged: (v) => setState(() => _values[option.id] = v),
            ),
          ],
        );
      case PageSelectionOption():
        final text = '${_values[option.id]}';
        final invalid = parsePageRanges(text, option.pageCount) == null;
        return TextField(
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: label,
            hintText: l10n.optPagesHint,
            helperText: l10n.pagesCount(option.pageCount),
            errorText: invalid ? l10n.optPagesInvalid(option.pageCount) : null,
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => setState(() => _values[option.id] = value),
        );
    }
  }
}

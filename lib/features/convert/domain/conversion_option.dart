sealed class ConversionOption {
  const ConversionOption(this.id);

  final String id;
}

final class ToggleOption extends ConversionOption {
  const ToggleOption(super.id, {required this.initial});

  final bool initial;
}

final class ChoiceOption extends ConversionOption {
  const ChoiceOption(super.id, {required this.choices, required this.initial});

  final List<String> choices;
  final String initial;
}

final class RangeOption extends ConversionOption {
  const RangeOption(
    super.id, {
    required this.min,
    required this.max,
    required this.initial,
    this.divisions,
    this.unit = '',
  });

  final double min;
  final double max;
  final double initial;
  final int? divisions;
  final String unit;
}

final class PageSelectionOption extends ConversionOption {
  const PageSelectionOption(super.id, {required this.pageCount});

  final int pageCount;
}

typedef OptionValues = Map<String, Object>;

Map<String, Object> defaultValues(List<ConversionOption> options) => {
  for (final option in options)
    option.id: switch (option) {
      ToggleOption() => option.initial,
      ChoiceOption() => option.initial,
      RangeOption() => option.initial,
      PageSelectionOption() => '',
    },
};

extension OptionValuesRead on Map<String, Object> {
  bool toggle(String id) => (this[id] as bool?) ?? false;
  String choice(String id) => (this[id] as String?) ?? '';
  double range(String id) => (this[id] as num?)?.toDouble() ?? 0;
}

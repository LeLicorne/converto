import 'package:converto/features/convert/domain/converter.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:converto/features/convert/presentation/labels.dart';
import 'package:converto/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class TargetGrid extends StatelessWidget {
  const TargetGrid({required this.targets, required this.onSelected, super.key});

  final List<Converter> targets;
  final ValueChanged<Converter> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final grouped = <FormatCategory, List<Converter>>{};
    for (final converter in targets) {
      grouped.putIfAbsent(targetCategory(converter), () => []).add(converter);
    }
    final categories = FormatCategory.values.where(grouped.containsKey);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final category in categories) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 10),
            child: Semantics(
              header: true,
              child: Row(
                children: [
                  Icon(categoryIcon(category), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    categoryLabel(l10n, category),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final converter in grouped[category]!)
                _TargetTile(
                  title: targetTitle(l10n, converter),
                  onTap: () => onSelected(converter),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _TargetTile extends StatelessWidget {
  const _TargetTile({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: '${l10n.convertTo} $title',
      excludeSemantics: true,
      child: Material(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 96, minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Center(
                widthFactor: 1,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSecondaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

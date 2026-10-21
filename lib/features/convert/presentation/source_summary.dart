import 'package:converto/core/formatting.dart';
import 'package:converto/features/convert/domain/source_file.dart';
import 'package:converto/features/convert/presentation/labels.dart';
import 'package:converto/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class SourceSummary extends StatelessWidget {
  const SourceSummary({required this.sources, required this.onChange, super.key});

  final List<SourceFile> sources;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final first = sources.first;
    final category = first.format?.category;
    final totalBytes = sources.fold<int>(0, (sum, file) => sum + file.sizeBytes);
    final title = sources.length == 1 ? first.name : l10n.filesSelected(sources.length);
    final formats = sources.map((file) => file.format).toSet();
    final formatText = formats.length == 1 && first.format != null
        ? l10n.detectedFormat(first.format!.label)
        : l10n.unknownFormat;
    final details = <String>[
      if (formats.length == 1 && first.format != null) formatText,
      formatBytes(totalBytes, Localizations.localeOf(context).toString()),
      if (sources.length == 1) ..._metadataDetails(l10n, first),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                category == null ? Icons.insert_drive_file_outlined : categoryIcon(category),
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    details.isEmpty ? formatText : details.join(' · '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onChange,
              child: Semantics(
                label: l10n.changeFileSemantics,
                excludeSemantics: true,
                child: Text(l10n.changeFile),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _metadataDetails(AppLocalizations l10n, SourceFile file) {
    final metadata = file.metadata;
    return [
      if (metadata.pageCount != null) l10n.pagesCount(metadata.pageCount!),
      if (metadata.width != null && metadata.height != null)
        '${metadata.width} × ${metadata.height}',
      if (metadata.duration != null) formatDuration(metadata.duration!),
    ];
  }
}

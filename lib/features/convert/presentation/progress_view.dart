import 'package:converto/features/convert/application/conversion_controller.dart';
import 'package:converto/features/convert/domain/converter.dart';
import 'package:converto/features/convert/presentation/labels.dart';
import 'package:converto/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressView extends ConsumerWidget {
  const ProgressView({
    required this.converter,
    required this.progress,
    this.detail,
    super.key,
  });

  final Converter converter;
  final double progress;
  final String? detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final percent = (progress * 100).round();
    final spoken = percent ~/ 10 * 10;
    final indeterminate = progress <= 0;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              liveRegion: true,
              label: l10n.convertingSemantics(spoken),
              excludeSemantics: true,
              child: SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: indeterminate ? null : progress,
                        strokeWidth: 10,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          indeterminate ? '…' : '$percent %',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (detail != null)
                          Text(
                            detail!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              '${l10n.converting} ${targetTitle(l10n, converter)}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.keepScreenOn,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            OutlinedButton(
              onPressed: ref.read(conversionControllerProvider.notifier).cancel,
              child: Text(l10n.cancel),
            ),
          ],
        ),
      ),
    );
  }
}

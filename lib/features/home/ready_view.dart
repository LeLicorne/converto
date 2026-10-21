import 'package:converto/core/layout.dart';
import 'package:converto/features/convert/application/conversion_controller.dart';
import 'package:converto/features/convert/domain/conversion_failure.dart';
import 'package:converto/features/convert/domain/converter.dart';
import 'package:converto/features/convert/domain/source_file.dart';
import 'package:converto/features/convert/presentation/failure_banner.dart';
import 'package:converto/features/convert/presentation/options_sheet.dart';
import 'package:converto/features/convert/presentation/source_summary.dart';
import 'package:converto/features/convert/presentation/target_grid.dart';
import 'package:converto/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReadyView extends ConsumerWidget {
  const ReadyView({
    required this.sources,
    required this.targets,
    this.failure,
    super.key,
  });

  final List<SourceFile> sources;
  final List<Converter> targets;
  final ConversionFailure? failure;

  Future<void> _select(BuildContext context, WidgetRef ref, Converter converter) async {
    final controller = ref.read(conversionControllerProvider.notifier);
    final options = converter.optionsFor(sources);
    if (options.isEmpty) {
      await controller.start(converter, const {});
      return;
    }
    final values = await showOptionsSheet(
      context,
      converter: converter,
      options: options,
    );
    if (values != null) await controller.start(converter, values);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(conversionControllerProvider.notifier);
    final mixed = sources.map((file) => file.format).toSet().length > 1;
    final banner = failure == null
        ? null
        : FailureBanner(failure: failure!, onDismiss: controller.clearFailure);
    final summary = SourceSummary(sources: sources, onChange: controller.reset);
    final choices = targets.isEmpty
        ? Semantics(
            liveRegion: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                mixed ? l10n.mixedFiles : l10n.noTargets,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.convertTo,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TargetGrid(
                targets: targets,
                onSelected: (converter) => _select(context, ref, converter),
              ),
            ],
          );
    if (isWideLayout(context)) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 340,
              child: Column(
                children: [
                  if (banner != null) ...[banner, const SizedBox(height: 12)],
                  summary,
                ],
              ),
            ),
            const SizedBox(width: 40),
            Expanded(child: choices),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        if (banner != null) ...[banner, const SizedBox(height: 12)],
        summary,
        const SizedBox(height: 20),
        choices,
      ],
    );
  }
}

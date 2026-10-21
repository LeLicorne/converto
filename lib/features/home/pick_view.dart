import 'package:converto/core/layout.dart';
import 'package:converto/features/convert/application/conversion_controller.dart';
import 'package:converto/features/convert/domain/conversion_failure.dart';
import 'package:converto/features/convert/presentation/failure_banner.dart';
import 'package:converto/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PickView extends ConsumerWidget {
  const PickView({this.failure, super.key});

  final ConversionFailure? failure;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final controller = ref.read(conversionControllerProvider.notifier);
    final wide = isWideLayout(context);
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (failure != null) ...[
          FailureBanner(failure: failure!, onDismiss: controller.clearFailure),
          const SizedBox(height: 16),
        ],
        Semantics(
          button: true,
          label: '${l10n.pickTitle}. ${l10n.pickSubtitle}',
          excludeSemantics: true,
          child: Card(
            color: scheme.primaryContainer,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: controller.pickFiles,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: wide ? 380 : 280),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.upload_file_rounded,
                          size: 42,
                          color: scheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.pickTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: scheme.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.pickSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            onPressed: () => controller.pickFiles(media: true),
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(l10n.pickMedia),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.pickMultipleHint,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
    final padded = Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: wide
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: body,
              ),
            )
          : body,
    );
    if (!wide) return SingleChildScrollView(child: padded);
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: box.maxHeight),
          child: Center(child: padded),
        ),
      ),
    );
  }
}
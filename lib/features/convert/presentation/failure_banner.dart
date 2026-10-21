import 'package:converto/features/convert/domain/conversion_failure.dart';
import 'package:converto/features/convert/presentation/failure_text.dart';
import 'package:converto/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class FailureBanner extends StatelessWidget {
  const FailureBanner({required this.failure, required this.onDismiss, super.key});

  final ConversionFailure failure;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = failureText(l10n, failure);
    if (text.isEmpty) return const SizedBox.shrink();
    return Semantics(
      liveRegion: true,
      child: Card(
        color: scheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: scheme.onErrorContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
              ),
              IconButton(
                tooltip: l10n.dismiss,
                onPressed: onDismiss,
                icon: Icon(Icons.close, color: scheme.onErrorContainer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

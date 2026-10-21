import 'dart:io';

import 'package:converto/core/formatting.dart';
import 'package:converto/core/layout.dart';
import 'package:converto/features/convert/application/conversion_controller.dart';
import 'package:converto/features/convert/domain/conversion_job.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:converto/features/convert/domain/source_file.dart';
import 'package:converto/features/convert/presentation/labels.dart';
import 'package:converto/features/result/output_actions.dart';
import 'package:converto/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResultView extends ConsumerStatefulWidget {
  const ResultView({
    required this.sources,
    required this.result,
    this.actions = const OutputActions(),
    super.key,
  });

  final List<SourceFile> sources;
  final ConversionResult result;
  final OutputActions actions;

  @override
  ConsumerState<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends ConsumerState<ResultView> {
  late bool _useBundle = widget.result.bundle != null;

  List<OutputFile> get _selected =>
      _useBundle && widget.result.bundle != null ? [widget.result.bundle!] : widget.result.files;

  Rect? _origin(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    return box == null ? null : box.localToGlobal(Offset.zero) & box.size;
  }

  void _announce(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
    SemanticsService.sendAnnouncement(
      View.of(context),
      message,
      Directionality.of(context),
    );
  }

  Future<void> _report(ActionOutcome outcome) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    switch (outcome) {
      case ActionOutcome.saved:
        _announce(l10n.savedOk);
      case ActionOutcome.savedToPhotos:
        _announce(l10n.savedPhotos);
      case ActionOutcome.failed:
        _announce(l10n.saveFailed);
      case ActionOutcome.noApp:
        _announce(l10n.openFailed);
      case ActionOutcome.cancelled:
        break;
    }
  }

  Future<void> _save(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final files = _selected;
    final origin = _origin(context);
    if (widget.actions.canSaveToPhotos(files)) {
      final choice = await showModalBottomSheet<String>(
        context: context,
        builder: (sheet) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.actionSaveToPhotos),
                onTap: () => Navigator.of(sheet).pop('photos'),
              ),
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(l10n.actionSaveToFiles),
                onTap: () => Navigator.of(sheet).pop('files'),
              ),
            ],
          ),
        ),
      );
      if (choice == null) return;
      await _report(
        choice == 'photos'
            ? await widget.actions.saveToPhotos(files)
            : await widget.actions.saveToFiles(files, shareOrigin: origin),
      );
      return;
    }
    await _report(await widget.actions.saveToFiles(files, shareOrigin: origin));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final result = widget.result;
    final before = widget.sources.fold<int>(0, (sum, file) => sum + file.sizeBytes);
    final single = _selected.length == 1 ? _selected.first : null;
    final header = Semantics(
      liveRegion: true,
      child: Column(
        children: [
          Icon(Icons.check_circle_rounded, size: 72, color: scheme.primary),
          const SizedBox(height: 12),
          Text(
            l10n.resultTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${l10n.resultFiles(result.files.length)} · ${l10n.resultSize(formatBytes(before, locale), formatBytes(result.totalBytes, locale))}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
    final controls = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (result.bundle != null)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.shareAsZip),
            value: _useBundle,
            onChanged: (value) => setState(() => _useBundle = value),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _save(context),
                icon: const Icon(Icons.save_alt_rounded),
                label: Text(l10n.actionSave),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Builder(
                builder: (buttonContext) => FilledButton.tonalIcon(
                  onPressed: () async => _report(
                    await widget.actions.share(
                      _selected,
                      shareOrigin: _origin(buttonContext),
                    ),
                  ),
                  icon: const Icon(Icons.ios_share_rounded),
                  label: Text(l10n.actionShare),
                ),
              ),
            ),
          ],
        ),
        if (single != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async => _report(await widget.actions.open(single)),
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(l10n.actionOpenWith),
          ),
        ],
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: ref.read(conversionControllerProvider.notifier).backToTargets,
                icon: const Icon(Icons.swap_horiz_rounded),
                label: Text(l10n.convertAnother),
              ),
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: ref.read(conversionControllerProvider.notifier).reset,
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.newFile),
              ),
            ),
          ],
        ),
      ],
    );
    final preview = _Preview(files: result.files);
    if (isWideLayout(context)) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
        child: Column(
          children: [
            header,
            const SizedBox(height: 28),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: preview),
                const SizedBox(width: 40),
                SizedBox(width: 380, child: controls),
              ],
            ),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        header,
        const SizedBox(height: 20),
        preview,
        const SizedBox(height: 16),
        controls,
      ],
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.files});

  final List<OutputFile> files;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final visible = files.take(6).toList();
    final previewable = visible.first.format.category == FormatCategory.image &&
        visible.first.format != FileFormat.tiff &&
        visible.first.format != FileFormat.heic &&
        visible.first.format != FileFormat.avif;
    if (previewable && files.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 260),
          child: Image.file(
            File(visible.first.path),
            fit: BoxFit.contain,
            cacheWidth: 1200,
            semanticLabel: visible.first.name,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
      );
    }
    return Card(
      child: Column(
        children: [
          for (final file in visible)
            ListTile(
              leading: Icon(categoryIcon(file.format.category), color: scheme.primary),
              title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('${file.format.label} · ${formatBytes(file.sizeBytes, Localizations.localeOf(context).toString())}'),
            ),
          if (files.length > visible.length)
            ListTile(
              title: Text('+ ${files.length - visible.length}'),
            ),
        ],
      ),
    );
  }
}

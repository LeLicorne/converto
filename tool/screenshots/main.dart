import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:converto/core/theme.dart';
import 'package:converto/core/workspace.dart';
import 'package:converto/features/convert/application/conversion_controller.dart';
import 'package:converto/features/convert/application/conversion_state.dart';
import 'package:converto/features/convert/domain/conversion_job.dart';
import 'package:converto/features/convert/domain/converter.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:converto/features/convert/domain/source_file.dart';
import 'package:converto/features/convert/engines/pdf_converters.dart';
import 'package:converto/features/convert/presentation/options_sheet.dart';
import 'package:converto/features/home/home_page.dart';
import 'package:converto/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _pdf = SourceFile(
  path: '/tmp/Rapport-2025.pdf',
  name: 'Rapport-2025.pdf',
  sizeBytes: 4823040,
  format: FileFormat.pdf,
  metadata: SourceMetadata(pageCount: 4),
);

const _converter = PdfToImagesConverter(FileFormat.png);

FlowState _stateFor(String scene) {
  final targets = ConversionRegistryHolder.targets;
  return switch (scene) {
    'ready' || 'options' => ReadyState(sources: const [_pdf], targets: targets),
    'running' => const RunningState(
      sources: [_pdf],
      converter: _converter,
      progress: 0.58,
      detail: '3/4',
    ),
    'done' => DoneState(
      sources: const [_pdf],
      targets: targets,
      converter: _converter,
      result: ConversionResult(
        files: [
          for (var i = 1; i <= 4; i++)
            OutputFile(
              path: '/tmp/Rapport-2025-${i.toString().padLeft(2, '0')}.png',
              name: 'Rapport-2025-${i.toString().padLeft(2, '0')}.png',
              format: FileFormat.png,
              sizeBytes: 640000 + i * 21000,
            ),
        ],
        bundle: const OutputFile(
          path: '/tmp/Rapport-2025.zip',
          name: 'Rapport-2025.zip',
          format: FileFormat.zip,
          sizeBytes: 8200000,
        ),
      ),
    ),
    _ => const IdleState(),
  };
}

class ConversionRegistryHolder {
  static List<Converter> get targets => [
    const PdfToImagesConverter(FileFormat.png),
    const PdfToImagesConverter(FileFormat.jpg),
    const PdfToImagesConverter(FileFormat.webp),
    const PdfToTextConverter(),
    const PdfMergeConverter(),
  ];
}

class SceneController extends ConversionController {
  SceneController(this.scene);

  final String scene;

  @override
  FlowState build() => _stateFor(scene);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final hostFile = File('/tmp/converto_scene');
  final route = hostFile.existsSync()
      ? hostFile.readAsStringSync().trim()
      : PlatformDispatcher.instance.defaultRouteName.replaceFirst('/', '');
  final parts = route.split(':');
  final scene = parts.first.isEmpty ? 'idle' : parts.first;
  final lang = parts.length > 1 ? parts[1] : 'en';
  final dark = parts.length > 2 && parts[2] == 'dark';
  runApp(
    ProviderScope(
      overrides: [
        workspaceProvider.overrideWithValue(Workspace.at(Directory.systemTemp)),
        conversionControllerProvider.overrideWith(() => SceneController(scene)),
      ],
      child: _ShotApp(scene: scene, locale: Locale(lang), dark: dark),
    ),
  );
}

class _ShotApp extends StatefulWidget {
  const _ShotApp({required this.scene, required this.locale, required this.dark});

  final String scene;
  final Locale locale;
  final bool dark;

  @override
  State<_ShotApp> createState() => _ShotAppState();
}

class _ShotAppState extends State<_ShotApp> {
  final _navigator = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    if (widget.scene == 'options') {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        final context = _navigator.currentContext;
        if (context == null || !context.mounted) return;
        unawaited(
          showOptionsSheet(
            context,
            converter: _converter,
            options: _converter.optionsFor(const [_pdf]),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: _navigator,
    debugShowCheckedModeBanner: false,
    locale: widget.locale,
    theme: buildTheme(Brightness.light),
    darkTheme: buildTheme(Brightness.dark),
    themeMode: widget.dark ? ThemeMode.dark : ThemeMode.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const HomePage(),
  );
}

import 'dart:io';

import 'package:converto/app.dart';
import 'package:converto/core/workspace.dart';
import 'package:converto/features/convert/application/conversion_controller.dart';
import 'package:converto/features/convert/application/conversion_state.dart';
import 'package:converto/features/convert/domain/conversion_job.dart';
import 'package:converto/features/convert/domain/converter.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:converto/features/convert/domain/source_file.dart';
import 'package:converto/features/convert/engines/image_converters.dart';
import 'package:converto/features/convert/engines/pdf_converters.dart';
import 'package:converto/features/convert/registry/conversion_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeController extends ConversionController {
  FakeController(this.initial);

  final FlowState initial;
  int resets = 0;
  Converter? started;

  @override
  FlowState build() => initial;

  @override
  Future<void> pickFiles({bool media = false}) async {}

  @override
  Future<void> start(Converter converter, Map<String, Object> options) async {
    started = converter;
  }

  @override
  Future<void> reset() async {
    resets++;
    state = const IdleState();
  }
}

Future<void> loadFonts() async {
  final regular = FontLoader('Roboto')
    ..addFont(File('assets/fonts/NotoSans-Regular.ttf').readAsBytes().then((b) => ByteData.sublistView(b)));
  final bold = FontLoader('Roboto')
    ..addFont(File('assets/fonts/NotoSans-Bold.ttf').readAsBytes().then((b) => ByteData.sublistView(b)));
  await regular.load();
  await bold.load();
}

SourceFile pdfSource() => const SourceFile(
  path: '/tmp/contract.pdf',
  name: 'contract.pdf',
  sizeBytes: 1843200,
  format: FileFormat.pdf,
  metadata: SourceMetadata(pageCount: 12),
);

SourceFile photoSource() => const SourceFile(
  path: '/tmp/IMG_2041.heic',
  name: 'IMG_2041.heic',
  sizeBytes: 3250000,
  format: FileFormat.heic,
  metadata: SourceMetadata(),
);

ReadyState readyFor(SourceFile source) => ReadyState(
  sources: [source],
  targets: ConversionRegistry.standard().targetsFor([source]),
);

DoneState doneState() {
  const output = OutputFile(path: '/tmp/IMG_2041.jpg', name: 'IMG_2041.jpg', format: FileFormat.jpg, sizeBytes: 840000);
  return DoneState(
    sources: [photoSource()],
    targets: ConversionRegistry.standard().targetsFor([photoSource()]),
    converter: const ImageToImageConverter(FileFormat.jpg),
    result: const ConversionResult(files: [output]),
  );
}

RunningState runningState() => const RunningState(
  sources: [],
  converter: PdfToImagesConverter(FileFormat.png),
  progress: 0.42,
  detail: '5/12',
);

Future<FakeController> pumpApp(
  WidgetTester tester,
  FlowState state, {
  Locale locale = const Locale('en'),
  Size size = const Size(390, 844),
  double textScale = 1,
  Brightness brightness = Brightness.light,
}) async {
  tester.view
    ..physicalSize = size * 3
    ..devicePixelRatio = 3;
  tester.platformDispatcher
    ..textScaleFactorTestValue = textScale
    ..platformBrightnessTestValue = brightness;
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher
      ..clearTextScaleFactorTestValue()
      ..clearPlatformBrightnessTestValue();
  });
  final controller = FakeController(state);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        workspaceProvider.overrideWithValue(Workspace.at(Directory.systemTemp)),
        conversionControllerProvider.overrideWith(() => controller),
      ],
      child: ConvertoApp(locale: locale),
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}

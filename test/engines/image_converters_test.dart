import 'dart:io';

import 'package:converto/features/convert/domain/conversion_option.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:converto/features/convert/engines/image_converters.dart';
import 'package:converto/features/convert/engines/images_to_pdf_converter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import '../support/fixtures.dart';

void main() {
  late Sandbox sandbox;
  setUp(() => sandbox = Sandbox.create());
  tearDown(() => sandbox.dispose());

  test('convertit un PNG transparent en JPG sur fond blanc', () async {
    final source = await describe(sandbox.png('logo.png', alpha: true));
    final result = await runConverter(
      const ImageToImageConverter(FileFormat.jpg),
      [source],
      sandbox,
    );
    final decoded = img.decodeJpg(File(result.files.single.path).readAsBytesSync())!;
    expect(result.files.single.format, FileFormat.jpg);
    expect(decoded.getPixel(2, 2).r, greaterThan(240));
  });

  test('redimensionne selon la taille maximale choisie', () async {
    final source = await describe(sandbox.png('big.png', width: 400, height: 200));
    final converter = const ImageToImageConverter(FileFormat.png);
    final options = defaultValues(converter.optionsFor([source]))..['maxSize'] = '100';
    final result = await runConverter(converter, [source], sandbox, options: options);
    final decoded = img.decodePng(File(result.files.single.path).readAsBytesSync())!;
    expect(decoded.width, 100);
    expect(decoded.height, 50);
  });

  test('produit BMP, GIF et TIFF lisibles', () async {
    final source = await describe(sandbox.png('a.png'));
    for (final format in [FileFormat.bmp, FileFormat.gif, FileFormat.tiff]) {
      final result = await runConverter(ImageToImageConverter(format), [source], sandbox);
      final bytes = File(result.files.single.path).readAsBytesSync();
      expect(img.decodeImage(bytes), isNotNull, reason: format.label);
    }
  });

  test('regroupe plusieurs images en un ZIP', () async {
    final a = await describe(sandbox.png('a.png'));
    final b = await describe(sandbox.png('b.png'));
    final result = await runConverter(
      const ImageToImageConverter(FileFormat.jpg),
      [a, b],
      sandbox,
    );
    expect(result.files, hasLength(2));
    expect(result.bundle?.format, FileFormat.zip);
  });

  test('assemble plusieurs images en un seul PDF', () async {
    final a = await describe(sandbox.png('a.png'));
    final b = await describe(sandbox.png('b.png', width: 30, height: 90));
    final result = await runConverter(const ImagesToPdfConverter(), [a, b], sandbox);
    final bytes = File(result.files.single.path).readAsBytesSync();
    expect(result.files, hasLength(1));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    final pages = RegExp(r'/Type\s*/Page(?![s\w])').allMatches(String.fromCharCodes(bytes));
    expect(pages.length, 2);
  });

  test('crée un PDF par image quand on le demande', () async {
    final a = await describe(sandbox.png('a.png'));
    final b = await describe(sandbox.png('b.png'));
    const converter = ImagesToPdfConverter();
    final options = defaultValues(converter.optionsFor([a, b]))..['grouping'] = 'perImage';
    final result = await runConverter(converter, [a, b], sandbox, options: options);
    expect(result.files, hasLength(2));
    expect(result.bundle, isNotNull);
  });
}

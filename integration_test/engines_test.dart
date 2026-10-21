import 'dart:convert';
import 'dart:io';

import 'package:converto/features/convert/domain/conversion_option.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:converto/features/convert/engines/document_converters.dart';
import 'package:converto/features/convert/engines/image_converters.dart';
import 'package:converto/features/convert/engines/pdf_converters.dart';
import 'package:converto/features/pick/file_import_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pdf/widgets.dart' as pw;

import '../test/support/fixtures.dart';

Future<String> samplePdf(Sandbox sandbox, int pages) async {
  final document = pw.Document();
  for (var i = 1; i <= pages; i++) {
    document.addPage(
      pw.Page(build: (_) => pw.Center(child: pw.Text('Page numero $i'))),
    );
  }
  return sandbox.write('sample.pdf', await document.save());
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late Sandbox sandbox;
  setUp(() => sandbox = Sandbox.create());
  tearDown(() => sandbox.dispose());

  testWidgets('lit le nombre de pages d\'un PDF', (tester) async {
    final source = await const FileImportService().describePath(await samplePdf(sandbox, 3));
    expect(source.format, FileFormat.pdf);
    expect(source.metadata.pageCount, 3);
  });

  testWidgets('PDF → une image par page avec ZIP', (tester) async {
    final source = await const FileImportService().describePath(await samplePdf(sandbox, 3));
    final result = await runConverter(const PdfToImagesConverter(FileFormat.png), [source], sandbox);
    expect(result.files, hasLength(3));
    expect(result.bundle?.format, FileFormat.zip);
    expect(result.files.first.name, 'sample-1.png');
    expect(File(result.files.first.path).lengthSync(), greaterThan(1000));
  });

  testWidgets('PDF → une seule image continue', (tester) async {
    final source = await const FileImportService().describePath(await samplePdf(sandbox, 3));
    const converter = PdfToImagesConverter(FileFormat.jpg);
    final options = defaultValues(converter.optionsFor([source]))
      ..['layout'] = 'single'
      ..['dpi'] = '72';
    final result = await runConverter(converter, [source], sandbox, options: options);
    expect(result.files, hasLength(1));
    expect(result.bundle, isNull);
    expect(result.files.single.format, FileFormat.jpg);
  });

  testWidgets('PDF → pages choisies', (tester) async {
    final source = await const FileImportService().describePath(await samplePdf(sandbox, 5));
    const converter = PdfToImagesConverter(FileFormat.png);
    final options = defaultValues(converter.optionsFor([source]))..['pages'] = '2-3,5';
    final result = await runConverter(converter, [source], sandbox, options: options);
    expect(result.files.map((f) => f.name), ['sample-2.png', 'sample-3.png', 'sample-5.png']);
  });

  testWidgets('PDF → texte', (tester) async {
    final source = await const FileImportService().describePath(await samplePdf(sandbox, 2));
    final result = await runConverter(const PdfToTextConverter(), [source], sandbox);
    final text = File(result.files.single.path).readAsStringSync();
    expect(text, contains('Page numero 1'));
    expect(text, contains('Page numero 2'));
  });

  testWidgets('PDF : extraction de pages et rotation', (tester) async {
    final source = await const FileImportService().describePath(await samplePdf(sandbox, 4));
    const converter = PdfMergeConverter();
    final options = defaultValues(converter.optionsFor([source]))
      ..['pages'] = '1,3'
      ..['rotation'] = '90';
    final result = await runConverter(converter, [source], sandbox, options: options);
    final out = await const FileImportService().describePath(result.files.single.path);
    expect(out.metadata.pageCount, 2);
  });

  testWidgets('fusion de deux PDF', (tester) async {
    final first = await const FileImportService().describePath(await samplePdf(sandbox, 2));
    final secondPath = sandbox.write('other.pdf', File(first.path).readAsBytesSync());
    final second = await const FileImportService().describePath(secondPath);
    final result = await runConverter(const PdfMergeConverter(), [first, second], sandbox);
    final out = await const FileImportService().describePath(result.files.single.path);
    expect(out.metadata.pageCount, 4);
  });

  testWidgets('PNG → WebP via le moteur natif', (tester) async {
    final source = await describe(sandbox.png('a.png'));
    final result = await runConverter(const ImageToImageConverter(FileFormat.webp), [source], sandbox);
    final bytes = File(result.files.single.path).readAsBytesSync();
    expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
    expect(String.fromCharCodes(bytes.sublist(8, 12)), 'WEBP');
  });

  testWidgets('texte Unicode → PDF avec la police embarquée', (tester) async {
    final source = await describe(sandbox.writeText('note.md', '# Café\n\nÀ la carte, œuvre Ελλάδα Привет'));
    final result = await runConverter(const TextToPdfConverter(), [source], sandbox);
    final pdf = await const FileImportService().describePath(result.files.single.path);
    expect(pdf.metadata.pageCount, 1);
    expect(String.fromCharCodes(File(result.files.single.path).readAsBytesSync()), contains('NotoSans'));
  });

  testWidgets('HEIC → JPG et PNG via le décodeur natif', (tester) async {
    final path = sandbox.write('photo.heic', base64Decode(_heic));
    final source = await describe(path);
    expect(source.format, FileFormat.heic);
    for (final format in [FileFormat.jpg, FileFormat.png, FileFormat.webp]) {
      final result = await runConverter(ImageToImageConverter(format), [source], sandbox);
      expect(File(result.files.single.path).lengthSync(), greaterThan(100), reason: format.label);
    }
  });
}

const _heic = 'AAAAJGZ0eXBoZWljAAAAAG1pZjFNaVBybWlhZk1pSEJoZWljAAABwm1ldGEAAAAAAAAAIWhkbHIAAAAAAAAAAHBpY3QAAAAAAAAAAAAAAAAAAAAAJGRpbmYAAAAcZHJlZgAAAAAAAAABAAAADHVybCAAAAABAAAADnBpdG0AAAAAAAEAAAA4aWluZgAAAAAAAgAAABVpbmZlAgAAAAABAABodmMxAAAAABVpbmZlAgAAAQACAABFeGlmAAAAABppcmVmAAAAAAAAAA5jZHNjAAIAAQABAAAA5WlwcnAAAADEaXBjbwAAABNjb2xybmNseAACAAIABoAAAAAMY2xsaQDLAEAAAAAUaXNwZQAAAAAAAABAAAAAYAAAAAlpcm90AAAAABBwaXhpAAAAAAMICAgAAABwaHZjQwEDcAAAALAAAAAAAB7wAPz9+PgAAAsDoAABABdAAQwB//8DcAAAAwCwAAADAAADAB5wJKEAAQAiQgEBA3AAAAMAsAAAAwAAAwAeoBQgYcGPiHuRZVNwICBgCKIAAQAJRAHAYXLIQFMkAAAAGWlwbWEAAAAAAAAAAQABBoECAwWGhAAAACxpbG9jAAAAAEQAAAIAAQAAAAEAAAJEAAACdAACAAAAAQAAAfYAAABOAAAAAW1kYXQAAAAAAAAC0gAAAAZFeGlmAABNTQAqAAAACAABh2kABAAAAAEAAAAaAAAAAAADoAEAAwAAAAEAAQAAoAIABAAAAAEAAABAoAMABAAAAAEAAABgAAAAAAAAAnAoAa+xN9ckDUQrZI5T9TihY8vIxKkmb7o7Z4J8j3M+YIfTJA/69ENeAGp/Gig95Q3+t1igqrn8lMM/H3RXqg37Jv96zH2SEFn/B4dggkDAAGkrv4sFwHecyl6xhmdkJ/tqnKo0+/F7MOXkv54cWyVWiysqCmKKBCESvV3t2fROcBCZX3OmwP82zyB2Q664zEqGQBZtagDfZyMjc0HWhjer6m8L5mVFxhJfAUoq512sxBeduwqRxVNKcTBH8OzHUeh2DAu/UvPxH8TKzRsBczQFzUouTdYNE8MMGfJdmRld7agKGEqieV/ns2Ts1MGjRzV1K089f+Yl5LUxA2H2oERi2/L/iI8iIqg6R7pepu0iTnx/WSkSB3OMkZPzslGSE9OdMUt5OmdRVcPIZ+WG2TIGoVYAIK4Gj2pnWcA4uEYP0CdV6R8Oi+L7OtoeJlHQ0ME5yAArmMSGr3AtOO+jQy5lc9nHO8Et8LIJ7oezE/ru2NcYrd70fY+z3Dv//62lLeF4kncw3gnaCa7QVTCd8muKD4GuLrCmS1qwPbcVcGF4woO1w0SYxMPSPwWcMmudRRkXSuWCDTAdV+RcsaACxeyCG/fQ/DIwQX+/hGrfV0WE6UGAGGGCzlnwPFfjnkkc2Q+4Xh4JtTHbP/03/hE1nql8P8edzM22icK38KYAuh5BsfAND+AIkMHzYyWJcuuTjaFDgp5eg75e9CQKVlaMuOpqYNYq5Fia0JjswUQJQOO55+WYfHnhhaWmvO1gpZMHg/N3KV5mL9JwxovTRYWCmg2AZaWD1ZN/cRGFiYDog2D4f1YO/aBZh6IV84xIg873n0A=';

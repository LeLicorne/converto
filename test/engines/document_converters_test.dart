import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:converto/features/convert/engines/archive_converters.dart';
import 'package:converto/features/convert/engines/document_converters.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

List<int> docx(List<String> paragraphs) {
  final body = paragraphs.map((p) => '<w:p><w:r><w:t>$p</w:t></w:r></w:p>').join();
  final xml = '<?xml version="1.0"?><w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body>$body</w:body></w:document>';
  final archive = Archive()
    ..addFile(ArchiveFile.bytes('word/document.xml', utf8.encode(xml)))
    ..addFile(ArchiveFile.bytes('[Content_Types].xml', utf8.encode('<Types/>')));
  return ZipEncoder().encode(archive);
}

void main() {
  late Sandbox sandbox;
  setUp(() => sandbox = Sandbox.create());
  tearDown(() => sandbox.dispose());

  test('extrait le texte d\'un DOCX', () async {
    final source = await describe(sandbox.write('letter.docx', docx(['Bonjour', 'Le monde'])));
    expect(source.format, FileFormat.docx);
    final result = await runConverter(const DocxToTextConverter(), [source], sandbox);
    expect(File(result.files.single.path).readAsStringSync(), 'Bonjour\nLe monde');
  });

  test('génère un PDF depuis du Markdown avec accents', () async {
    final source = await describe(sandbox.writeText('note.md', '# Titre\n\nÉté très chaud\n- point'));
    final result = await runConverter(
      TextToPdfConverter(
        loadAsset: (asset) async =>
            File(asset).readAsBytesSync().buffer.asByteData(),
      ),
      [source],
      sandbox,
    );
    final bytes = File(result.files.single.path).readAsBytesSync();
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(String.fromCharCodes(bytes), contains('NotoSans'));
  });

  test('convertit du HTML en texte en retirant balises et scripts', () async {
    final source = await describe(
      sandbox.writeText('page.html', '<html><script>x()</script><h1>Titre</h1><p>Un &amp; deux</p></html>'),
    );
    final result = await runConverter(const DocxToTextConverter(), [source], sandbox);
    final text = File(result.files.single.path).readAsStringSync();
    expect(text, contains('Titre'));
    expect(text, contains('Un & deux'));
    expect(text, isNot(contains('x()')));
  });

  test('crée puis extrait une archive ZIP', () async {
    final a = await describe(sandbox.writeText('a.txt', 'alpha'));
    final b = await describe(sandbox.writeText('b.txt', 'beta'));
    final zipped = await runConverter(const ZipCreateConverter(), [a, b], sandbox);
    final zip = await describe(zipped.files.single.path);
    expect(zip.format, FileFormat.zip);
    final extracted = await runConverter(const ZipExtractConverter(), [zip], sandbox);
    expect(extracted.files.map((f) => f.name).toList()..sort(), ['a.txt', 'b.txt']);
    expect(File(extracted.files.first.path).readAsStringSync(), anyOf('alpha', 'beta'));
  });
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:converto/features/convert/domain/conversion_failure.dart';
import 'package:converto/features/convert/domain/conversion_job.dart';
import 'package:converto/features/convert/domain/conversion_option.dart';
import 'package:converto/features/convert/domain/converter.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:converto/features/convert/domain/source_file.dart';
import 'package:converto/features/convert/engines/output_writer.dart';
import 'package:converto/features/convert/engines/text_decoding.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:xml/xml.dart';


Future<String> readText(String path) => readTextFile(path);

typedef FontLoader = Future<ByteData> Function(String asset);

Future<ByteData> _bundleAsset(String asset) => rootBundle.load(asset);

class TextToPdfConverter extends Converter {
  const TextToPdfConverter({this.loadAsset = _bundleAsset});

  final FontLoader loadAsset;

  @override
  Set<FileFormat> get inputs => {FileFormat.txt, FileFormat.md, FileFormat.html, FileFormat.docx};

  @override
  FileFormat get output => FileFormat.pdf;

  @override
  List<ConversionOption> optionsFor(List<SourceFile> sources) => const [
    ChoiceOption('pageSize', choices: ['a4', 'letter'], initial: 'a4'),
    ChoiceOption('fontSize', choices: ['10', '12', '14'], initial: '12'),
  ];

  @override
  Future<ConversionResult> run(ConversionJob job) async {
    final source = job.source;
    final blocks = switch (source.format) {
      FileFormat.docx => await extractDocxBlocks(source.path),
      FileFormat.html => _htmlBlocks(await readText(source.path)),
      FileFormat.md => _markdownBlocks(await readText(source.path)),
      _ => _plainBlocks(await readText(source.path)),
    };
    job.onProgress(0.4);
    final fontSize = double.parse(job.options.choice('fontSize'));
    final format = job.options.choice('pageSize') == 'letter'
        ? PdfPageFormat.letter
        : PdfPageFormat.a4;
    final font = pw.Font.ttf(await loadAsset('assets/fonts/NotoSans-Regular.ttf'));
    final bold = pw.Font.ttf(await loadAsset('assets/fonts/NotoSans-Bold.ttf'));
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(48),
        theme: pw.ThemeData.withFont(base: font, bold: bold),
        build: (_) => [
          for (final block in blocks)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Text(
                block.text,
                style: pw.TextStyle(
                  fontSize: fontSize * block.scale,
                  fontWeight: block.bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                ),
              ),
            ),
        ],
      ),
    );
    final bytes = await document.save();
    job.onProgress(1);
    final file = await writeOutput(
      directory: job.outputDirectory,
      baseName: source.baseName,
      format: FileFormat.pdf,
      bytes: Uint8List.fromList(bytes),
    );
    return ConversionResult(files: [file]);
  }
}

class TextBlock {
  const TextBlock(this.text, {this.scale = 1, this.bold = false});

  final String text;
  final double scale;
  final bool bold;
}

List<TextBlock> _plainBlocks(String text) => [
  for (final line in const LineSplitter().convert(text)) TextBlock(line.isEmpty ? ' ' : line),
];

List<TextBlock> _markdownBlocks(String text) {
  final blocks = <TextBlock>[];
  for (final line in const LineSplitter().convert(text)) {
    final heading = RegExp(r'^(#{1,6})\s+(.*)$').firstMatch(line);
    if (heading != null) {
      final level = heading.group(1)!.length;
      blocks.add(TextBlock(_stripInline(heading.group(2)!), scale: 2.0 - (level - 1) * 0.2, bold: true));
    } else {
      blocks.add(TextBlock(line.isEmpty ? ' ' : _stripInline(line.replaceFirst(RegExp(r'^[-*+]\s+'), '• '))));
    }
  }
  return blocks;
}

String _stripInline(String text) => text
    .replaceAllMapped(RegExp(r'!?\[([^\]]*)\]\([^)]*\)'), (m) => m.group(1)!)
    .replaceAll(RegExp(r'[*_`~]'), '');

List<TextBlock> _htmlBlocks(String html) {
  final withoutScripts = html.replaceAll(
    RegExp(r'<(script|style)[^>]*>.*?</\1>', caseSensitive: false, dotAll: true),
    '',
  );
  final blocks = <TextBlock>[];
  final pattern = RegExp(
    r'<(h[1-6]|p|li|div|tr|br)[^>]*>(.*?)(?=<(?:h[1-6]|p|li|div|tr|br)\b|$)',
    caseSensitive: false,
    dotAll: true,
  );
  for (final match in pattern.allMatches(withoutScripts)) {
    final tag = match.group(1)!.toLowerCase();
    final text = _decodeEntities(match.group(2)!.replaceAll(RegExp(r'<[^>]+>'), '')).trim();
    if (text.isEmpty) continue;
    if (tag.startsWith('h')) {
      final level = int.parse(tag.substring(1));
      blocks.add(TextBlock(text, scale: 2.0 - (level - 1) * 0.2, bold: true));
    } else {
      blocks.add(TextBlock(tag == 'li' ? '• $text' : text));
    }
  }
  if (blocks.isEmpty) {
    final plain = _decodeEntities(withoutScripts.replaceAll(RegExp(r'<[^>]+>'), ' '));
    return _plainBlocks(plain.trim());
  }
  return blocks;
}

String _decodeEntities(String text) => text
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
    .replaceAll('&amp;', '&')
    .replaceAll(RegExp(r'\s+'), ' ');

Future<List<TextBlock>> extractDocxBlocks(String path) async {
  final input = InputFileStream(path);
  try {
    final archive = ZipDecoder().decodeStream(input);
    final entry = archive.findFile('word/document.xml');
    if (entry == null) throw const CorruptedFile();
    final xml = XmlDocument.parse(utf8.decode(entry.content as List<int>));
    final blocks = <TextBlock>[];
    for (final paragraph in xml.findAllElements('w:p')) {
      final text = paragraph.findAllElements('w:t').map((e) => e.innerText).join();
      final style = paragraph
          .findAllElements('w:pStyle')
          .map((e) => e.getAttribute('w:val') ?? '')
          .firstOrNull;
      final level = style != null && style.startsWith('Heading')
          ? int.tryParse(style.substring(7))
          : null;
      blocks.add(
        level == null
            ? TextBlock(text.isEmpty ? ' ' : text)
            : TextBlock(text, scale: 2.0 - (level - 1).clamp(0, 5) * 0.2, bold: true),
      );
    }
    return blocks;
  } on XmlException {
    throw const CorruptedFile();
  } finally {
    input.closeSync();
  }
}

class DocxToTextConverter extends Converter {
  const DocxToTextConverter();

  @override
  Set<FileFormat> get inputs => {FileFormat.docx, FileFormat.html, FileFormat.md};

  @override
  FileFormat get output => FileFormat.txt;

  @override
  Future<ConversionResult> run(ConversionJob job) async {
    final source = job.source;
    final blocks = switch (source.format) {
      FileFormat.docx => await extractDocxBlocks(source.path),
      FileFormat.html => _htmlBlocks(await readText(source.path)),
      _ => _markdownBlocks(await readText(source.path)),
    };
    final text = blocks.map((block) => block.text.trim()).join('\n');
    job.onProgress(1);
    final file = await writeOutput(
      directory: job.outputDirectory,
      baseName: source.baseName,
      format: FileFormat.txt,
      bytes: Uint8List.fromList(utf8.encode(text)),
    );
    return ConversionResult(files: [file]);
  }
}

class MarkdownToHtmlConverter extends Converter {
  const MarkdownToHtmlConverter();

  @override
  Set<FileFormat> get inputs => {FileFormat.md, FileFormat.txt};

  @override
  FileFormat get output => FileFormat.html;

  @override
  Future<ConversionResult> run(ConversionJob job) async {
    final text = await readText(job.source.path);
    final escape = const HtmlEscape();
    final body = StringBuffer();
    for (final block in job.source.format == FileFormat.md ? _markdownBlocks(text) : _plainBlocks(text)) {
      final content = escape.convert(block.text.trim());
      if (content.isEmpty) continue;
      if (block.bold) {
        final level = ((2.0 - block.scale) / 0.2).round().clamp(0, 5) + 1;
        body.writeln('<h$level>$content</h$level>');
      } else {
        body.writeln('<p>$content</p>');
      }
    }
    final html = '<!doctype html>\n<html><head><meta charset="utf-8">'
        '<meta name="viewport" content="width=device-width,initial-scale=1">'
        '<title>${escape.convert(job.source.baseName)}</title></head>\n<body>\n$body</body></html>\n';
    job.onProgress(1);
    final file = await writeOutput(
      directory: job.outputDirectory,
      baseName: job.source.baseName,
      format: FileFormat.html,
      bytes: Uint8List.fromList(utf8.encode(html)),
    );
    return ConversionResult(files: [file]);
  }
}

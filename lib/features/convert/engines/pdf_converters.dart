import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:converto/features/convert/domain/conversion_failure.dart';
import 'package:converto/features/convert/domain/conversion_job.dart';
import 'package:converto/features/convert/domain/conversion_option.dart';
import 'package:converto/features/convert/domain/converter.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:converto/features/convert/domain/source_file.dart';
import 'package:converto/features/convert/engines/image_pipeline.dart';
import 'package:converto/features/convert/engines/output_writer.dart';
import 'package:converto/features/convert/engines/page_ranges.dart';
import 'package:converto/features/convert/engines/pdf_support.dart';
import 'package:image/image.dart' as img;
import 'package:pdfrx/pdfrx.dart';

const _maxStitchedHeight = 30000;
const _maxPageEdge = 8000;

class PdfToImagesConverter extends Converter {
  const PdfToImagesConverter(this.output);

  @override
  final FileFormat output;

  @override
  Set<FileFormat> get inputs => {FileFormat.pdf};

  bool get _lossy => output == FileFormat.jpg || output == FileFormat.webp;

  @override
  List<ConversionOption> optionsFor(List<SourceFile> sources) {
    final pageCount = sources.first.metadata.pageCount ?? 1;
    return [
      if (pageCount > 1) PageSelectionOption('pages', pageCount: pageCount),
      if (pageCount > 1)
        const ChoiceOption(
          'layout',
          choices: ['separate', 'single'],
          initial: 'separate',
        ),
      const ChoiceOption(
        'dpi',
        choices: ['72', '150', '200', '300'],
        initial: '150',
      ),
      if (_lossy)
        const RangeOption(
          'quality',
          min: 30,
          max: 100,
          initial: 90,
          divisions: 14,
          unit: '%',
        ),
    ];
  }

  @override
  Future<ConversionResult> run(ConversionJob job) async {
    final source = job.source;
    final document = await openPdf(source.path, password: source.password);
    try {
      final pageCount = document.pages.length;
      final selection = parsePageRanges(job.options.choice('pages'), pageCount);
      if (selection == null) throw const UnsupportedFile();
      final dpi = double.parse(job.options.choice('dpi'));
      final stitched = job.options.choice('layout') == 'single' && selection.length > 1;
      final quality = _lossy ? job.options.range('quality').round() : 100;
      return stitched
          ? await _renderStitched(job, document, selection, dpi, quality)
          : await _renderSeparate(job, document, selection, dpi, quality);
    } finally {
      await document.dispose();
    }
  }

  Future<ConversionResult> _renderSeparate(
    ConversionJob job,
    PdfDocument document,
    List<int> selection,
    double dpi,
    int quality,
  ) async {
    final outputs = <OutputFile>[];
    final digits = document.pages.length.toString().length;
    for (var i = 0; i < selection.length; i++) {
      job.cancelToken.throwIfCancelled();
      final index = selection[i];
      final bytes = await _renderPage(document.pages[index], dpi, quality);
      final suffix = selection.length == 1
          ? ''
          : '-${(index + 1).toString().padLeft(digits, '0')}';
      outputs.add(
        await writeOutput(
          directory: job.outputDirectory,
          baseName: '${job.source.baseName}$suffix',
          format: output,
          bytes: bytes,
        ),
      );
      job.onProgress(
        (i + 1) / selection.length,
        detail: '${i + 1}/${selection.length}',
      );
    }
    return resultWithBundle(
      directory: job.outputDirectory,
      baseName: job.source.baseName,
      files: outputs,
    );
  }

  Future<ConversionResult> _renderStitched(
    ConversionJob job,
    PdfDocument document,
    List<int> selection,
    double requestedDpi,
    int quality,
  ) async {
    var dpi = requestedDpi;
    double totalHeight(double d) => selection.fold<double>(
      0,
      (sum, index) => sum + document.pages[index].height * d / 72,
    );
    while (dpi > 30 && totalHeight(dpi) > _maxStitchedHeight) {
      dpi *= 0.9;
    }
    if (totalHeight(dpi) > _maxStitchedHeight) throw const FileTooLarge();
    final maxWidth = selection
        .map((index) => document.pages[index].width * dpi / 72)
        .reduce((a, b) => a > b ? a : b)
        .ceil();
    final totalPixels = totalHeight(dpi).ceil();
    final canvas = Uint8List(maxWidth * totalPixels * 4)..fillRange(0, maxWidth * totalPixels * 4, 255);
    var offset = 0;
    for (var i = 0; i < selection.length; i++) {
      job.cancelToken.throwIfCancelled();
      final page = document.pages[selection[i]];
      final width = (page.width * dpi / 72).round();
      final height = (page.height * dpi / 72).round();
      final rendered = await page.render(
        fullWidth: width.toDouble(),
        fullHeight: height.toDouble(),
        backgroundColor: 0xFFFFFFFF,
      );
      if (rendered == null) throw const CorruptedFile();
      final left = ((maxWidth - rendered.width) / 2).floor();
      for (var row = 0; row < rendered.height && offset + row < totalPixels; row++) {
        final from = row * rendered.width * 4;
        final to = ((offset + row) * maxWidth + left) * 4;
        canvas.setRange(to, to + rendered.width * 4, rendered.pixels, from);
      }
      offset += rendered.height;
      rendered.dispose();
      job.onProgress((i + 1) / selection.length * 0.8);
    }
    final bytes = await _encodeBgra(canvas, maxWidth, totalPixels, quality);
    job.onProgress(1);
    final file = await writeOutput(
      directory: job.outputDirectory,
      baseName: job.source.baseName,
      format: output,
      bytes: bytes,
    );
    return ConversionResult(files: [file]);
  }

  Future<Uint8List> _renderPage(PdfPage page, double dpi, int quality) async {
    var scale = dpi / 72;
    final longest = page.width > page.height ? page.width : page.height;
    if (longest * scale > _maxPageEdge) scale = _maxPageEdge / longest;
    final width = (page.width * scale).round();
    final height = (page.height * scale).round();
    final rendered = await page.render(
      fullWidth: width.toDouble(),
      fullHeight: height.toDouble(),
      backgroundColor: 0xFFFFFFFF,
    );
    if (rendered == null) throw const CorruptedFile();
    try {
      return await _encodeBgra(
        Uint8List.fromList(rendered.pixels),
        rendered.width,
        rendered.height,
        quality,
      );
    } finally {
      rendered.dispose();
    }
  }

  Future<Uint8List> _encodeBgra(
    Uint8List bgra,
    int width,
    int height,
    int quality,
  ) async {
    final intermediate = output == FileFormat.webp ? FileFormat.png : output;
    final encoded = await Isolate.run(() {
      final image = img.Image.fromBytes(
        width: width,
        height: height,
        bytes: bgra.buffer,
        numChannels: 4,
        order: img.ChannelOrder.bgra,
      );
      return switch (intermediate) {
        FileFormat.jpg => img.encodeJpg(
          _opaque(image),
          quality: quality,
        ),
        _ => img.encodePng(image),
      };
    });
    if (output != FileFormat.webp) return encoded;
    return encodeWebp(encoded, quality);
  }
}

img.Image _opaque(img.Image image) {
  final flat = img.Image(width: image.width, height: image.height, numChannels: 3)
    ..clear(img.ColorRgb8(255, 255, 255));
  img.compositeImage(flat, image);
  return flat;
}

class PdfToTextConverter extends Converter {
  const PdfToTextConverter();

  @override
  Set<FileFormat> get inputs => {FileFormat.pdf};

  @override
  FileFormat get output => FileFormat.txt;

  @override
  List<ConversionOption> optionsFor(List<SourceFile> sources) {
    final pageCount = sources.first.metadata.pageCount ?? 1;
    return [
      if (pageCount > 1) PageSelectionOption('pages', pageCount: pageCount),
      if (pageCount > 1) const ToggleOption('pageSeparators', initial: true),
    ];
  }

  @override
  Future<ConversionResult> run(ConversionJob job) async {
    final document = await openPdf(job.source.path, password: job.source.password);
    try {
      final selection = parsePageRanges(
        job.options.choice('pages'),
        document.pages.length,
      );
      if (selection == null) throw const UnsupportedFile();
      final separators = job.options.toggle('pageSeparators');
      final buffer = StringBuffer();
      for (var i = 0; i < selection.length; i++) {
        job.cancelToken.throwIfCancelled();
        final text = await document.pages[selection[i]].loadText();
        if (separators && selection.length > 1) {
          buffer.writeln('--- ${selection[i] + 1} ---');
        }
        buffer
          ..writeln(text?.fullText.trim() ?? '')
          ..writeln();
        job.onProgress((i + 1) / selection.length);
      }
      final bytes = Uint8List.fromList(utf8.encode(buffer.toString()));
      final file = await writeOutput(
        directory: job.outputDirectory,
        baseName: job.source.baseName,
        format: FileFormat.txt,
        bytes: bytes,
      );
      return ConversionResult(files: [file]);
    } finally {
      await document.dispose();
    }
  }
}

class PdfMergeConverter extends Converter {
  const PdfMergeConverter();

  @override
  Set<FileFormat> get inputs => {FileFormat.pdf};

  @override
  FileFormat get output => FileFormat.pdf;

  @override
  bool get acceptsMultiple => true;

  @override
  List<ConversionOption> optionsFor(List<SourceFile> sources) {
    if (sources.length > 1) return const [];
    final pageCount = sources.first.metadata.pageCount ?? 1;
    return [
      if (pageCount > 1) PageSelectionOption('pages', pageCount: pageCount),
      const ChoiceOption(
        'rotation',
        choices: ['0', '90', '180', '270'],
        initial: '0',
      ),
    ];
  }

  @override
  Future<ConversionResult> run(ConversionJob job) async {
    final opened = <PdfDocument>[];
    try {
      final pages = <PdfPage>[];
      final rotation = PdfPageRotation.values[
        int.parse(job.options.choice('rotation').isEmpty ? '0' : job.options.choice('rotation')) ~/ 90
      ];
      for (final source in job.sources) {
        job.cancelToken.throwIfCancelled();
        final document = await openPdf(source.path, password: source.password);
        opened.add(document);
        final selection = job.sources.length > 1
            ? List.generate(document.pages.length, (i) => i)
            : parsePageRanges(job.options.choice('pages'), document.pages.length);
        if (selection == null) throw const UnsupportedFile();
        for (final index in selection) {
          final page = document.pages[index];
          pages.add(rotation == PdfPageRotation.none ? page : page.rotatedBy(rotation));
        }
      }
      final target = opened.first..pages = pages;
      await target.assemble();
      final bytes = await target.encodePdf();
      job.onProgress(1);
      final base = job.sources.length > 1 ? 'merged' : job.source.baseName;
      final file = await writeOutput(
        directory: job.outputDirectory,
        baseName: base,
        format: FileFormat.pdf,
        bytes: bytes,
      );
      return ConversionResult(files: [file]);
    } finally {
      for (final document in opened) {
        await document.dispose();
      }
    }
  }
}

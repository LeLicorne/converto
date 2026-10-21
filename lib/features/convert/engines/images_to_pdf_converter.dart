import 'dart:typed_data';

import 'package:converto/features/convert/domain/conversion_job.dart';
import 'package:converto/features/convert/domain/conversion_option.dart';
import 'package:converto/features/convert/domain/converter.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:converto/features/convert/domain/source_file.dart';
import 'package:converto/features/convert/engines/image_pipeline.dart';
import 'package:converto/features/convert/engines/output_writer.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ImagesToPdfConverter extends Converter {
  const ImagesToPdfConverter();

  @override
  Set<FileFormat> get inputs => imageInputFormats;

  @override
  FileFormat get output => FileFormat.pdf;

  @override
  bool get acceptsMultiple => true;

  @override
  List<ConversionOption> optionsFor(List<SourceFile> sources) => [
    const ChoiceOption(
      'pageSize',
      choices: ['fit', 'a4', 'letter'],
      initial: 'fit',
    ),
    if (sources.length > 1)
      const ChoiceOption(
        'grouping',
        choices: ['single', 'perImage'],
        initial: 'single',
      ),
    const ToggleOption('optimize', initial: true),
  ];

  @override
  Future<ConversionResult> run(ConversionJob job) async {
    final optimize = job.options.toggle('optimize');
    final transform = ImageTransform(
      output: FileFormat.jpg,
      quality: optimize ? 85 : 97,
      maxEdge: optimize ? 3000 : null,
    );
    final pageFormat = switch (job.options.choice('pageSize')) {
      'a4' => PdfPageFormat.a4,
      'letter' => PdfPageFormat.letter,
      _ => null,
    };
    final perImage = job.options.choice('grouping') == 'perImage';
    final outputs = <OutputFile>[];
    var document = pw.Document();
    for (var i = 0; i < job.sources.length; i++) {
      job.cancelToken.throwIfCancelled();
      final source = job.sources[i];
      final jpeg = await transformImage(
        path: source.path,
        input: source.format!,
        transform: transform,
      );
      _addPage(document, jpeg, pageFormat);
      job.onProgress((i + 1) / job.sources.length * 0.9);
      if (perImage || i == job.sources.length - 1) {
        final bytes = await document.save();
        outputs.add(
          await writeOutput(
            directory: job.outputDirectory,
            baseName: perImage || job.sources.length == 1
                ? source.baseName
                : 'images',
            format: FileFormat.pdf,
            bytes: Uint8List.fromList(bytes),
          ),
        );
        document = pw.Document();
      }
    }
    job.onProgress(1);
    return resultWithBundle(
      directory: job.outputDirectory,
      baseName: 'pdf',
      files: outputs,
    );
  }

  void _addPage(pw.Document document, Uint8List jpeg, PdfPageFormat? format) {
    final image = pw.MemoryImage(jpeg);
    final width = image.width?.toDouble() ?? 1;
    final height = image.height?.toDouble() ?? 1;
    if (format == null) {
      const scale = 72 / 150;
      document.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(width * scale, height * scale),
          margin: pw.EdgeInsets.zero,
          build: (_) => pw.Image(image, fit: pw.BoxFit.fill),
        ),
      );
      return;
    }
    document.addPage(
      pw.Page(
        pageFormat: width > height ? format.landscape : format,
        margin: const pw.EdgeInsets.all(24),
        build: (_) => pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
      ),
    );
  }
}

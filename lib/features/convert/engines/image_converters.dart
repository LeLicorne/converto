import 'package:converto/features/convert/domain/conversion_job.dart';
import 'package:converto/features/convert/domain/conversion_option.dart';
import 'package:converto/features/convert/domain/converter.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:converto/features/convert/domain/source_file.dart';
import 'package:converto/features/convert/engines/image_pipeline.dart';
import 'package:converto/features/convert/engines/output_writer.dart';

class ImageToImageConverter extends Converter {
  const ImageToImageConverter(this.output);

  @override
  final FileFormat output;

  @override
  Set<FileFormat> get inputs => imageInputFormats;

  @override
  bool get acceptsMultiple => true;

  bool get _lossy => output == FileFormat.jpg || output == FileFormat.webp;

  @override
  List<ConversionOption> optionsFor(List<SourceFile> sources) => [
    if (_lossy)
      const RangeOption(
        'quality',
        min: 10,
        max: 100,
        initial: 90,
        divisions: 18,
        unit: '%',
      ),
    const ChoiceOption(
      'maxSize',
      choices: ['original', '4096', '2048', '1280', '800'],
      initial: 'original',
    ),
    const ToggleOption('stripMetadata', initial: false),
  ];

  @override
  Future<ConversionResult> run(ConversionJob job) async {
    final quality = _lossy ? job.options.range('quality').round() : 100;
    final maxSize = int.tryParse(job.options.choice('maxSize'));
    final transform = ImageTransform(
      output: output,
      quality: quality,
      maxEdge: maxSize,
      stripMetadata: job.options.toggle('stripMetadata'),
    );
    final outputs = <OutputFile>[];
    for (var i = 0; i < job.sources.length; i++) {
      job.cancelToken.throwIfCancelled();
      final source = job.sources[i];
      final bytes = await transformImage(
        path: source.path,
        input: source.format!,
        transform: transform,
      );
      outputs.add(
        await writeOutput(
          directory: job.outputDirectory,
          baseName: source.baseName,
          format: output,
          bytes: bytes,
        ),
      );
      job.onProgress((i + 1) / job.sources.length);
    }
    return resultWithBundle(
      directory: job.outputDirectory,
      baseName: 'images',
      files: outputs,
    );
  }
}

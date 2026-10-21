import 'package:converto/features/convert/domain/converter.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:converto/features/convert/domain/source_file.dart';
import 'package:converto/features/convert/engines/archive_converters.dart';
import 'package:converto/features/convert/engines/data_converters.dart';
import 'package:converto/features/convert/engines/document_converters.dart';
import 'package:converto/features/convert/engines/image_converters.dart';
import 'package:converto/features/convert/engines/images_to_pdf_converter.dart';
import 'package:converto/features/convert/engines/media_converters.dart';
import 'package:converto/features/convert/engines/pdf_converters.dart';

class ConversionTarget {
  const ConversionTarget(this.converter, {this.variant});

  final Converter converter;
  final String? variant;

  FileFormat get format => converter.output;
}

class ConversionRegistry {
  ConversionRegistry(this.converters);

  factory ConversionRegistry.standard() => ConversionRegistry([
    const ImageToImageConverter(FileFormat.jpg),
    const ImageToImageConverter(FileFormat.png),
    const ImageToImageConverter(FileFormat.webp),
    const ImageToImageConverter(FileFormat.gif),
    const ImageToImageConverter(FileFormat.bmp),
    const ImageToImageConverter(FileFormat.tiff),
    const ImagesToPdfConverter(),
    const PdfToImagesConverter(FileFormat.png),
    const PdfToImagesConverter(FileFormat.jpg),
    const PdfToImagesConverter(FileFormat.webp),
    const PdfToTextConverter(),
    const PdfMergeConverter(),
    const TextToPdfConverter(),
    const DocxToTextConverter(),
    const MarkdownToHtmlConverter(),
    const DataConverter(FileFormat.csv, FileFormat.json),
    const DataConverter(FileFormat.csv, FileFormat.xlsx),
    const DataConverter(FileFormat.json, FileFormat.csv),
    const DataConverter(FileFormat.json, FileFormat.xlsx),
    const DataConverter(FileFormat.xlsx, FileFormat.csv),
    const DataConverter(FileFormat.xlsx, FileFormat.json),
    const ZipCreateConverter(),
    const ZipExtractConverter(),
    for (final format in audioFormats) AudioConverter(format),
    const VideoConverter(FileFormat.mp4),
    const VideoConverter(FileFormat.mov),
    const VideoConverter(FileFormat.mkv),
    const VideoConverter(FileFormat.webm),
    const VideoConverter(FileFormat.gif),
  ]);

  final List<Converter> converters;

  List<Converter> targetsFor(List<SourceFile> sources) {
    if (sources.isEmpty) return const [];
    final formats = sources.map((source) => source.format).toSet();
    if (formats.contains(null)) return const [];
    final multiple = sources.length > 1;
    final result = <Converter>[];
    for (final converter in converters) {
      if (multiple && !converter.acceptsMultiple) continue;
      if (!formats.every(converter.inputs.contains)) continue;
      if (_isIdentity(converter, formats)) continue;
      result.add(converter);
    }
    return _dedupe(result);
  }

  bool _isIdentity(Converter converter, Set<FileFormat?> formats) {
    if (converter is ZipExtractConverter || converter is PdfMergeConverter) {
      return false;
    }
    return formats.length == 1 && formats.single == converter.output;
  }

  List<Converter> _dedupe(List<Converter> converters) {
    final seen = <String>{};
    return [
      for (final converter in converters)
        if (seen.add('${converter.runtimeType}-${converter.output.name}')) converter,
    ];
  }
}

extension ConverterPresentation on Converter {
  String get id => '${runtimeType}_${output.name}';
}

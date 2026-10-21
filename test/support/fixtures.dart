import 'dart:convert';
import 'dart:io';

import 'package:converto/features/convert/domain/conversion_job.dart';
import 'package:converto/features/convert/domain/conversion_option.dart';
import 'package:converto/features/convert/domain/converter.dart';
import 'package:converto/features/convert/domain/source_file.dart';
import 'package:converto/features/pick/file_import_service.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

class Sandbox {
  Sandbox._(this.directory);

  final Directory directory;

  static Sandbox create() =>
      Sandbox._(Directory.systemTemp.createTempSync('converto-test-'));

  String get out {
    final dir = Directory(p.join(directory.path, 'out'))..createSync();
    return dir.path;
  }

  String write(String name, List<int> bytes) {
    final file = File(p.join(directory.path, name))..writeAsBytesSync(bytes);
    return file.path;
  }

  String writeText(String name, String text) => write(name, utf8.encode(text));

  String png(String name, {int width = 64, int height = 48, bool alpha = false}) {
    final image = img.Image(width: width, height: height, numChannels: alpha ? 4 : 3);
    for (final pixel in image) {
      pixel
        ..r = pixel.x * 4 % 256
        ..g = pixel.y * 5 % 256
        ..b = 128;
      if (alpha) pixel.a = pixel.x < width / 2 ? 0 : 255;
    }
    return write(name, img.encodePng(image));
  }

  void dispose() => directory.deleteSync(recursive: true);
}

Future<SourceFile> describe(String path) =>
    const FileImportService().describePath(path);

Future<ConversionResult> runConverter(
  Converter converter,
  List<SourceFile> sources,
  Sandbox sandbox, {
  OptionValues? options,
}) {
  final values = options ?? defaultValues(converter.optionsFor(sources));
  return converter.run(
    ConversionJob(
      sources: sources,
      options: values,
      outputDirectory: sandbox.out,
      onProgress: (_, {detail}) {},
      cancelToken: CancelToken(),
    ),
  );
}

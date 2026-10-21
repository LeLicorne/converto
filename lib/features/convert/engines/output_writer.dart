import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:converto/features/convert/domain/conversion_failure.dart';
import 'package:converto/features/convert/domain/conversion_job.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:path/path.dart' as p;

String uniquePath(String directory, String baseName, String extension) {
  var candidate = p.join(directory, '$baseName.$extension');
  var counter = 2;
  while (File(candidate).existsSync()) {
    candidate = p.join(directory, '$baseName ($counter).$extension');
    counter++;
  }
  return candidate;
}

Future<OutputFile> writeOutput({
  required String directory,
  required String baseName,
  required FileFormat format,
  required Uint8List bytes,
}) async {
  final path = uniquePath(directory, baseName, format.extension);
  try {
    await File(path).writeAsBytes(bytes, flush: true);
  } on FileSystemException catch (error) {
    throw _isNoSpace(error) ? const NotEnoughSpace() : const CorruptedFile();
  }
  return OutputFile(
    path: path,
    name: p.basename(path),
    format: format,
    sizeBytes: bytes.length,
  );
}

bool _isNoSpace(FileSystemException error) =>
    error.osError?.errorCode == 28 || error.osError?.errorCode == 112;

Future<OutputFile> zipOutputs({
  required String directory,
  required String baseName,
  required List<OutputFile> files,
}) async {
  final path = uniquePath(directory, baseName, FileFormat.zip.extension);
  final encoder = ZipFileEncoder()..create(path);
  try {
    for (final file in files) {
      await encoder.addFile(File(file.path), file.name);
    }
  } finally {
    await encoder.close();
  }
  return OutputFile(
    path: path,
    name: p.basename(path),
    format: FileFormat.zip,
    sizeBytes: File(path).lengthSync(),
  );
}

Future<ConversionResult> resultWithBundle({
  required String directory,
  required String baseName,
  required List<OutputFile> files,
}) async {
  if (files.length < 2) return ConversionResult(files: files);
  final bundle = await zipOutputs(
    directory: directory,
    baseName: baseName,
    files: files,
  );
  return ConversionResult(files: files, bundle: bundle);
}

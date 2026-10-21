import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:converto/features/convert/domain/conversion_failure.dart';
import 'package:converto/features/convert/domain/conversion_job.dart';
import 'package:converto/features/convert/domain/converter.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:converto/features/convert/engines/output_writer.dart';
import 'package:path/path.dart' as p;

class ZipCreateConverter extends Converter {
  const ZipCreateConverter();

  @override
  Set<FileFormat> get inputs => FileFormat.values.where((f) => f != FileFormat.zip).toSet();

  @override
  FileFormat get output => FileFormat.zip;

  @override
  bool get acceptsMultiple => true;

  @override
  Future<ConversionResult> run(ConversionJob job) async {
    final single = job.sources.length == 1;
    final path = uniquePath(
      job.outputDirectory,
      single ? job.source.baseName : 'archive',
      'zip',
    );
    final encoder = ZipFileEncoder()..create(path);
    try {
      for (var i = 0; i < job.sources.length; i++) {
        job.cancelToken.throwIfCancelled();
        final source = job.sources[i];
        await encoder.addFile(File(source.path), source.name);
        job.onProgress((i + 1) / job.sources.length);
      }
    } finally {
      await encoder.close();
    }
    final size = File(path).lengthSync();
    return ConversionResult(
      files: [OutputFile(path: path, name: p.basename(path), format: FileFormat.zip, sizeBytes: size)],
    );
  }
}

const _maxExtractedBytes = 4 * 1024 * 1024 * 1024;
const _maxExtractedEntries = 20000;

class ZipExtractConverter extends Converter {
  const ZipExtractConverter();

  @override
  Set<FileFormat> get inputs => {FileFormat.zip};

  @override
  FileFormat get output => FileFormat.zip;

  @override
  Future<ConversionResult> run(ConversionJob job) async {
    final input = InputFileStream(job.source.path);
    try {
      final archive = ZipDecoder().decodeStream(input);
      final entries = archive.files.where((f) => f.isFile && _isSafe(f.name)).toList();
      if (entries.isEmpty) throw const CorruptedFile();
      final declaredBytes = entries.fold<int>(0, (sum, entry) => sum + entry.size);
      if (entries.length > _maxExtractedEntries || declaredBytes > _maxExtractedBytes) {
        throw const FileTooLarge();
      }
      final directory = Directory(
        p.join(job.outputDirectory, '${job.source.baseName}-extracted'),
      )..createSync(recursive: true);
      final outputs = <OutputFile>[];
      for (var i = 0; i < entries.length; i++) {
        job.cancelToken.throwIfCancelled();
        final entry = entries[i];
        final target = File(p.join(directory.path, entry.name));
        target.parent.createSync(recursive: true);
        final stream = OutputFileStream(target.path);
        entry.writeContent(stream);
        await stream.close();
        outputs.add(
          OutputFile(
            path: target.path,
            name: entry.name,
            format: FileFormat.fromExtension(p.extension(entry.name)) ?? FileFormat.zip,
            sizeBytes: target.lengthSync(),
          ),
        );
        job.onProgress((i + 1) / entries.length);
      }
      return ConversionResult(files: outputs);
    } finally {
      input.closeSync();
    }
  }

  bool _isSafe(String name) {
    final normalized = p.normalize(name);
    return !p.isAbsolute(normalized) && !normalized.startsWith('..');
  }
}

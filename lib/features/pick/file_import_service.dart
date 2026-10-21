import 'dart:io';

import 'package:converto/features/convert/domain/conversion_failure.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:converto/features/convert/domain/source_file.dart';
import 'package:converto/features/convert/engines/ffmpeg_runner.dart';
import 'package:converto/features/convert/engines/pdf_support.dart';
import 'package:converto/features/pick/format_detector.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

class ImportEntry {
  const ImportEntry(this.path, this.name);

  final String path;
  final String name;
}

class FileImportService {
  const FileImportService();

  Future<List<PlatformFile>> pickDocuments() =>
      FilePicker.pickFiles();

  Future<List<PlatformFile>> pickMedia() =>
      FilePicker.pickFiles(type: FileType.media);

  Future<ImportEntry> materialize(PlatformFile picked, Directory session) async {
    final path = await _materialize(picked, session);
    return ImportEntry(path, picked.name);
  }

  Future<SourceFile> describePath(
    String path, {
    String? name,
    String? password,
  }) async {
    final format = await detectFormat(path);
    return SourceFile(
      path: path,
      name: name == null || name.isEmpty ? p.basename(path) : name,
      sizeBytes: File(path).lengthSync(),
      format: format,
      metadata: await _metadata(path, format, password),
      password: password,
    );
  }

  Future<String> _materialize(PlatformFile picked, Directory session) async {
    final path = picked.path;
    if (path != null && File(path).existsSync()) return path;
    final target = p.join(session.path, picked.name);
    await picked.xFile.saveTo(target);
    return target;
  }

  Future<SourceMetadata> _metadata(
    String path,
    FileFormat? format,
    String? password,
  ) async {
    try {
      switch (format?.category) {
        case FormatCategory.audio:
        case FormatCategory.video:
          return await probeMetadata(path);
        case FormatCategory.document:
          if (format == FileFormat.pdf) {
            return await _pdfMetadata(path, password);
          }
        case FormatCategory.image:
          return await _imageMetadata(path, format!);
        case FormatCategory.data:
        case FormatCategory.archive:
        case null:
          break;
      }
    } on ConversionFailure {
      rethrow;
    } on Object {
      return const SourceMetadata();
    }
    return const SourceMetadata();
  }

  Future<SourceMetadata> _pdfMetadata(String path, String? password) async {
    final document = await openPdf(path, password: password);
    try {
      return SourceMetadata(pageCount: document.pages.length);
    } finally {
      await document.dispose();
    }
  }

  Future<SourceMetadata> _imageMetadata(String path, FileFormat format) async {
    if (format == FileFormat.heic || format == FileFormat.avif) {
      return const SourceMetadata();
    }
    final handle = await File(path).open();
    try {
      final bytes = await handle.read(65536);
      final info = img.findDecoderForData(bytes)?.startDecode(bytes);
      return SourceMetadata(width: info?.width, height: info?.height);
    } finally {
      await handle.close();
    }
  }
}

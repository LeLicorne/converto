import 'package:converto/features/convert/domain/conversion_failure.dart';
import 'package:converto/features/convert/domain/conversion_option.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:converto/features/convert/domain/source_file.dart';

class CancelToken {
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  void cancel() => _cancelled = true;

  void throwIfCancelled() {
    if (_cancelled) throw const ConversionCancelled();
  }
}

typedef ProgressCallback = void Function(double fraction, {String? detail});

class ConversionJob {
  const ConversionJob({
    required this.sources,
    required this.options,
    required this.outputDirectory,
    required this.onProgress,
    required this.cancelToken,
  });

  final List<SourceFile> sources;
  final OptionValues options;
  final String outputDirectory;
  final ProgressCallback onProgress;
  final CancelToken cancelToken;

  SourceFile get source => sources.first;
}

class OutputFile {
  const OutputFile({
    required this.path,
    required this.name,
    required this.format,
    required this.sizeBytes,
  });

  final String path;
  final String name;
  final FileFormat format;
  final int sizeBytes;
}

class ConversionResult {
  const ConversionResult({required this.files, this.bundle});

  final List<OutputFile> files;
  final OutputFile? bundle;

  int get totalBytes => files.fold(0, (sum, file) => sum + file.sizeBytes);
}

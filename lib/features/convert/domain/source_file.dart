import 'package:converto/features/convert/domain/file_format.dart';

class SourceMetadata {
  const SourceMetadata({this.pageCount, this.width, this.height, this.duration});

  final int? pageCount;
  final int? width;
  final int? height;
  final Duration? duration;
}

class SourceFile {
  const SourceFile({
    required this.path,
    required this.name,
    required this.sizeBytes,
    required this.format,
    this.metadata = const SourceMetadata(),
    this.password,
  });

  final String path;
  final String name;
  final int sizeBytes;
  final FileFormat? format;
  final SourceMetadata metadata;
  final String? password;

  String get baseName {
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }

  SourceFile copyWith({SourceMetadata? metadata, String? password}) =>
      SourceFile(
        path: path,
        name: name,
        sizeBytes: sizeBytes,
        format: format,
        metadata: metadata ?? this.metadata,
        password: password ?? this.password,
      );
}

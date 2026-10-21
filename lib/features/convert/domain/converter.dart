import 'package:converto/features/convert/domain/conversion_job.dart';
import 'package:converto/features/convert/domain/conversion_option.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:converto/features/convert/domain/source_file.dart';

abstract class Converter {
  const Converter();

  Set<FileFormat> get inputs;

  FileFormat get output;

  bool get acceptsMultiple => false;

  List<ConversionOption> optionsFor(List<SourceFile> sources) => const [];

  Future<ConversionResult> run(ConversionJob job);
}

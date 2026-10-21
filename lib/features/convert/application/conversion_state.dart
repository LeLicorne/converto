import 'package:converto/features/convert/domain/conversion_failure.dart';
import 'package:converto/features/convert/domain/conversion_job.dart';
import 'package:converto/features/convert/domain/converter.dart';
import 'package:converto/features/convert/domain/source_file.dart';
import 'package:converto/features/pick/file_import_service.dart';

sealed class FlowState {
  const FlowState();
}

final class IdleState extends FlowState {
  const IdleState({this.failure});

  final ConversionFailure? failure;
}

final class LoadingState extends FlowState {
  const LoadingState();
}

final class PasswordNeededState extends FlowState {
  const PasswordNeededState({
    required this.current,
    required this.resolved,
    required this.pending,
    required this.wrongPassword,
  });

  final ImportEntry current;
  final List<SourceFile> resolved;
  final List<ImportEntry> pending;
  final bool wrongPassword;
}

final class ReadyState extends FlowState {
  const ReadyState({
    required this.sources,
    required this.targets,
    this.failure,
  });

  final List<SourceFile> sources;
  final List<Converter> targets;
  final ConversionFailure? failure;
}

final class RunningState extends FlowState {
  const RunningState({
    required this.sources,
    required this.converter,
    required this.progress,
    this.detail,
  });

  final List<SourceFile> sources;
  final Converter converter;
  final double progress;
  final String? detail;
}

final class DoneState extends FlowState {
  const DoneState({
    required this.sources,
    required this.targets,
    required this.converter,
    required this.result,
  });

  final List<SourceFile> sources;
  final List<Converter> targets;
  final Converter converter;
  final ConversionResult result;
}

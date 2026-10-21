import 'dart:io';

import 'package:converto/core/workspace.dart';
import 'package:converto/features/convert/application/conversion_state.dart';
import 'package:converto/features/convert/domain/conversion_failure.dart';
import 'package:converto/features/convert/domain/conversion_job.dart';
import 'package:converto/features/convert/domain/conversion_option.dart';
import 'package:converto/features/convert/domain/converter.dart';
import 'package:converto/features/convert/domain/source_file.dart';
import 'package:converto/features/convert/registry/conversion_registry.dart';
import 'package:converto/features/pick/file_import_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

final workspaceProvider = Provider<Workspace>(
  (ref) => throw StateError('workspace not initialised'),
);

final registryProvider = Provider<ConversionRegistry>(
  (ref) => ConversionRegistry.standard(),
);

final importServiceProvider = Provider<FileImportService>(
  (ref) => const FileImportService(),
);

final conversionControllerProvider =
    NotifierProvider<ConversionController, FlowState>(ConversionController.new);

class ConversionController extends Notifier<FlowState> {
  Directory? _session;
  CancelToken? _cancelToken;

  @override
  FlowState build() {
    ref.onDispose(() => _cancelToken?.cancel());
    return const IdleState();
  }

  Workspace get _workspace => ref.read(workspaceProvider);

  Directory get _sessionDirectory => _session ??= _workspace.newSession();

  Future<void> pickFiles({bool media = false}) async {
    final service = ref.read(importServiceProvider);
    final List<PlatformFile> picked;
    try {
      picked = await (media ? service.pickMedia() : service.pickDocuments());
    } on Object {
      state = const IdleState(failure: UnsupportedFile());
      return;
    }
    if (picked.isEmpty) return;
    await _discardSession();
    state = const LoadingState();
    try {
      final entries = <ImportEntry>[
        for (final file in picked)
          await service.materialize(file, _sessionDirectory),
      ];
      await _describeAll(const [], entries);
    } on Object {
      state = const IdleState(failure: CorruptedFile());
    }
  }

  Future<void> importPaths(List<String> paths) async {
    await _discardSession();
    state = const LoadingState();
    await _describeAll(const [], [
      for (final path in paths) ImportEntry(path, p.basename(path)),
    ]);
  }

  Future<void> _describeAll(
    List<SourceFile> resolved,
    List<ImportEntry> pending, {
    String? password,
    bool wrongPassword = false,
  }) async {
    final service = ref.read(importServiceProvider);
    final done = [...resolved];
    var queue = [...pending];
    var secret = password;
    while (queue.isNotEmpty) {
      final entry = queue.first;
      try {
        done.add(
          await service.describePath(
            entry.path,
            name: entry.name,
            password: secret,
          ),
        );
        queue = queue.sublist(1);
        secret = null;
      } on PasswordRequired catch (required) {
        state = PasswordNeededState(
          current: entry,
          resolved: done,
          pending: queue.sublist(1),
          wrongPassword: required.wrongPassword || (wrongPassword && secret != null),
        );
        return;
      } on ConversionFailure catch (failure) {
        state = IdleState(failure: failure);
        return;
      } on Object {
        state = const IdleState(failure: CorruptedFile());
        return;
      }
    }
    final targets = ref.read(registryProvider).targetsFor(done);
    state = ReadyState(sources: done, targets: targets);
  }

  Future<void> submitPassword(String password) async {
    final current = state;
    if (current is! PasswordNeededState) return;
    state = const LoadingState();
    await _describeAll(
      current.resolved,
      [current.current, ...current.pending],
      password: password,
      wrongPassword: true,
    );
  }

  Future<void> start(Converter converter, OptionValues options) async {
    final current = state;
    final sources = switch (current) {
      ReadyState() => current.sources,
      DoneState() => current.sources,
      _ => null,
    };
    if (sources == null) return;
    final targets = ref.read(registryProvider).targetsFor(sources);
    final outputDirectory = Directory(
      p.join(_sessionDirectory.path, 'out-${DateTime.now().microsecondsSinceEpoch}'),
    )..createSync(recursive: true);
    final token = CancelToken();
    _cancelToken = token;
    state = RunningState(sources: sources, converter: converter, progress: 0);
    final job = ConversionJob(
      sources: sources,
      options: options,
      outputDirectory: outputDirectory.path,
      cancelToken: token,
      onProgress: (fraction, {detail}) {
        if (_cancelToken != token) return;
        state = RunningState(
          sources: sources,
          converter: converter,
          progress: fraction.clamp(0.0, 1.0),
          detail: detail,
        );
      },
    );
    try {
      final result = await converter.run(job);
      if (token.isCancelled) throw const ConversionCancelled();
      state = DoneState(
        sources: sources,
        targets: targets,
        converter: converter,
        result: result,
      );
    } on ConversionCancelled {
      _cleanup(outputDirectory);
      state = ReadyState(sources: sources, targets: targets);
    } on ConversionFailure catch (failure) {
      _cleanup(outputDirectory);
      state = ReadyState(sources: sources, targets: targets, failure: failure);
    } on FileSystemException {
      _cleanup(outputDirectory);
      state = ReadyState(
        sources: sources,
        targets: targets,
        failure: const NotEnoughSpace(),
      );
    } on Object {
      _cleanup(outputDirectory);
      state = ReadyState(
        sources: sources,
        targets: targets,
        failure: const CorruptedFile(),
      );
    } finally {
      if (_cancelToken == token) _cancelToken = null;
    }
  }

  void cancel() => _cancelToken?.cancel();

  void backToTargets() {
    final current = state;
    if (current is DoneState) {
      state = ReadyState(sources: current.sources, targets: current.targets);
    }
  }

  void clearFailure() {
    final current = state;
    if (current is ReadyState && current.failure != null) {
      state = ReadyState(sources: current.sources, targets: current.targets);
    } else if (current is IdleState && current.failure != null) {
      state = const IdleState();
    }
  }

  Future<void> reset() async {
    _cancelToken?.cancel();
    await _discardSession();
    state = const IdleState();
  }

  Future<void> _discardSession() async {
    final session = _session;
    _session = null;
    if (session != null && session.existsSync()) {
      try {
        session.deleteSync(recursive: true);
      } on FileSystemException {
        return;
      }
    }
  }

  void _cleanup(Directory directory) {
    if (directory.existsSync()) {
      try {
        directory.deleteSync(recursive: true);
      } on FileSystemException {
        return;
      }
    }
  }
}

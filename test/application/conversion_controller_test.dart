import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:converto/core/workspace.dart';
import 'package:converto/features/convert/application/conversion_controller.dart';
import 'package:converto/features/convert/application/conversion_state.dart';
import 'package:converto/features/convert/domain/conversion_failure.dart';
import 'package:converto/features/convert/domain/conversion_job.dart';
import 'package:converto/features/convert/domain/converter.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:converto/features/convert/domain/source_file.dart';
import 'package:converto/features/convert/registry/conversion_registry.dart';
import 'package:converto/features/pick/file_import_service.dart';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

base class FakePicked extends PlatformFile {
  FakePicked(this.path0, this.name);

  final String path0;

  @override
  final String name;

  @override
  Uri get uri => Uri.file(path0);

  @override
  XFile get xFile => XFile(path0);

  @override
  int? lengthSync() => 1;

  @override
  Future<int?> length() async => 1;

  @override
  Future<Uint8List> readAsBytes() async => Uint8List(0);

  @override
  Stream<Uint8List> readAsByteStream() => const Stream.empty();
}

class StubImport extends FileImportService {
  StubImport(this.describeImpl);

  final Future<SourceFile> Function(String path, String? password) describeImpl;

  @override
  Future<List<PlatformFile>> pickDocuments() async => [
    FakePicked('/tmp/a.pdf', 'a.pdf'),
  ];

  @override
  Future<ImportEntry> materialize(PlatformFile picked, Directory session) async =>
      ImportEntry(picked.path!, picked.name);

  @override
  Future<SourceFile> describePath(String path, {String? name, String? password}) =>
      describeImpl(path, password);
}

class StubConverter extends Converter {
  StubConverter(this.behaviour);

  final Future<ConversionResult> Function(ConversionJob job) behaviour;

  @override
  Set<FileFormat> get inputs => {FileFormat.pdf};

  @override
  FileFormat get output => FileFormat.txt;

  @override
  Future<ConversionResult> run(ConversionJob job) => behaviour(job);
}

SourceFile pdf({String? password}) => SourceFile(
  path: '/tmp/a.pdf',
  name: 'a.pdf',
  sizeBytes: 1,
  format: FileFormat.pdf,
  password: password,
);

ProviderContainer container({
  required Future<SourceFile> Function(String, String?) describe,
  required Converter converter,
}) {
  final workspace = Workspace.at(Directory.systemTemp.createTempSync('converto-ws-'));
  final container = ProviderContainer(
    overrides: [
      workspaceProvider.overrideWithValue(workspace),
      importServiceProvider.overrideWithValue(StubImport(describe)),
      registryProvider.overrideWithValue(ConversionRegistry([converter])),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

const done = ConversionResult(files: []);

void main() {
  test('sélectionner un fichier présente les formats proposés', () async {
    final c = container(describe: (_, _) async => pdf(), converter: StubConverter((_) async => done));
    await c.read(conversionControllerProvider.notifier).pickFiles();
    final state = c.read(conversionControllerProvider);
    expect(state, isA<ReadyState>());
    expect((state as ReadyState).targets.single.output, FileFormat.txt);
  });

  test('un PDF protégé demande le mot de passe, puis le valide', () async {
    final c = container(
      describe: (_, password) async {
        if (password == null) throw const PasswordRequired();
        if (password != 'secret') throw const PasswordRequired(wrongPassword: true);
        return pdf(password: password);
      },
      converter: StubConverter((_) async => done),
    );
    final controller = c.read(conversionControllerProvider.notifier);
    await controller.pickFiles();
    expect(c.read(conversionControllerProvider), isA<PasswordNeededState>());

    await controller.submitPassword('nope');
    final wrong = c.read(conversionControllerProvider) as PasswordNeededState;
    expect(wrong.wrongPassword, isTrue);

    await controller.submitPassword('secret');
    final ready = c.read(conversionControllerProvider) as ReadyState;
    expect(ready.sources.single.password, 'secret');
  });

  test('une conversion réussie aboutit à l\'écran résultat', () async {
    final c = container(describe: (_, _) async => pdf(), converter: StubConverter((job) async {
      job.onProgress(0.5);
      return done;
    }));
    final controller = c.read(conversionControllerProvider.notifier);
    await controller.pickFiles();
    final converter = (c.read(conversionControllerProvider) as ReadyState).targets.single;
    await controller.start(converter, const {});
    expect(c.read(conversionControllerProvider), isA<DoneState>());
  });

  test('un échec ramène aux formats avec le message d\'erreur', () async {
    final c = container(
      describe: (_, _) async => pdf(),
      converter: StubConverter((_) async => throw const NotEnoughSpace()),
    );
    final controller = c.read(conversionControllerProvider.notifier);
    await controller.pickFiles();
    await controller.start((c.read(conversionControllerProvider) as ReadyState).targets.single, const {});
    final state = c.read(conversionControllerProvider) as ReadyState;
    expect(state.failure, isA<NotEnoughSpace>());
    controller.clearFailure();
    expect((c.read(conversionControllerProvider) as ReadyState).failure, isNull);
  });

  test('annuler pendant la conversion revient aux formats sans erreur', () async {
    final started = Completer<void>();
    final c = container(
      describe: (_, _) async => pdf(),
      converter: StubConverter((job) async {
        started.complete();
        while (!job.cancelToken.isCancelled) {
          await Future<void>.delayed(const Duration(milliseconds: 5));
        }
        throw const ConversionCancelled();
      }),
    );
    final controller = c.read(conversionControllerProvider.notifier);
    await controller.pickFiles();
    final run = controller.start((c.read(conversionControllerProvider) as ReadyState).targets.single, const {});
    await started.future;
    expect(c.read(conversionControllerProvider), isA<RunningState>());
    controller.cancel();
    await run;
    final state = c.read(conversionControllerProvider) as ReadyState;
    expect(state.failure, isNull);
  });

  test('une erreur inattendue est rapportée sans planter', () async {
    final c = container(
      describe: (_, _) async => pdf(),
      converter: StubConverter((_) async => throw StateError('boom')),
    );
    final controller = c.read(conversionControllerProvider.notifier);
    await controller.pickFiles();
    await controller.start((c.read(conversionControllerProvider) as ReadyState).targets.single, const {});
    expect((c.read(conversionControllerProvider) as ReadyState).failure, isA<CorruptedFile>());
  });

  test('« nouveau fichier » remet l\'accueil à zéro', () async {
    final c = container(describe: (_, _) async => pdf(), converter: StubConverter((_) async => done));
    final controller = c.read(conversionControllerProvider.notifier);
    await controller.pickFiles();
    await controller.reset();
    expect(c.read(conversionControllerProvider), isA<IdleState>());
  });
}

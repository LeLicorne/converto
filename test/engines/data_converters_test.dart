import 'dart:convert';
import 'dart:io';

import 'package:converto/features/convert/domain/conversion_option.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:converto/features/convert/engines/data_converters.dart';
import 'package:converto/features/convert/engines/xlsx_codec.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

void main() {
  late Sandbox sandbox;
  setUp(() => sandbox = Sandbox.create());
  tearDown(() => sandbox.dispose());

  test('convertit un CSV avec en-têtes en JSON', () async {
    final source = await describe(sandbox.writeText('people.csv', 'name;age\nAda;36\nLinus;54\n'));
    final result = await runConverter(
      const DataConverter(FileFormat.csv, FileFormat.json),
      [source],
      sandbox,
    );
    final json = jsonDecode(File(result.files.single.path).readAsStringSync()) as List<dynamic>;
    expect(json, [
      {'name': 'Ada', 'age': 36},
      {'name': 'Linus', 'age': 54},
    ]);
  });

  test('convertit un JSON d\'objets en CSV avec colonnes unifiées', () async {
    final source = await describe(
      sandbox.writeText('data.json', '[{"a":1,"b":"x"},{"a":2,"c":true}]'),
    );
    final result = await runConverter(
      const DataConverter(FileFormat.json, FileFormat.csv),
      [source],
      sandbox,
    );
    final text = File(result.files.single.path).readAsStringSync().replaceFirst('﻿', '');
    expect(text.trim().split(RegExp(r'\r?\n')), ['a,b,c', '1,x,', '2,,true']);
  });

  test('fait un aller-retour CSV → XLSX → CSV sans perte', () async {
    final source = await describe(sandbox.writeText('t.csv', 'a,b\n1,"x, y"\n2.5,é\n'));
    final xlsx = await runConverter(
      const DataConverter(FileFormat.csv, FileFormat.xlsx),
      [source],
      sandbox,
    );
    final table = readXlsx(File(xlsx.files.single.path).readAsBytesSync());
    expect(table, [
      ['a', 'b'],
      [1, 'x, y'],
      [2.5, 'é'],
    ]);
    final back = await describe(xlsx.files.single.path);
    final csv = await runConverter(
      const DataConverter(FileFormat.xlsx, FileFormat.csv),
      [back],
      sandbox,
    );
    final text = File(csv.files.single.path).readAsStringSync();
    expect(text, contains('"x, y"'));
  });

  test('détecte automatiquement le séparateur d\'un CSV', () async {
    final source = await describe(sandbox.writeText('s.csv', 'a\tb\n1\t2\n'));
    const converter = DataConverter(FileFormat.csv, FileFormat.json);
    final options = defaultValues(converter.optionsFor([source]));
    expect(options.choice('delimiter'), 'auto');
    final result = await runConverter(converter, [source], sandbox, options: options);
    final json = jsonDecode(File(result.files.single.path).readAsStringSync()) as List<dynamic>;
    expect(json.single, {'a': 1, 'b': 2});
  });
}

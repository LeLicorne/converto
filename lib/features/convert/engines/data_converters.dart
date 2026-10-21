import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:converto/features/convert/domain/conversion_failure.dart';
import 'package:converto/features/convert/domain/conversion_job.dart';
import 'package:converto/features/convert/domain/conversion_option.dart';
import 'package:converto/features/convert/domain/converter.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:converto/features/convert/domain/source_file.dart';
import 'package:converto/features/convert/engines/output_writer.dart';
import 'package:converto/features/convert/engines/text_decoding.dart';
import 'package:converto/features/convert/engines/xlsx_codec.dart';
import 'package:csv/csv.dart';

class DataConverter extends Converter {
  const DataConverter(this.from, this.output);

  final FileFormat from;

  @override
  final FileFormat output;

  @override
  Set<FileFormat> get inputs => {from};

  @override
  List<ConversionOption> optionsFor(List<SourceFile> sources) => [
    if (from == FileFormat.csv)
      const ChoiceOption(
        'delimiter',
        choices: ['auto', ',', ';', 'tab'],
        initial: 'auto',
      ),
    if (output == FileFormat.csv)
      const ChoiceOption(
        'outputDelimiter',
        choices: [',', ';', 'tab'],
        initial: ',',
      ),
    if (output == FileFormat.json)
      const ToggleOption('firstRowHeader', initial: true),
    if (output == FileFormat.json) const ToggleOption('pretty', initial: true),
  ];

  @override
  Future<ConversionResult> run(ConversionJob job) async {
    final source = job.source;
    final table = await _read(source, job.options);
    job.onProgress(0.5);
    final bytes = await _write(table, job.options);
    job.onProgress(1);
    final file = await writeOutput(
      directory: job.outputDirectory,
      baseName: source.baseName,
      format: output,
      bytes: bytes,
    );
    return ConversionResult(files: [file]);
  }

  Future<Table> _read(SourceFile source, OptionValues options) async {
    final file = File(source.path);
    switch (from) {
      case FileFormat.csv:
        final text = await readTextFile(source.path);
        final delimiter = switch (options.choice('delimiter')) {
          ',' => ',',
          ';' => ';',
          'tab' => '\t',
          _ => _guessDelimiter(text),
        };
        return CsvDecoder(fieldDelimiter: delimiter, fieldTransform: _typed).convert(text).map((row) => row.cast<Object?>()).toList();
      case FileFormat.xlsx:
        return readXlsx(await file.readAsBytes());
      case FileFormat.json:
        final decoded = jsonDecode(await readTextFile(source.path));
        return _jsonToTable(decoded);
      default:
        throw const UnsupportedFile();
    }
  }

  Future<Uint8List> _write(Table table, OptionValues options) async {
    switch (output) {
      case FileFormat.csv:
        final delimiter = switch (options.choice('outputDelimiter')) {
          ';' => ';',
          'tab' => '\t',
          _ => ',',
        };
        final text = CsvEncoder(fieldDelimiter: delimiter).convert(table);
        return Uint8List.fromList(utf8.encode('﻿$text'));
      case FileFormat.xlsx:
        return writeXlsx(table);
      case FileFormat.json:
        final header = options.toggle('firstRowHeader');
        final Object data;
        if (header && table.length > 1) {
          final keys = table.first.map((e) => '${e ?? ''}').toList();
          data = [
            for (final row in table.skip(1))
              {for (var i = 0; i < keys.length; i++) keys[i]: i < row.length ? row[i] : null},
          ];
        } else {
          data = table;
        }
        final encoder = options.toggle('pretty') ? const JsonEncoder.withIndent('  ') : const JsonEncoder();
        return Uint8List.fromList(utf8.encode(encoder.convert(data)));
      default:
        throw const UnsupportedFile();
    }
  }
}

final _canonicalNumber = RegExp(r'^-?(0|[1-9]\d*)(\.\d+)?$');

dynamic _typed(dynamic field, int index, String? header) {
  if (field is! String || !_canonicalNumber.hasMatch(field)) return field;
  return int.tryParse(field) ?? double.tryParse(field) ?? field;
}

String _guessDelimiter(String text) {
  final firstLine = text.split('\n').first;
  final counts = {',': 0, ';': 0, '\t': 0};
  for (final entry in counts.keys.toList()) {
    counts[entry] = entry.allMatches(firstLine).length;
  }
  return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
}

Table _jsonToTable(Object? decoded) {
  final rows = decoded is List ? decoded : [decoded];
  if (rows.isNotEmpty && rows.every((row) => row is Map)) {
    final keys = <String>{};
    for (final row in rows) {
      keys.addAll((row as Map).keys.map((key) => '$key'));
    }
    final ordered = keys.toList();
    return [
      ordered,
      for (final row in rows)
        [for (final key in ordered) _scalar((row as Map)[key])],
    ];
  }
  if (rows.every((row) => row is List)) {
    return [
      for (final row in rows) [for (final cell in row as List) _scalar(cell)],
    ];
  }
  return [
    for (final row in rows) [_scalar(row)],
  ];
}

Object? _scalar(Object? value) =>
    value is Map || value is List ? jsonEncode(value) : value;

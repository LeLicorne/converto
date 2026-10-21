import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:converto/features/convert/domain/conversion_failure.dart';
import 'package:xml/xml.dart';

typedef Table = List<List<Object?>>;

Table readXlsx(Uint8List bytes) {
  final Archive archive;
  try {
    archive = ZipDecoder().decodeBytes(bytes);
  } on Object {
    throw const CorruptedFile();
  }
  final sheetPath = _firstSheetPath(archive);
  final sheet = _text(archive, sheetPath);
  if (sheet == null) throw const CorruptedFile();
  final shared = _sharedStrings(_text(archive, 'xl/sharedStrings.xml'));
  final document = XmlDocument.parse(sheet);
  final table = <List<Object?>>[];
  for (final row in document.findAllElements('row')) {
    final cells = <Object?>[];
    for (final cell in row.findElements('c')) {
      final column = _columnIndex(cell.getAttribute('r'), cells.length);
      while (cells.length < column) {
        cells.add(null);
      }
      cells.add(_cellValue(cell, shared));
    }
    final rowIndex = int.tryParse(row.getAttribute('r') ?? '');
    while (rowIndex != null && table.length < rowIndex - 1) {
      table.add(<Object?>[]);
    }
    table.add(cells);
  }
  return table;
}

String _firstSheetPath(Archive archive) {
  final workbook = _text(archive, 'xl/workbook.xml');
  final relations = _text(archive, 'xl/_rels/workbook.xml.rels');
  if (workbook != null && relations != null) {
    final sheet = XmlDocument.parse(workbook).findAllElements('sheet').firstOrNull;
    final id = sheet?.attributes
        .where((a) => a.name.local == 'id')
        .map((a) => a.value)
        .firstOrNull;
    for (final rel in XmlDocument.parse(relations).findAllElements('Relationship')) {
      if (rel.getAttribute('Id') == id) {
        final target = rel.getAttribute('Target') ?? '';
        return target.startsWith('/') ? target.substring(1) : 'xl/$target';
      }
    }
  }
  return 'xl/worksheets/sheet1.xml';
}

String? _text(Archive archive, String path) {
  final file = archive.findFile(path);
  if (file == null) return null;
  return utf8.decode(file.content, allowMalformed: true);
}

List<String> _sharedStrings(String? xml) {
  if (xml == null) return const [];
  return [
    for (final item in XmlDocument.parse(xml).findAllElements('si'))
      item.findAllElements('t').map((t) => t.innerText).join(),
  ];
}

int _columnIndex(String? reference, int fallback) {
  if (reference == null) return fallback;
  var column = 0;
  for (final unit in reference.codeUnits) {
    if (unit >= 65 && unit <= 90) {
      column = column * 26 + (unit - 64);
    } else if (unit >= 97 && unit <= 122) {
      column = column * 26 + (unit - 96);
    } else {
      break;
    }
  }
  return column == 0 ? fallback : column - 1;
}

Object? _cellValue(XmlElement cell, List<String> shared) {
  final type = cell.getAttribute('t');
  if (type == 'inlineStr') {
    return cell.findAllElements('t').map((t) => t.innerText).join();
  }
  final raw = cell.getElement('v')?.innerText;
  if (raw == null) return null;
  switch (type) {
    case 's':
      final index = int.tryParse(raw);
      return index != null && index < shared.length ? shared[index] : null;
    case 'b':
      return raw == '1';
    case 'str':
    case 'e':
      return raw;
    default:
      return int.tryParse(raw) ?? double.tryParse(raw) ?? raw;
  }
}

Uint8List writeXlsx(Table table) {
  final sheet = StringBuffer(
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>',
  );
  for (var r = 0; r < table.length; r++) {
    sheet.write('<row r="${r + 1}">');
    for (var c = 0; c < table[r].length; c++) {
      final value = table[r][c];
      if (value == null) continue;
      final ref = '${_columnName(c)}${r + 1}';
      switch (value) {
        case final int number:
          sheet.write('<c r="$ref"><v>$number</v></c>');
        case final double number when number.isFinite:
          sheet.write('<c r="$ref"><v>$number</v></c>');
        case final bool flag:
          sheet.write('<c r="$ref" t="b"><v>${flag ? 1 : 0}</v></c>');
        default:
          final text = XmlText('$value').toXmlString();
          sheet.write('<c r="$ref" t="inlineStr"><is><t xml:space="preserve">$text</t></is></c>');
      }
    }
    sheet.write('</row>');
  }
  sheet.write('</sheetData></worksheet>');
  final archive = Archive()
    ..addFile(_entry('[Content_Types].xml',
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
        '<Default Extension="xml" ContentType="application/xml"/>'
        '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
        '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
        '</Types>'))
    ..addFile(_entry('_rels/.rels',
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
        '</Relationships>'))
    ..addFile(_entry('xl/workbook.xml',
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
        'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
        '<sheets><sheet name="Sheet1" sheetId="1" r:id="rId1"/></sheets></workbook>'))
    ..addFile(_entry('xl/_rels/workbook.xml.rels',
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>'
        '</Relationships>'))
    ..addFile(_entry('xl/worksheets/sheet1.xml', sheet.toString()));
  return Uint8List.fromList(ZipEncoder().encode(archive));
}

ArchiveFile _entry(String name, String content) =>
    ArchiveFile.bytes(name, utf8.encode(content));

String _columnName(int index) {
  var n = index + 1;
  final buffer = StringBuffer();
  while (n > 0) {
    final remainder = (n - 1) % 26;
    buffer.write(String.fromCharCode(65 + remainder));
    n = (n - 1) ~/ 26;
  }
  return buffer.toString().split('').reversed.join();
}

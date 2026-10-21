import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:converto/features/convert/domain/file_format.dart';

const _headerLength = 4096;

Future<FileFormat?> detectFormat(String path) async {
  final file = File(path);
  final handle = await file.open();
  final Uint8List header;
  try {
    header = await handle.read(_headerLength);
  } finally {
    await handle.close();
  }
  final byContent = detectFormatFromHeader(header);
  if (byContent == FileFormat.zip) {
    return _refineZip(path) ?? _byExtension(path) ?? FileFormat.zip;
  }
  if (byContent != null) return _preferExtensionWithinFamily(byContent, path);
  return _byExtension(path) ?? _detectText(header, path);
}

FileFormat? _byExtension(String path) {
  final dot = path.lastIndexOf('.');
  if (dot < 0 || dot < path.lastIndexOf(Platform.pathSeparator)) return null;
  return FileFormat.fromExtension(path.substring(dot + 1));
}

FileFormat _preferExtensionWithinFamily(FileFormat detected, String path) {
  final byExtension = _byExtension(path);
  if (byExtension == null) return detected;
  const families = <Set<FileFormat>>[
    {FileFormat.mp4, FileFormat.mov, FileFormat.m4a, FileFormat.heic, FileFormat.avif},
    {FileFormat.ogg, FileFormat.opus},
    {FileFormat.mkv, FileFormat.webm},
  ];
  for (final family in families) {
    if (family.contains(detected) && family.contains(byExtension)) {
      return byExtension;
    }
  }
  return detected;
}

FileFormat? _detectText(Uint8List header, String path) {
  if (header.isEmpty) return null;
  final sample = header.length > 1024 ? header.sublist(0, 1024) : header;
  final isText = !sample.any((byte) => byte == 0 || (byte < 9) || (byte > 13 && byte < 32));
  return isText ? FileFormat.txt : null;
}

FileFormat? _refineZip(String path) {
  try {
    final input = InputFileStream(path);
    try {
      final archive = ZipDecoder().decodeStream(input);
      final names = archive.files.map((file) => file.name).toSet();
      if (names.contains('word/document.xml')) return FileFormat.docx;
      if (names.contains('xl/workbook.xml')) return FileFormat.xlsx;
    } finally {
      input.closeSync();
    }
  } on Object {
    return null;
  }
  return null;
}

FileFormat? detectFormatFromHeader(Uint8List b) {
  bool starts(List<int> signature, [int offset = 0]) {
    if (b.length < offset + signature.length) return false;
    for (var i = 0; i < signature.length; i++) {
      if (b[offset + i] != signature[i]) return false;
    }
    return true;
  }

  bool asciiAt(String text, int offset) =>
      starts(text.codeUnits, offset);

  if (starts([0xFF, 0xD8, 0xFF])) return FileFormat.jpg;
  if (starts([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) {
    return FileFormat.png;
  }
  if (asciiAt('GIF8', 0)) return FileFormat.gif;
  if (asciiAt('BM', 0) && b.length > 14) return FileFormat.bmp;
  if (starts([0x49, 0x49, 0x2A, 0x00]) || starts([0x4D, 0x4D, 0x00, 0x2A])) {
    return FileFormat.tiff;
  }
  if (asciiAt('%PDF', 0)) return FileFormat.pdf;
  if (asciiAt('RIFF', 0) && asciiAt('WEBP', 8)) return FileFormat.webp;
  if (asciiAt('RIFF', 0) && asciiAt('WAVE', 8)) return FileFormat.wav;
  if (asciiAt('fLaC', 0)) return FileFormat.flac;
  if (asciiAt('OggS', 0)) {
    return _containsAscii(b, 'OpusHead') ? FileFormat.opus : FileFormat.ogg;
  }
  if (asciiAt('FORM', 0) && (asciiAt('AIFF', 8) || asciiAt('AIFC', 8))) {
    return FileFormat.aiff;
  }
  if (asciiAt('ID3', 0)) return FileFormat.mp3;
  if (b.length > 1 && b[0] == 0xFF && (b[1] & 0xF6) == 0xF0) {
    return FileFormat.aac;
  }
  if (b.length > 1 && b[0] == 0xFF && (b[1] & 0xE0) == 0xE0) {
    return FileFormat.mp3;
  }
  if (starts([0x1A, 0x45, 0xDF, 0xA3])) {
    return _containsAscii(b, 'webm') ? FileFormat.webm : FileFormat.mkv;
  }
  if (asciiAt('ftyp', 4)) return _fromFtypBrand(b);
  if (starts([0x50, 0x4B, 0x03, 0x04])) return FileFormat.zip;
  return null;
}

FileFormat _fromFtypBrand(Uint8List b) {
  if (b.length < 12) return FileFormat.mp4;
  final brand = String.fromCharCodes(b.sublist(8, 12));
  if (brand.startsWith('heic') ||
      brand.startsWith('heix') ||
      brand.startsWith('hevc') ||
      brand.startsWith('mif1') ||
      brand.startsWith('msf1')) {
    return FileFormat.heic;
  }
  if (brand.startsWith('avif') || brand.startsWith('avis')) {
    return FileFormat.avif;
  }
  if (brand.startsWith('qt')) return FileFormat.mov;
  if (brand.startsWith('M4A') || brand.startsWith('M4B')) return FileFormat.m4a;
  return FileFormat.mp4;
}

bool _containsAscii(Uint8List bytes, String needle) {
  final pattern = needle.codeUnits;
  for (var i = 0; i <= bytes.length - pattern.length; i++) {
    var match = true;
    for (var j = 0; j < pattern.length; j++) {
      if (bytes[i + j] != pattern[j]) {
        match = false;
        break;
      }
    }
    if (match) return true;
  }
  return false;
}

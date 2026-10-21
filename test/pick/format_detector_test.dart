import 'dart:typed_data';

import 'package:converto/features/convert/domain/file_format.dart';
import 'package:converto/features/pick/format_detector.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

Uint8List bytes(List<int> head, [int pad = 32]) =>
    Uint8List.fromList([...head, ...List.filled(pad, 0)]);

Uint8List ascii(String text, {int at = 0}) {
  final data = Uint8List(64);
  data.setRange(at, at + text.length, text.codeUnits);
  return data;
}

void main() {
  group('detectFormatFromHeader', () {
    test('reconnaît les formats d\'image courants', () {
      expect(detectFormatFromHeader(bytes([0xFF, 0xD8, 0xFF, 0xE0])), FileFormat.jpg);
      expect(
        detectFormatFromHeader(bytes([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])),
        FileFormat.png,
      );
      expect(detectFormatFromHeader(ascii('GIF89a')), FileFormat.gif);
      expect(detectFormatFromHeader(bytes([0x49, 0x49, 0x2A, 0x00])), FileFormat.tiff);
    });

    test('distingue WebP et WAV malgré l\'en-tête RIFF commun', () {
      final webp = ascii('RIFF')..setRange(8, 12, 'WEBP'.codeUnits);
      final wav = ascii('RIFF')..setRange(8, 12, 'WAVE'.codeUnits);
      expect(detectFormatFromHeader(webp), FileFormat.webp);
      expect(detectFormatFromHeader(wav), FileFormat.wav);
    });

    test('lit la marque ftyp pour HEIC, AVIF, MOV, M4A et MP4', () {
      Uint8List ftyp(String brand) =>
          ascii('ftyp', at: 4)..setRange(8, 12, brand.codeUnits);
      expect(detectFormatFromHeader(ftyp('heic')), FileFormat.heic);
      expect(detectFormatFromHeader(ftyp('avif')), FileFormat.avif);
      expect(detectFormatFromHeader(ftyp('qt  ')), FileFormat.mov);
      expect(detectFormatFromHeader(ftyp('M4A ')), FileFormat.m4a);
      expect(detectFormatFromHeader(ftyp('isom')), FileFormat.mp4);
    });

    test('reconnaît PDF, FLAC, OGG, MP3, AIFF et Matroska', () {
      expect(detectFormatFromHeader(ascii('%PDF-1.7')), FileFormat.pdf);
      expect(detectFormatFromHeader(ascii('fLaC')), FileFormat.flac);
      expect(detectFormatFromHeader(ascii('OggS')), FileFormat.ogg);
      expect(detectFormatFromHeader(ascii('ID3')), FileFormat.mp3);
      expect(
        detectFormatFromHeader(ascii('FORM')..setRange(8, 12, 'AIFF'.codeUnits)),
        FileFormat.aiff,
      );
      expect(detectFormatFromHeader(bytes([0x1A, 0x45, 0xDF, 0xA3])), FileFormat.mkv);
    });

    test('renvoie null pour un contenu inconnu', () {
      expect(detectFormatFromHeader(bytes([1, 2, 3, 4])), isNull);
    });
  });

  group('detectFormat', () {
    late Sandbox sandbox;
    setUp(() => sandbox = Sandbox.create());
    tearDown(() => sandbox.dispose());

    test('privilégie le contenu à l\'extension trompeuse', () async {
      final path = sandbox.png('photo.jpg');
      expect(await detectFormat(path), FileFormat.png);
    });

    test('se replie sur l\'extension pour les formats texte', () async {
      expect(await detectFormat(sandbox.writeText('a.csv', 'a,b\n1,2')), FileFormat.csv);
      expect(await detectFormat(sandbox.writeText('a.json', '{}')), FileFormat.json);
      expect(await detectFormat(sandbox.writeText('a.md', '# t')), FileFormat.md);
    });

    test('traite un texte sans extension connue comme du texte brut', () async {
      expect(await detectFormat(sandbox.writeText('notes', 'bonjour')), FileFormat.txt);
    });

    test('ne reconnaît pas un binaire inconnu', () async {
      expect(await detectFormat(sandbox.write('blob.bin', [0, 1, 2, 3, 0, 0])), isNull);
    });
  });
}

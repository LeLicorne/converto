import 'package:converto/features/convert/domain/file_format.dart';
import 'package:converto/features/convert/domain/source_file.dart';
import 'package:converto/features/convert/registry/conversion_registry.dart';
import 'package:flutter_test/flutter_test.dart';

SourceFile file(FileFormat? format, {String name = 'f'}) => SourceFile(
  path: '/tmp/$name',
  name: name,
  sizeBytes: 1,
  format: format,
);

Set<FileFormat> targets(List<SourceFile> sources) =>
    ConversionRegistry.standard().targetsFor(sources).map((c) => c.output).toSet();

void main() {
  test('un PDF n\'est jamais convertible en audio ou en vidéo', () {
    final result = targets([file(FileFormat.pdf)]);
    expect(result, containsAll([FileFormat.png, FileFormat.jpg, FileFormat.webp, FileFormat.txt]));
    for (final format in FileFormat.values.where(
      (f) => f.category == FormatCategory.audio || f.category == FormatCategory.video,
    )) {
      expect(result, isNot(contains(format)), reason: format.label);
    }
  });

  test('une image propose les autres images et le PDF, pas elle-même', () {
    final result = targets([file(FileFormat.heic)]);
    expect(result, containsAll([FileFormat.jpg, FileFormat.png, FileFormat.webp, FileFormat.pdf]));
    expect(targets([file(FileFormat.png)]), isNot(contains(FileFormat.png)));
  });

  test('un fichier audio propose les autres audios mais pas de vidéo ni d\'image', () {
    final result = targets([file(FileFormat.wav)]);
    expect(result, containsAll([FileFormat.mp3, FileFormat.flac, FileFormat.opus]));
    expect(result, isNot(contains(FileFormat.wav)));
    expect(result, isNot(contains(FileFormat.mp4)));
    expect(result, isNot(contains(FileFormat.png)));
  });

  test('une vidéo propose vidéo, GIF et extraction audio', () {
    final result = targets([file(FileFormat.mov)]);
    expect(result, containsAll([FileFormat.mp4, FileFormat.webm, FileFormat.gif, FileFormat.mp3]));
  });

  test('un fichier inconnu ne propose aucune conversion', () {
    expect(targets([file(null)]), isEmpty);
  });

  test('plusieurs images : seules les conversions multi-fichiers restent', () {
    final result = targets([file(FileFormat.png, name: 'a'), file(FileFormat.jpg, name: 'b')]);
    expect(result, containsAll([FileFormat.pdf, FileFormat.zip]));
  });

  test('plusieurs PDF : fusion proposée, pas de rendu en image', () {
    final result = targets([file(FileFormat.pdf, name: 'a'), file(FileFormat.pdf, name: 'b')]);
    expect(result, contains(FileFormat.pdf));
    expect(result, isNot(contains(FileFormat.png)));
  });

  test('des fichiers de types différents ne sont pas convertibles ensemble', () {
    final result = targets([file(FileFormat.png, name: 'a'), file(FileFormat.pdf, name: 'b')]);
    expect(result, {FileFormat.zip});
  });

  test('un ZIP propose l\'extraction', () {
    final converters = ConversionRegistry.standard().targetsFor([file(FileFormat.zip)]);
    expect(converters.map((c) => c.runtimeType.toString()), contains('ZipExtractConverter'));
  });

  test('chaque conversion déclare au moins une entrée valide', () {
    for (final converter in ConversionRegistry.standard().converters) {
      expect(converter.inputs, isNotEmpty, reason: converter.runtimeType.toString());
    }
  });
}

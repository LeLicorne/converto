import 'dart:io';

import 'package:image/image.dart' as img;

void main(List<String> args) {
  final root = Directory(args.isEmpty ? 'store/screenshots' : args.first);
  var count = 0;
  for (final entity in root.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.png')) continue;
    final decoded = img.decodePng(entity.readAsBytesSync());
    if (decoded == null) continue;
    final flat = img.Image(width: decoded.width, height: decoded.height, numChannels: 3)
      ..clear(img.ColorRgb8(255, 255, 255));
    img.compositeImage(flat, decoded);
    entity.writeAsBytesSync(img.encodePng(flat));
    count++;
  }
  stdout.writeln('$count captures sans canal alpha');
}

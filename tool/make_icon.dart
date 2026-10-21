import 'dart:io';

import 'package:image/image.dart' as img;

void arrow(img.Image image, {required int y, required bool right, required double scale, required int cx}) {
  final white = img.ColorRgba8(255, 255, 255, 255);
  final half = (300 * scale).round();
  final thickness = (64 * scale).round();
  final head = (150 * scale).round();
  final x1 = cx - half;
  final x2 = cx + half;
  img.fillRect(image, x1: x1, y1: y - thickness ~/ 2, x2: x2, y2: y + thickness ~/ 2, color: white, radius: thickness / 2);
  final tipX = right ? x2 + (60 * scale).round() : x1 - (60 * scale).round();
  final baseX = right ? tipX - head : tipX + head;
  img.fillPolygon(
    image,
    vertices: [
      img.Point(tipX, y),
      img.Point(baseX, y - head),
      img.Point(baseX, y + head),
    ],
    color: white,
  );
}

img.Image render({required bool background, required double scale}) {
  final image = img.Image(width: 1024, height: 1024, numChannels: 4);
  if (background) {
    for (final pixel in image) {
      final t = (pixel.x + pixel.y) / 2048;
      pixel
        ..r = (79 + (110 - 79) * t).round()
        ..g = (70 + (80 - 70) * t).round()
        ..b = (229 + (240 - 229) * t).round()
        ..a = 255;
    }
  }
  arrow(image, y: 1024 ~/ 2 - (110 * scale).round(), right: true, scale: scale, cx: 512);
  arrow(image, y: 1024 ~/ 2 + (110 * scale).round(), right: false, scale: scale, cx: 512);
  return image;
}

void main() {
  File('assets/icon/icon.png').writeAsBytesSync(img.encodePng(render(background: true, scale: 1)));
  File('assets/icon/foreground.png').writeAsBytesSync(img.encodePng(render(background: false, scale: 0.72)));
}

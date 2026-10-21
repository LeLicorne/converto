import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:converto/features/convert/domain/conversion_failure.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;

const imageInputFormats = <FileFormat>{
  FileFormat.jpg,
  FileFormat.png,
  FileFormat.webp,
  FileFormat.gif,
  FileFormat.bmp,
  FileFormat.tiff,
  FileFormat.heic,
  FileFormat.avif,
};

const _nativeDecodedFormats = {FileFormat.heic, FileFormat.avif};

class ImageTransform {
  const ImageTransform({
    required this.output,
    this.quality = 90,
    this.maxEdge,
    this.flattenOnWhite = false,
    this.stripMetadata = false,
  });

  final FileFormat output;
  final int quality;
  final int? maxEdge;
  final bool flattenOnWhite;
  final bool stripMetadata;
}

Future<Uint8List> readDecodableBytes(String path, FileFormat format) async {
  if (!_nativeDecodedFormats.contains(format)) {
    return File(path).readAsBytes();
  }
  final converted = await FlutterImageCompress.compressWithFile(
    path,
    minWidth: 100000,
    minHeight: 100000,
    quality: 100,
    format: CompressFormat.png,
  );
  if (converted == null) throw const UnsupportedFile();
  return converted;
}

Future<Uint8List> transformImage({
  required String path,
  required FileFormat input,
  required ImageTransform transform,
}) async {
  final bytes = await readDecodableBytes(path, input);
  final intermediate = transform.output == FileFormat.webp
      ? FileFormat.png
      : transform.output;
  final encoded = await Isolate.run(
    () => _transformInIsolate(bytes, transform, intermediate),
  );
  if (transform.output != FileFormat.webp) return encoded;
  return encodeWebp(encoded, transform.quality);
}

Future<Uint8List> encodeWebp(Uint8List source, int quality) =>
    FlutterImageCompress.compressWithList(
      source,
      minWidth: 100000,
      minHeight: 100000,
      quality: quality,
      format: CompressFormat.webp,
    );

Uint8List _transformInIsolate(
  Uint8List bytes,
  ImageTransform transform,
  FileFormat target,
) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw const CorruptedFile();
  var image = img.bakeOrientation(decoded);
  final edge = transform.maxEdge;
  if (edge != null && (image.width > edge || image.height > edge)) {
    image = image.width >= image.height
        ? img.copyResize(image, width: edge, interpolation: img.Interpolation.average)
        : img.copyResize(image, height: edge, interpolation: img.Interpolation.average);
  }
  final needsOpaque = transform.flattenOnWhite ||
      target == FileFormat.jpg ||
      target == FileFormat.bmp;
  if (needsOpaque && image.hasAlpha) {
    final background = img.Image(
      width: image.width,
      height: image.height,
      numChannels: 3,
    )..clear(img.ColorRgb8(255, 255, 255));
    img.compositeImage(background, image);
    image = background;
  }
  if (transform.stripMetadata) image.exif.clear();
  return switch (target) {
    FileFormat.jpg => img.encodeJpg(image, quality: transform.quality),
    FileFormat.png => img.encodePng(image),
    FileFormat.gif => img.encodeGif(image),
    FileFormat.bmp => img.encodeBmp(image),
    FileFormat.tiff => img.encodeTiff(image),
    _ => throw const UnsupportedFile(),
  };
}

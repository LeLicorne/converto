import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

String decodeText(Uint8List bytes) {
  var data = bytes;
  if (data.length >= 3 && data[0] == 0xEF && data[1] == 0xBB && data[2] == 0xBF) {
    data = Uint8List.sublistView(data, 3);
  }
  try {
    return utf8.decode(data);
  } on FormatException {
    return latin1.decode(data);
  }
}

Future<String> readTextFile(String path) async =>
    decodeText(await File(path).readAsBytes());

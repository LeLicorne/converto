import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class Workspace {
  Workspace._(this.root);

  Workspace.at(this.root);

  final Directory root;

  static Future<Workspace> open() async {
    final base = await getTemporaryDirectory();
    final root = Directory(p.join(base.path, 'converto'));
    if (!root.existsSync()) root.createSync(recursive: true);
    return Workspace._(root);
  }

  Future<void> purge() async {
    if (!root.existsSync()) return;
    for (final entry in root.listSync()) {
      try {
        entry.deleteSync(recursive: true);
      } on FileSystemException {
        continue;
      }
    }
  }

  Directory newSession() {
    final directory = Directory(
      p.join(root.path, DateTime.now().microsecondsSinceEpoch.toString()),
    )..createSync(recursive: true);
    return directory;
  }
}

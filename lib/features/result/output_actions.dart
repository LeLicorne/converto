import 'dart:io';
import 'dart:ui';

import 'package:converto/features/convert/domain/conversion_job.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gal/gal.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

enum ActionOutcome { saved, savedToPhotos, cancelled, failed, noApp }

const _inMemorySaveLimit = 100 * 1024 * 1024;

class OutputActions {
  const OutputActions();

  bool canSaveToPhotos(List<OutputFile> files) =>
      files.isNotEmpty &&
      files.every(
        (file) =>
            file.format.category == FormatCategory.image ||
            file.format.category == FormatCategory.video,
      );

  Future<ActionOutcome> saveToPhotos(List<OutputFile> files) async {
    try {
      if (!await Gal.hasAccess() && !await Gal.requestAccess()) {
        return ActionOutcome.failed;
      }
      for (final file in files) {
        if (file.format.category == FormatCategory.video) {
          await Gal.putVideo(file.path);
        } else {
          await Gal.putImage(file.path);
        }
      }
      return ActionOutcome.savedToPhotos;
    } on Object {
      return ActionOutcome.failed;
    }
  }

  Future<ActionOutcome> saveToFiles(
    List<OutputFile> files, {
    required Rect? shareOrigin,
  }) async {
    try {
      for (final file in files) {
        if (file.sizeBytes > _inMemorySaveLimit) {
          return await share([file], shareOrigin: shareOrigin);
        }
        final saved = await FilePicker.saveFile(
          fileName: file.name,
          bytes: await File(file.path).readAsBytes(),
          mimeType: file.format.mimeType,
        );
        if (saved == null) return ActionOutcome.cancelled;
      }
      return ActionOutcome.saved;
    } on Object {
      return ActionOutcome.failed;
    }
  }

  Future<ActionOutcome> share(
    List<OutputFile> files, {
    required Rect? shareOrigin,
  }) async {
    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [
            for (final file in files)
              XFile(file.path, mimeType: file.format.mimeType, name: file.name),
          ],
          sharePositionOrigin: shareOrigin,
        ),
      );
      return result.status == ShareResultStatus.dismissed
          ? ActionOutcome.cancelled
          : ActionOutcome.saved;
    } on Object {
      return ActionOutcome.failed;
    }
  }

  Future<ActionOutcome> open(OutputFile file) async {
    try {
      final result = await OpenFilex.open(file.path, type: file.format.mimeType);
      return switch (result.type) {
        ResultType.done => ActionOutcome.saved,
        ResultType.noAppToOpen => ActionOutcome.noApp,
        _ => ActionOutcome.failed,
      };
    } on Object {
      return ActionOutcome.failed;
    }
  }
}

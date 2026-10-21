import 'dart:async';
import 'dart:io';

import 'package:converto/features/convert/domain/conversion_failure.dart';
import 'package:converto/features/convert/domain/conversion_job.dart';
import 'package:converto/features/convert/domain/source_file.dart';
import 'package:ffmpeg_kit_flutter_new_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_full/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new_full/return_code.dart';

class MediaProbe {
  const MediaProbe({
    this.duration,
    this.width,
    this.height,
    this.frameRate,
    this.hasVideo = false,
    this.hasAudio = false,
  });

  final Duration? duration;
  final int? width;
  final int? height;
  final double? frameRate;
  final bool hasVideo;
  final bool hasAudio;
}

Future<MediaProbe> probeMedia(String path) async {
  try {
    final session = await FFprobeKit.getMediaInformation(path);
    final info = session.getMediaInformation();
    if (info == null) return const MediaProbe();
    final seconds = double.tryParse(info.getDuration() ?? '');
    var hasVideo = false;
    var hasAudio = false;
    int? width;
    int? height;
    double? frameRate;
    for (final stream in info.getStreams()) {
      final type = stream.getType();
      if (type == 'video' && !hasVideo) {
        final disposition = stream.getAllProperties()?['disposition'];
        if (disposition is Map && disposition['attached_pic'] == 1) continue;
        hasVideo = true;
        width = stream.getWidth();
        height = stream.getHeight();
        frameRate = _parseRate(stream.getAverageFrameRate());
      }
      if (type == 'audio') hasAudio = true;
    }
    return MediaProbe(
      duration: seconds == null ? null : Duration(milliseconds: (seconds * 1000).round()),
      width: width,
      height: height,
      frameRate: frameRate,
      hasVideo: hasVideo,
      hasAudio: hasAudio,
    );
  } on Object {
    return const MediaProbe();
  }
}

double? _parseRate(String? rate) {
  if (rate == null) return null;
  final parts = rate.split('/');
  final numerator = double.tryParse(parts.first);
  final denominator = parts.length > 1 ? double.tryParse(parts[1]) : 1;
  if (numerator == null || denominator == null || denominator == 0) return null;
  return numerator / denominator;
}

Future<SourceMetadata> probeMetadata(String path) async {
  final probe = await probeMedia(path);
  return SourceMetadata(
    duration: probe.duration,
    width: probe.width,
    height: probe.height,
  );
}

Future<void> runFfmpeg({
  required List<String> arguments,
  required String inputPath,
  required String outputPath,
  required ConversionJob job,
  Duration? duration,
}) async {
  final completer = Completer<ReturnCode?>();
  final full = [
    '-y',
    '-hide_banner',
    '-nostdin',
    '-protocol_whitelist',
    'file',
    '-i',
    inputPath,
    ...arguments,
    outputPath,
  ];
  final totalMs = duration?.inMilliseconds ?? 0;
  final session = await FFmpegKit.executeWithArgumentsAsync(
    full,
    (session) async => completer.complete(await session.getReturnCode()),
    null,
    (statistics) {
      if (totalMs > 0) {
        job.onProgress((statistics.getTime() / totalMs).clamp(0.0, 0.99));
      }
    },
  );
  final sessionId = session.getSessionId();
  final watcher = Timer.periodic(const Duration(milliseconds: 300), (_) {
    if (job.cancelToken.isCancelled && sessionId != null) {
      FFmpegKit.cancel(sessionId);
    }
  });
  try {
    final code = await completer.future;
    if (job.cancelToken.isCancelled || ReturnCode.isCancel(code)) {
      _delete(outputPath);
      throw const ConversionCancelled();
    }
    if (!ReturnCode.isSuccess(code)) {
      _delete(outputPath);
      final logs = await session.getAllLogsAsString() ?? '';
      if (logs.contains('No space left')) throw const NotEnoughSpace();
      if (logs.contains('Invalid data') || logs.contains('moov atom not found')) {
        throw const CorruptedFile();
      }
      throw const UnsupportedFile();
    }
    job.onProgress(1);
  } finally {
    watcher.cancel();
  }
}

void _delete(String path) {
  final file = File(path);
  if (file.existsSync()) file.deleteSync();
}

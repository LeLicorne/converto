import 'dart:io';

import 'package:converto/features/convert/domain/conversion_failure.dart';
import 'package:converto/features/convert/domain/conversion_job.dart';
import 'package:converto/features/convert/domain/conversion_option.dart';
import 'package:converto/features/convert/domain/converter.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:converto/features/convert/domain/source_file.dart';
import 'package:converto/features/convert/engines/ffmpeg_runner.dart';
import 'package:converto/features/convert/engines/output_writer.dart';
import 'package:path/path.dart' as p;

const audioFormats = <FileFormat>{
  FileFormat.mp3,
  FileFormat.aac,
  FileFormat.m4a,
  FileFormat.wav,
  FileFormat.flac,
  FileFormat.ogg,
  FileFormat.opus,
  FileFormat.aiff,
};

const videoFormats = <FileFormat>{
  FileFormat.mp4,
  FileFormat.mov,
  FileFormat.mkv,
  FileFormat.webm,
};

const _lossyAudio = {
  FileFormat.mp3,
  FileFormat.aac,
  FileFormat.m4a,
  FileFormat.ogg,
  FileFormat.opus,
};

class AudioConverter extends Converter {
  const AudioConverter(this.output);

  @override
  final FileFormat output;

  @override
  Set<FileFormat> get inputs => {...audioFormats, ...videoFormats}..remove(output);

  @override
  List<ConversionOption> optionsFor(List<SourceFile> sources) => [
    if (_lossyAudio.contains(output))
      const ChoiceOption(
        'bitrate',
        choices: ['96', '128', '192', '256', '320'],
        initial: '192',
      ),
    const ChoiceOption(
      'sampleRate',
      choices: ['original', '44100', '48000'],
      initial: 'original',
    ),
    const ChoiceOption(
      'channels',
      choices: ['original', 'mono', 'stereo'],
      initial: 'original',
    ),
    const ToggleOption('keepMetadata', initial: true),
  ];

  List<String> _codec(OptionValues options) {
    final bitrate = '${options.choice('bitrate').isEmpty ? '192' : options.choice('bitrate')}k';
    return switch (output) {
      FileFormat.mp3 => ['-c:a', 'libmp3lame', '-b:a', bitrate],
      FileFormat.aac => ['-c:a', 'aac', '-b:a', bitrate, '-f', 'adts'],
      FileFormat.m4a => ['-c:a', 'aac', '-b:a', bitrate, '-f', 'ipod'],
      FileFormat.ogg => ['-c:a', 'libvorbis', '-b:a', bitrate],
      FileFormat.opus => ['-c:a', 'libopus', '-b:a', bitrate, '-f', 'opus'],
      FileFormat.flac => ['-c:a', 'flac'],
      FileFormat.aiff => ['-c:a', 'pcm_s16be', '-f', 'aiff'],
      _ => ['-c:a', 'pcm_s16le'],
    };
  }

  @override
  Future<ConversionResult> run(ConversionJob job) async {
    final source = job.source;
    final probe = await probeMedia(source.path);
    if (!probe.hasAudio) throw const UnsupportedFile();
    final options = job.options;
    final arguments = <String>[
      '-vn',
      '-map',
      '0:a:0',
      ..._codec(options),
      if (options.choice('sampleRate') != 'original' && options.choice('sampleRate').isNotEmpty) ...[
        '-ar',
        options.choice('sampleRate'),
      ],
      if (options.choice('channels') == 'mono') ...['-ac', '1'],
      if (options.choice('channels') == 'stereo') ...['-ac', '2'],
      if (!options.toggle('keepMetadata')) ...['-map_metadata', '-1'],
    ];
    final path = uniquePath(job.outputDirectory, source.baseName, output.extension);
    await runFfmpeg(
      arguments: arguments,
      inputPath: source.path,
      outputPath: path,
      job: job,
      duration: probe.duration,
    );
    return ConversionResult(
      files: [
        OutputFile(
          path: path,
          name: p.basename(path),
          format: output,
          sizeBytes: File(path).lengthSync(),
        ),
      ],
    );
  }
}

class VideoConverter extends Converter {
  const VideoConverter(this.output);

  @override
  final FileFormat output;

  @override
  Set<FileFormat> get inputs => {...videoFormats}..remove(output);

  bool get _isGif => output == FileFormat.gif;

  @override
  List<ConversionOption> optionsFor(List<SourceFile> sources) {
    if (_isGif) {
      return const [
        ChoiceOption('gifWidth', choices: ['320', '480', '640'], initial: '480'),
        ChoiceOption('gifFps', choices: ['10', '15', '20'], initial: '15'),
        ChoiceOption('gifDuration', choices: ['full', '30', '10', '5'], initial: '10'),
      ];
    }
    return [
      const ChoiceOption(
        'resolution',
        choices: ['original', '1080', '720', '480', '360'],
        initial: 'original',
      ),
      const ChoiceOption('quality', choices: ['high', 'medium', 'low'], initial: 'medium'),
      const ChoiceOption('fps', choices: ['original', '30', '24', '15'], initial: 'original'),
      if (output != FileFormat.webm)
        const ChoiceOption('codec', choices: ['h264', 'hevc'], initial: 'h264'),
      const ToggleOption('keepAudio', initial: true),
    ];
  }

  @override
  Future<ConversionResult> run(ConversionJob job) async {
    final source = job.source;
    final probe = await probeMedia(source.path);
    if (!probe.hasVideo) throw const UnsupportedFile();
    final arguments = _isGif ? _gifArguments(job) : _videoArguments(job, probe);
    final path = uniquePath(job.outputDirectory, source.baseName, output.extension);
    await runFfmpeg(
      arguments: arguments,
      inputPath: source.path,
      outputPath: path,
      job: job,
      duration: _effectiveDuration(job, probe),
    );
    return ConversionResult(
      files: [
        OutputFile(
          path: path,
          name: p.basename(path),
          format: output,
          sizeBytes: File(path).lengthSync(),
        ),
      ],
    );
  }

  Duration? _effectiveDuration(ConversionJob job, MediaProbe probe) {
    if (!_isGif) return probe.duration;
    final limit = int.tryParse(job.options.choice('gifDuration'));
    if (limit == null || probe.duration == null) return probe.duration;
    final capped = Duration(seconds: limit);
    return probe.duration! < capped ? probe.duration : capped;
  }

  List<String> _gifArguments(ConversionJob job) {
    final width = job.options.choice('gifWidth');
    final fps = job.options.choice('gifFps');
    final limit = int.tryParse(job.options.choice('gifDuration'));
    return [
      if (limit != null) ...['-t', '$limit'],
      '-an',
      '-vf',
      'fps=$fps,scale=$width:-2:flags=lanczos,split[a][b];[a]palettegen=stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=5',
      '-loop',
      '0',
    ];
  }

  List<String> _videoArguments(ConversionJob job, MediaProbe probe) {
    final options = job.options;
    final targetHeight = int.tryParse(options.choice('resolution'));
    final sourceHeight = probe.height ?? 1080;
    final sourceWidth = probe.width ?? 1920;
    final outHeight = targetHeight != null && targetHeight < sourceHeight ? targetHeight : sourceHeight;
    final outWidth = (sourceWidth * outHeight / sourceHeight).round();
    final sourceFps = probe.frameRate ?? 30;
    final fps = double.tryParse(options.choice('fps'));
    final outFps = fps != null && fps < sourceFps ? fps : sourceFps;
    final filters = <String>[
      if (targetHeight != null && targetHeight < sourceHeight) 'scale=-2:$targetHeight',
      if (fps != null && fps < sourceFps) 'fps=${fps.round()}',
      'format=yuv420p',
    ];
    final factor = switch (options.choice('quality')) {
      'high' => 0.14,
      'low' => 0.05,
      _ => 0.08,
    };
    final bitrate = (outWidth * outHeight * outFps * factor).clamp(300000, 40000000).round();
    final hevc = options.choice('codec') == 'hevc';
    final video = <String>[
      if (output == FileFormat.webm) ...[
        '-c:v', 'libvpx-vp9', '-b:v', '$bitrate', '-deadline', 'realtime', '-cpu-used', '8', '-row-mt', '1',
      ] else if (Platform.isIOS) ...[
        '-c:v', hevc ? 'hevc_videotoolbox' : 'h264_videotoolbox', '-b:v', '$bitrate',
        if (hevc) ...['-tag:v', 'hvc1'],
      ] else ...[
        '-c:v', hevc ? 'hevc_mediacodec' : 'h264_mediacodec', '-b:v', '$bitrate',
        if (hevc) ...['-tag:v', 'hvc1'],
      ],
    ];
    final audio = !options.toggle('keepAudio') || !probe.hasAudio
        ? ['-an']
        : output == FileFormat.webm
        ? ['-c:a', 'libopus', '-b:a', '128k']
        : ['-c:a', 'aac', '-b:a', '160k'];
    return [
      '-map', '0:v:0',
      if (probe.hasAudio && options.toggle('keepAudio')) ...['-map', '0:a:0'],
      '-vf', filters.join(','),
      ...video,
      ...audio,
      if (output == FileFormat.mp4 || output == FileFormat.mov) ...['-movflags', '+faststart'],
    ];
  }
}

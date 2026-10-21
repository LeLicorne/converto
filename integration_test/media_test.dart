import 'dart:io';

import 'package:converto/features/convert/domain/conversion_option.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:converto/features/convert/engines/ffmpeg_runner.dart';
import 'package:converto/features/convert/engines/media_converters.dart';
import 'package:ffmpeg_kit_flutter_new_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_full/return_code.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/fixtures.dart';

Future<String> generate(Sandbox sandbox, String name, List<String> args) async {
  final path = '${sandbox.directory.path}/$name';
  final session = await FFmpegKit.executeWithArguments(['-y', ...args, path]);
  final code = await session.getReturnCode();
  expect(ReturnCode.isSuccess(code), isTrue, reason: await session.getAllLogsAsString());
  return path;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late Sandbox sandbox;
  setUp(() => sandbox = Sandbox.create());
  tearDown(() => sandbox.dispose());

  testWidgets('audio : WAV vers tous les formats audio', (tester) async {
    final wav = await generate(sandbox, 'tone.wav', ['-f', 'lavfi', '-i', 'sine=frequency=440:duration=2']);
    final source = await describe(wav);
    expect(source.format, FileFormat.wav);
    expect(source.metadata.duration, isNotNull);
    for (final format in audioFormats.where((f) => f != FileFormat.wav)) {
      final result = await runConverter(AudioConverter(format), [source], sandbox);
      final out = await describe(result.files.single.path);
      expect(File(out.path).lengthSync(), greaterThan(500), reason: format.label);
      final probe = await probeMedia(out.path);
      expect(probe.hasAudio, isTrue, reason: format.label);
    }
  });

  testWidgets('audio : réglages mono et débit', (tester) async {
    final wav = await generate(sandbox, 'tone.wav', ['-f', 'lavfi', '-i', 'sine=frequency=440:duration=2']);
    final source = await describe(wav);
    const converter = AudioConverter(FileFormat.mp3);
    final options = defaultValues(converter.optionsFor([source]))
      ..['bitrate'] = '96'
      ..['channels'] = 'mono';
    final result = await runConverter(converter, [source], sandbox, options: options);
    expect(result.files.single.format, FileFormat.mp3);
  });

  testWidgets('vidéo : MP4 vers WebM, GIF, MOV et audio', (tester) async {
    final video = await generate(sandbox, 'clip.mp4', [
      '-f', 'lavfi', '-i', 'testsrc=duration=2:size=320x240:rate=15',
      '-f', 'lavfi', '-i', 'sine=frequency=330:duration=2',
      '-c:v', 'mpeg4', '-c:a', 'aac', '-shortest',
    ]);
    final source = await describe(video);
    expect(source.format, FileFormat.mp4);
    expect(source.metadata.width, 320);
    for (final format in [FileFormat.webm, FileFormat.gif, FileFormat.mkv]) {
      final result = await runConverter(VideoConverter(format), [source], sandbox);
      expect(File(result.files.single.path).lengthSync(), greaterThan(1000), reason: format.label);
    }
    final audio = await runConverter(const AudioConverter(FileFormat.mp3), [source], sandbox);
    expect((await probeMedia(audio.files.single.path)).hasAudio, isTrue);
  });

  testWidgets('vidéo : encodage H.264 matériel vers MP4', (tester) async {
    final video = await generate(sandbox, 'clip.mov', [
      '-f', 'lavfi', '-i', 'testsrc=duration=2:size=320x240:rate=15', '-c:v', 'mpeg4',
    ]);
    final source = await describe(video);
    const converter = VideoConverter(FileFormat.mp4);
    final options = defaultValues(converter.optionsFor([source]))
      ..['resolution'] = '120'
      ..['quality'] = 'low';
    final result = await runConverter(converter, [source], sandbox, options: options);
    final probe = await probeMedia(result.files.single.path);
    expect(probe.hasVideo, isTrue);
    expect(probe.height, 120);
  });
}

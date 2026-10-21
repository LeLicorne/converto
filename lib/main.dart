import 'package:converto/app.dart';
import 'package:converto/core/workspace.dart';
import 'package:converto/features/convert/application/conversion_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final text = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['Noto Sans'], text);
  });
  final workspace = await Workspace.open();
  await workspace.purge();
  runApp(
    ProviderScope(
      overrides: [workspaceProvider.overrideWithValue(workspace)],
      child: const ConvertoApp(),
    ),
  );
}

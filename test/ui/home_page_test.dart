import 'dart:io';

import 'package:converto/features/convert/application/conversion_state.dart';
import 'package:converto/features/convert/domain/conversion_failure.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:converto/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ui_harness.dart';

void main() {
  setUpAll(loadFonts);

  group('accueil', () {
    testWidgets('affiche le nom de l\'app et une grande carte de sélection', (tester) async {
      await pumpApp(tester, const IdleState());
      expect(find.text('Converto'), findsOneWidget);
      expect(find.text('Choose a file'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Choose a file')), findsOneWidget);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/idle_light.png'));
    });

    testWidgets('suit la langue du téléphone', (tester) async {
      await pumpApp(tester, const IdleState(), locale: const Locale('fr'));
      expect(find.text('Choisir un fichier'), findsOneWidget);
      await pumpApp(tester, const IdleState(), locale: const Locale('de'));
      expect(find.text('Datei auswählen'), findsOneWidget);
    });

    testWidgets('affiche un message d\'erreur traduit et le ferme', (tester) async {
      await pumpApp(tester, const IdleState(failure: CorruptedFile()));
      expect(find.text('This file looks damaged or can\'t be read.'), findsOneWidget);
      await tester.tap(find.byTooltip('Dismiss'));
      await tester.pumpAndSettle();
      expect(find.text('This file looks damaged or can\'t be read.'), findsNothing);
    });

    testWidgets('rend le thème sombre', (tester) async {
      await pumpApp(tester, const IdleState(), brightness: Brightness.dark);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/idle_dark.png'));
    });
  });

  group('fichier choisi', () {
    testWidgets('PDF : propose images, texte et fusion, jamais audio ni vidéo', (tester) async {
      await pumpApp(tester, readyFor(pdfSource()));
      expect(find.text('contract.pdf'), findsOneWidget);
      expect(find.textContaining('12 pages'), findsOneWidget);
      for (final label in ['PNG', 'JPG', 'WEBP', 'TXT']) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      for (final label in ['MP3', 'MP4', 'WAV', 'FLAC']) {
        expect(find.text(label), findsNothing, reason: label);
      }
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/ready_pdf.png'));
    });

    testWidgets('un tap sur un format ouvre les options de raffinement du PDF', (tester) async {
      await pumpApp(tester, readyFor(pdfSource()));
      await tester.tap(find.text('PNG'));
      await tester.pumpAndSettle();
      expect(find.text('One image per page'), findsOneWidget);
      expect(find.text('A single long image'), findsOneWidget);
      expect(find.text('Resolution (DPI)'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Convert to PNG'), findsOneWidget);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/options_pdf.png'));
    });

    testWidgets('refuse une sélection de pages invalide', (tester) async {
      await pumpApp(tester, readyFor(pdfSource()));
      await tester.tap(find.text('PNG'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '40');
      await tester.pump();
      expect(find.text('Invalid page selection (1 to 12).'), findsOneWidget);
      final button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Convert to PNG'));
      expect(button.onPressed, isNull);
    });

    testWidgets('lance la conversion avec le convertisseur choisi', (tester) async {
      final controller = await pumpApp(tester, readyFor(photoSource()));
      await tester.tap(find.text('PDF'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Convert to PDF'));
      await tester.pumpAndSettle();
      expect(controller.started?.output, FileFormat.pdf);
    });

    testWidgets('« Changer » revient à l\'accueil', (tester) async {
      final controller = await pumpApp(tester, readyFor(photoSource()));
      await tester.tap(find.text('Change'));
      await tester.pumpAndSettle();
      expect(controller.resets, 1);
      expect(find.text('Choose a file'), findsOneWidget);
    });

    testWidgets('fichier inconnu : message clair, aucune cible', (tester) async {
      await pumpApp(tester, ReadyState(sources: [pdfSource()], targets: const []));
      expect(find.text('No conversion is available for this file.'), findsOneWidget);
      expect(find.text('Convert to'), findsNothing);
    });
  });

  group('progression et résultat', () {
    testWidgets('affiche le pourcentage et permet d\'annuler', (tester) async {
      await pumpApp(tester, runningState());
      expect(find.text('42 %'), findsOneWidget);
      expect(find.text('5/12'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/running.png'));
    });

    testWidgets('résultat : enregistrer, partager, ouvrir, autre format', (tester) async {
      await pumpApp(tester, doneState());
      expect(find.text('Done!'), findsOneWidget);
      for (final label in ['Save', 'Share', 'Open with…', 'Another format', 'New file']) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/done.png'));
    });
  });

  group('accessibilité', () {
    for (final entry in {
      'accueil': const IdleState(),
      'formats': null,
      'progression': null,
    }.entries) {
      testWidgets('${entry.key} : zones tactiles et libellés conformes', (tester) async {
        final state = switch (entry.key) {
          'formats' => readyFor(pdfSource()),
          'progression' => runningState(),
          _ => entry.value!,
        };
        await pumpApp(tester, state);
        final handle = tester.ensureSemantics();
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });
    }

    testWidgets('contrastes suffisants en clair et en sombre', (tester) async {
      for (final brightness in Brightness.values) {
        await pumpApp(tester, readyFor(pdfSource()), brightness: brightness);
        await expectLater(tester, meetsGuideline(textContrastGuideline));
      }
    });

    testWidgets('texte à 200 % sans débordement', (tester) async {
      await pumpApp(tester, readyFor(pdfSource()), textScale: 2);
      expect(tester.takeException(), isNull);
      await pumpApp(tester, const IdleState(), textScale: 2, size: const Size(320, 640));
      expect(tester.takeException(), isNull);
    });
  });

  group('tablette', () {
    const ipad = Size(1032, 1376);

    testWidgets('accueil : carte centrée sans débordement', (tester) async {
      await pumpApp(tester, const IdleState(), size: ipad);
      expect(tester.takeException(), isNull);
      expect(find.text('Choose a file'), findsOneWidget);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/ipad_idle.png'));
    });

    testWidgets('formats : résumé à gauche, choix à droite', (tester) async {
      await pumpApp(tester, readyFor(pdfSource()), size: ipad);
      expect(tester.takeException(), isNull);
      final summary = tester.getTopLeft(find.text('contract.pdf'));
      final target = tester.getTopLeft(find.text('PNG'));
      expect(target.dx, greaterThan(summary.dx + 300));
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/ipad_ready.png'));
    });

    testWidgets('résultat : aperçu et actions côte à côte', (tester) async {
      await pumpApp(tester, doneState(), size: ipad);
      expect(tester.takeException(), isNull);
      final title = tester.getTopLeft(find.text('Done!'));
      final save = tester.getTopLeft(find.text('Save'));
      expect(save.dy, greaterThan(title.dy));
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/ipad_done.png'));
    });

    testWidgets('progression sans débordement', (tester) async {
      await pumpApp(tester, runningState(), size: ipad);
      expect(tester.takeException(), isNull);
    });

    testWidgets('options sans débordement', (tester) async {
      await pumpApp(tester, readyFor(pdfSource()), size: ipad);
      await tester.tap(find.text('PNG'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('langues', () {
    for (final locale in AppLocalizations.supportedLocales) {
      testWidgets('${locale.languageCode} : écran de formats sans débordement', (tester) async {
        await pumpApp(tester, readyFor(pdfSource()), locale: locale, size: const Size(320, 640));
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('PNG'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }

    test('toutes les langues définissent les mêmes clés', () {
      final base = _keys('en');
      for (final locale in AppLocalizations.supportedLocales) {
        expect(_keys(locale.languageCode), base, reason: locale.languageCode);
      }
    });
  });
}

Set<String> _keys(String lang) {
  final text = File('lib/l10n/app_$lang.arb').readAsStringSync();
  return RegExp(r'^  "([^@"][^"]*)":', multiLine: true)
      .allMatches(text)
      .map((m) => m.group(1)!)
      .where((k) => k != '@@locale')
      .toSet();
}

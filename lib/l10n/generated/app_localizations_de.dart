// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Converto';

  @override
  String get pickTitle => 'Datei auswählen';

  @override
  String get pickSubtitle =>
      'Bild, PDF, Dokument, Audio oder Video. Alles bleibt auf deinem Gerät.';

  @override
  String get pickMedia => 'Fotos und Videos';

  @override
  String get pickMultipleHint =>
      'Du kannst mehrere Dateien auswählen, um sie zusammenzuführen.';

  @override
  String get loading => 'Datei wird gelesen …';

  @override
  String get changeFile => 'Ändern';

  @override
  String get changeFileSemantics => 'Andere Datei auswählen';

  @override
  String filesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Dateien',
      one: '1 Datei',
    );
    return '$_temp0';
  }

  @override
  String detectedFormat(String format) {
    return 'Erkannt: $format';
  }

  @override
  String get unknownFormat => 'Unbekanntes Format';

  @override
  String get convertTo => 'Konvertieren in';

  @override
  String get noTargets => 'Für diese Datei ist keine Konvertierung verfügbar.';

  @override
  String get mixedFiles =>
      'Diese Dateien haben unterschiedliche Typen und können nicht zusammen konvertiert werden.';

  @override
  String pagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Seiten',
      one: '1 Seite',
    );
    return '$_temp0';
  }

  @override
  String get categoryImage => 'Bilder';

  @override
  String get categoryDocument => 'Dokumente';

  @override
  String get categoryData => 'Daten';

  @override
  String get categoryArchive => 'Archive';

  @override
  String get categoryAudio => 'Audio';

  @override
  String get categoryVideo => 'Video';

  @override
  String get extractArchive => 'Dateien entpacken';

  @override
  String get mergePdf => 'PDF zusammenführen / bearbeiten';

  @override
  String get createZip => 'ZIP-Archiv';

  @override
  String get optionsTitle => 'Optionen';

  @override
  String convertButton(String format) {
    return 'In $format konvertieren';
  }

  @override
  String get optQuality => 'Qualität';

  @override
  String get optMaxSize => 'Maximale Größe';

  @override
  String get optStripMetadata => 'Metadaten entfernen (Standort, Kamera …)';

  @override
  String get optPages => 'Seiten';

  @override
  String get optPagesHint => 'Alle Seiten oder zum Beispiel 1-3, 5';

  @override
  String optPagesInvalid(int count) {
    return 'Ungültige Seitenauswahl (1 bis $count).';
  }

  @override
  String get optLayout => 'Ergebnis';

  @override
  String get layoutSeparate => 'Ein Bild pro Seite';

  @override
  String get layoutSingle => 'Ein einziges langes Bild';

  @override
  String get optDpi => 'Auflösung (DPI)';

  @override
  String get optPageSize => 'Seitengröße';

  @override
  String get pageSizeFit => 'An Bild anpassen';

  @override
  String get optGrouping => 'Ergebnis';

  @override
  String get groupingSingle => 'Ein PDF mit allen Bildern';

  @override
  String get groupingPerImage => 'Ein PDF pro Bild';

  @override
  String get optOptimize => 'Dateigröße optimieren';

  @override
  String get optFontSize => 'Schriftgröße';

  @override
  String get optDelimiter => 'Trennzeichen';

  @override
  String get optOutputDelimiter => 'Trennzeichen';

  @override
  String get optFirstRowHeader => 'Erste Zeile enthält Spaltennamen';

  @override
  String get optPretty => 'Lesbare Formatierung';

  @override
  String get optPageSeparators => 'Seitentrenner einfügen';

  @override
  String get optRotation => 'Drehung';

  @override
  String get optBitrate => 'Bitrate';

  @override
  String get optSampleRate => 'Abtastrate';

  @override
  String get optChannels => 'Kanäle';

  @override
  String get optKeepMetadata => 'Tags und Cover behalten';

  @override
  String get optResolution => 'Auflösung';

  @override
  String get optFps => 'Bildrate';

  @override
  String get optCodec => 'Codec';

  @override
  String get optKeepAudio => 'Tonspur behalten';

  @override
  String get optGifWidth => 'Breite';

  @override
  String get optGifFps => 'Bilder pro Sekunde';

  @override
  String get optGifDuration => 'Maximale Dauer';

  @override
  String get choiceOriginal => 'Original';

  @override
  String get choiceFull => 'Ganzes Video';

  @override
  String get choiceMono => 'Mono';

  @override
  String get choiceStereo => 'Stereo';

  @override
  String get choiceAuto => 'Automatisch';

  @override
  String get choiceTab => 'Tabulator';

  @override
  String get choiceHigh => 'Hoch';

  @override
  String get choiceMedium => 'Ausgewogen';

  @override
  String get choiceLow => 'Kleine Datei';

  @override
  String get converting => 'Wird konvertiert …';

  @override
  String convertingSemantics(int percent) {
    return 'Konvertierung läuft, $percent Prozent';
  }

  @override
  String get keepScreenOn =>
      'Lass die App geöffnet, bis die Konvertierung fertig ist.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get ok => 'OK';

  @override
  String get resultTitle => 'Fertig!';

  @override
  String resultFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Dateien erstellt',
      one: '1 Datei erstellt',
    );
    return '$_temp0';
  }

  @override
  String resultSize(String before, String after) {
    return '$before → $after';
  }

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionSaveToFiles => 'In Dateien sichern';

  @override
  String get actionSaveToPhotos => 'In Fotos sichern';

  @override
  String get actionShare => 'Teilen';

  @override
  String get actionOpen => 'Öffnen';

  @override
  String get actionOpenWith => 'Öffnen mit …';

  @override
  String get shareAsZip => 'Alles als ein ZIP';

  @override
  String get convertAnother => 'Anderes Format';

  @override
  String get newFile => 'Neue Datei';

  @override
  String get savedOk => 'Gespeichert.';

  @override
  String get savedPhotos => 'In deinen Fotos gesichert.';

  @override
  String get saveFailed => 'Die Datei konnte nicht gespeichert werden.';

  @override
  String get openFailed => 'Keine App kann diese Datei öffnen.';

  @override
  String get passwordTitle => 'Passwort erforderlich';

  @override
  String passwordBody(String name) {
    return '„$name“ ist geschützt. Das Passwort wird nur auf diesem Gerät verwendet.';
  }

  @override
  String get passwordLabel => 'Passwort';

  @override
  String get passwordWrong => 'Falsches Passwort, bitte erneut versuchen.';

  @override
  String get errCorrupt =>
      'Diese Datei scheint beschädigt oder nicht lesbar zu sein.';

  @override
  String get errUnsupported =>
      'Diese Datei kann mit diesen Einstellungen nicht konvertiert werden.';

  @override
  String get errTooLarge =>
      'Diese Datei ist zu groß für die Konvertierung auf diesem Gerät.';

  @override
  String get errNoSpace => 'Nicht genügend freier Speicherplatz.';

  @override
  String get errEngine =>
      'Diese Konvertierung ist auf diesem Gerät nicht verfügbar.';

  @override
  String get errPick => 'Die Datei konnte nicht geöffnet werden.';

  @override
  String get dismiss => 'Schließen';

  @override
  String get settingsTooltip => 'Info und rechtliche Hinweise';

  @override
  String get aboutTitle => 'Info';

  @override
  String get aboutTagline =>
      'Kostenlos. Keine Werbung, kein Konto, kein Tracking. Deine Dateien verlassen nie dein Gerät.';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutPrivacy => 'Datenschutz';

  @override
  String get aboutPrivacyBody =>
      'Diese App erhebt, speichert und überträgt keine personenbezogenen Daten. Deine Dateien werden vollständig auf deinem Gerät konvertiert und aus dem temporären Speicher gelöscht, sobald du fertig bist oder eine andere Datei wählst.\n\nDie App hat kein Konto, keine Werbung, keine Analyse, keine Cookies und kein Tracking und benötigt keine Internetverbindung. Dateien werden nur von Orten gelesen, die du auswählst, und Ergebnisse werden nur auf deinen Wunsch gespeichert oder geteilt.\n\nDa der Herausgeber keine Daten verarbeitet, ist kein Einwilligungsbanner erforderlich.';

  @override
  String get aboutAccessibility => 'Barrierefreiheit';

  @override
  String aboutAccessibilityBody(String contact) {
    return 'Die App ist so gestaltet, dass alle sie nutzen können: Unterstützung für Screenreader (VoiceOver und TalkBack), Text, der der Systemschriftgröße folgt, helle und dunkle Designs mit ausreichendem Kontrast, große Touch-Flächen und keine Zeitlimits.\n\nZiel ist die Stufe AA der WCAG 2.1, die Grundlage des französischen RGAA. Eine formale Prüfung durch Dritte wurde noch nicht durchgeführt, daher ist die Konformität noch nicht zertifiziert; diese Erklärung wird nach der Prüfung aktualisiert.\n\nWenn dir ein Barrierefreiheitsproblem begegnet, schreibe bitte an $contact. Wir antworten in angemessener Zeit und suchen nach einem alternativen Weg, dir die Funktion zugänglich zu machen.';
  }

  @override
  String get aboutLegal => 'Impressum und Nutzungsbedingungen';

  @override
  String aboutLegalBody(String publisher, String contact) {
    return 'Herausgeber: $publisher, Privatperson, die nicht gewerblich handelt.\nKontakt: $contact.\nHoster der Website: OVH SAS, 2 rue Kellermann, 59100 Roubaix, Frankreich. Wie es Artikel 6 III-2 des französischen LCEN erlaubt, hat der Herausgeber dem Hoster seine vollständigen Kontaktdaten mitgeteilt.\n\nDie App wird kostenlos und „wie besehen“ bereitgestellt, ohne Kauf, Abonnement oder Werbung. Die Ergebnisse hängen von der Quelldatei ab und können vom Original abweichen (Layout, Qualität, Metadaten); bewahre eine Kopie deiner Originale auf.\n\nDu bist dafür verantwortlich, die Rechte an den konvertierten Dateien zu besitzen und die Ergebnisse rechtmäßig zu verwenden. Die App entfernt keinen Kopierschutz: Ein verschlüsseltes PDF lässt sich nur mit dem von dir angegebenen Passwort öffnen.';
  }

  @override
  String get aboutLicenses => 'Open-Source-Lizenzen';

  @override
  String get aboutContact => 'Herausgeber kontaktieren';

  @override
  String get aboutFfmpeg =>
      'Die Audio- und Videokonvertierung nutzt FFmpeg (LGPL 3.0).';
}

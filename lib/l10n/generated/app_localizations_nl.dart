// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appName => 'Converto';

  @override
  String get pickTitle => 'Kies een bestand';

  @override
  String get pickSubtitle =>
      'Afbeelding, pdf, document, audio of video. Alles blijft op je apparaat.';

  @override
  String get pickMedia => 'Foto\'s en video\'s';

  @override
  String get pickMultipleHint =>
      'Je kunt meerdere bestanden kiezen om ze samen te voegen.';

  @override
  String get loading => 'Bestand lezen…';

  @override
  String get changeFile => 'Wijzigen';

  @override
  String get changeFileSemantics => 'Kies een ander bestand';

  @override
  String filesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bestanden',
      one: '1 bestand',
    );
    return '$_temp0';
  }

  @override
  String detectedFormat(String format) {
    return 'Herkend: $format';
  }

  @override
  String get unknownFormat => 'Onbekend formaat';

  @override
  String get convertTo => 'Converteren naar';

  @override
  String get noTargets => 'Er is geen conversie beschikbaar voor dit bestand.';

  @override
  String get mixedFiles =>
      'Deze bestanden zijn van verschillende typen en kunnen niet samen worden geconverteerd.';

  @override
  String pagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pagina\'s',
      one: '1 pagina',
    );
    return '$_temp0';
  }

  @override
  String get categoryImage => 'Afbeeldingen';

  @override
  String get categoryDocument => 'Documenten';

  @override
  String get categoryData => 'Gegevens';

  @override
  String get categoryArchive => 'Archieven';

  @override
  String get categoryAudio => 'Audio';

  @override
  String get categoryVideo => 'Video';

  @override
  String get extractArchive => 'Bestanden uitpakken';

  @override
  String get mergePdf => 'Pdf samenvoegen / bewerken';

  @override
  String get createZip => 'ZIP-archief';

  @override
  String get optionsTitle => 'Opties';

  @override
  String convertButton(String format) {
    return 'Converteren naar $format';
  }

  @override
  String get optQuality => 'Kwaliteit';

  @override
  String get optMaxSize => 'Maximale grootte';

  @override
  String get optStripMetadata => 'Metagegevens verwijderen (locatie, camera…)';

  @override
  String get optPages => 'Pagina\'s';

  @override
  String get optPagesHint => 'Alle pagina\'s, of bijvoorbeeld 1-3, 5';

  @override
  String optPagesInvalid(int count) {
    return 'Ongeldige paginaselectie (1 tot $count).';
  }

  @override
  String get optLayout => 'Resultaat';

  @override
  String get layoutSeparate => 'Eén afbeelding per pagina';

  @override
  String get layoutSingle => 'Eén lange afbeelding';

  @override
  String get optDpi => 'Resolutie (DPI)';

  @override
  String get optPageSize => 'Paginaformaat';

  @override
  String get pageSizeFit => 'Aangepast aan afbeelding';

  @override
  String get optGrouping => 'Resultaat';

  @override
  String get groupingSingle => 'Eén pdf met alle afbeeldingen';

  @override
  String get groupingPerImage => 'Eén pdf per afbeelding';

  @override
  String get optOptimize => 'Bestandsgrootte optimaliseren';

  @override
  String get optFontSize => 'Tekstgrootte';

  @override
  String get optDelimiter => 'Scheidingsteken';

  @override
  String get optOutputDelimiter => 'Scheidingsteken';

  @override
  String get optFirstRowHeader => 'Eerste rij bevat kolomnamen';

  @override
  String get optPretty => 'Leesbare opmaak';

  @override
  String get optPageSeparators => 'Paginascheidingen toevoegen';

  @override
  String get optRotation => 'Rotatie';

  @override
  String get optBitrate => 'Bitrate';

  @override
  String get optSampleRate => 'Samplefrequentie';

  @override
  String get optChannels => 'Kanalen';

  @override
  String get optKeepMetadata => 'Tags en albumhoes behouden';

  @override
  String get optResolution => 'Resolutie';

  @override
  String get optFps => 'Beeldsnelheid';

  @override
  String get optCodec => 'Codec';

  @override
  String get optKeepAudio => 'Audiospoor behouden';

  @override
  String get optGifWidth => 'Breedte';

  @override
  String get optGifFps => 'Beelden per seconde';

  @override
  String get optGifDuration => 'Maximale duur';

  @override
  String get choiceOriginal => 'Origineel';

  @override
  String get choiceFull => 'Hele video';

  @override
  String get choiceMono => 'Mono';

  @override
  String get choiceStereo => 'Stereo';

  @override
  String get choiceAuto => 'Automatisch';

  @override
  String get choiceTab => 'Tab';

  @override
  String get choiceHigh => 'Hoog';

  @override
  String get choiceMedium => 'Gebalanceerd';

  @override
  String get choiceLow => 'Klein bestand';

  @override
  String get converting => 'Bezig met converteren…';

  @override
  String convertingSemantics(int percent) {
    return 'Conversie bezig, $percent procent';
  }

  @override
  String get keepScreenOn => 'Houd de app open tot de conversie klaar is.';

  @override
  String get cancel => 'Annuleren';

  @override
  String get ok => 'OK';

  @override
  String get resultTitle => 'Klaar!';

  @override
  String resultFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bestanden gemaakt',
      one: '1 bestand gemaakt',
    );
    return '$_temp0';
  }

  @override
  String resultSize(String before, String after) {
    return '$before → $after';
  }

  @override
  String get actionSave => 'Opslaan';

  @override
  String get actionSaveToFiles => 'Opslaan in Bestanden';

  @override
  String get actionSaveToPhotos => 'Opslaan in Foto\'s';

  @override
  String get actionShare => 'Delen';

  @override
  String get actionOpen => 'Openen';

  @override
  String get actionOpenWith => 'Openen met…';

  @override
  String get shareAsZip => 'Alles in één ZIP';

  @override
  String get convertAnother => 'Ander formaat';

  @override
  String get newFile => 'Nieuw bestand';

  @override
  String get savedOk => 'Opgeslagen.';

  @override
  String get savedPhotos => 'Opgeslagen in je foto\'s.';

  @override
  String get saveFailed => 'Het bestand kon niet worden opgeslagen.';

  @override
  String get openFailed => 'Geen app kan dit bestand openen.';

  @override
  String get passwordTitle => 'Wachtwoord vereist';

  @override
  String passwordBody(String name) {
    return '‘$name’ is beveiligd. Het wachtwoord wordt alleen op dit apparaat gebruikt.';
  }

  @override
  String get passwordLabel => 'Wachtwoord';

  @override
  String get passwordWrong => 'Onjuist wachtwoord, probeer het opnieuw.';

  @override
  String get errCorrupt => 'Dit bestand lijkt beschadigd of onleesbaar.';

  @override
  String get errUnsupported =>
      'Dit bestand kan niet met deze instellingen worden geconverteerd.';

  @override
  String get errTooLarge =>
      'Dit bestand is te groot om op dit apparaat te worden geconverteerd.';

  @override
  String get errNoSpace => 'Onvoldoende opslagruimte.';

  @override
  String get errEngine => 'Deze conversie is niet beschikbaar op dit apparaat.';

  @override
  String get errPick => 'Het bestand kon niet worden geopend.';

  @override
  String get dismiss => 'Sluiten';

  @override
  String get settingsTooltip => 'Info en juridische kennisgeving';

  @override
  String get aboutTitle => 'Over';

  @override
  String get aboutTagline =>
      'Gratis. Geen advertenties, geen account, geen tracking. Je bestanden verlaten je apparaat nooit.';

  @override
  String aboutVersion(String version) {
    return 'Versie $version';
  }

  @override
  String get aboutPrivacy => 'Privacy';

  @override
  String get aboutPrivacyBody =>
      'Deze app verzamelt, bewaart of verzendt geen persoonsgegevens. Je bestanden worden volledig op je apparaat geconverteerd en uit de tijdelijke opslag verwijderd zodra je klaar bent of een ander bestand kiest.\n\nDe app heeft geen account, geen advertenties, geen analyse, geen cookies en geen tracking en heeft geen internetverbinding nodig. Bestanden worden alleen gelezen van locaties die jij kiest, en resultaten worden alleen opgeslagen of gedeeld wanneer jij dat vraagt.\n\nOmdat de uitgever geen gegevens verwerkt, is geen toestemmingsbanner nodig.';

  @override
  String get aboutAccessibility => 'Toegankelijkheid';

  @override
  String aboutAccessibilityBody(String contact) {
    return 'De app is ontworpen om voor iedereen bruikbaar te zijn: ondersteuning voor schermlezers (VoiceOver en TalkBack), tekst die de systeemtekstgrootte volgt, lichte en donkere thema\'s met voldoende contrast, grote aanraakvlakken en geen tijdslimieten.\n\nHet doel is niveau AA van WCAG 2.1, de basis van de Franse RGAA. Er is nog geen formele audit door een derde uitgevoerd, dus de conformiteit is nog niet gecertificeerd; deze verklaring wordt na de audit bijgewerkt.\n\nAls je een toegankelijkheidsprobleem tegenkomt, schrijf dan naar $contact. We antwoorden binnen een redelijke termijn en zoeken een alternatieve manier om je toegang tot de functie te geven.';
  }

  @override
  String get aboutLegal => 'Juridische kennisgeving en voorwaarden';

  @override
  String aboutLegalBody(String publisher, String contact) {
    return 'Uitgever: $publisher, particulier die niet beroepsmatig handelt.\nContact: $contact.\nHost van de website: OVH SAS, 2 rue Kellermann, 59100 Roubaix, Frankrijk. Zoals artikel 6, III-2 van de Franse LCEN toestaat, heeft de uitgever zijn volledige gegevens aan de host doorgegeven.\n\nDe app wordt gratis en ‘zoals hij is’ aangeboden, zonder aankopen, abonnementen of advertenties. Resultaten hangen af van het bronbestand en kunnen afwijken van het origineel (opmaak, kwaliteit, metagegevens); bewaar een kopie van je originelen.\n\nJij bent verantwoordelijk voor het bezit van de rechten op de bestanden die je converteert en voor het rechtmatig gebruik van de resultaten. De app verwijdert geen beveiliging: een versleutelde pdf kan alleen worden geopend met het wachtwoord dat je opgeeft.';
  }

  @override
  String get aboutLicenses => 'Open-sourcelicenties';

  @override
  String get aboutContact => 'Contact opnemen met de uitgever';

  @override
  String get aboutFfmpeg =>
      'Audio- en videoconversie gebruikt FFmpeg (LGPL 3.0).';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Converto';

  @override
  String get pickTitle => 'Scegli un file';

  @override
  String get pickSubtitle =>
      'Immagine, PDF, documento, audio o video. Tutto resta sul tuo dispositivo.';

  @override
  String get pickMedia => 'Foto e video';

  @override
  String get pickMultipleHint => 'Puoi selezionare più file per unirli.';

  @override
  String get loading => 'Lettura del file…';

  @override
  String get changeFile => 'Cambia';

  @override
  String get changeFileSemantics => 'Scegli un altro file';

  @override
  String filesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count file',
      one: '1 file',
    );
    return '$_temp0';
  }

  @override
  String detectedFormat(String format) {
    return 'Rilevato: $format';
  }

  @override
  String get unknownFormat => 'Formato non riconosciuto';

  @override
  String get convertTo => 'Converti in';

  @override
  String get noTargets => 'Nessuna conversione disponibile per questo file.';

  @override
  String get mixedFiles =>
      'Questi file sono di tipi diversi e non possono essere convertiti insieme.';

  @override
  String pagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pagine',
      one: '1 pagina',
    );
    return '$_temp0';
  }

  @override
  String get categoryImage => 'Immagini';

  @override
  String get categoryDocument => 'Documenti';

  @override
  String get categoryData => 'Dati';

  @override
  String get categoryArchive => 'Archivi';

  @override
  String get categoryAudio => 'Audio';

  @override
  String get categoryVideo => 'Video';

  @override
  String get extractArchive => 'Estrai i file';

  @override
  String get mergePdf => 'Unisci / modifica PDF';

  @override
  String get createZip => 'Archivio ZIP';

  @override
  String get optionsTitle => 'Opzioni';

  @override
  String convertButton(String format) {
    return 'Converti in $format';
  }

  @override
  String get optQuality => 'Qualità';

  @override
  String get optMaxSize => 'Dimensione massima';

  @override
  String get optStripMetadata => 'Rimuovi i metadati (posizione, fotocamera…)';

  @override
  String get optPages => 'Pagine';

  @override
  String get optPagesHint => 'Tutte le pagine, oppure ad esempio 1-3, 5';

  @override
  String optPagesInvalid(int count) {
    return 'Selezione di pagine non valida (da 1 a $count).';
  }

  @override
  String get optLayout => 'Risultato';

  @override
  String get layoutSeparate => 'Un\'immagine per pagina';

  @override
  String get layoutSingle => 'Una sola immagine continua';

  @override
  String get optDpi => 'Risoluzione (DPI)';

  @override
  String get optPageSize => 'Dimensione pagina';

  @override
  String get pageSizeFit => 'Adatta all\'immagine';

  @override
  String get optGrouping => 'Risultato';

  @override
  String get groupingSingle => 'Un solo PDF con tutte le immagini';

  @override
  String get groupingPerImage => 'Un PDF per immagine';

  @override
  String get optOptimize => 'Ottimizza la dimensione del file';

  @override
  String get optFontSize => 'Dimensione del testo';

  @override
  String get optDelimiter => 'Separatore';

  @override
  String get optOutputDelimiter => 'Separatore';

  @override
  String get optFirstRowHeader => 'La prima riga contiene i nomi delle colonne';

  @override
  String get optPretty => 'Formattazione leggibile';

  @override
  String get optPageSeparators => 'Aggiungi separatori di pagina';

  @override
  String get optRotation => 'Rotazione';

  @override
  String get optBitrate => 'Bitrate';

  @override
  String get optSampleRate => 'Frequenza di campionamento';

  @override
  String get optChannels => 'Canali';

  @override
  String get optKeepMetadata => 'Mantieni tag e copertina';

  @override
  String get optResolution => 'Risoluzione';

  @override
  String get optFps => 'Fotogrammi al secondo';

  @override
  String get optCodec => 'Codec';

  @override
  String get optKeepAudio => 'Mantieni la traccia audio';

  @override
  String get optGifWidth => 'Larghezza';

  @override
  String get optGifFps => 'Fotogrammi al secondo';

  @override
  String get optGifDuration => 'Durata massima';

  @override
  String get choiceOriginal => 'Originale';

  @override
  String get choiceFull => 'Intero video';

  @override
  String get choiceMono => 'Mono';

  @override
  String get choiceStereo => 'Stereo';

  @override
  String get choiceAuto => 'Automatico';

  @override
  String get choiceTab => 'Tabulazione';

  @override
  String get choiceHigh => 'Alta';

  @override
  String get choiceMedium => 'Bilanciata';

  @override
  String get choiceLow => 'File leggero';

  @override
  String get converting => 'Conversione in corso…';

  @override
  String convertingSemantics(int percent) {
    return 'Conversione in corso, $percent per cento';
  }

  @override
  String get keepScreenOn =>
      'Tieni l\'app aperta fino al termine della conversione.';

  @override
  String get cancel => 'Annulla';

  @override
  String get ok => 'OK';

  @override
  String get resultTitle => 'Fatto!';

  @override
  String resultFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count file creati',
      one: '1 file creato',
    );
    return '$_temp0';
  }

  @override
  String resultSize(String before, String after) {
    return '$before → $after';
  }

  @override
  String get actionSave => 'Salva';

  @override
  String get actionSaveToFiles => 'Salva in File';

  @override
  String get actionSaveToPhotos => 'Salva in Foto';

  @override
  String get actionShare => 'Condividi';

  @override
  String get actionOpen => 'Apri';

  @override
  String get actionOpenWith => 'Apri con…';

  @override
  String get shareAsZip => 'Tutto in un unico ZIP';

  @override
  String get convertAnother => 'Altro formato';

  @override
  String get newFile => 'Nuovo file';

  @override
  String get savedOk => 'Salvato.';

  @override
  String get savedPhotos => 'Salvato nelle tue foto.';

  @override
  String get saveFailed => 'Impossibile salvare il file.';

  @override
  String get openFailed => 'Nessuna app può aprire questo file.';

  @override
  String get passwordTitle => 'Password richiesta';

  @override
  String passwordBody(String name) {
    return '«$name» è protetto. La password viene usata solo su questo dispositivo.';
  }

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordWrong => 'Password errata, riprova.';

  @override
  String get errCorrupt => 'Questo file sembra danneggiato o illeggibile.';

  @override
  String get errUnsupported =>
      'Questo file non può essere convertito con queste impostazioni.';

  @override
  String get errTooLarge =>
      'Questo file è troppo grande per essere convertito su questo dispositivo.';

  @override
  String get errNoSpace => 'Spazio di archiviazione insufficiente.';

  @override
  String get errEngine =>
      'Questa conversione non è disponibile su questo dispositivo.';

  @override
  String get errPick => 'Impossibile aprire il file.';

  @override
  String get dismiss => 'Chiudi';

  @override
  String get settingsTooltip => 'Informazioni e note legali';

  @override
  String get aboutTitle => 'Informazioni';

  @override
  String get aboutTagline =>
      'Gratuita. Niente pubblicità, niente account, niente tracciamento. I tuoi file non lasciano mai il dispositivo.';

  @override
  String aboutVersion(String version) {
    return 'Versione $version';
  }

  @override
  String get aboutPrivacy => 'Privacy';

  @override
  String get aboutPrivacyBody =>
      'Questa app non raccoglie, conserva né trasmette dati personali. I tuoi file vengono convertiti interamente sul dispositivo e rimossi dall\'archiviazione temporanea quando hai finito o scegli un altro file.\n\nL\'app non ha account, pubblicità, analisi, cookie né tracciamento e non richiede una connessione a internet. I file vengono letti solo dalle posizioni che scegli e i risultati sono salvati o condivisi solo su tua richiesta.\n\nPoiché l\'editore non tratta alcun dato, non serve alcun banner di consenso.';

  @override
  String get aboutAccessibility => 'Accessibilità';

  @override
  String aboutAccessibilityBody(String contact) {
    return 'L\'app è progettata per essere utilizzabile da tutti: supporto per lettori di schermo (VoiceOver e TalkBack), testo che segue la dimensione del testo di sistema, temi chiaro e scuro con contrasto sufficiente, aree touch ampie e nessun limite di tempo.\n\nL\'obiettivo è il livello AA delle WCAG 2.1, base del RGAA francese. Non è ancora stato eseguito un audit formale da parte di terzi, quindi la conformità non è ancora certificata; questa dichiarazione sarà aggiornata dopo l\'audit.\n\nSe incontri un problema di accessibilità, scrivi a $contact. Risponderemo in tempi ragionevoli e cercheremo un modo alternativo per darti accesso alla funzione.';
  }

  @override
  String get aboutLegal => 'Note legali e condizioni';

  @override
  String aboutLegalBody(String publisher, String contact) {
    return 'Editore: $publisher, persona fisica che agisce a titolo non professionale.\nContatto: $contact.\nHosting del sito web: OVH SAS, 2 rue Kellermann, 59100 Roubaix, Francia. Come consente l\'articolo 6, III-2 della LCEN francese, l\'editore ha comunicato i propri dati completi al fornitore di hosting.\n\nL\'app è fornita gratuitamente e «così com\'è», senza acquisti, abbonamenti né pubblicità. I risultati dipendono dal file di origine e possono differire dall\'originale (impaginazione, qualità, metadati); conserva una copia degli originali.\n\nSei responsabile di detenere i diritti sui file che converti e di usare i risultati in modo lecito. L\'app non rimuove protezioni: un PDF cifrato si apre solo con la password che fornisci.';
  }

  @override
  String get aboutLicenses => 'Licenze open source';

  @override
  String get aboutContact => 'Contatta l\'editore';

  @override
  String get aboutFfmpeg =>
      'La conversione audio e video usa FFmpeg (LGPL 3.0).';
}

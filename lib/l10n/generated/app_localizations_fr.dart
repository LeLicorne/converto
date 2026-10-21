// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Converto';

  @override
  String get pickTitle => 'Choisir un fichier';

  @override
  String get pickSubtitle =>
      'Image, PDF, document, audio ou vidéo. Tout reste sur votre appareil.';

  @override
  String get pickMedia => 'Photos et vidéos';

  @override
  String get pickMultipleHint =>
      'Vous pouvez sélectionner plusieurs fichiers pour les fusionner.';

  @override
  String get loading => 'Lecture du fichier…';

  @override
  String get changeFile => 'Changer';

  @override
  String get changeFileSemantics => 'Choisir un autre fichier';

  @override
  String filesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers',
      one: '1 fichier',
    );
    return '$_temp0';
  }

  @override
  String detectedFormat(String format) {
    return 'Détecté : $format';
  }

  @override
  String get unknownFormat => 'Format non reconnu';

  @override
  String get convertTo => 'Convertir en';

  @override
  String get noTargets =>
      'Aucune conversion n\'est disponible pour ce fichier.';

  @override
  String get mixedFiles =>
      'Ces fichiers sont de types différents et ne peuvent pas être convertis ensemble.';

  @override
  String pagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return '$_temp0';
  }

  @override
  String get categoryImage => 'Images';

  @override
  String get categoryDocument => 'Documents';

  @override
  String get categoryData => 'Données';

  @override
  String get categoryArchive => 'Archives';

  @override
  String get categoryAudio => 'Audio';

  @override
  String get categoryVideo => 'Vidéo';

  @override
  String get extractArchive => 'Extraire les fichiers';

  @override
  String get mergePdf => 'Fusionner / modifier le PDF';

  @override
  String get createZip => 'Archive ZIP';

  @override
  String get optionsTitle => 'Options';

  @override
  String convertButton(String format) {
    return 'Convertir en $format';
  }

  @override
  String get optQuality => 'Qualité';

  @override
  String get optMaxSize => 'Taille maximale';

  @override
  String get optStripMetadata =>
      'Supprimer les métadonnées (position, appareil…)';

  @override
  String get optPages => 'Pages';

  @override
  String get optPagesHint => 'Toutes les pages, ou par exemple 1-3, 5';

  @override
  String optPagesInvalid(int count) {
    return 'Sélection de pages invalide (1 à $count).';
  }

  @override
  String get optLayout => 'Résultat';

  @override
  String get layoutSeparate => 'Une image par page';

  @override
  String get layoutSingle => 'Une seule image continue';

  @override
  String get optDpi => 'Résolution (DPI)';

  @override
  String get optPageSize => 'Taille de page';

  @override
  String get pageSizeFit => 'Ajustée à l\'image';

  @override
  String get optGrouping => 'Résultat';

  @override
  String get groupingSingle => 'Un seul PDF avec toutes les images';

  @override
  String get groupingPerImage => 'Un PDF par image';

  @override
  String get optOptimize => 'Optimiser la taille du fichier';

  @override
  String get optFontSize => 'Taille du texte';

  @override
  String get optDelimiter => 'Séparateur';

  @override
  String get optOutputDelimiter => 'Séparateur';

  @override
  String get optFirstRowHeader =>
      'La première ligne contient les noms de colonnes';

  @override
  String get optPretty => 'Mise en forme lisible';

  @override
  String get optPageSeparators => 'Ajouter des séparateurs de page';

  @override
  String get optRotation => 'Rotation';

  @override
  String get optBitrate => 'Débit';

  @override
  String get optSampleRate => 'Fréquence d\'échantillonnage';

  @override
  String get optChannels => 'Canaux';

  @override
  String get optKeepMetadata => 'Conserver les tags et la pochette';

  @override
  String get optResolution => 'Résolution';

  @override
  String get optFps => 'Images par seconde';

  @override
  String get optCodec => 'Codec';

  @override
  String get optKeepAudio => 'Conserver la piste audio';

  @override
  String get optGifWidth => 'Largeur';

  @override
  String get optGifFps => 'Images par seconde';

  @override
  String get optGifDuration => 'Durée maximale';

  @override
  String get choiceOriginal => 'Original';

  @override
  String get choiceFull => 'Toute la vidéo';

  @override
  String get choiceMono => 'Mono';

  @override
  String get choiceStereo => 'Stéréo';

  @override
  String get choiceAuto => 'Automatique';

  @override
  String get choiceTab => 'Tabulation';

  @override
  String get choiceHigh => 'Élevée';

  @override
  String get choiceMedium => 'Équilibrée';

  @override
  String get choiceLow => 'Fichier léger';

  @override
  String get converting => 'Conversion en cours…';

  @override
  String convertingSemantics(int percent) {
    return 'Conversion en cours, $percent pour cent';
  }

  @override
  String get keepScreenOn =>
      'Gardez l\'application ouverte jusqu\'à la fin de la conversion.';

  @override
  String get cancel => 'Annuler';

  @override
  String get ok => 'OK';

  @override
  String get resultTitle => 'Terminé !';

  @override
  String resultFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers créés',
      one: '1 fichier créé',
    );
    return '$_temp0';
  }

  @override
  String resultSize(String before, String after) {
    return '$before → $after';
  }

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionSaveToFiles => 'Enregistrer dans Fichiers';

  @override
  String get actionSaveToPhotos => 'Enregistrer dans Photos';

  @override
  String get actionShare => 'Partager';

  @override
  String get actionOpen => 'Ouvrir';

  @override
  String get actionOpenWith => 'Ouvrir avec…';

  @override
  String get shareAsZip => 'Tout en un seul ZIP';

  @override
  String get convertAnother => 'Autre format';

  @override
  String get newFile => 'Nouveau fichier';

  @override
  String get savedOk => 'Enregistré.';

  @override
  String get savedPhotos => 'Enregistré dans vos photos.';

  @override
  String get saveFailed => 'Le fichier n\'a pas pu être enregistré.';

  @override
  String get openFailed => 'Aucune application ne peut ouvrir ce fichier.';

  @override
  String get passwordTitle => 'Mot de passe requis';

  @override
  String passwordBody(String name) {
    return '« $name » est protégé. Le mot de passe n\'est utilisé que sur cet appareil.';
  }

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get passwordWrong => 'Mot de passe incorrect, réessayez.';

  @override
  String get errCorrupt => 'Ce fichier semble endommagé ou illisible.';

  @override
  String get errUnsupported =>
      'Ce fichier ne peut pas être converti avec ces réglages.';

  @override
  String get errTooLarge =>
      'Ce fichier est trop volumineux pour être converti sur cet appareil.';

  @override
  String get errNoSpace => 'Espace de stockage insuffisant.';

  @override
  String get errEngine =>
      'Cette conversion n\'est pas disponible sur cet appareil.';

  @override
  String get errPick => 'Le fichier n\'a pas pu être ouvert.';

  @override
  String get dismiss => 'Fermer';

  @override
  String get settingsTooltip => 'À propos et mentions légales';

  @override
  String get aboutTitle => 'À propos';

  @override
  String get aboutTagline =>
      'Gratuit. Sans publicité, sans compte, sans suivi. Vos fichiers ne quittent jamais votre appareil.';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutPrivacy => 'Confidentialité';

  @override
  String get aboutPrivacyBody =>
      'Cette application ne collecte, ne stocke et ne transmet aucune donnée personnelle. Vos fichiers sont convertis entièrement sur votre appareil et supprimés du stockage temporaire lorsque vous avez terminé ou choisi un autre fichier.\n\nL\'application n\'a ni compte, ni publicité, ni statistiques, ni cookies, ni suivi, et n\'a pas besoin de connexion internet. Les fichiers ne sont lus que depuis les emplacements que vous choisissez, et les résultats ne sont enregistrés ou partagés que sur votre demande.\n\nAucune donnée n\'étant traitée par l\'éditeur, aucune bannière de consentement n\'est nécessaire.';

  @override
  String get aboutAccessibility => 'Accessibilité';

  @override
  String aboutAccessibilityBody(String contact) {
    return 'L\'application est conçue pour être utilisable par tous : prise en charge des lecteurs d\'écran (VoiceOver et TalkBack), texte qui suit la taille de texte du système, thèmes clair et sombre avec des contrastes suffisants, grandes zones tactiles et aucune limite de temps.\n\nL\'objectif est le niveau AA des WCAG 2.1, base du RGAA. Un audit formel par un tiers n\'a pas encore été réalisé : la conformité n\'est donc pas encore certifiée ; cette déclaration sera mise à jour après l\'audit.\n\nSi vous rencontrez un problème d\'accessibilité, écrivez à $contact. Nous répondrons dans un délai raisonnable et chercherons un moyen alternatif de vous donner accès à la fonctionnalité.';
  }

  @override
  String get aboutLegal => 'Mentions légales et conditions';

  @override
  String aboutLegalBody(String publisher, String contact) {
    return 'Éditeur : $publisher, personne physique agissant à titre non professionnel.\nContact : $contact.\nHébergeur du site web : OVH SAS, 2 rue Kellermann, 59100 Roubaix, France. Comme l\'autorise l\'article 6, III-2 de la LCEN, l\'éditeur a communiqué ses coordonnées complètes à l\'hébergeur.\n\nL\'application est fournie gratuitement et « en l\'état », sans achat, abonnement ni publicité. Les résultats dépendent du fichier source et peuvent différer de l\'original (mise en page, qualité, métadonnées) ; conservez une copie de vos originaux.\n\nVous êtes responsable de détenir les droits sur les fichiers que vous convertissez et d\'utiliser les résultats de façon licite. L\'application ne supprime aucune protection : un PDF chiffré ne peut être ouvert qu\'avec le mot de passe que vous fournissez.';
  }

  @override
  String get aboutLicenses => 'Licences open source';

  @override
  String get aboutContact => 'Contacter l\'éditeur';

  @override
  String get aboutFfmpeg =>
      'La conversion audio et vidéo utilise FFmpeg (LGPL 3.0).';
}

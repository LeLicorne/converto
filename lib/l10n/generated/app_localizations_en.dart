// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Converto';

  @override
  String get pickTitle => 'Choose a file';

  @override
  String get pickSubtitle =>
      'Image, PDF, document, audio or video. Everything stays on your device.';

  @override
  String get pickMedia => 'Photos and videos';

  @override
  String get pickMultipleHint => 'You can select several files to merge them.';

  @override
  String get loading => 'Reading file…';

  @override
  String get changeFile => 'Change';

  @override
  String get changeFileSemantics => 'Choose another file';

  @override
  String filesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files',
      one: '1 file',
    );
    return '$_temp0';
  }

  @override
  String detectedFormat(String format) {
    return 'Detected: $format';
  }

  @override
  String get unknownFormat => 'Unrecognised format';

  @override
  String get convertTo => 'Convert to';

  @override
  String get noTargets => 'No conversion is available for this file.';

  @override
  String get mixedFiles =>
      'These files have different types and can\'t be converted together.';

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
  String get categoryData => 'Data';

  @override
  String get categoryArchive => 'Archives';

  @override
  String get categoryAudio => 'Audio';

  @override
  String get categoryVideo => 'Video';

  @override
  String get extractArchive => 'Extract files';

  @override
  String get mergePdf => 'Merge / edit PDF';

  @override
  String get createZip => 'ZIP archive';

  @override
  String get optionsTitle => 'Options';

  @override
  String convertButton(String format) {
    return 'Convert to $format';
  }

  @override
  String get optQuality => 'Quality';

  @override
  String get optMaxSize => 'Maximum size';

  @override
  String get optStripMetadata => 'Remove metadata (location, camera…)';

  @override
  String get optPages => 'Pages';

  @override
  String get optPagesHint => 'All pages, or for example 1-3, 5';

  @override
  String optPagesInvalid(int count) {
    return 'Invalid page selection (1 to $count).';
  }

  @override
  String get optLayout => 'Result';

  @override
  String get layoutSeparate => 'One image per page';

  @override
  String get layoutSingle => 'A single long image';

  @override
  String get optDpi => 'Resolution (DPI)';

  @override
  String get optPageSize => 'Page size';

  @override
  String get pageSizeFit => 'Fit the image';

  @override
  String get optGrouping => 'Result';

  @override
  String get groupingSingle => 'One PDF with all images';

  @override
  String get groupingPerImage => 'One PDF per image';

  @override
  String get optOptimize => 'Optimise file size';

  @override
  String get optFontSize => 'Font size';

  @override
  String get optDelimiter => 'Separator';

  @override
  String get optOutputDelimiter => 'Separator';

  @override
  String get optFirstRowHeader => 'First row contains column names';

  @override
  String get optPretty => 'Readable formatting';

  @override
  String get optPageSeparators => 'Add page separators';

  @override
  String get optRotation => 'Rotation';

  @override
  String get optBitrate => 'Bitrate';

  @override
  String get optSampleRate => 'Sample rate';

  @override
  String get optChannels => 'Channels';

  @override
  String get optKeepMetadata => 'Keep tags and cover art';

  @override
  String get optResolution => 'Resolution';

  @override
  String get optFps => 'Frame rate';

  @override
  String get optCodec => 'Codec';

  @override
  String get optKeepAudio => 'Keep audio track';

  @override
  String get optGifWidth => 'Width';

  @override
  String get optGifFps => 'Frames per second';

  @override
  String get optGifDuration => 'Maximum duration';

  @override
  String get choiceOriginal => 'Original';

  @override
  String get choiceFull => 'Whole video';

  @override
  String get choiceMono => 'Mono';

  @override
  String get choiceStereo => 'Stereo';

  @override
  String get choiceAuto => 'Automatic';

  @override
  String get choiceTab => 'Tab';

  @override
  String get choiceHigh => 'High';

  @override
  String get choiceMedium => 'Balanced';

  @override
  String get choiceLow => 'Small file';

  @override
  String get converting => 'Converting…';

  @override
  String convertingSemantics(int percent) {
    return 'Conversion in progress, $percent percent';
  }

  @override
  String get keepScreenOn => 'Keep the app open until the conversion ends.';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get resultTitle => 'Done!';

  @override
  String resultFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files created',
      one: '1 file created',
    );
    return '$_temp0';
  }

  @override
  String resultSize(String before, String after) {
    return '$before → $after';
  }

  @override
  String get actionSave => 'Save';

  @override
  String get actionSaveToFiles => 'Save to Files';

  @override
  String get actionSaveToPhotos => 'Save to Photos';

  @override
  String get actionShare => 'Share';

  @override
  String get actionOpen => 'Open';

  @override
  String get actionOpenWith => 'Open with…';

  @override
  String get shareAsZip => 'Everything as one ZIP';

  @override
  String get convertAnother => 'Another format';

  @override
  String get newFile => 'New file';

  @override
  String get savedOk => 'Saved.';

  @override
  String get savedPhotos => 'Saved to your photos.';

  @override
  String get saveFailed => 'The file couldn\'t be saved.';

  @override
  String get openFailed => 'No app can open this file.';

  @override
  String get passwordTitle => 'Password required';

  @override
  String passwordBody(String name) {
    return '“$name” is protected. The password is only used on this device.';
  }

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordWrong => 'Wrong password, please try again.';

  @override
  String get errCorrupt => 'This file looks damaged or can\'t be read.';

  @override
  String get errUnsupported =>
      'This file can\'t be converted with these settings.';

  @override
  String get errTooLarge =>
      'This file is too large to be converted on this device.';

  @override
  String get errNoSpace => 'Not enough free storage space.';

  @override
  String get errEngine => 'This conversion isn\'t available on this device.';

  @override
  String get errPick => 'The file couldn\'t be opened.';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get settingsTooltip => 'About and legal';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutTagline =>
      'Free. No ads, no account, no tracking. Your files never leave your device.';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutPrivacy => 'Privacy';

  @override
  String get aboutPrivacyBody =>
      'This app does not collect, store or transmit any personal data. Your files are converted entirely on your device and removed from temporary storage when you finish or pick another file.\n\nThe app has no account, no advertising, no analytics, no cookies and no tracking, and it does not need an internet connection. Files are only read from the locations you choose, and results are saved or shared only when you ask.\n\nBecause no data is processed by the publisher, no consent banner is needed.';

  @override
  String get aboutAccessibility => 'Accessibility';

  @override
  String aboutAccessibilityBody(String contact) {
    return 'The app is designed to be usable by everyone: screen reader support (VoiceOver and TalkBack), text that follows your system text size, light and dark themes with sufficient contrast, large touch targets and no time limits.\n\nThe target is level AA of WCAG 2.1, the basis of the French RGAA. A formal third-party audit has not been carried out yet, so compliance is not yet certified; this statement will be updated after the audit.\n\nIf you meet an accessibility problem, please write to $contact. We will reply within a reasonable time and look for an alternative way to give you access to the feature.';
  }

  @override
  String get aboutLegal => 'Legal notice and terms';

  @override
  String aboutLegalBody(String publisher, String contact) {
    return 'Publisher: $publisher, private individual acting in a non-professional capacity.\nContact: $contact.\nWebsite host: OVH SAS, 2 rue Kellermann, 59100 Roubaix, France. As permitted by Article 6, III-2 of the French LCEN, the publisher has given the host their full contact details.\n\nThe app is provided free of charge and “as is”, without any purchase, subscription or advertising. Conversion results depend on the source file and may differ from the original (layout, quality, metadata); keep a copy of your originals.\n\nYou are responsible for holding the rights to the files you convert and for using the results lawfully. The app does not remove copy protection: an encrypted PDF can only be opened with the password you provide.';
  }

  @override
  String get aboutLicenses => 'Open-source licences';

  @override
  String get aboutContact => 'Contact the publisher';

  @override
  String get aboutFfmpeg =>
      'Audio and video conversion uses FFmpeg (LGPL 3.0).';
}

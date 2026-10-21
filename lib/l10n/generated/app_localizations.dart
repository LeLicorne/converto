import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('nl'),
    Locale('pt'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Converto'**
  String get appName;

  /// No description provided for @pickTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a file'**
  String get pickTitle;

  /// No description provided for @pickSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Image, PDF, document, audio or video. Everything stays on your device.'**
  String get pickSubtitle;

  /// No description provided for @pickMedia.
  ///
  /// In en, this message translates to:
  /// **'Photos and videos'**
  String get pickMedia;

  /// No description provided for @pickMultipleHint.
  ///
  /// In en, this message translates to:
  /// **'You can select several files to merge them.'**
  String get pickMultipleHint;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Reading file…'**
  String get loading;

  /// No description provided for @changeFile.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeFile;

  /// No description provided for @changeFileSemantics.
  ///
  /// In en, this message translates to:
  /// **'Choose another file'**
  String get changeFileSemantics;

  /// No description provided for @filesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file} other{{count} files}}'**
  String filesSelected(int count);

  /// No description provided for @detectedFormat.
  ///
  /// In en, this message translates to:
  /// **'Detected: {format}'**
  String detectedFormat(String format);

  /// No description provided for @unknownFormat.
  ///
  /// In en, this message translates to:
  /// **'Unrecognised format'**
  String get unknownFormat;

  /// No description provided for @convertTo.
  ///
  /// In en, this message translates to:
  /// **'Convert to'**
  String get convertTo;

  /// No description provided for @noTargets.
  ///
  /// In en, this message translates to:
  /// **'No conversion is available for this file.'**
  String get noTargets;

  /// No description provided for @mixedFiles.
  ///
  /// In en, this message translates to:
  /// **'These files have different types and can\'t be converted together.'**
  String get mixedFiles;

  /// No description provided for @pagesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 page} other{{count} pages}}'**
  String pagesCount(int count);

  /// No description provided for @categoryImage.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get categoryImage;

  /// No description provided for @categoryDocument.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get categoryDocument;

  /// No description provided for @categoryData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get categoryData;

  /// No description provided for @categoryArchive.
  ///
  /// In en, this message translates to:
  /// **'Archives'**
  String get categoryArchive;

  /// No description provided for @categoryAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get categoryAudio;

  /// No description provided for @categoryVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get categoryVideo;

  /// No description provided for @extractArchive.
  ///
  /// In en, this message translates to:
  /// **'Extract files'**
  String get extractArchive;

  /// No description provided for @mergePdf.
  ///
  /// In en, this message translates to:
  /// **'Merge / edit PDF'**
  String get mergePdf;

  /// No description provided for @createZip.
  ///
  /// In en, this message translates to:
  /// **'ZIP archive'**
  String get createZip;

  /// No description provided for @optionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get optionsTitle;

  /// No description provided for @convertButton.
  ///
  /// In en, this message translates to:
  /// **'Convert to {format}'**
  String convertButton(String format);

  /// No description provided for @optQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get optQuality;

  /// No description provided for @optMaxSize.
  ///
  /// In en, this message translates to:
  /// **'Maximum size'**
  String get optMaxSize;

  /// No description provided for @optStripMetadata.
  ///
  /// In en, this message translates to:
  /// **'Remove metadata (location, camera…)'**
  String get optStripMetadata;

  /// No description provided for @optPages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get optPages;

  /// No description provided for @optPagesHint.
  ///
  /// In en, this message translates to:
  /// **'All pages, or for example 1-3, 5'**
  String get optPagesHint;

  /// No description provided for @optPagesInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid page selection (1 to {count}).'**
  String optPagesInvalid(int count);

  /// No description provided for @optLayout.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get optLayout;

  /// No description provided for @layoutSeparate.
  ///
  /// In en, this message translates to:
  /// **'One image per page'**
  String get layoutSeparate;

  /// No description provided for @layoutSingle.
  ///
  /// In en, this message translates to:
  /// **'A single long image'**
  String get layoutSingle;

  /// No description provided for @optDpi.
  ///
  /// In en, this message translates to:
  /// **'Resolution (DPI)'**
  String get optDpi;

  /// No description provided for @optPageSize.
  ///
  /// In en, this message translates to:
  /// **'Page size'**
  String get optPageSize;

  /// No description provided for @pageSizeFit.
  ///
  /// In en, this message translates to:
  /// **'Fit the image'**
  String get pageSizeFit;

  /// No description provided for @optGrouping.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get optGrouping;

  /// No description provided for @groupingSingle.
  ///
  /// In en, this message translates to:
  /// **'One PDF with all images'**
  String get groupingSingle;

  /// No description provided for @groupingPerImage.
  ///
  /// In en, this message translates to:
  /// **'One PDF per image'**
  String get groupingPerImage;

  /// No description provided for @optOptimize.
  ///
  /// In en, this message translates to:
  /// **'Optimise file size'**
  String get optOptimize;

  /// No description provided for @optFontSize.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get optFontSize;

  /// No description provided for @optDelimiter.
  ///
  /// In en, this message translates to:
  /// **'Separator'**
  String get optDelimiter;

  /// No description provided for @optOutputDelimiter.
  ///
  /// In en, this message translates to:
  /// **'Separator'**
  String get optOutputDelimiter;

  /// No description provided for @optFirstRowHeader.
  ///
  /// In en, this message translates to:
  /// **'First row contains column names'**
  String get optFirstRowHeader;

  /// No description provided for @optPretty.
  ///
  /// In en, this message translates to:
  /// **'Readable formatting'**
  String get optPretty;

  /// No description provided for @optPageSeparators.
  ///
  /// In en, this message translates to:
  /// **'Add page separators'**
  String get optPageSeparators;

  /// No description provided for @optRotation.
  ///
  /// In en, this message translates to:
  /// **'Rotation'**
  String get optRotation;

  /// No description provided for @optBitrate.
  ///
  /// In en, this message translates to:
  /// **'Bitrate'**
  String get optBitrate;

  /// No description provided for @optSampleRate.
  ///
  /// In en, this message translates to:
  /// **'Sample rate'**
  String get optSampleRate;

  /// No description provided for @optChannels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get optChannels;

  /// No description provided for @optKeepMetadata.
  ///
  /// In en, this message translates to:
  /// **'Keep tags and cover art'**
  String get optKeepMetadata;

  /// No description provided for @optResolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get optResolution;

  /// No description provided for @optFps.
  ///
  /// In en, this message translates to:
  /// **'Frame rate'**
  String get optFps;

  /// No description provided for @optCodec.
  ///
  /// In en, this message translates to:
  /// **'Codec'**
  String get optCodec;

  /// No description provided for @optKeepAudio.
  ///
  /// In en, this message translates to:
  /// **'Keep audio track'**
  String get optKeepAudio;

  /// No description provided for @optGifWidth.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get optGifWidth;

  /// No description provided for @optGifFps.
  ///
  /// In en, this message translates to:
  /// **'Frames per second'**
  String get optGifFps;

  /// No description provided for @optGifDuration.
  ///
  /// In en, this message translates to:
  /// **'Maximum duration'**
  String get optGifDuration;

  /// No description provided for @choiceOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get choiceOriginal;

  /// No description provided for @choiceFull.
  ///
  /// In en, this message translates to:
  /// **'Whole video'**
  String get choiceFull;

  /// No description provided for @choiceMono.
  ///
  /// In en, this message translates to:
  /// **'Mono'**
  String get choiceMono;

  /// No description provided for @choiceStereo.
  ///
  /// In en, this message translates to:
  /// **'Stereo'**
  String get choiceStereo;

  /// No description provided for @choiceAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get choiceAuto;

  /// No description provided for @choiceTab.
  ///
  /// In en, this message translates to:
  /// **'Tab'**
  String get choiceTab;

  /// No description provided for @choiceHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get choiceHigh;

  /// No description provided for @choiceMedium.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get choiceMedium;

  /// No description provided for @choiceLow.
  ///
  /// In en, this message translates to:
  /// **'Small file'**
  String get choiceLow;

  /// No description provided for @converting.
  ///
  /// In en, this message translates to:
  /// **'Converting…'**
  String get converting;

  /// No description provided for @convertingSemantics.
  ///
  /// In en, this message translates to:
  /// **'Conversion in progress, {percent} percent'**
  String convertingSemantics(int percent);

  /// No description provided for @keepScreenOn.
  ///
  /// In en, this message translates to:
  /// **'Keep the app open until the conversion ends.'**
  String get keepScreenOn;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @resultTitle.
  ///
  /// In en, this message translates to:
  /// **'Done!'**
  String get resultTitle;

  /// No description provided for @resultFiles.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file created} other{{count} files created}}'**
  String resultFiles(int count);

  /// No description provided for @resultSize.
  ///
  /// In en, this message translates to:
  /// **'{before} → {after}'**
  String resultSize(String before, String after);

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionSaveToFiles.
  ///
  /// In en, this message translates to:
  /// **'Save to Files'**
  String get actionSaveToFiles;

  /// No description provided for @actionSaveToPhotos.
  ///
  /// In en, this message translates to:
  /// **'Save to Photos'**
  String get actionSaveToPhotos;

  /// No description provided for @actionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// No description provided for @actionOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get actionOpen;

  /// No description provided for @actionOpenWith.
  ///
  /// In en, this message translates to:
  /// **'Open with…'**
  String get actionOpenWith;

  /// No description provided for @shareAsZip.
  ///
  /// In en, this message translates to:
  /// **'Everything as one ZIP'**
  String get shareAsZip;

  /// No description provided for @convertAnother.
  ///
  /// In en, this message translates to:
  /// **'Another format'**
  String get convertAnother;

  /// No description provided for @newFile.
  ///
  /// In en, this message translates to:
  /// **'New file'**
  String get newFile;

  /// No description provided for @savedOk.
  ///
  /// In en, this message translates to:
  /// **'Saved.'**
  String get savedOk;

  /// No description provided for @savedPhotos.
  ///
  /// In en, this message translates to:
  /// **'Saved to your photos.'**
  String get savedPhotos;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'The file couldn\'t be saved.'**
  String get saveFailed;

  /// No description provided for @openFailed.
  ///
  /// In en, this message translates to:
  /// **'No app can open this file.'**
  String get openFailed;

  /// No description provided for @passwordTitle.
  ///
  /// In en, this message translates to:
  /// **'Password required'**
  String get passwordTitle;

  /// No description provided for @passwordBody.
  ///
  /// In en, this message translates to:
  /// **'“{name}” is protected. The password is only used on this device.'**
  String passwordBody(String name);

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong password, please try again.'**
  String get passwordWrong;

  /// No description provided for @errCorrupt.
  ///
  /// In en, this message translates to:
  /// **'This file looks damaged or can\'t be read.'**
  String get errCorrupt;

  /// No description provided for @errUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This file can\'t be converted with these settings.'**
  String get errUnsupported;

  /// No description provided for @errTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This file is too large to be converted on this device.'**
  String get errTooLarge;

  /// No description provided for @errNoSpace.
  ///
  /// In en, this message translates to:
  /// **'Not enough free storage space.'**
  String get errNoSpace;

  /// No description provided for @errEngine.
  ///
  /// In en, this message translates to:
  /// **'This conversion isn\'t available on this device.'**
  String get errEngine;

  /// No description provided for @errPick.
  ///
  /// In en, this message translates to:
  /// **'The file couldn\'t be opened.'**
  String get errPick;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'About and legal'**
  String get settingsTooltip;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Free. No ads, no account, no tracking. Your files never leave your device.'**
  String get aboutTagline;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get aboutPrivacy;

  /// No description provided for @aboutPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'This app does not collect, store or transmit any personal data. Your files are converted entirely on your device and removed from temporary storage when you finish or pick another file.\n\nThe app has no account, no advertising, no analytics, no cookies and no tracking, and it does not need an internet connection. Files are only read from the locations you choose, and results are saved or shared only when you ask.\n\nBecause no data is processed by the publisher, no consent banner is needed.'**
  String get aboutPrivacyBody;

  /// No description provided for @aboutAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get aboutAccessibility;

  /// No description provided for @aboutAccessibilityBody.
  ///
  /// In en, this message translates to:
  /// **'The app is designed to be usable by everyone: screen reader support (VoiceOver and TalkBack), text that follows your system text size, light and dark themes with sufficient contrast, large touch targets and no time limits.\n\nThe target is level AA of WCAG 2.1, the basis of the French RGAA. A formal third-party audit has not been carried out yet, so compliance is not yet certified; this statement will be updated after the audit.\n\nIf you meet an accessibility problem, please write to {contact}. We will reply within a reasonable time and look for an alternative way to give you access to the feature.'**
  String aboutAccessibilityBody(String contact);

  /// No description provided for @aboutLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal notice and terms'**
  String get aboutLegal;

  /// No description provided for @aboutLegalBody.
  ///
  /// In en, this message translates to:
  /// **'Publisher: {publisher}, private individual acting in a non-professional capacity.\nContact: {contact}.\nWebsite host: OVH SAS, 2 rue Kellermann, 59100 Roubaix, France. As permitted by Article 6, III-2 of the French LCEN, the publisher has given the host their full contact details.\n\nThe app is provided free of charge and “as is”, without any purchase, subscription or advertising. Conversion results depend on the source file and may differ from the original (layout, quality, metadata); keep a copy of your originals.\n\nYou are responsible for holding the rights to the files you convert and for using the results lawfully. The app does not remove copy protection: an encrypted PDF can only be opened with the password you provide.'**
  String aboutLegalBody(String publisher, String contact);

  /// No description provided for @aboutLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licences'**
  String get aboutLicenses;

  /// No description provided for @aboutContact.
  ///
  /// In en, this message translates to:
  /// **'Contact the publisher'**
  String get aboutContact;

  /// No description provided for @aboutFfmpeg.
  ///
  /// In en, this message translates to:
  /// **'Audio and video conversion uses FFmpeg (LGPL 3.0).'**
  String get aboutFfmpeg;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'nl',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'nl':
      return AppLocalizationsNl();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

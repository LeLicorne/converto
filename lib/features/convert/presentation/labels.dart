import 'package:converto/features/convert/domain/converter.dart';
import 'package:converto/features/convert/domain/file_format.dart';
import 'package:converto/features/convert/engines/archive_converters.dart';
import 'package:converto/features/convert/engines/pdf_converters.dart';
import 'package:converto/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

String categoryLabel(AppLocalizations l10n, FormatCategory category) =>
    switch (category) {
      FormatCategory.image => l10n.categoryImage,
      FormatCategory.document => l10n.categoryDocument,
      FormatCategory.data => l10n.categoryData,
      FormatCategory.archive => l10n.categoryArchive,
      FormatCategory.audio => l10n.categoryAudio,
      FormatCategory.video => l10n.categoryVideo,
    };

IconData categoryIcon(FormatCategory category) => switch (category) {
  FormatCategory.image => Icons.image_outlined,
  FormatCategory.document => Icons.description_outlined,
  FormatCategory.data => Icons.table_chart_outlined,
  FormatCategory.archive => Icons.folder_zip_outlined,
  FormatCategory.audio => Icons.music_note_outlined,
  FormatCategory.video => Icons.movie_outlined,
};

FormatCategory targetCategory(Converter converter) =>
    converter is ZipExtractConverter ? FormatCategory.archive : converter.output.category;

String targetTitle(AppLocalizations l10n, Converter converter) {
  if (converter is ZipExtractConverter) return l10n.extractArchive;
  if (converter is PdfMergeConverter) return l10n.mergePdf;
  if (converter is ZipCreateConverter) return l10n.createZip;
  return converter.output.label;
}

String optionLabel(AppLocalizations l10n, String id) => switch (id) {
  'quality' => l10n.optQuality,
  'maxSize' => l10n.optMaxSize,
  'stripMetadata' => l10n.optStripMetadata,
  'pages' => l10n.optPages,
  'layout' => l10n.optLayout,
  'dpi' => l10n.optDpi,
  'pageSize' => l10n.optPageSize,
  'grouping' => l10n.optGrouping,
  'optimize' => l10n.optOptimize,
  'fontSize' => l10n.optFontSize,
  'delimiter' => l10n.optDelimiter,
  'outputDelimiter' => l10n.optOutputDelimiter,
  'firstRowHeader' => l10n.optFirstRowHeader,
  'pretty' => l10n.optPretty,
  'pageSeparators' => l10n.optPageSeparators,
  'rotation' => l10n.optRotation,
  'bitrate' => l10n.optBitrate,
  'sampleRate' => l10n.optSampleRate,
  'channels' => l10n.optChannels,
  'keepMetadata' => l10n.optKeepMetadata,
  'resolution' => l10n.optResolution,
  'fps' => l10n.optFps,
  'codec' => l10n.optCodec,
  'keepAudio' => l10n.optKeepAudio,
  'gifWidth' => l10n.optGifWidth,
  'gifFps' => l10n.optGifFps,
  'gifDuration' => l10n.optGifDuration,
  _ => id,
};

String choiceLabel(AppLocalizations l10n, String optionId, String value) {
  switch (value) {
    case 'original':
      return l10n.choiceOriginal;
    case 'full':
      return l10n.choiceFull;
    case 'mono':
      return l10n.choiceMono;
    case 'stereo':
      return l10n.choiceStereo;
    case 'auto':
      return l10n.choiceAuto;
    case 'tab':
      return l10n.choiceTab;
    case 'high':
      return l10n.choiceHigh;
    case 'medium':
      return l10n.choiceMedium;
    case 'low':
      return l10n.choiceLow;
    case 'fit':
      return l10n.pageSizeFit;
    case 'a4':
      return 'A4';
    case 'letter':
      return 'Letter';
    case 'perImage':
      return l10n.groupingPerImage;
    case 'h264':
      return 'H.264';
    case 'hevc':
      return 'HEVC';
  }
  switch (optionId) {
    case 'layout':
      return value == 'separate' ? l10n.layoutSeparate : l10n.layoutSingle;
    case 'grouping':
      return l10n.groupingSingle;
    case 'dpi':
      return '$value DPI';
    case 'maxSize':
      return '$value px';
    case 'bitrate':
      return '$value kbps';
    case 'sampleRate':
      return '${(int.parse(value) / 1000).toString().replaceFirst(RegExp(r'\.0$'), '')} kHz';
    case 'resolution':
      return '${value}p';
    case 'fps':
    case 'gifFps':
      return '$value fps';
    case 'fontSize':
      return '$value pt';
    case 'gifWidth':
      return '$value px';
    case 'gifDuration':
      return '$value s';
    case 'rotation':
      return '$value°';
  }
  return value;
}

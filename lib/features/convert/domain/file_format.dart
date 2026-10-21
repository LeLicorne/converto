enum FormatCategory { image, document, data, archive, audio, video }

enum FileFormat {
  jpg('jpg', 'image/jpeg', FormatCategory.image, ['jpg', 'jpeg']),
  png('png', 'image/png', FormatCategory.image, ['png']),
  webp('webp', 'image/webp', FormatCategory.image, ['webp']),
  gif('gif', 'image/gif', FormatCategory.image, ['gif']),
  bmp('bmp', 'image/bmp', FormatCategory.image, ['bmp']),
  tiff('tiff', 'image/tiff', FormatCategory.image, ['tif', 'tiff']),
  heic('heic', 'image/heic', FormatCategory.image, ['heic', 'heif']),
  avif('avif', 'image/avif', FormatCategory.image, ['avif']),
  pdf('pdf', 'application/pdf', FormatCategory.document, ['pdf']),
  txt('txt', 'text/plain', FormatCategory.document, ['txt']),
  md('md', 'text/markdown', FormatCategory.document, ['md', 'markdown']),
  html('html', 'text/html', FormatCategory.document, ['html', 'htm']),
  docx(
    'docx',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    FormatCategory.document,
    ['docx'],
  ),
  csv('csv', 'text/csv', FormatCategory.data, ['csv']),
  json('json', 'application/json', FormatCategory.data, ['json']),
  xlsx(
    'xlsx',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    FormatCategory.data,
    ['xlsx'],
  ),
  zip('zip', 'application/zip', FormatCategory.archive, ['zip']),
  mp3('mp3', 'audio/mpeg', FormatCategory.audio, ['mp3']),
  aac('aac', 'audio/aac', FormatCategory.audio, ['aac']),
  m4a('m4a', 'audio/mp4', FormatCategory.audio, ['m4a']),
  wav('wav', 'audio/wav', FormatCategory.audio, ['wav']),
  flac('flac', 'audio/flac', FormatCategory.audio, ['flac']),
  ogg('ogg', 'audio/ogg', FormatCategory.audio, ['ogg', 'oga']),
  opus('opus', 'audio/opus', FormatCategory.audio, ['opus']),
  aiff('aiff', 'audio/aiff', FormatCategory.audio, ['aif', 'aiff']),
  mp4('mp4', 'video/mp4', FormatCategory.video, ['mp4', 'm4v']),
  mov('mov', 'video/quicktime', FormatCategory.video, ['mov']),
  mkv('mkv', 'video/x-matroska', FormatCategory.video, ['mkv']),
  webm('webm', 'video/webm', FormatCategory.video, ['webm']);

  const FileFormat(this.extension, this.mimeType, this.category, this.aliases);

  final String extension;
  final String mimeType;
  final FormatCategory category;
  final List<String> aliases;

  String get label => extension.toUpperCase();

  static FileFormat? fromExtension(String extension) {
    final normalized = extension.toLowerCase().replaceFirst('.', '');
    for (final format in FileFormat.values) {
      if (format.aliases.contains(normalized)) return format;
    }
    return null;
  }
}

List<int>? parsePageRanges(String input, int pageCount) {
  final text = input.trim();
  if (text.isEmpty) return List.generate(pageCount, (i) => i);
  final pages = <int>[];
  for (final part in text.split(RegExp(r'[,;\s]+'))) {
    if (part.isEmpty) continue;
    final range = part.split('-');
    if (range.length > 2) return null;
    final start = int.tryParse(range.first);
    final end = range.length == 2 ? int.tryParse(range.last) : start;
    if (start == null || end == null || start < 1 || end < start) return null;
    if (end > pageCount) return null;
    for (var page = start; page <= end; page++) {
      pages.add(page - 1);
    }
  }
  return pages.isEmpty ? null : pages;
}

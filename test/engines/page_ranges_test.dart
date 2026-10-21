import 'package:converto/features/convert/engines/page_ranges.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parsePageRanges', () {
    test('sélectionne toutes les pages quand le texte est vide', () {
      expect(parsePageRanges('', 3), [0, 1, 2]);
      expect(parsePageRanges('   ', 2), [0, 1]);
    });

    test('accepte des pages seules, des plages et des séparateurs variés', () {
      expect(parsePageRanges('1-3, 5', 6), [0, 1, 2, 4]);
      expect(parsePageRanges('2;4 6', 6), [1, 3, 5]);
    });

    test('refuse les sélections hors limites ou mal formées', () {
      expect(parsePageRanges('0', 5), isNull);
      expect(parsePageRanges('6', 5), isNull);
      expect(parsePageRanges('3-1', 5), isNull);
      expect(parsePageRanges('a', 5), isNull);
      expect(parsePageRanges('1-2-3', 5), isNull);
    });
  });
}

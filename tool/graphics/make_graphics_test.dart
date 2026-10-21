import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _Arrows extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final u = size.width / 1024;
    void arrow(double y, bool right) {
      final x1 = 212 * u;
      final x2 = 812 * u;
      canvas.drawRRect(
        RRect.fromLTRBR(x1, y - 32 * u, x2, y + 32 * u, Radius.circular(32 * u)),
        paint,
      );
      final tip = right ? x2 + 60 * u : x1 - 60 * u;
      final base = right ? tip - 150 * u : tip + 150 * u;
      canvas.drawPath(
        Path()
          ..moveTo(tip, y)
          ..lineTo(base, y - 150 * u)
          ..lineTo(base, y + 150 * u)
          ..close(),
        paint,
      );
    }

    arrow(size.height / 2 - 110 * u, true);
    arrow(size.height / 2 + 110 * u, false);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Future<void> _font(String family, String path) async {
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.sublistView(File(path).readAsBytesSync())));
  await loader.load();
}

void main() {
  setUpAll(() => _font('Noto', 'assets/fonts/NotoSans-Bold.ttf'));

  testWidgets('feature graphic 1024x500', (tester) async {
    tester.view
      ..physicalSize = const Size(1024, 500)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4F46E5), Color(0xFF6E50F0)],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 260,
                height: 260,
                child: CustomPaint(painter: _Arrows()),
              ),
              const SizedBox(width: 40),
              const Text(
                'Converto',
                style: TextStyle(
                  fontFamily: 'Noto',
                  fontSize: 120,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await expectLater(
      find.byType(Container).first,
      matchesGoldenFile('../../store/graphics/play-feature-graphic-1024x500.png'),
    );
  });
}

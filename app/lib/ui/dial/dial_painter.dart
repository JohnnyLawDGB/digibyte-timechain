import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/chain_snapshot.dart';
import '../../domain/ring_math.dart';
import '../theme/timechain_theme.dart';

class DialPainter extends CustomPainter {
  DialPainter({required this.snapshot, required this.palette});
  final ChainSnapshot snapshot;
  final TimechainPalette palette;

  static const rSupply = 0.465, rReduction = 0.412, rAlgo = 0.359, rTicks = 0.306;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final w = size.shortestSide;
    final r1 = w * rSupply, r2 = w * rReduction, r3 = w * rAlgo, r4 = w * rTicks;

    Paint stroke(Color col, double width, {StrokeCap cap = StrokeCap.round}) =>
        Paint()..color = col..style = PaintingStyle.stroke..strokeWidth = width..strokeCap = cap;

    // tracks
    for (final (r, sw) in [(r1, 6.0), (r2, 5.0), (r3, 8.0)]) {
      canvas.drawCircle(c, r, stroke(palette.track, sw, cap: StrokeCap.butt));
    }
    // ring 1: supply of cap
    final total = snapshot.supply.total;
    final supplyFrac = total == null ? 0.0 : total / snapshot.supply.cap;
    final s1 = sweepFor(supplyFrac);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r1), kStartAngle, s1, false, stroke(TimechainPalette.brandBlue, 6));
    // ring 2: reduction cycle
    final s2 = sweepFor(snapshot.reduction.fraction);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r2), kStartAngle, s2, false, stroke(palette.ring2, 5));
    // ring 3: algorithm share
    for (final a in algoArcs(snapshot.algoShare24h.asMap, TimechainPalette.algoOrder)) {
      canvas.drawArc(Rect.fromCircle(center: c, radius: r3), a.start, a.sweep, false, stroke(palette.algo(a.key), 8, cap: StrokeCap.butt));
    }
    // ring 4: one tick per recent block, newest at 12 o'clock
    final blocks = snapshot.recentBlocks;
    final n = max(blocks.length, 240);
    for (var i = 0; i < blocks.length; i++) {
      final ang = tickAngle(i, n);
      final len = tickLength(blocks[i].sizeBytes);
      canvas.drawLine(pointOnCircle(c, r4, ang), pointOnCircle(c, r4 - len, ang), stroke(palette.algo(blocks[i].algo), 1.6));
    }
    // selected block marker + arc-end dots
    final dot = Paint()..style = PaintingStyle.fill;
    canvas.drawCircle(pointOnCircle(c, r4 + 5, kStartAngle), 3.5, dot..color = palette.text);
    for (final (r, s, col) in [(r1, s1, TimechainPalette.brandBlue), (r2, s2, palette.ring2)]) {
      final p = pointOnCircle(c, r, kStartAngle + s);
      canvas.drawCircle(p, 6.5, dot..color = palette.bg);
      canvas.drawCircle(p, 5, dot..color = col);
    }
  }

  /// Where the pill for ring 1 / ring 2 should sit (outside the ring).
  static Offset pillOffset(Size size, double radiusFactor, double fraction) {
    final c = Offset(size.width / 2, size.height / 2);
    final p = pointOnCircle(c, size.shortestSide * radiusFactor + 18, kStartAngle + sweepFor(fraction));
    return Offset(p.dx.clamp(42, size.width - 42), p.dy);
  }

  @override
  bool shouldRepaint(DialPainter old) => old.snapshot != snapshot || old.palette != palette;
}

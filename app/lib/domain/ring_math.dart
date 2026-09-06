import 'dart:math';
import 'dart:ui';

/// 12 o'clock in Flutter's canvas angle convention.
const double kStartAngle = -pi / 2;

/// Sweep angle for a fraction of a full turn, clamped so a full ring still draws as an arc.
double sweepFor(double fraction) => (fraction.clamp(0.0, 1.0) * 2 * pi).clamp(0.0, 2 * pi - 1e-6);

Offset pointOnCircle(Offset center, double radius, double angle) =>
    Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));

/// Angle of tick [index] out of [count], index 0 at 12 o'clock, clockwise.
double tickAngle(int index, int count) => kStartAngle + (2 * pi) * (index / count);

/// Tick length grows with the square root of block size: 4 px empty → 14 px at [fullBytes].
double tickLength(int sizeBytes, {double min = 4, double max = 14, int fullBytes = 8000}) {
  final f = sqrt(sizeBytes / fullBytes).clamp(0.0, 1.0);
  return min + (max - min) * f;
}

class ArcSpan {
  const ArcSpan(this.key, this.start, this.sweep);
  final String key;
  final double start, sweep;
}

/// Consecutive arcs, one per key in [order], sized by [shares] (fractions summing to ≤ 1).
List<ArcSpan> algoArcs(Map<String, double> shares, List<String> order) {
  var a = kStartAngle;
  final out = <ArcSpan>[];
  for (final k in order) {
    final f = shares[k];
    if (f == null) continue;
    final s = sweepFor(f);
    out.add(ArcSpan(k, a, s));
    a += s;
  }
  return out;
}

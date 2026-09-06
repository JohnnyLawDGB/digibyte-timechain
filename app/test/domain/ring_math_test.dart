import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:digibyte_timechain/domain/ring_math.dart';

void main() {
  test('sweepFor clamps and scales', () {
    expect(sweepFor(0), 0);
    expect(sweepFor(0.5), closeTo(pi, 1e-9));
    expect(sweepFor(1.0), closeTo(2 * pi - 1e-6, 1e-5));
    expect(sweepFor(-1), 0);
  });
  test('pointOnCircle from 12 o clock', () {
    final p = pointOnCircle(const Offset(170, 170), 100, kStartAngle);
    expect(p.dx, closeTo(170, 1e-9)); expect(p.dy, closeTo(70, 1e-9));
  });
  test('tickAngle: index 0 at 12 o clock, clockwise, 240 ticks = 1.5° each', () {
    expect(tickAngle(0, 240), closeTo(kStartAngle, 1e-9));
    expect(tickAngle(60, 240), closeTo(kStartAngle + pi / 2, 1e-9));
  });
  test('tickLength grows with sqrt of size and clamps', () {
    expect(tickLength(0), 4);
    expect(tickLength(8000), 14);
    expect(tickLength(2000), closeTo(9, 1e-9));
    expect(tickLength(1000000), 14);
  });
  test('algoArcs lays five spans end to end in order', () {
    final arcs = algoArcs({'a': 0.5, 'b': 0.25, 'c': 0.25}, ['a', 'b', 'c']);
    expect(arcs.map((a) => a.key), ['a', 'b', 'c']);
    expect(arcs[0].start, closeTo(kStartAngle, 1e-9));
    expect(arcs[1].start, closeTo(kStartAngle + pi, 1e-9));
    expect(arcs[2].sweep, closeTo(pi / 2, 1e-9));
    expect(algoArcs({}, ['a']), isEmpty);
  });
}

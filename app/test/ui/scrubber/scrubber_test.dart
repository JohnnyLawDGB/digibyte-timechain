import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digibyte_timechain/ui/scrubber/scrubber.dart';
import 'package:digibyte_timechain/ui/theme/timechain_theme.dart';

void main() {
  const tip = 24151775;
  Widget host(int? sel, ValueChanged<int?> on) => MaterialApp(theme: timechainTheme(TimechainPalette.dark), home: Scaffold(body: SizedBox(width: 390, child: Scrubber(tipHeight: tip, selectedHeight: sel, onChanged: on))));

  testWidgets('prev steps back one block; next at the tip returns to live', (t) async {
    final got = <int?>[];
    await t.pumpWidget(host(null, got.add));
    expect(find.text('SCRUB BLOCKS · TIP'), findsOneWidget);
    await t.tap(find.byKey(const Key('scrub-prev')));
    expect(got, [tip - 1]);
    await t.pumpWidget(host(tip - 1, got.add));
    expect(find.text('SCRUB BLOCKS · 1 BACK'), findsOneWidget);
    await t.tap(find.byKey(const Key('scrub-next')));
    expect(got.last, isNull);
  });
  testWidgets('dragging the track snaps to whole blocks and the right edge means live', (t) async {
    final got = <int?>[];
    await t.pumpWidget(host(null, got.add));
    final track = find.byKey(const Key('scrub-track'));
    final box = t.getRect(track);
    await t.dragFrom(box.centerRight, Offset(-box.width / 2, 0));
    await t.pumpAndSettle();
    // half-way along a 240-block window: 119.5 blocks back, rounded to a whole block
    expect((got.last! - (tip - 120)).abs() <= 1, isTrue, reason: 'got ${got.last}');
    await t.dragFrom(box.center, Offset(box.width, 0));
    await t.pumpAndSettle();
    expect(got.last, isNull);
  });
  testWidgets('prev clamps at the window edge', (t) async {
    final got = <int?>[];
    await t.pumpWidget(host(tip - 239, got.add));
    await t.tap(find.byKey(const Key('scrub-prev')));
    expect(got, [tip - 239]);
  });
}

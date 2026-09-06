import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digibyte_timechain/ui/dial/dial.dart';
import 'package:digibyte_timechain/ui/dial/dial_painter.dart';
import 'package:digibyte_timechain/ui/theme/timechain_theme.dart';
import '../../fixtures/fixtures.dart';

const goldenFrameKey = Key('golden-frame');

Widget host(Widget child, TimechainPalette p) => MaterialApp(
  theme: timechainTheme(p),
  home: Scaffold(
    body: Center(
      child: RepaintBoundary(
        child: ColoredBox(
          key: goldenFrameKey,
          color: p.bg,
          child: Padding(padding: const EdgeInsets.all(12), child: child),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('renders height, algo, fee band and pills for a scrubbed block', (t) async {
    await t.pumpWidget(host(Dial(snapshot: blockFixture()), TimechainPalette.dark));
    expect(find.text('24,151,710'), findsOneWidget);
    expect(find.text('QUBIT'), findsOneWidget);
    expect(find.textContaining('0.1000'), findsOneWidget);
    expect(find.textContaining('min 0.001100'), findsOneWidget);
    expect(find.text('7,579 B · 4 tx'), findsOneWidget);
    expect(find.text('87.9%'), findsOneWidget);
    expect(find.text('69.0%'), findsOneWidget);
  });
  testWidgets('shows dashes for a coinbase-only block and null supply', (t) async {
    final s = tipFixture().copyWith(supply: tipFixture().supply.copyWith(total: null));
    await t.pumpWidget(host(Dial(snapshot: s), TimechainPalette.dark));
    expect(find.textContaining('— DGB/kB'), findsOneWidget);
    expect(find.text('—'), findsWidgets);
  });
  testWidgets('center readout stays inside the tick ring at a 328 px host width', (t) async {
    await t.binding.setSurfaceSize(const Size(360, 1400));
    await t.pumpWidget(MaterialApp(
      theme: timechainTheme(TimechainPalette.dark),
      home: Scaffold(body: ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: [Center(child: Dial(snapshot: ringFixture()))])),
    ));
    expect(t.takeException(), isNull);
    final dial = t.getRect(find.byType(Dial));
    expect(dial.width, 328, reason: 'the ListView clamps the declared 340 down to 328');
    // The rings paint at the laid-out width, so the readout must fit the inner
    // circle measured from that width — not from the declared `size`.
    final side = 2 * DialPainter.rTicks * dial.width - 32;
    final inner = Rect.fromCenter(center: dial.center, width: side, height: side);
    for (final f in [find.text('BLOCK HEIGHT'), find.text('24,151,710'), find.byType(IconButton)]) {
      final r = t.getRect(f);
      expect(r.left >= inner.left - 0.5 && r.right <= inner.right + 0.5 && r.top >= inner.top - 0.5 && r.bottom <= inner.bottom + 0.5, isTrue,
          reason: 'readout piece $r escapes the inner circle $inner');
    }
    await t.binding.setSurfaceSize(null);
  });
  testWidgets('golden: dark', (t) async {
    await t.pumpWidget(host(Dial(snapshot: ringFixture()), TimechainPalette.dark));
    await expectLater(find.byKey(goldenFrameKey), matchesGoldenFile('../../goldens/dial_dark.png'));
  });
  testWidgets('golden: light', (t) async {
    await t.pumpWidget(host(Dial(snapshot: ringFixture()), TimechainPalette.light));
    await expectLater(find.byKey(goldenFrameKey), matchesGoldenFile('../../goldens/dial_light.png'));
  });
  testWidgets('golden: dark at tablet size', (t) async {
    await t.binding.setSurfaceSize(const Size(900, 900));
    await t.pumpWidget(host(Dial(snapshot: ringFixture(), size: 800), TimechainPalette.dark));
    await expectLater(find.byKey(goldenFrameKey), matchesGoldenFile('../../goldens/dial_dark_800.png'));
  });
}

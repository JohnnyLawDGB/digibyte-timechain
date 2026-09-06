import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digibyte_timechain/ui/theme/timechain_theme.dart';
import 'package:digibyte_timechain/ui/tiles/algo_legend.dart';
import 'package:digibyte_timechain/ui/tiles/block_timer_tile.dart';
import 'package:digibyte_timechain/ui/tiles/fee_mempool_card.dart';
import 'package:digibyte_timechain/ui/tiles/footer_stats.dart';
import 'package:digibyte_timechain/ui/tiles/header_stats.dart';
import 'package:digibyte_timechain/ui/tiles/reward_tile.dart';
import '../../fixtures/fixtures.dart';

Widget host(Widget w) => MaterialApp(theme: timechainTheme(TimechainPalette.dark), home: Scaffold(body: SizedBox(width: 390, child: w)));

void main() {
  testWidgets('HeaderStats shows reduction, subsidy and price', (t) async {
    await t.pumpWidget(host(HeaderStats(snapshot: tipFixture(), isLive: true)));
    expect(find.text('#130'), findsOneWidget);
    expect(find.text('253.56'), findsOneWidget);
    expect(find.text('0.00469'), findsOneWidget);
    expect(find.text('213 DGB per USD'), findsOneWidget);
  });
  testWidgets('BlockTimerTile counts seconds when live and shows mined-at when scrubbed', (t) async {
    final s = tipFixture();
    final now = DateTime.fromMillisecondsSinceEpoch((s.time + 9) * 1000, isUtc: true);
    await t.pumpWidget(host(BlockTimerTile(snapshot: s, now: now, isLive: true, blocksBehind: 0)));
    expect(find.text('9s'), findsOneWidget);
    expect(find.text('of 15s target'), findsOneWidget);
    await t.pumpWidget(host(BlockTimerTile(snapshot: blockFixture(), now: now, isLive: false, blocksBehind: 65)));
    expect(find.text('10:40:29'), findsOneWidget);
    expect(find.text('65 behind tip'), findsOneWidget);
  });
  testWidgets('RewardTile adds up and names the pool', (t) async {
    await t.pumpWidget(host(RewardTile(snapshot: blockFixture())));
    expect(find.text('253.56'), findsOneWidget);
    expect(find.text('0.645'), findsOneWidget);
    expect(find.text('254.20'), findsOneWidget);
    expect(find.text('m2pool.com'), findsOneWidget);
    expect(find.text('QUBIT'), findsOneWidget);
  });
  testWidgets('RewardTile shows unknown for an untagged pool', (t) async {
    final s = blockFixture().copyWith(pool: blockFixture().pool.copyWith(tag: null));
    await t.pumpWidget(host(RewardTile(snapshot: s)));
    expect(find.text('unknown'), findsOneWidget);
  });
  testWidgets('RewardTile truncates a long pool tag instead of overflowing', (t) async {
    final s = blockFixture().copyWith(pool: blockFixture().pool.copyWith(tag: 'a-very-long-pool-tag-that-would-never-fit-in-the-row-at-all-' * 2));
    await t.pumpWidget(host(RewardTile(snapshot: s)));
    expect(t.takeException(), isNull);
    expect(find.byType(RewardTile), findsOneWidget);
  });
  testWidgets('FeeMempoolCard shows DGB/kB estimates and mempool figures', (t) async {
    await t.pumpWidget(host(FeeMempoolCard(snapshot: tipFixture(), isLive: true)));
    expect(find.text('DGB / kB'), findsOneWidget);
    expect(find.text('0.01100'), findsOneWidget);
    expect(find.text('0.001100'), findsOneWidget);
    expect(find.text('transactions'), findsOneWidget);
    await t.pumpWidget(host(FeeMempoolCard(snapshot: blockFixture(), isLive: false)));
    expect(find.text('live · not block-specific'), findsOneWidget);
  });
  testWidgets('FeeMempoolCard does not overflow at a 358px slot (390 minus 16px margins)', (t) async {
    await t.pumpWidget(MaterialApp(theme: timechainTheme(TimechainPalette.dark), home: Scaffold(body: SizedBox(width: 358, child: FeeMempoolCard(snapshot: blockFixture(), isLive: false)))));
    expect(t.takeException(), isNull);
  });
  testWidgets('FooterStats and AlgoLegend', (t) async {
    await t.pumpWidget(host(Column(children: [FooterStats(snapshot: tipFixture(), isLive: true), AlgoLegend(snapshot: tipFixture())])));
    expect(find.text('18.46B'), findsOneWidget);
    expect(find.text('87.89% of 21B'), findsOneWidget);
    expect(find.text('54,225'), findsOneWidget);
    expect(find.text('blocks · ~9.4 days'), findsOneWidget);
    expect(find.text('\$86.6M'), findsOneWidget);
    expect(find.text('SKEIN'), findsOneWidget);
    expect(find.text('21%'), findsOneWidget);
  });
}

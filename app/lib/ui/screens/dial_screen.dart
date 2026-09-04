import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config.dart';
import '../../data/chain_repository.dart';
import '../../data/models/chain_snapshot.dart';
import '../../domain/formatters.dart';
import '../../state/providers.dart';
import '../dial/dial.dart';
import '../scrubber/scrubber.dart';
import '../theme/timechain_theme.dart';
import '../tiles/algo_legend.dart';
import '../tiles/block_timer_tile.dart';
import '../tiles/fee_mempool_card.dart';
import '../tiles/footer_stats.dart';
import '../tiles/header_stats.dart';
import '../tiles/reward_tile.dart';
import '../widgets/status_pill.dart';
import 'settings_screen.dart';

class DialScreen extends ConsumerWidget {
  const DialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final tip = ref.watch(tipUpdateProvider);
    final selected = ref.watch(selectedSnapshotProvider);
    final isLive = ref.watch(isLiveProvider);
    final now = ref.watch(nowProvider).value ?? DateTime.now();

    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(child: tip.when(
        loading: () => _message(context, 'Connecting to the chain…'),
        error: (e, _) => _message(context, 'Could not reach the chain feed.\n$e'),
        // In live mode, `selected` briefly reports `loading` for one microtask hop after
        // each tip update (FutureProvider re-resolving) even though its eventual value
        // is exactly `u.snapshot`; using the real `isLive` here (rather than hardcoding
        // false) keeps the LIVE pill in sync with the tip instead of lagging a frame.
        // When scrubbed, `isLive` is already false, so this is a no-op for that path.
        data: (u) => selected.when(
          loading: () => _body(context, ref, u, u.snapshot, isLive: isLive, now: now, loadingBlock: true),
          error: (e, _) => _body(context, ref, u, u.snapshot, isLive: isLive, now: now, blockError: e.toString()),
          data: (s) => _body(context, ref, u, s, isLive: isLive, now: now),
        ),
      )),
    );
  }

  Widget _message(BuildContext context, String text) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: context.palette.muted))));

  Widget _body(BuildContext context, WidgetRef ref, TipUpdate u, ChainSnapshot s, {required bool isLive, required DateTime now, bool loadingBlock = false, String? blockError}) {
    final p = context.palette;
    final tipHeight = u.snapshot.height;
    final behind = tipHeight - s.height;
    final pill = !isLive
        ? StatusPill(label: 'VIEWING BLOCK', color: p.muted)
        : switch (u.status) {
            FeedStatus.live => StatusPill(label: 'LIVE', color: p.live, pulse: true),
            FeedStatus.reconnecting => StatusPill(label: 'RECONNECTING', color: const Color(0xFFF5A524)),
            FeedStatus.stale => StatusPill(label: 'STALE · ${fmtElapsed(now.difference(DateTime.fromMillisecondsSinceEpoch(s.time * 1000)))} AGO', color: const Color(0xFFF5A524)),
          };
    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 28), children: [
      SizedBox(height: 44, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(child: Row(mainAxisSize: MainAxisSize.min, children: [
          SvgPicture.asset('assets/brand/digibyte_symbol.svg', width: 30, height: 30), const SizedBox(width: 10),
          Flexible(child: Text('TIMECHAIN', maxLines: 1, overflow: TextOverflow.ellipsis, style: kLabel.copyWith(fontSize: 15, letterSpacing: 2.2, color: p.text))),
        ])),
        const SizedBox(width: 8),
        pill,
        IconButton(icon: const Icon(Icons.settings), color: p.muted, onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()))),
      ])),
      const SizedBox(height: 14),
      HeaderStats(snapshot: s, isLive: isLive),
      const SizedBox(height: 20),
      Center(child: Opacity(opacity: loadingBlock ? 0.5 : 1, child: Dial(snapshot: s, onOpenExplorer: () => _copyExplorer(context, s.height)))),
      if (blockError != null) Padding(padding: const EdgeInsets.only(top: 8), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Flexible(child: Text('Could not load that block.', style: TextStyle(color: const Color(0xFFF5A524), fontSize: 12))),
        TextButton(key: const Key('scrub-retry'), onPressed: () => ref.invalidate(selectedSnapshotProvider), child: const Text('Retry')),
      ])),
      const SizedBox(height: 14),
      Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(child: RichText(overflow: TextOverflow.ellipsis, maxLines: 1, text: TextSpan(text: fmtUtcTime(s.time), style: kMono.copyWith(fontSize: 38, letterSpacing: -1, color: p.text), children: [TextSpan(text: '  UTC', style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14, fontWeight: FontWeight.w500, color: p.muted))]))),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(fmtWeekday(s.time), style: kLabel.copyWith(fontSize: 11, letterSpacing: 1.6, color: p.muted)), Text(fmtUtcDate(s.time), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: p.text))]),
      ]),
      const SizedBox(height: 14),
      Scrubber(tipHeight: tipHeight, selectedHeight: isLive ? null : s.height, onChanged: (h) => ref.read(selectedHeightProvider.notifier).state = h),
      const SizedBox(height: 14),
      Row(children: [BlockTimerTile(snapshot: s, now: now, isLive: isLive, blocksBehind: behind), const SizedBox(width: 12), Expanded(child: RewardTile(snapshot: s))]),
      const SizedBox(height: 14),
      FeeMempoolCard(snapshot: isLive ? s : s.copyWith(mempool: u.snapshot.mempool), isLive: isLive),
      const SizedBox(height: 14),
      FooterStats(snapshot: isLive ? s : s.copyWith(price: u.snapshot.price), isLive: isLive),
      const SizedBox(height: 12),
      AlgoLegend(snapshot: s),
    ]);
  }

  void _copyExplorer(BuildContext context, int height) {
    final url = '$kExplorerBase$height';
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied $url')));
  }
}

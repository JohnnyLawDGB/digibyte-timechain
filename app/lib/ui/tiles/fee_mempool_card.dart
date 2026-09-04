import 'package:flutter/material.dart';
import '../../data/models/chain_snapshot.dart';
import '../../domain/formatters.dart';
import '../theme/timechain_theme.dart';
import 'stat.dart';

class FeeMempoolCard extends StatelessWidget {
  const FeeMempoolCard({super.key, required this.snapshot, required this.isLive});
  final ChainSnapshot snapshot; final bool isLive;
  @override
  Widget build(BuildContext context) {
    final p = context.palette; final m = snapshot.mempool;
    Widget title(String a, String b) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Flexible(child: Text(a, overflow: TextOverflow.ellipsis, style: kLabel.copyWith(letterSpacing: 1.6, color: p.muted))),
      Flexible(child: Text(b, overflow: TextOverflow.ellipsis, textAlign: TextAlign.end, style: TextStyle(fontSize: 10, color: p.muted))),
    ]);
    Widget est(String label, String value, String sub) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: p.card2, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: kLabel.copyWith(fontSize: 9, letterSpacing: 1.2, color: p.muted)), Text(value, style: kMono.copyWith(fontSize: 20, color: p.text)), Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9.5, color: p.muted))]));
    return Card2(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      title('FEE RATES', 'DGB / kB'), const SizedBox(height: 12),
      Row(children: [
        Expanded(child: est('PRIORITY', fmtFeeDgbPerKb(m?.fees.priority), 'next 2 blocks · ~30 s')), const SizedBox(width: 10),
        Expanded(child: est('ANYTIME', fmtFeeDgbPerKb(m?.fees.anytime), 'within 20 blocks · ~5 min')),
      ]),
      Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: p.track)),
      title('MEMPOOL', isLive ? 'live' : 'live · not block-specific'), const SizedBox(height: 8),
      Row(children: [
        Expanded(child: Stat(label: 'INFLOW', value: m == null ? '—' : m.inflowVbPerSec.toStringAsFixed(0), sub: 'vB / s')),
        Expanded(child: Stat(label: 'UNCONFIRMED', value: m == null ? '—' : fmtHeight(m.txCount), sub: 'transactions', align: CrossAxisAlignment.center)),
        Expanded(child: Stat(label: 'DEPTH', value: m == null ? '—' : m.depthBlocks.toStringAsFixed(m.depthBlocks < 10 ? 1 : 0), sub: 'blocks', align: CrossAxisAlignment.end)),
      ]),
    ]));
  }
}

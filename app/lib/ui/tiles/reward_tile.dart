import 'package:flutter/material.dart';
import '../../data/models/chain_snapshot.dart';
import '../../domain/formatters.dart';
import '../theme/timechain_theme.dart';
import 'stat.dart';

class RewardTile extends StatelessWidget {
  const RewardTile({super.key, required this.snapshot});
  final ChainSnapshot snapshot;
  @override
  Widget build(BuildContext context) {
    final p = context.palette; final r = snapshot.reward; final algoColor = p.algo(snapshot.algo);
    Widget cell(String label, String value, CrossAxisAlignment a, {Color? color}) => Column(crossAxisAlignment: a, children: [
      Text(label, style: kLabel.copyWith(fontSize: 9, letterSpacing: 1.2, color: p.muted)), const SizedBox(height: 2),
      Text(value, style: kMono.copyWith(fontSize: 13, color: color ?? p.text)),
    ]);
    return Card2(padding: const EdgeInsets.fromLTRB(14, 12, 14, 12), child: Column(children: [
      Row(children: [
        Expanded(child: cell('SUBSIDY', fmtDgb(r.subsidy), CrossAxisAlignment.start)),
        Expanded(child: cell('+ FEES', fmtDgb(r.fees, decimals: 3), CrossAxisAlignment.center)),
        Expanded(child: cell('= REWARD', fmtDgb(r.total), CrossAxisAlignment.end, color: TimechainPalette.brandBlue)),
      ]),
      Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: p.track)),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('MINED BY', style: kLabel.copyWith(fontSize: 9.5, letterSpacing: 1.2, color: p.muted)),
        // The gap lives inside the flexible tag rather than beside it: at 360 dp the
        // label plus the algo pill already fill the row, and a rigid 6 px spacer there
        // overflowed by exactly its own width once the tag had ellipsised away.
        Flexible(child: Row(mainAxisSize: MainAxisSize.min, children: [
          Flexible(child: Padding(padding: const EdgeInsets.only(right: 6),
            child: Text(snapshot.pool.tag ?? 'unknown', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: p.text)))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(border: Border.all(color: algoColor), borderRadius: BorderRadius.circular(999)),
            child: Text((TimechainPalette.algoLabels[snapshot.algo] ?? snapshot.algo).toUpperCase(), style: kLabel.copyWith(fontSize: 9, letterSpacing: 1, color: algoColor))),
        ])),
      ]),
    ]));
  }
}

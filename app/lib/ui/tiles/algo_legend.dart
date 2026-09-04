import 'package:flutter/material.dart';
import '../../data/models/chain_snapshot.dart';
import '../theme/timechain_theme.dart';

class AlgoLegend extends StatelessWidget {
  const AlgoLegend({super.key, required this.snapshot});
  final ChainSnapshot snapshot;
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Wrap(alignment: WrapAlignment.center, spacing: 14, runSpacing: 8, children: [
      for (final k in TimechainPalette.algoOrder)
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 9, height: 9, decoration: BoxDecoration(shape: BoxShape.circle, color: p.algo(k))), const SizedBox(width: 6),
          Text(TimechainPalette.algoLabels[k]!.toUpperCase(), style: kLabel.copyWith(fontSize: 10.5, letterSpacing: 0.8, color: p.muted)), const SizedBox(width: 4),
          Text('${(snapshot.algoShare24h.share(k) * 100).round()}%', style: kMono.copyWith(fontSize: 10.5, fontWeight: FontWeight.w600, color: p.text)),
        ]),
    ]);
  }
}

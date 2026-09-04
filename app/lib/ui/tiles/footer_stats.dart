import 'package:flutter/material.dart';
import '../../data/models/chain_snapshot.dart';
import '../../domain/formatters.dart';
import 'stat.dart';

class FooterStats extends StatelessWidget {
  const FooterStats({super.key, required this.snapshot, required this.isLive});
  final ChainSnapshot snapshot; final bool isLive;
  @override
  Widget build(BuildContext context) {
    final total = snapshot.supply.total; final r = snapshot.reduction;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Stat(label: 'SUPPLY', value: fmtBillions(total), sub: total == null ? 'scanning…' : '${fmtPercent(total / snapshot.supply.cap, decimals: 2)} of 21B')),
      Expanded(child: Stat(label: 'NEXT CUT', value: fmtHeight(r.blocksUntilNext), sub: 'blocks · ${fmtDaysFromBlocks(r.blocksUntilNext)}', align: CrossAxisAlignment.center)),
      Expanded(child: Stat(label: 'MARKET', value: fmtUsdCompact(snapshot.price?.marketCapUsd), sub: 'USD', align: CrossAxisAlignment.end, dim: !isLive)),
    ]);
  }
}

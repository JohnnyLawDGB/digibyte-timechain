import 'package:flutter/material.dart';
import '../../data/models/chain_snapshot.dart';
import '../../domain/formatters.dart';
import 'stat.dart';

class HeaderStats extends StatelessWidget {
  const HeaderStats({super.key, required this.snapshot, required this.isLive});
  final ChainSnapshot snapshot; final bool isLive;
  @override
  Widget build(BuildContext context) {
    final usd = snapshot.price?.usd;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Stat(label: 'REDUCTION', value: '#${snapshot.reduction.step}', sub: 'cut 1.116% monthly', mono: false)),
      Expanded(child: Stat(label: 'SUBSIDY', value: fmtDgb(snapshot.reward.subsidy), sub: 'DGB per block', align: CrossAxisAlignment.center)),
      Expanded(child: Stat(label: 'USD / DGB', value: fmtUsdPrice(usd), sub: '${fmtDgbPerUsd(usd)} DGB per USD', align: CrossAxisAlignment.end, dim: !isLive)),
    ]);
  }
}

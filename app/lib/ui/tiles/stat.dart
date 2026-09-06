import 'package:flutter/material.dart';
import '../theme/timechain_theme.dart';

class Stat extends StatelessWidget {
  const Stat({super.key, required this.label, required this.value, this.sub = '', this.align = CrossAxisAlignment.start, this.mono = true, this.dim = false});
  final String label, value, sub; final CrossAxisAlignment align; final bool mono, dim;
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Opacity(opacity: dim ? 0.45 : 1, child: Column(crossAxisAlignment: align, mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: kLabel.copyWith(color: p.muted)),
      const SizedBox(height: 2),
      Text(value, style: (mono ? kMono : kLabel.copyWith(letterSpacing: 0)).copyWith(fontSize: 17, color: p.text, height: 1.1)),
      if (sub.isNotEmpty) Text(sub, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: p.muted)),
    ]));
  }
}

class Card2 extends StatelessWidget {
  const Card2({super.key, required this.child, this.padding = const EdgeInsets.all(14)});
  final Widget child; final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(padding: padding, decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.track)), child: child);
  }
}

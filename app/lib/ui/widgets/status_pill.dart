import 'package:flutter/material.dart';
import '../theme/timechain_theme.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color, this.pulse = false});
  final String label; final Color color; final bool pulse;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: pulse ? [BoxShadow(color: color.withValues(alpha: 0.25), spreadRadius: 3)] : null)),
    const SizedBox(width: 6),
    Text(label, style: kLabel.copyWith(fontSize: 11, color: color)),
  ]);
}

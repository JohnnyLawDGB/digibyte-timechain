import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/chain_snapshot.dart';
import '../../domain/formatters.dart';
import '../../domain/ring_math.dart';
import '../theme/timechain_theme.dart';

class BlockTimerTile extends StatelessWidget {
  const BlockTimerTile({super.key, required this.snapshot, required this.now, required this.isLive, required this.blocksBehind});
  final ChainSnapshot snapshot; final DateTime now; final bool isLive; final int blocksBehind;
  static const target = Duration(seconds: 15);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final elapsed = Duration(seconds: max(0, now.toUtc().millisecondsSinceEpoch ~/ 1000 - snapshot.time));
    final over = elapsed > target;
    final frac = isLive ? min(1.0, elapsed.inSeconds / target.inSeconds) : 0.0;
    final ringColor = over ? const Color(0xFFF5A524) : p.live;
    return SizedBox(width: 104, height: 104, child: Stack(alignment: Alignment.center, children: [
      CustomPaint(size: const Size.square(104), painter: _RingPainter(frac: frac, track: p.track, color: ringColor)),
      Column(mainAxisSize: MainAxisSize.min, children: isLive
        ? [Text('LAST BLOCK', style: kLabel.copyWith(fontSize: 9, color: p.muted)), Text(fmtElapsed(elapsed), style: kMono.copyWith(fontSize: 20, color: p.text)), Text('of 15s target', style: TextStyle(fontSize: 9, color: p.muted))]
        : [Text('MINED AT', style: kLabel.copyWith(fontSize: 9, color: p.muted)), Text(fmtUtcTimeSec(snapshot.time), style: kMono.copyWith(fontSize: 15, color: p.text)), Text('$blocksBehind behind tip', style: TextStyle(fontSize: 9, color: p.muted))]),
    ]));
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.frac, required this.track, required this.color});
  final double frac; final Color track, color;
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero); const r = 40.0;
    canvas.drawCircle(c, r, Paint()..color = track..style = PaintingStyle.stroke..strokeWidth = 6);
    if (frac > 0) canvas.drawArc(Rect.fromCircle(center: c, radius: r), kStartAngle, sweepFor(frac), false, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 6..strokeCap = StrokeCap.round);
  }
  @override
  bool shouldRepaint(_RingPainter o) => o.frac != frac || o.color != color;
}

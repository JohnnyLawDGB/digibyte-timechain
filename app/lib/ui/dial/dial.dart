import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../data/models/chain_snapshot.dart';
import '../../domain/formatters.dart';
import '../theme/timechain_theme.dart';
import 'dial_painter.dart';

class Dial extends StatelessWidget {
  const Dial({super.key, required this.snapshot, this.size = 340, this.onOpenExplorer});
  final ChainSnapshot snapshot;
  final double size;
  final VoidCallback? onOpenExplorer;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final algoColor = p.algo(snapshot.algo);
    final supplyFrac = snapshot.supply.total == null ? 0.0 : snapshot.supply.total! / snapshot.supply.cap;
    final fee = snapshot.feeRate;
    // The painter draws its rings from the LAID-OUT width, which a narrow phone clamps
    // below the declared `size` (340 -> 328 at 360 dp). Measure it here so the centre
    // readout and the pills use the same geometry the rings are painted with, and cap
    // the readout to the inner tick circle so it can never collide with the ticks.
    return LayoutBuilder(builder: (context, constraints) {
      final w = math.min(size, constraints.maxWidth);
      final sz = Size.square(w);
      final inner = 2 * DialPainter.rTicks * w - 32;
      return SizedBox.fromSize(
        size: sz,
        child: Stack(clipBehavior: Clip.none, children: [
          CustomPaint(size: sz, painter: DialPainter(snapshot: snapshot, palette: p)),
          Center(
            child: SizedBox(
              width: inner, height: inner,
              child: FittedBox(fit: BoxFit.scaleDown, child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('BLOCK HEIGHT', style: kLabel.copyWith(fontSize: 9.5, letterSpacing: 1.6, color: p.muted)),
              const SizedBox(height: 3),
              FittedBox(child: Text(fmtHeight(snapshot.height), style: kMono.copyWith(fontSize: 31, letterSpacing: -0.5, color: p.text))),
              const SizedBox(height: 6),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: algoColor, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 6),
                Text((TimechainPalette.algoLabels[snapshot.algo] ?? snapshot.algo).toUpperCase(), style: kLabel.copyWith(fontSize: 11, color: algoColor)),
              ]),
              const SizedBox(height: 4),
              Text('${fmtFeeDgbPerKb(fee?.median)} DGB/kB', style: kMono.copyWith(fontSize: 12, color: p.text)),
              Text(fee == null ? 'no fee-paying tx' : 'min ${fmtFeeDgbPerKb(fee.min)} · max ${fmtFeeDgbPerKb(fee.max)}', style: kMono.copyWith(fontSize: 10.5, fontWeight: FontWeight.w500, color: p.muted)),
              const SizedBox(height: 2),
              Text('${fmtHeight(snapshot.sizeBytes)} B · ${snapshot.txCount} tx', style: kMono.copyWith(fontSize: 12, color: p.text)),
              IconButton(onPressed: onOpenExplorer, iconSize: 16, color: p.muted, constraints: const BoxConstraints(minWidth: 44, minHeight: 44), icon: const Icon(Icons.content_copy)),
              ])),
            ),
          ),
          _pill(context, DialPainter.pillOffset(sz, DialPainter.rSupply, supplyFrac), snapshot.supply.total == null ? '—' : fmtPercent(supplyFrac)),
          _pill(context, DialPainter.pillOffset(sz, DialPainter.rReduction, snapshot.reduction.fraction), fmtPercent(snapshot.reduction.fraction)),
        ]),
      );
    });
  }

  Widget _pill(BuildContext context, Offset at, String text) {
    final p = context.palette;
    return Positioned(
      left: at.dx, top: at.dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(999), border: Border.all(color: p.track)),
          child: Text(text, style: kMono.copyWith(fontSize: 10, color: p.text)),
        ),
      ),
    );
  }
}

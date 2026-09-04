import 'package:flutter/material.dart';
import '../theme/timechain_theme.dart';

class Scrubber extends StatelessWidget {
  const Scrubber({super.key, required this.tipHeight, required this.selectedHeight, this.window = 240, required this.onChanged});
  final int tipHeight; final int? selectedHeight; final int window; final ValueChanged<int?> onChanged;

  int get _current => selectedHeight ?? tipHeight;
  int get _floor => tipHeight - window + 1;
  int get _behind => tipHeight - _current;

  void _set(int h) => onChanged(h >= tipHeight ? null : h.clamp(_floor, tipHeight));

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final frac = (_current - _floor) / (window - 1);
    Widget btn(Key key, IconData icon, VoidCallback onTap) => InkWell(key: key, onTap: onTap, borderRadius: BorderRadius.circular(12),
      child: Container(width: 44, height: 44, decoration: BoxDecoration(border: Border.all(color: p.track, width: 1.5), borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 20, color: p.text)));
    return Row(children: [
      btn(const Key('scrub-prev'), Icons.chevron_left, () => _set(_current - 1)),
      const SizedBox(width: 10),
      Expanded(child: LayoutBuilder(builder: (context, c) {
        // The GestureDetector below owns the full outer width (`outerW`) so that a drag or
        // tap starting anywhere within the visible track — including exactly at its right
        // edge — is captured. The keyed, measured track itself is inset by a couple of
        // pixels: Flutter's hit-testing treats a RenderBox's own right/bottom edge as
        // exclusive, so `tester.getRect(trackFinder).centerRight` would otherwise land
        // exactly on that box's boundary and miss it. Insetting the visual/measured track
        // inside a slightly larger hit region keeps that point strictly interior.
        final outerW = c.maxWidth;
        const inset = 2.0;
        final w = outerW - inset * 2;
        void fromDx(double dx) => _set(_floor + (((dx - inset) / w).clamp(0.0, 1.0) * (window - 1)).round());
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (d) => fromDx(d.localPosition.dx),
          onHorizontalDragUpdate: (d) => fromDx(d.localPosition.dx),
          onTapDown: (d) => fromDx(d.localPosition.dx),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: inset),
            child: SizedBox(key: const Key('scrub-track'), height: 56, child: Stack(alignment: Alignment.centerLeft, clipBehavior: Clip.none, children: [
              Positioned(left: 0, right: 0, top: 20, child: Container(height: 3, decoration: BoxDecoration(color: p.track, borderRadius: BorderRadius.circular(2)))),
              Positioned(left: 0, width: w * frac, top: 20, child: Container(height: 3, decoration: BoxDecoration(color: TimechainPalette.brandBlue, borderRadius: BorderRadius.circular(2)))),
              Positioned(left: w * frac - 13, top: 8, child: Container(width: 26, height: 26, decoration: BoxDecoration(shape: BoxShape.circle, color: p.bg, border: Border.all(color: TimechainPalette.brandBlue, width: 4)))),
              Positioned(left: 0, right: 0, top: 40, child: Text(selectedHeight == null ? 'SCRUB BLOCKS · TIP' : 'SCRUB BLOCKS · $_behind BACK', textAlign: TextAlign.center, style: kLabel.copyWith(fontSize: 9.5, letterSpacing: 1.6, color: p.muted))),
            ])),
          ),
        );
      })),
      const SizedBox(width: 10),
      btn(const Key('scrub-next'), Icons.chevron_right, () => _set(_current + 1)),
    ]);
  }
}

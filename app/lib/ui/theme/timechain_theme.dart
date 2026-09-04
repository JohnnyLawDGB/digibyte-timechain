import 'package:flutter/material.dart';

class TimechainPalette extends ThemeExtension<TimechainPalette> {
  const TimechainPalette({
    required this.bg, required this.card, required this.card2, required this.text, required this.muted,
    required this.track, required this.ring2, required this.live, required this.brightness,
  });
  final Color bg, card, card2, text, muted, track, ring2, live;
  final Brightness brightness;

  static const brandBlue = Color(0xFF0066CC);
  static const navy = Color(0xFF002352);
  static const Map<String, Color> algoColors = {
    'sha256d': Color(0xFF0066CC), 'scrypt': Color(0xFF00D4AA), 'skein': Color(0xFFF5A524),
    'qubit': Color(0xFFB45CFF), 'odocrypt': Color(0xFFFF5C7A),
  };
  static const List<String> algoOrder = ['sha256d', 'scrypt', 'skein', 'qubit', 'odocrypt'];
  static const Map<String, String> algoLabels = {
    'sha256d': 'SHA256d', 'scrypt': 'Scrypt', 'skein': 'Skein', 'qubit': 'Qubit', 'odocrypt': 'Odocrypt',
  };

  Color algo(String key) => algoColors[key] ?? muted;

  static const dark = TimechainPalette(
    bg: Color(0xFF06101F), card: Color(0xFF0B1A30), card2: Color(0xFF0F2340), text: Color(0xFFF2F6FB), muted: Color(0xFF8EA3BF),
    track: Color(0x17FFFFFF), ring2: Color(0xFFE6EDF7), live: Color(0xFF00D4AA), brightness: Brightness.dark,
  );
  static const light = TimechainPalette(
    bg: Color(0xFFF4F7FB), card: Color(0xFFFFFFFF), card2: Color(0xFFEAF0F8), text: Color(0xFF002352), muted: Color(0xFF5A6F8C),
    track: Color(0x1A002352), ring2: Color(0xFF002352), live: Color(0xFF00A688), brightness: Brightness.light,
  );

  @override
  TimechainPalette copyWith({Color? bg}) => this;
  @override
  TimechainPalette lerp(TimechainPalette? other, double t) => t < 0.5 ? this : (other ?? this);
}

ThemeData timechainTheme(TimechainPalette p) {
  final base = ThemeData(brightness: p.brightness, useMaterial3: true, fontFamily: 'SpaceGrotesk');
  return base.copyWith(
    scaffoldBackgroundColor: p.bg,
    colorScheme: base.colorScheme.copyWith(primary: TimechainPalette.brandBlue, surface: p.card, onSurface: p.text),
    textTheme: base.textTheme.apply(bodyColor: p.text, displayColor: p.text, fontFamily: 'SpaceGrotesk'),
    extensions: [p],
  );
}

extension PaletteX on BuildContext {
  TimechainPalette get palette => Theme.of(this).extension<TimechainPalette>() ?? TimechainPalette.dark;
}

/// Figures use the mono face everywhere.
const TextStyle kMono = TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.w700);
/// Small tracked-out uppercase labels.
const TextStyle kLabel = TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 1.4);

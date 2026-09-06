import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digibyte_timechain/ui/theme/timechain_theme.dart';

void main() {
  test('palettes carry the mockup colors', () {
    expect(TimechainPalette.dark.bg, const Color(0xFF06101F));
    expect(TimechainPalette.light.text, const Color(0xFF002352));
    expect(TimechainPalette.dark.algo('odocrypt'), const Color(0xFFFF5C7A));
    expect(TimechainPalette.dark.algo('unknown'), TimechainPalette.dark.muted);
  });
  test('theme uses the bundled fonts and palette background', () {
    final t = timechainTheme(TimechainPalette.dark);
    expect(t.scaffoldBackgroundColor, TimechainPalette.dark.bg);
    expect(t.textTheme.bodyMedium?.fontFamily, 'SpaceGrotesk');
    expect(t.brightness, Brightness.dark);
    expect(timechainTheme(TimechainPalette.light).brightness, Brightness.light);
  });
}

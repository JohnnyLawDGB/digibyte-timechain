import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'state/settings.dart';
import 'ui/screens/dial_screen.dart';
import 'ui/theme/timechain_theme.dart';

class TimechainApp extends ConsumerWidget {
  const TimechainApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final choice = ref.watch(settingsProvider).theme;
    final mode = switch (choice) { ThemeChoice.dark => ThemeMode.dark, ThemeChoice.light => ThemeMode.light, ThemeChoice.system => ThemeMode.system };
    // `theme` follows the chosen palette so tests can read brightness off MaterialApp.theme.
    final light = timechainTheme(TimechainPalette.light), dark = timechainTheme(TimechainPalette.dark);
    return MaterialApp(
      title: 'DigiByte Timechain',
      debugShowCheckedModeBanner: false,
      theme: mode == ThemeMode.light ? light : dark,
      darkTheme: dark,
      themeMode: mode == ThemeMode.system ? ThemeMode.system : ThemeMode.light,
      home: const DialScreen(),
    );
  }
}

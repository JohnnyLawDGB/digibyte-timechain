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
    return MaterialApp(
      title: 'DigiByte Timechain',
      debugShowCheckedModeBanner: false,
      theme: timechainTheme(TimechainPalette.light),
      darkTheme: timechainTheme(TimechainPalette.dark),
      themeMode: mode,
      home: const DialScreen(),
    );
  }
}

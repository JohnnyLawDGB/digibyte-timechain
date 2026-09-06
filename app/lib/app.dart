import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'state/providers.dart';
import 'state/settings.dart';
import 'ui/screens/dial_screen.dart';
import 'ui/theme/timechain_theme.dart';

class TimechainApp extends ConsumerStatefulWidget {
  const TimechainApp({super.key});
  @override
  ConsumerState<TimechainApp> createState() => _TimechainAppState();
}

class _TimechainAppState extends ConsumerState<TimechainApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onStateChange: _onLifecycle);
  }

  void _onLifecycle(AppLifecycleState state) {
    final resumed = state == AppLifecycleState.resumed;
    ref.read(appResumedProvider.notifier).state = resumed;
    // A backgrounded socket usually dies without telling anyone, and the
    // watchdog is only a minute quick: on resume, ask for the tip outright.
    if (resumed) unawaited(ref.read(chainRepositoryProvider).refreshNow());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

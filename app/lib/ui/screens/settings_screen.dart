import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/settings.dart';
import '../theme/timechain_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider); final n = ref.read(settingsProvider.notifier); final p = context.palette;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), backgroundColor: p.bg, foregroundColor: p.text),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('THEME', style: kLabel.copyWith(color: p.muted)), const SizedBox(height: 8),
        SegmentedButton<ThemeChoice>(
          segments: const [ButtonSegment(value: ThemeChoice.dark, label: Text('Dark')), ButtonSegment(value: ThemeChoice.light, label: Text('Light')), ButtonSegment(value: ThemeChoice.system, label: Text('System'))],
          selected: {s.theme}, onSelectionChanged: (v) => n.setTheme(v.first)),
        const SizedBox(height: 24),
        Text('FIAT', style: kLabel.copyWith(color: p.muted)), const SizedBox(height: 8),
        SegmentedButton<String>(segments: [for (final f in kFiatOptions) ButtonSegment(value: f, label: Text(f))], selected: {s.fiat}, onSelectionChanged: (v) => n.setFiat(v.first)),
        const SizedBox(height: 8),
        Text('Price is the on-chain DigiDollar oracle rate (USD).', style: TextStyle(fontSize: 12, color: p.muted)),
      ]),
    );
  }
}

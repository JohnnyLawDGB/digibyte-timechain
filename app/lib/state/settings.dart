import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeChoice { dark, light, system }

/// v1 price source is the DigiDollar oracle (USD). Other fiats need an FX feed — not in v1.
const kFiatOptions = ['USD'];

class Settings {
  const Settings({required this.theme, required this.fiat});
  final ThemeChoice theme;
  final String fiat;
  Settings copyWith({ThemeChoice? theme, String? fiat}) => Settings(theme: theme ?? this.theme, fiat: fiat ?? this.fiat);
  @override
  bool operator ==(Object other) => other is Settings && other.theme == theme && other.fiat == fiat;
  @override
  int get hashCode => Object.hash(theme, fiat);
}

final sharedPrefsProvider = Provider<SharedPreferences>((_) => throw UnimplementedError('override in main'));

class SettingsNotifier extends Notifier<Settings> {
  SharedPreferences get _p => ref.read(sharedPrefsProvider);
  @override
  Settings build() {
    final t = ThemeChoice.values.firstWhere((v) => v.name == _p.getString('theme'), orElse: () => ThemeChoice.dark);
    final f = _p.getString('fiat');
    return Settings(theme: t, fiat: kFiatOptions.contains(f) ? f! : 'USD');
  }
  void setTheme(ThemeChoice t) { _p.setString('theme', t.name); state = state.copyWith(theme: t); }
  void setFiat(String f) {
    if (!kFiatOptions.contains(f)) throw ArgumentError.value(f, 'fiat', 'unsupported');
    _p.setString('fiat', f); state = state.copyWith(fiat: f);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:digibyte_timechain/state/settings.dart';

void main() {
  test('defaults to dark/USD and persists changes', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final c = ProviderContainer(overrides: [sharedPrefsProvider.overrideWithValue(prefs)]);
    expect(c.read(settingsProvider), const Settings(theme: ThemeChoice.dark, fiat: 'USD'));
    c.read(settingsProvider.notifier).setTheme(ThemeChoice.light);
    expect(c.read(settingsProvider).theme, ThemeChoice.light);
    expect(prefs.getString('theme'), 'light');
    final c2 = ProviderContainer(overrides: [sharedPrefsProvider.overrideWithValue(prefs)]);
    expect(c2.read(settingsProvider).theme, ThemeChoice.light);
  });
  test('rejects an unsupported fiat', () async {
    SharedPreferences.setMockInitialValues({'fiat': 'EUR'});
    final prefs = await SharedPreferences.getInstance();
    final c = ProviderContainer(overrides: [sharedPrefsProvider.overrideWithValue(prefs)]);
    expect(c.read(settingsProvider).fiat, 'USD');
    expect(() => c.read(settingsProvider.notifier).setFiat('EUR'), throwsArgumentError);
  });
}

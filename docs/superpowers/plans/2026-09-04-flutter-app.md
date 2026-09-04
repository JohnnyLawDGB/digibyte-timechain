# DigiByte Timechain — Flutter App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A Flutter app for Android and iOS that renders the DigiByte chain as the dial screen in the approved mockups, fed live by `api.digiscope.me/api/chain`, with a scrubber to step back through recent blocks.

**Architecture:** Three layers under `app/lib/`: `domain/` (pure Dart: reduction schedule, ring geometry, formatters), `data/` (freezed models, REST client, SSE client with polling fallback, JSON file cache, repository), `ui/` (a CustomPainter dial, tiles, scrubber, two screens). Riverpod providers in `state/` connect them. The app never computes chain facts the backend already ships; domain math exists for the timer, ring geometry, and formatting only, plus a subsidy replica used to sanity-check the feed in tests.

**Tech Stack:** Flutter 3.29.0 / Dart 3.7.0 (verified on this box), flutter_riverpod 2.6, freezed 2.5 + json_serializable, http 1.3, path_provider, shared_preferences, intl; tests with flutter_test, mocktail, golden files.

**Spec:** `docs/superpowers/specs/2026-09-04-digibyte-timechain-design.md` (§4 dial, §6 app structure, §7 error handling, §8 testing). Backend contract: `docs/superpowers/plans/2026-09-04-chain-backend.md` "Snapshot JSON". Visual reference: `docs/mockups/2026-09-04-dial/` (dark, light, scrubbed PNGs and the generator that produced them).

## Global Constraints

- Project lives at `app/` inside this repo (`~/digibyte-timechain`). Package name `digibyte_timechain`, org `me.digiscope`, platforms `android,ios` only.
- API base URL defaults to `https://api.digiscope.me/api` and is overridable with `--dart-define=CHAIN_API_BASE=...`.
- Fee unit is **DGB/kB**, formatted to 4 significant digits (`0.1000`, `0.0011`). Never show sat/vB.
- Reduction ring label is **percent of the cycle** (`69.0%`); the block count and days estimate belong to the "Next cut" tile.
- Colors (from the mockup generator, `docs/mockups/2026-09-04-dial/gen.py`): brand blue `#0066CC`, navy `#002352`; dark: bg `#06101F`, card `#0B1A30`, card2 `#0F2340`, text `#F2F6FB`, muted `#8EA3BF`, ring2 `#E6EDF7`, live `#00D4AA`; light: bg `#F4F7FB`, card `#FFFFFF`, card2 `#EAF0F8`, text `#002352`, muted `#5A6F8C`, ring2 `#002352`, live `#00A688`. Algorithm colors: sha256d `#0066CC`, scrypt `#00D4AA`, skein `#F5A524`, qubit `#B45CFF`, odocrypt `#FF5C7A`.
- Fonts: Space Grotesk (labels/display) and JetBrains Mono (figures) bundled as assets from Google Fonts (OFL). Fallback to system fonts if the download step fails; do not block on it.
- Hit targets ≥ 44 px. No fake status bar.
- Dark theme is the default. Fiat setting exists but v1 offers USD only (the backend price is the DigiDollar oracle, USD-denominated). This is a known narrowing of spec §2 "fiat currency for the price tiles" and is flagged at handoff.
- Every task: `cd ~/digibyte-timechain/app && flutter analyze` must be clean and `flutter test` green before commit.
- Commit messages: conventional prefix, end with
  `Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>`.
- iOS build/test needs macOS; this box is Linux. Android is verified on the Samsung SM-N950U (API 28). iOS steps are written down but marked "run on the Mac".

---

## File Structure

```
app/
  pubspec.yaml
  assets/fonts/SpaceGrotesk-{Medium,Bold}.ttf, JetBrainsMono-{Medium,Bold}.ttf
  assets/brand/digibyte_symbol.svg
  lib/
    main.dart                    entry; ProviderScope; loads settings
    app.dart                     MaterialApp, theme switch, routes
    config.dart                  API base URL from dart-define
    domain/
      reduction_schedule.dart    subsidySats(height), reductionAt(height)
      ring_math.dart             angles, arc sweep, tick geometry
      formatters.dart            height, DGB, DGB/kB, billions, usd, durations
    data/
      models/chain_snapshot.dart freezed models mirroring the backend JSON
      sse_parser.dart            Stream<String> lines → Stream<SseEvent>
      sse_client.dart            reconnecting SSE over http, connection state
      chain_api.dart             GET tip / block
      snapshot_cache.dart        last tip snapshot as JSON file
      chain_repository.dart      watchTip() merge of SSE + poll fallback; fetchBlock()
    state/
      settings.dart              Settings + SettingsNotifier (shared_preferences)
      providers.dart             repository, tip stream, selected height/snapshot, clock
    ui/
      theme/timechain_theme.dart palette + ThemeData for dark/light
      dial/dial_painter.dart     CustomPainter: 4 rings + markers
      dial/dial.dart             Dial widget: painter + center readout + pills
      tiles/header_stats.dart    Reduction / Subsidy / USD per DGB
      tiles/block_timer_tile.dart seconds since block (live) or mined-at (scrubbed)
      tiles/reward_tile.dart     subsidy + fees = reward, mined by, algo badge
      tiles/fee_mempool_card.dart fee rates + mempool
      tiles/footer_stats.dart    Supply / Next cut / Market
      tiles/algo_legend.dart     five dots with 24 h share
      scrubber/scrubber.dart     prev/next + draggable track
      widgets/status_pill.dart   LIVE / VIEWING BLOCK / RECONNECTING / STALE
      screens/dial_screen.dart   composes everything
      screens/settings_screen.dart theme + currency
  test/  (mirrors lib/; goldens under test/goldens/)
```

Snapshot JSON the models parse (from the backend plan):

```json
{"height":24151710,"hash":"…","prevHash":"…","time":1788518429,"algo":"qubit","sizeBytes":7579,"txCount":4,
 "feeRate":{"unit":"DGB/kB","median":0.10003,"min":0.0011,"max":0.1102},
 "reward":{"subsidy":253.55810338,"fees":0.64499045,"total":254.20309383},
 "pool":{"tag":"m2pool.com","raw":"…"},
 "reduction":{"step":130,"cycle":175200,"blocksUntilNext":54290,"nextHeight":24206000,"fraction":0.6901},
 "supply":{"total":18457061165.39,"cap":21000000000},
 "algoShare24h":{"sha256d":0.2,"scrypt":0.2,"skein":0.2125,"qubit":0.1833,"odocrypt":0.2042,"blocksCounted":240},
 "recentBlocks":[{"height":24151710,"algo":"qubit","sizeBytes":7579,"txCount":4,"time":1788518429}],
 "mempool":{"txCount":0,"vbytes":0,"inflowVbPerSec":0,"depthBlocks":0,"fees":{"unit":"DGB/kB","priority":0.011,"anytime":0.0011},"asOf":1788519200},
 "price":{"usd":0.004692,"marketCapUsd":86600000,"asOf":1788519180,"isStale":false},
 "isTip":true}
```

SSE events: `tip` (full snapshot), `mempool` (`{"height":…,"mempool":{…},"price":{…}|null}`), `ping`.

---

### Task 1: Scaffold the project, dependencies, fonts, theme

**Files:**
- Create: `app/` via `flutter create`, `app/pubspec.yaml` (edited), `app/lib/config.dart`, `app/lib/ui/theme/timechain_theme.dart`, `app/assets/fonts/*`, `app/assets/brand/digibyte_symbol.svg`
- Test: `app/test/ui/theme/timechain_theme_test.dart`

**Interfaces:**
- Produces: `class TimechainPalette { bg, card, card2, text, muted, track, ring2, live, brandBlue, navy; static const dark; static const light; Color algo(String key) }`, `ThemeData timechainTheme(TimechainPalette p)`, `extension PaletteX on BuildContext { TimechainPalette get palette }`, `const String kApiBase`.

- [ ] **Step 1: Create the project and add dependencies**

```bash
cd ~/digibyte-timechain && flutter create --org me.digiscope --project-name digibyte_timechain --platforms android,ios app
cd app
flutter pub add flutter_riverpod:^2.6.1 freezed_annotation:^2.4.4 json_annotation:^4.9.0 http:^1.3.0 path_provider:^2.1.5 shared_preferences:^2.5.3 intl:^0.20.2 flutter_svg:^2.0.17
flutter pub add --dev build_runner:^2.4.15 freezed:^2.5.8 json_serializable:^6.9.4 mocktail:^1.0.4
rm test/widget_test.dart
```

- [ ] **Step 2: Fetch fonts and the brand symbol**

```bash
cd ~/digibyte-timechain/app && mkdir -p assets/fonts assets/brand
cp "/home/polloloco/digiscope-oracle/data/branding/digibyte-logos/Logos Vector/DigiByte Symbol.svg" assets/brand/digibyte_symbol.svg
for f in SpaceGrotesk-Medium SpaceGrotesk-Bold; do curl -fsSL -o assets/fonts/$f.ttf "https://github.com/floriankarsten/space-grotesk/raw/master/fonts/ttf/$f.ttf"; done
for f in JetBrainsMono-Medium JetBrainsMono-Bold; do curl -fsSL -o assets/fonts/$f.ttf "https://github.com/JetBrains/JetBrainsMono/raw/master/fonts/ttf/$f.ttf"; done
ls -la assets/fonts
```

If a download fails, leave that family out of `pubspec.yaml` and the theme falls back to the platform font; note it in the commit message.

- [ ] **Step 3: pubspec assets and fonts**

Under `flutter:` in `app/pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/brand/digibyte_symbol.svg
  fonts:
    - family: SpaceGrotesk
      fonts:
        - asset: assets/fonts/SpaceGrotesk-Medium.ttf
          weight: 500
        - asset: assets/fonts/SpaceGrotesk-Bold.ttf
          weight: 700
    - family: JetBrainsMono
      fonts:
        - asset: assets/fonts/JetBrainsMono-Medium.ttf
          weight: 500
        - asset: assets/fonts/JetBrainsMono-Bold.ttf
          weight: 700
```

- [ ] **Step 4: Write the failing theme test**

```dart
// app/test/ui/theme/timechain_theme_test.dart
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
```

- [ ] **Step 5: Run the test to verify it fails**

Run: `cd ~/digibyte-timechain/app && flutter test test/ui/theme/timechain_theme_test.dart`
Expected: FAIL — `timechain_theme.dart` not found.

- [ ] **Step 6: Write config and theme**

```dart
// app/lib/config.dart
/// Base URL of the DigiScope backend API. Override: --dart-define=CHAIN_API_BASE=http://10.0.2.2:3001/api
const String kApiBase = String.fromEnvironment('CHAIN_API_BASE', defaultValue: 'https://api.digiscope.me/api');
const String kExplorerBase = 'https://digiscope.me/explorer/block/';
```

```dart
// app/lib/ui/theme/timechain_theme.dart
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
```

- [ ] **Step 7: Run the test to verify it passes, analyze, commit**

Run: `cd ~/digibyte-timechain/app && flutter pub get && flutter analyze && flutter test`
Expected: analyze "No issues found!", 2 tests pass.

```bash
cd ~/digibyte-timechain && git add app && git commit -m "feat(app): scaffold Flutter project with DigiByte palette, fonts and theme

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 2: Domain — reduction schedule

**Files:**
- Create: `app/lib/domain/reduction_schedule.dart`
- Test: `app/test/domain/reduction_schedule_test.dart`

**Interfaces:**
- Produces: `class ReductionSchedule { static const periodViStart = 1430000; static const blocksPerMonth = 175200; static const supplyCap = 21000000000; static BigInt subsidySats(int height); static double subsidyDgb(int height); static Reduction at(int height); }`, `class Reduction { final int step, cycle, blocksUntilNext, nextHeight; final double fraction; }`.

- [ ] **Step 1: Write the failing test**

```dart
// app/test/domain/reduction_schedule_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:digibyte_timechain/domain/reduction_schedule.dart';

void main() {
  group('subsidySats — Core Period VI replica', () {
    test('matches the live node at 24,151,775', () {
      expect(ReductionSchedule.subsidySats(24151775), BigInt.from(25355810338));
    });
    test('steps down on the cycle boundary', () {
      expect(ReductionSchedule.subsidySats(24205999), BigInt.from(25355810338));
      expect(ReductionSchedule.subsidySats(24206000), BigInt.from(25072839494));
    });
    test('refuses pre-Period-VI heights', () {
      expect(() => ReductionSchedule.subsidySats(1429999), throwsRangeError);
    });
    test('subsidyDgb', () {
      expect(ReductionSchedule.subsidyDgb(24151775), closeTo(253.55810338, 1e-8));
    });
  });
  group('at', () {
    test('step 130, 54,225 blocks to go at 24,151,775', () {
      final r = ReductionSchedule.at(24151775);
      expect(r.step, 130); expect(r.cycle, 175200); expect(r.blocksUntilNext, 54225);
      expect(r.nextHeight, 24206000); expect(r.fraction, closeTo(0.6905, 1e-4));
    });
    test('origin is step 1 with fraction 0', () {
      expect(ReductionSchedule.at(1430000).step, 1);
      expect(ReductionSchedule.at(1430000).fraction, 0);
    });
  });
}
```

- [ ] **Step 2: Run it to verify it fails**

Run: `cd ~/digibyte-timechain/app && flutter test test/domain/reduction_schedule_test.dart`
Expected: FAIL — file not found.

- [ ] **Step 3: Implement**

```dart
// app/lib/domain/reduction_schedule.dart
/// DigiByte Core `GetBlockSubsidy` Period VI (height >= 1,430,000), replicated
/// exactly with BigInt so integer truncation matches the C++.
/// Verified 2026-09-04: 24,151,775 → 25,355,810,338 sats; 24,206,000 → 25,072,839,494.
class Reduction {
  const Reduction({required this.step, required this.cycle, required this.blocksUntilNext, required this.nextHeight, required this.fraction});
  final int step, cycle, blocksUntilNext, nextHeight;
  final double fraction;
}

class ReductionSchedule {
  ReductionSchedule._();
  static const int periodViStart = 1430000;
  static const int blockTimeSeconds = 15;
  static const int secondsPerMonth = 2628000; // 60*60*24*365 ~/ 12
  static const int blocksPerMonth = secondsPerMonth ~/ blockTimeSeconds; // 175200
  static const int supplyCap = 21000000000;
  static final BigInt _coin = BigInt.from(100000000);

  static BigInt subsidySats(int height) {
    if (height < periodViStart) throw RangeError.value(height, 'height', 'Period VI only (>= $periodViStart)');
    var n = (BigInt.from(2157) * _coin) ~/ BigInt.two;
    final months = ((height - periodViStart) * blockTimeSeconds) ~/ secondsPerMonth;
    for (var i = 0; i < months; i++) {
      n = (n * BigInt.from(98884)) ~/ BigInt.from(100000);
    }
    return n < _coin ? BigInt.zero : n;
  }

  static double subsidyDgb(int height) => subsidySats(height).toDouble() / 1e8;

  static Reduction at(int height) {
    if (height < periodViStart) throw RangeError.value(height, 'height', 'Period VI only (>= $periodViStart)');
    final n = height - periodViStart;
    final months = n ~/ blocksPerMonth;
    final next = periodViStart + (months + 1) * blocksPerMonth;
    return Reduction(step: months + 1, cycle: blocksPerMonth, blocksUntilNext: next - height, nextHeight: next, fraction: (n % blocksPerMonth) / blocksPerMonth);
  }
}
```

- [ ] **Step 4: Run to verify it passes, commit**

Run: `cd ~/digibyte-timechain/app && flutter test test/domain/reduction_schedule_test.dart && flutter analyze`
Expected: 6 tests pass, no issues.

```bash
cd ~/digibyte-timechain && git add app/lib/domain/reduction_schedule.dart app/test/domain/reduction_schedule_test.dart && git commit -m "feat(app): exact Period VI subsidy and reduction-cycle replica

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 3: Domain — ring math and formatters

**Files:**
- Create: `app/lib/domain/ring_math.dart`, `app/lib/domain/formatters.dart`
- Test: `app/test/domain/ring_math_test.dart`, `app/test/domain/formatters_test.dart`

**Interfaces:**
- Produces (`ring_math.dart`): `const double kStartAngle = -pi / 2;` `double sweepFor(double fraction)` (radians, clamped to [0, 2π)), `Offset pointOnCircle(Offset center, double radius, double angle)`, `double tickAngle(int index, int count)` (index 0 at 12 o'clock, clockwise), `double tickLength(int sizeBytes, {double min = 4, double max = 14, int fullBytes = 8000})`, `List<ArcSpan> algoArcs(Map<String, double> shares, List<String> order)` where `ArcSpan { String key; double start; double sweep; }`.
- Produces (`formatters.dart`): `String fmtHeight(int)` → `24,151,775`; `String fmtDgb(double, {int decimals = 2})` → `253.56`; `String fmtFeeDgbPerKb(double?)` → `0.1000` / `0.0011` / `—`; `String fmtBillions(double?)` → `18.46B` / `—`; `String fmtPercent(double, {int decimals = 1})` → `69.0%`; `String fmtUsdPrice(double?)` → `0.00469` / `—`; `String fmtUsdCompact(double?)` → `$86.6M` / `—`; `String fmtDgbPerUsd(double?)` → `213`; `String fmtDaysFromBlocks(int)` → `~9.4 days`; `String fmtElapsed(Duration)` → `9s`, `1m 08s`, `2h 05m`; `String fmtUtcTime(int unix)` → `10:40`; `String fmtUtcTimeSec(int unix)` → `10:40:29`; `String fmtUtcDate(int unix)` → `Sep 4, 2026`; `String fmtWeekday(int unix)` → `FRIDAY`.

- [ ] **Step 1: Write the failing tests**

```dart
// app/test/domain/ring_math_test.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:digibyte_timechain/domain/ring_math.dart';

void main() {
  test('sweepFor clamps and scales', () {
    expect(sweepFor(0), 0);
    expect(sweepFor(0.5), closeTo(pi, 1e-9));
    expect(sweepFor(1.0), closeTo(2 * pi - 1e-6, 1e-5));
    expect(sweepFor(-1), 0);
  });
  test('pointOnCircle from 12 o clock', () {
    final p = pointOnCircle(const Offset(170, 170), 100, kStartAngle);
    expect(p.dx, closeTo(170, 1e-9)); expect(p.dy, closeTo(70, 1e-9));
  });
  test('tickAngle: index 0 at 12 o clock, clockwise, 240 ticks = 1.5° each', () {
    expect(tickAngle(0, 240), closeTo(kStartAngle, 1e-9));
    expect(tickAngle(60, 240), closeTo(kStartAngle + pi / 2, 1e-9));
  });
  test('tickLength grows with sqrt of size and clamps', () {
    expect(tickLength(0), 4);
    expect(tickLength(8000), 14);
    expect(tickLength(2000), closeTo(9, 1e-9));
    expect(tickLength(1000000), 14);
  });
  test('algoArcs lays five spans end to end in order', () {
    final arcs = algoArcs({'a': 0.5, 'b': 0.25, 'c': 0.25}, ['a', 'b', 'c']);
    expect(arcs.map((a) => a.key), ['a', 'b', 'c']);
    expect(arcs[0].start, closeTo(kStartAngle, 1e-9));
    expect(arcs[1].start, closeTo(kStartAngle + pi, 1e-9));
    expect(arcs[2].sweep, closeTo(pi / 2, 1e-9));
    expect(algoArcs({}, ['a']), isEmpty);
  });
}
```

```dart
// app/test/domain/formatters_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:digibyte_timechain/domain/formatters.dart';

void main() {
  test('heights and DGB', () {
    expect(fmtHeight(24151775), '24,151,775');
    expect(fmtDgb(253.55810338), '253.56');
    expect(fmtDgb(0.64499045, decimals: 3), '0.645');
  });
  test('fees in DGB/kB to 4 significant digits, dash when unknown', () {
    expect(fmtFeeDgbPerKb(0.10003), '0.1000');
    expect(fmtFeeDgbPerKb(0.0011), '0.001100');
    expect(fmtFeeDgbPerKb(0.011), '0.01100');
    expect(fmtFeeDgbPerKb(null), '—');
  });
  test('supply, percent, price, market cap', () {
    expect(fmtBillions(18457077640.5), '18.46B');
    expect(fmtBillions(null), '—');
    expect(fmtPercent(0.6905), '69.0%');
    expect(fmtPercent(0.8789, decimals: 2), '87.89%');
    expect(fmtUsdPrice(0.004692), '0.00469');
    expect(fmtUsdPrice(null), '—');
    expect(fmtUsdCompact(86638859), '\$86.6M');
    expect(fmtUsdCompact(1234567890), '\$1.23B');
    expect(fmtDgbPerUsd(0.004692), '213');
  });
  test('durations', () {
    expect(fmtDaysFromBlocks(54225), '~9.4 days');
    expect(fmtElapsed(const Duration(seconds: 9)), '9s');
    expect(fmtElapsed(const Duration(seconds: 68)), '1m 08s');
    expect(fmtElapsed(const Duration(hours: 2, minutes: 5)), '2h 05m');
  });
  test('UTC time and date', () {
    expect(fmtUtcTime(1788518429), '10:40');
    expect(fmtUtcTimeSec(1788518429), '10:40:29');
    expect(fmtUtcDate(1788518429), 'Sep 4, 2026');
    expect(fmtWeekday(1788518429), 'FRIDAY');
  });
}
```

- [ ] **Step 2: Run to verify they fail**

Run: `cd ~/digibyte-timechain/app && flutter test test/domain/`
Expected: two files fail to compile (missing imports).

- [ ] **Step 3: Implement**

```dart
// app/lib/domain/ring_math.dart
import 'dart:math';
import 'dart:ui';

/// 12 o'clock in Flutter's canvas angle convention.
const double kStartAngle = -pi / 2;

/// Sweep angle for a fraction of a full turn, clamped so a full ring still draws as an arc.
double sweepFor(double fraction) => (fraction.clamp(0.0, 1.0) * 2 * pi).clamp(0.0, 2 * pi - 1e-6);

Offset pointOnCircle(Offset center, double radius, double angle) =>
    Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));

/// Angle of tick [index] out of [count], index 0 at 12 o'clock, clockwise.
double tickAngle(int index, int count) => kStartAngle + (2 * pi) * (index / count);

/// Tick length grows with the square root of block size: 4 px empty → 14 px at [fullBytes].
double tickLength(int sizeBytes, {double min = 4, double max = 14, int fullBytes = 8000}) {
  final f = sqrt(sizeBytes / fullBytes).clamp(0.0, 1.0);
  return min + (max - min) * f;
}

class ArcSpan {
  const ArcSpan(this.key, this.start, this.sweep);
  final String key;
  final double start, sweep;
}

/// Consecutive arcs, one per key in [order], sized by [shares] (fractions summing to ≤ 1).
List<ArcSpan> algoArcs(Map<String, double> shares, List<String> order) {
  var a = kStartAngle;
  final out = <ArcSpan>[];
  for (final k in order) {
    final f = shares[k];
    if (f == null) continue;
    final s = sweepFor(f);
    out.add(ArcSpan(k, a, s));
    a += s;
  }
  return out;
}
```

```dart
// app/lib/domain/formatters.dart
import 'package:intl/intl.dart';

final _int = NumberFormat('#,##0', 'en_US');
const _dash = '—';

String fmtHeight(int h) => _int.format(h);
String fmtDgb(double v, {int decimals = 2}) => NumberFormat('#,##0.${'0' * decimals}', 'en_US').format(v);

/// DGB/kB to 4 significant digits (0.1000, 0.01100, 0.001100).
String fmtFeeDgbPerKb(double? v) {
  if (v == null || v <= 0) return _dash;
  final s = v.toStringAsPrecision(4);
  return s.contains('e') ? v.toStringAsFixed(6) : s;
}

String fmtBillions(double? v) => v == null ? _dash : '${(v / 1e9).toStringAsFixed(2)}B';
String fmtPercent(double f, {int decimals = 1}) => '${(f * 100).toStringAsFixed(decimals)}%';
String fmtUsdPrice(double? usd) => usd == null || usd <= 0 ? _dash : usd.toStringAsPrecision(3);
String fmtDgbPerUsd(double? usd) => usd == null || usd <= 0 ? _dash : _int.format((1 / usd).round());

String fmtUsdCompact(double? v) {
  if (v == null || v <= 0) return _dash;
  if (v >= 1e9) return '\$${(v / 1e9).toStringAsFixed(2)}B';
  if (v >= 1e6) return '\$${(v / 1e6).toStringAsFixed(1)}M';
  if (v >= 1e3) return '\$${(v / 1e3).toStringAsFixed(1)}K';
  return '\$${v.toStringAsFixed(0)}';
}

String fmtDaysFromBlocks(int blocks) => '~${(blocks * 15 / 86400).toStringAsFixed(1)} days';

String fmtElapsed(Duration d) {
  final s = d.inSeconds;
  if (s < 60) return '${s}s';
  if (s < 3600) return '${s ~/ 60}m ${(s % 60).toString().padLeft(2, '0')}s';
  return '${s ~/ 3600}h ${((s % 3600) ~/ 60).toString().padLeft(2, '0')}m';
}

DateTime _utc(int unix) => DateTime.fromMillisecondsSinceEpoch(unix * 1000, isUtc: true);
String fmtUtcTime(int unix) => DateFormat('HH:mm', 'en_US').format(_utc(unix));
String fmtUtcTimeSec(int unix) => DateFormat('HH:mm:ss', 'en_US').format(_utc(unix));
String fmtUtcDate(int unix) => DateFormat('MMM d, y', 'en_US').format(_utc(unix));
String fmtWeekday(int unix) => DateFormat('EEEE', 'en_US').format(_utc(unix)).toUpperCase();
```

- [ ] **Step 4: Run to verify they pass, commit**

Run: `cd ~/digibyte-timechain/app && flutter test test/domain/ && flutter analyze`
Expected: 11 tests pass, no issues.

```bash
cd ~/digibyte-timechain && git add app/lib/domain app/test/domain && git commit -m "feat(app): ring geometry and display formatters

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 4: Data — freezed models

**Files:**
- Create: `app/lib/data/models/chain_snapshot.dart` (+ generated `.freezed.dart`, `.g.dart`)
- Create: `app/test/fixtures/tip.json`, `app/test/fixtures/block.json`, `app/test/fixtures/fixtures.dart`
- Test: `app/test/data/models/chain_snapshot_test.dart`

**Interfaces:**
- Produces: `ChainSnapshot`, `FeeRate`, `Reward`, `PoolInfo`, `ReductionInfo`, `SupplyInfo`, `AlgoShare` (with `double share(String key)` and `Map<String,double> asMap`), `BlockRef`, `MempoolInfo`, `FeeEstimates`, `PriceInfo`, `MempoolPatch` (`{height, mempool, price}`), each with `fromJson`/`toJson`; `ChainSnapshot.withPatch(MempoolPatch)`.

- [ ] **Step 1: Fixtures**

```json
// app/test/fixtures/tip.json  (real mainnet block 24,151,775 + sample mempool/price)
{"height":24151775,"hash":"000000000000000e1f","prevHash":"000000000000000e1e","time":1788519180,"algo":"odocrypt","sizeBytes":386,"txCount":1,
 "feeRate":null,
 "reward":{"subsidy":253.55810338,"fees":0,"total":253.55810338},
 "pool":{"tag":"m2pool.com","raw":"/m2pool.com/"},
 "reduction":{"step":130,"cycle":175200,"blocksUntilNext":54225,"nextHeight":24206000,"fraction":0.6905},
 "supply":{"total":18457077640.5,"cap":21000000000},
 "algoShare24h":{"sha256d":0.2,"scrypt":0.2,"skein":0.2125,"qubit":0.1833,"odocrypt":0.2042,"blocksCounted":240},
 "recentBlocks":[{"height":24151775,"algo":"odocrypt","sizeBytes":386,"txCount":1,"time":1788519180},{"height":24151774,"algo":"qubit","sizeBytes":281,"txCount":1,"time":1788519110}],
 "mempool":{"txCount":0,"vbytes":0,"inflowVbPerSec":0,"depthBlocks":0,"fees":{"unit":"DGB/kB","priority":0.011,"anytime":0.0011},"asOf":1788519200},
 "price":{"usd":0.004692,"marketCapUsd":86600608,"asOf":1788519180,"isStale":false},
 "isTip":true}
```

```json
// app/test/fixtures/block.json  (real mainnet block 24,151,710)
{"height":24151710,"hash":"000000000000000d00","prevHash":"000000000000000cff","time":1788518429,"algo":"qubit","sizeBytes":7579,"txCount":4,
 "feeRate":{"unit":"DGB/kB","median":0.10003,"min":0.0011,"max":0.1102},
 "reward":{"subsidy":253.55810338,"fees":0.64499045,"total":254.20309383},
 "pool":{"tag":"m2pool.com","raw":"/m2pool.com/"},
 "reduction":{"step":130,"cycle":175200,"blocksUntilNext":54290,"nextHeight":24206000,"fraction":0.6901},
 "supply":{"total":18457061165.39,"cap":21000000000},
 "algoShare24h":{"sha256d":0.2,"scrypt":0.2,"skein":0.2125,"qubit":0.1833,"odocrypt":0.2042,"blocksCounted":240},
 "recentBlocks":[{"height":24151710,"algo":"qubit","sizeBytes":7579,"txCount":4,"time":1788518429}],
 "isTip":false}
```

```dart
// app/test/fixtures/fixtures.dart
import 'dart:convert';
import 'dart:io';
import 'package:digibyte_timechain/data/models/chain_snapshot.dart';

String fixtureText(String name) => File('test/fixtures/$name').readAsStringSync();
Map<String, dynamic> fixtureJson(String name) => jsonDecode(fixtureText(name)) as Map<String, dynamic>;
ChainSnapshot tipFixture() => ChainSnapshot.fromJson(fixtureJson('tip.json'));
ChainSnapshot blockFixture() => ChainSnapshot.fromJson(fixtureJson('block.json'));
```

- [ ] **Step 2: Write the failing test**

```dart
// app/test/data/models/chain_snapshot_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:digibyte_timechain/data/models/chain_snapshot.dart';
import '../../fixtures/fixtures.dart';

void main() {
  test('parses the tip snapshot', () {
    final s = tipFixture();
    expect(s.height, 24151775); expect(s.algo, 'odocrypt'); expect(s.isTip, isTrue);
    expect(s.feeRate, isNull);
    expect(s.reward.total, closeTo(253.55810338, 1e-8));
    expect(s.pool.tag, 'm2pool.com');
    expect(s.reduction.blocksUntilNext, 54225);
    expect(s.supply.total, closeTo(18457077640.5, 1e-3)); expect(s.supply.cap, 21000000000);
    expect(s.algoShare24h.share('skein'), closeTo(0.2125, 1e-9));
    expect(s.algoShare24h.asMap.keys, ['sha256d', 'scrypt', 'skein', 'qubit', 'odocrypt']);
    expect(s.recentBlocks.first.height, 24151775);
    expect(s.mempool!.fees.priority, closeTo(0.011, 1e-9));
    expect(s.price!.usd, closeTo(0.004692, 1e-9));
  });
  test('parses a scrubbed block without mempool/price and with a fee band', () {
    final b = blockFixture();
    expect(b.isTip, isFalse); expect(b.mempool, isNull); expect(b.price, isNull);
    expect(b.feeRate!.median, closeTo(0.10003, 1e-9)); expect(b.feeRate!.unit, 'DGB/kB');
  });
  test('tolerates a null supply total and missing price', () {
    final j = fixtureJson('tip.json')..['supply'] = {'total': null, 'cap': 21000000000}..['price'] = null;
    final s = ChainSnapshot.fromJson(j);
    expect(s.supply.total, isNull); expect(s.price, isNull);
  });
  test('withPatch replaces mempool and price only', () {
    final s = tipFixture();
    final p = MempoolPatch.fromJson({'height': 24151775, 'mempool': {'txCount': 7, 'vbytes': 900, 'inflowVbPerSec': 12.5, 'depthBlocks': 0.0, 'fees': {'unit': 'DGB/kB', 'priority': null, 'anytime': null}, 'asOf': 1}, 'price': null});
    final s2 = s.withPatch(p);
    expect(s2.mempool!.txCount, 7); expect(s2.mempool!.fees.priority, isNull); expect(s2.price, isNull);
    expect(s2.height, s.height); expect(s2.recentBlocks, s.recentBlocks);
  });
  test('round-trips through toJson', () {
    final s = tipFixture();
    expect(ChainSnapshot.fromJson(s.toJson()), s);
  });
}
```

- [ ] **Step 3: Run to verify it fails**

Run: `cd ~/digibyte-timechain/app && flutter test test/data/models/chain_snapshot_test.dart`
Expected: FAIL — model file missing.

- [ ] **Step 4: Write the models and generate**

```dart
// app/lib/data/models/chain_snapshot.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chain_snapshot.freezed.dart';
part 'chain_snapshot.g.dart';

@freezed
class FeeRate with _$FeeRate {
  const factory FeeRate({required String unit, required double median, required double min, required double max}) = _FeeRate;
  factory FeeRate.fromJson(Map<String, dynamic> json) => _$FeeRateFromJson(json);
}

@freezed
class Reward with _$Reward {
  const factory Reward({required double subsidy, required double fees, required double total}) = _Reward;
  factory Reward.fromJson(Map<String, dynamic> json) => _$RewardFromJson(json);
}

@freezed
class PoolInfo with _$PoolInfo {
  const factory PoolInfo({String? tag, String? raw}) = _PoolInfo;
  factory PoolInfo.fromJson(Map<String, dynamic> json) => _$PoolInfoFromJson(json);
}

@freezed
class ReductionInfo with _$ReductionInfo {
  const factory ReductionInfo({required int step, required int cycle, required int blocksUntilNext, required int nextHeight, required double fraction}) = _ReductionInfo;
  factory ReductionInfo.fromJson(Map<String, dynamic> json) => _$ReductionInfoFromJson(json);
}

@freezed
class SupplyInfo with _$SupplyInfo {
  const factory SupplyInfo({double? total, required double cap}) = _SupplyInfo;
  factory SupplyInfo.fromJson(Map<String, dynamic> json) => _$SupplyInfoFromJson(json);
}

@freezed
class AlgoShare with _$AlgoShare {
  const AlgoShare._();
  const factory AlgoShare({
    @Default(0) double sha256d, @Default(0) double scrypt, @Default(0) double skein,
    @Default(0) double qubit, @Default(0) double odocrypt, @Default(0) int blocksCounted,
  }) = _AlgoShare;
  factory AlgoShare.fromJson(Map<String, dynamic> json) => _$AlgoShareFromJson(json);

  Map<String, double> get asMap => {'sha256d': sha256d, 'scrypt': scrypt, 'skein': skein, 'qubit': qubit, 'odocrypt': odocrypt};
  double share(String key) => asMap[key] ?? 0;
}

@freezed
class BlockRef with _$BlockRef {
  const factory BlockRef({required int height, required String algo, required int sizeBytes, required int txCount, required int time}) = _BlockRef;
  factory BlockRef.fromJson(Map<String, dynamic> json) => _$BlockRefFromJson(json);
}

@freezed
class FeeEstimates with _$FeeEstimates {
  const factory FeeEstimates({required String unit, double? priority, double? anytime}) = _FeeEstimates;
  factory FeeEstimates.fromJson(Map<String, dynamic> json) => _$FeeEstimatesFromJson(json);
}

@freezed
class MempoolInfo with _$MempoolInfo {
  const factory MempoolInfo({required int txCount, required int vbytes, required double inflowVbPerSec, required double depthBlocks, required FeeEstimates fees, required int asOf}) = _MempoolInfo;
  factory MempoolInfo.fromJson(Map<String, dynamic> json) => _$MempoolInfoFromJson(json);
}

@freezed
class PriceInfo with _$PriceInfo {
  const factory PriceInfo({required double usd, double? marketCapUsd, required int asOf, @Default(false) bool isStale}) = _PriceInfo;
  factory PriceInfo.fromJson(Map<String, dynamic> json) => _$PriceInfoFromJson(json);
}

@freezed
class MempoolPatch with _$MempoolPatch {
  const factory MempoolPatch({int? height, MempoolInfo? mempool, PriceInfo? price}) = _MempoolPatch;
  factory MempoolPatch.fromJson(Map<String, dynamic> json) => _$MempoolPatchFromJson(json);
}

@freezed
class ChainSnapshot with _$ChainSnapshot {
  const ChainSnapshot._();
  const factory ChainSnapshot({
    required int height, required String hash, String? prevHash, required int time,
    required String algo, required int sizeBytes, required int txCount,
    FeeRate? feeRate, required Reward reward, required PoolInfo pool,
    required ReductionInfo reduction, required SupplyInfo supply, required AlgoShare algoShare24h,
    required List<BlockRef> recentBlocks, MempoolInfo? mempool, PriceInfo? price,
    @Default(false) bool isTip,
  }) = _ChainSnapshot;
  factory ChainSnapshot.fromJson(Map<String, dynamic> json) => _$ChainSnapshotFromJson(json);

  ChainSnapshot withPatch(MempoolPatch p) => copyWith(mempool: p.mempool, price: p.price);
}
```

Generate: `cd ~/digibyte-timechain/app && dart run build_runner build --delete-conflicting-outputs`

`json_serializable` needs `int` fields to be ints in JSON; the backend emits `depthBlocks`/`inflowVbPerSec` as numbers that may serialize as `0` — `double` fields accept ints in Dart JSON decoding via `(json['x'] as num).toDouble()`, which json_serializable generates automatically. If `flutter analyze` complains about the generated files, add `analyzer: exclude: ['**/*.g.dart', '**/*.freezed.dart']` to `analysis_options.yaml`.

- [ ] **Step 5: Run to verify it passes, commit**

Run: `cd ~/digibyte-timechain/app && flutter test test/data/models/ && flutter analyze`
Expected: 5 tests pass.

```bash
cd ~/digibyte-timechain && git add app/lib/data/models app/test/data/models app/test/fixtures app/analysis_options.yaml && git commit -m "feat(app): freezed models for the /api/chain snapshot contract

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 5: Data — SSE parser and reconnecting client

**Files:**
- Create: `app/lib/data/sse_parser.dart`, `app/lib/data/sse_client.dart`
- Test: `app/test/data/sse_parser_test.dart`, `app/test/data/sse_client_test.dart`

**Interfaces:**
- Produces: `class SseEvent { final String event; final String data; }`, `Stream<SseEvent> parseSse(Stream<String> lines)`; `enum SseState { connecting, connected, disconnected }`; `abstract class SseSource { Stream<SseEvent> get events; ValueListenable<SseState> get state; void close(); }`; `class SseClient implements SseSource { SseClient({required Uri uri, http.Client Function()? clientFactory, Duration minBackoff = 1s, Duration maxBackoff = 30s, Duration? Function(int attempt)? backoff}); }`.

- [ ] **Step 1: Write the failing tests**

```dart
// app/test/data/sse_parser_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:digibyte_timechain/data/sse_parser.dart';

void main() {
  test('groups event/data lines into events on the blank line', () async {
    final lines = Stream.fromIterable(['event: tip', 'data: {"h":1}', '', 'event: ping', 'data: {"t":2}', '', ': comment', 'data: no-event', '']);
    final out = await parseSse(lines).toList();
    expect(out.map((e) => '${e.event}|${e.data}'), ['tip|{"h":1}', 'ping|{"t":2}', 'message|no-event']);
  });
  test('joins multi-line data with newlines and tolerates CR', () async {
    final out = await parseSse(Stream.fromIterable(['data: a\r', 'data: b', '', ''])).toList();
    expect(out.single.data, 'a\nb');
  });
}
```

```dart
// app/test/data/sse_client_test.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:digibyte_timechain/data/sse_client.dart';

/// One scripted connection: a list of frames, then EOF (or an error if [fail]).
http.Client scripted(List<List<String>> connections, {List<bool>? fail, void Function(int)? onConnect}) {
  var n = 0;
  return MockClient.streaming((req, body) async {
    final i = n++;
    onConnect?.call(i);
    if (fail != null && i < fail.length && fail[i]) throw http.ClientException('refused');
    final frames = i < connections.length ? connections[i] : const <String>[];
    final ctrl = StreamController<List<int>>();
    Future(() async { for (final f in frames) { ctrl.add(utf8.encode(f)); await Future<void>.delayed(const Duration(milliseconds: 5)); } await ctrl.close(); });
    return http.StreamedResponse(ctrl.stream, 200, headers: {'content-type': 'text/event-stream'});
  });
}

void main() {
  test('emits parsed events and reports connected/disconnected', () async {
    final states = <SseState>[];
    final client = SseClient(uri: Uri.parse('http://x/stream'), clientFactory: () => scripted([['event: tip\ndata: {"height":1}\n\n', 'event: ping\ndata: {}\n\n']]), backoff: (_) => null);
    client.state.addListener(() => states.add(client.state.value));
    final events = await client.events.take(2).toList();
    expect(events.first.event, 'tip'); expect(events.first.data, '{"height":1}');
    expect(states.first, SseState.connecting); expect(states, contains(SseState.connected));
    client.close();
  });
  test('reconnects after EOF and after a connection error with backoff', () async {
    final attempts = <int>[]; final delays = <int>[];
    final client = SseClient(
      uri: Uri.parse('http://x/stream'),
      clientFactory: () => scripted([[], ['event: tip\ndata: {"height":2}\n\n']], fail: [true, false], onConnect: attempts.add),
      backoff: (attempt) { delays.add(attempt); return attempt < 3 ? const Duration(milliseconds: 1) : null; },
    );
    final e = await client.events.first;
    expect(e.data, '{"height":2}');
    expect(attempts, [0, 1]);
    expect(delays, [1]);
    client.close();
  });
  test('close() ends the stream and stops reconnecting', () async {
    var connects = 0;
    final client = SseClient(uri: Uri.parse('http://x/stream'), clientFactory: () => scripted([[]], onConnect: (_) => connects++), backoff: (_) => const Duration(milliseconds: 1));
    final sub = client.events.listen((_) {});
    await Future<void>.delayed(const Duration(milliseconds: 20));
    client.close();
    final before = connects;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(connects, before);
    expect(client.state.value, SseState.disconnected);
    await sub.cancel();
  });
}
```

- [ ] **Step 2: Run to verify they fail**

Run: `cd ~/digibyte-timechain/app && flutter test test/data/sse_parser_test.dart test/data/sse_client_test.dart`
Expected: FAIL — missing files.

- [ ] **Step 3: Implement**

```dart
// app/lib/data/sse_parser.dart
class SseEvent {
  const SseEvent(this.event, this.data);
  final String event;
  final String data;
  @override
  String toString() => 'SseEvent($event, $data)';
}

/// Minimal text/event-stream parser over a stream of lines (CR/LF already split).
Stream<SseEvent> parseSse(Stream<String> lines) async* {
  var event = 'message';
  final data = <String>[];
  await for (final raw in lines) {
    final line = raw.endsWith('\r') ? raw.substring(0, raw.length - 1) : raw;
    if (line.isEmpty) {
      if (data.isNotEmpty) yield SseEvent(event, data.join('\n'));
      event = 'message'; data.clear();
      continue;
    }
    if (line.startsWith(':')) continue;
    final idx = line.indexOf(':');
    final field = idx < 0 ? line : line.substring(0, idx);
    var value = idx < 0 ? '' : line.substring(idx + 1);
    if (value.startsWith(' ')) value = value.substring(1);
    if (field == 'event') event = value;
    if (field == 'data') data.add(value);
  }
  if (data.isNotEmpty) yield SseEvent(event, data.join('\n'));
}
```

```dart
// app/lib/data/sse_client.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'sse_parser.dart';

export 'sse_parser.dart' show SseEvent;

enum SseState { connecting, connected, disconnected }

abstract class SseSource {
  Stream<SseEvent> get events;
  ValueListenable<SseState> get state;
  void close();
}

/// Reconnecting SSE client. [backoff] returns the delay before attempt N
/// (N starts at 1 after the first failure) or null to stop retrying.
class SseClient implements SseSource {
  SseClient({required this.uri, http.Client Function()? clientFactory, Duration? Function(int attempt)? backoff})
      : _clientFactory = clientFactory ?? http.Client.new,
        _backoff = backoff ?? defaultBackoff;

  final Uri uri;
  final http.Client Function() _clientFactory;
  final Duration? Function(int attempt) _backoff;
  final _state = ValueNotifier<SseState>(SseState.disconnected);
  StreamController<SseEvent>? _ctrl;
  http.Client? _client;
  var _closed = false;

  /// 1 s → 30 s exponential, forever.
  static Duration? defaultBackoff(int attempt) => Duration(seconds: min(30, pow(2, attempt - 1).toInt()));

  @override
  ValueListenable<SseState> get state => _state;

  @override
  Stream<SseEvent> get events {
    _ctrl ??= StreamController<SseEvent>.broadcast(onListen: _run, onCancel: close);
    return _ctrl!.stream;
  }

  Future<void> _run() async {
    var attempt = 0;
    while (!_closed) {
      _state.value = SseState.connecting;
      try {
        _client = _clientFactory();
        final res = await _client!.send(http.Request('GET', uri)..headers['Accept'] = 'text/event-stream');
        if (res.statusCode != 200) throw http.ClientException('HTTP ${res.statusCode}', uri);
        _state.value = SseState.connected;
        attempt = 0;
        await for (final e in parseSse(res.stream.transform(utf8.decoder).transform(const LineSplitter()))) {
          if (_closed) break;
          _ctrl?.add(e);
        }
      } catch (_) {
        // fall through to reconnect
      } finally {
        _client?.close(); _client = null;
      }
      if (_closed) break;
      _state.value = SseState.disconnected;
      final delay = _backoff(++attempt);
      if (delay == null) break;
      await Future<void>.delayed(delay);
    }
    _state.value = SseState.disconnected;
  }

  @override
  void close() {
    _closed = true;
    _client?.close();
    _state.value = SseState.disconnected;
    final c = _ctrl; _ctrl = null;
    if (c != null && !c.isClosed) c.close();
  }
}
```

- [ ] **Step 4: Run to verify they pass, commit**

Run: `cd ~/digibyte-timechain/app && flutter test test/data/ && flutter analyze`
Expected: 10 tests pass, no issues.

```bash
cd ~/digibyte-timechain && git add app/lib/data/sse_parser.dart app/lib/data/sse_client.dart app/test/data/sse_parser_test.dart app/test/data/sse_client_test.dart && git commit -m "feat(app): SSE parser and reconnecting client with backoff

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 6: Data — REST client and snapshot cache

**Files:**
- Create: `app/lib/data/chain_api.dart`, `app/lib/data/snapshot_cache.dart`
- Test: `app/test/data/chain_api_test.dart`, `app/test/data/snapshot_cache_test.dart`

**Interfaces:**
- Produces: `class ChainApi { ChainApi({required Uri base, http.Client? client}); Uri get streamUri; Future<ChainSnapshot> fetchTip(); Future<ChainSnapshot> fetchBlock(int height); }` throwing `ChainApiException(statusCode, message)`; `class BlockNotFound extends ChainApiException`; `class ChainWarmingUp extends ChainApiException`.
- Produces: `class SnapshotCache { SnapshotCache(Directory dir); Future<ChainSnapshot?> load(); Future<void> save(ChainSnapshot s); }` storing `tip.json`.

- [ ] **Step 1: Write the failing tests**

```dart
// app/test/data/chain_api_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:digibyte_timechain/data/chain_api.dart';
import '../fixtures/fixtures.dart';

void main() {
  ChainApi api(Map<String, http.Response Function()> routes) => ChainApi(
    base: Uri.parse('https://api.example/api'),
    client: MockClient((req) async => (routes[req.url.path] ?? () => http.Response('nope', 404))()),
  );

  test('fetchTip and fetchBlock parse snapshots from the right paths', () async {
    final a = api({'/api/chain/tip': () => http.Response(fixtureText('tip.json'), 200), '/api/chain/block/24151710': () => http.Response(fixtureText('block.json'), 200)});
    expect((await a.fetchTip()).height, 24151775);
    expect((await a.fetchBlock(24151710)).feeRate!.median, closeTo(0.10003, 1e-9));
    expect(a.streamUri.toString(), 'https://api.example/api/chain/stream');
  });
  test('maps 404 to BlockNotFound, 503 to ChainWarmingUp, others to ChainApiException', () async {
    final a = api({'/api/chain/block/1': () => http.Response('{"error":"block not found"}', 404), '/api/chain/tip': () => http.Response('{"error":"chain data warming up"}', 503)});
    expect(() => a.fetchBlock(1), throwsA(isA<BlockNotFound>()));
    expect(() => a.fetchTip(), throwsA(isA<ChainWarmingUp>()));
    expect(() => a.fetchBlock(2), throwsA(isA<ChainApiException>().having((e) => e.statusCode, 'status', 404)));
  });
}
```

```dart
// app/test/data/snapshot_cache_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:digibyte_timechain/data/snapshot_cache.dart';
import '../fixtures/fixtures.dart';

void main() {
  test('round-trips the tip and returns null when empty or corrupt', () async {
    final dir = await Directory.systemTemp.createTemp('tc-cache');
    final cache = SnapshotCache(dir);
    expect(await cache.load(), isNull);
    await cache.save(tipFixture());
    expect((await cache.load())!.height, 24151775);
    File('${dir.path}/tip.json').writeAsStringSync('{not json');
    expect(await cache.load(), isNull);
    await dir.delete(recursive: true);
  });
}
```

- [ ] **Step 2: Run to verify they fail**

Run: `cd ~/digibyte-timechain/app && flutter test test/data/chain_api_test.dart test/data/snapshot_cache_test.dart`
Expected: FAIL — missing files.

- [ ] **Step 3: Implement**

```dart
// app/lib/data/chain_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/chain_snapshot.dart';

class ChainApiException implements Exception {
  ChainApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;
  @override
  String toString() => 'ChainApiException($statusCode: $message)';
}
class BlockNotFound extends ChainApiException { BlockNotFound() : super(404, 'block not found'); }
class ChainWarmingUp extends ChainApiException { ChainWarmingUp() : super(503, 'chain data warming up'); }

class ChainApi {
  ChainApi({required Uri base, http.Client? client}) : _base = base, _client = client ?? http.Client();
  final Uri _base;
  final http.Client _client;

  Uri _u(String path) => _base.replace(path: '${_base.path}/$path');
  Uri get streamUri => _u('chain/stream');

  Future<ChainSnapshot> fetchTip() => _get('chain/tip');
  Future<ChainSnapshot> fetchBlock(int height) => _get('chain/block/$height');

  Future<ChainSnapshot> _get(String path) async {
    final res = await _client.get(_u(path)).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) return ChainSnapshot.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    String msg = res.body;
    try { msg = (jsonDecode(res.body) as Map<String, dynamic>)['error']?.toString() ?? msg; } catch (_) {}
    if (res.statusCode == 404 && path.startsWith('chain/block/')) throw BlockNotFound();
    if (res.statusCode == 503) throw ChainWarmingUp();
    throw ChainApiException(res.statusCode, msg);
  }
}
```

```dart
// app/lib/data/snapshot_cache.dart
import 'dart:convert';
import 'dart:io';
import 'models/chain_snapshot.dart';

/// Last tip snapshot on disk so the app opens with data while offline.
class SnapshotCache {
  SnapshotCache(this.dir);
  final Directory dir;
  File get _file => File('${dir.path}/tip.json');

  Future<ChainSnapshot?> load() async {
    try {
      if (!await _file.exists()) return null;
      return ChainSnapshot.fromJson(jsonDecode(await _file.readAsString()) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(ChainSnapshot s) async {
    try {
      await dir.create(recursive: true);
      await _file.writeAsString(jsonEncode(s.toJson()), flush: true);
    } catch (_) {/* cache is best-effort */}
  }
}
```

- [ ] **Step 4: Run to verify they pass, commit**

Run: `cd ~/digibyte-timechain/app && flutter test test/data/ && flutter analyze`
Expected: 13 tests pass.

```bash
cd ~/digibyte-timechain && git add app/lib/data/chain_api.dart app/lib/data/snapshot_cache.dart app/test/data/chain_api_test.dart app/test/data/snapshot_cache_test.dart && git commit -m "feat(app): chain REST client and on-disk tip cache

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 7: Data — ChainRepository (SSE + polling fallback + cache)

**Files:**
- Create: `app/lib/data/chain_repository.dart`
- Test: `app/test/data/chain_repository_test.dart`

**Interfaces:**
- Consumes: `ChainApi`, `SseSource`, `SnapshotCache`, models.
- Produces: `enum FeedStatus { live, reconnecting, stale }`, `class TipUpdate { final ChainSnapshot snapshot; final FeedStatus status; }`, `class ChainRepository { ChainRepository({required ChainApi api, required SseSource sse, required SnapshotCache cache, Duration pollInterval = 10s, DateTime Function() now}); Stream<TipUpdate> watchTip(); Future<ChainSnapshot> fetchBlock(int height); void dispose(); }`.

Behaviour: on subscribe, emit the cached tip (status `stale`) if any, then connect SSE. `tip` events emit `live`. `mempool` events patch the last tip and emit `live`. While SSE state is `disconnected`, poll `fetchTip()` every `pollInterval`; a successful poll emits `live` (data is fresh even though the socket is down); a failed poll re-emits the last snapshot as `reconnecting`. Every emitted tip is saved to the cache. `fetchBlock` memoizes up to 512 heights.

- [ ] **Step 1: Write the failing test**

```dart
// app/test/data/chain_repository_test.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:digibyte_timechain/data/chain_api.dart';
import 'package:digibyte_timechain/data/chain_repository.dart';
import 'package:digibyte_timechain/data/models/chain_snapshot.dart';
import 'package:digibyte_timechain/data/snapshot_cache.dart';
import 'package:digibyte_timechain/data/sse_client.dart';
import '../fixtures/fixtures.dart';

class MockApi extends Mock implements ChainApi {}

class FakeSse implements SseSource {
  final ctrl = StreamController<SseEvent>.broadcast();
  final _state = ValueNotifier(SseState.connecting);
  @override Stream<SseEvent> get events => ctrl.stream;
  @override ValueListenable<SseState> get state => _state;
  void set(SseState s) => _state.value = s;
  @override void close() { ctrl.close(); }
}

void main() {
  late MockApi api; late FakeSse sse; late Directory dir; late SnapshotCache cache;
  setUp(() async { api = MockApi(); sse = FakeSse(); dir = await Directory.systemTemp.createTemp('tc-repo'); cache = SnapshotCache(dir); });
  tearDown(() => dir.delete(recursive: true));

  test('emits the cached tip as stale, then live tips from SSE, and caches them', () async {
    await cache.save(blockFixture().copyWith(isTip: true));
    final repo = ChainRepository(api: api, sse: sse, cache: cache, pollInterval: const Duration(hours: 1));
    final got = <TipUpdate>[];
    final sub = repo.watchTip().listen(got.add);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    sse.set(SseState.connected);
    sse.ctrl.add(SseEvent('tip', fixtureText('tip.json')));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(got.map((u) => u.status), [FeedStatus.stale, FeedStatus.live]);
    expect(got.last.snapshot.height, 24151775);
    expect((await cache.load())!.height, 24151775);
    await sub.cancel(); repo.dispose();
  });

  test('mempool patches update the last tip in place', () async {
    final repo = ChainRepository(api: api, sse: sse, cache: cache, pollInterval: const Duration(hours: 1));
    final got = <TipUpdate>[]; final sub = repo.watchTip().listen(got.add);
    sse.set(SseState.connected);
    sse.ctrl.add(SseEvent('tip', fixtureText('tip.json')));
    sse.ctrl.add(SseEvent('mempool', jsonEncode({'height': 24151775, 'mempool': {'txCount': 9, 'vbytes': 1, 'inflowVbPerSec': 0, 'depthBlocks': 0, 'fees': {'unit': 'DGB/kB'}, 'asOf': 5}, 'price': null})));
    sse.ctrl.add(SseEvent('ping', '{}'));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(got.length, 2);
    expect(got.last.snapshot.mempool!.txCount, 9); expect(got.last.snapshot.price, isNull); expect(got.last.snapshot.height, 24151775);
    await sub.cancel(); repo.dispose();
  });

  test('polls while the socket is down and marks failures as reconnecting', () async {
    var calls = 0;
    when(() => api.fetchTip()).thenAnswer((_) async { calls++; if (calls == 2) throw ChainApiException(500, 'x'); return tipFixture(); });
    final repo = ChainRepository(api: api, sse: sse, cache: cache, pollInterval: const Duration(milliseconds: 30));
    final got = <TipUpdate>[]; final sub = repo.watchTip().listen(got.add);
    sse.set(SseState.disconnected);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(got.map((u) => u.status).take(2), [FeedStatus.live, FeedStatus.reconnecting]);
    sse.set(SseState.connected);
    final before = calls;
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(calls, before);
    await sub.cancel(); repo.dispose();
  });

  test('fetchBlock memoizes', () async {
    when(() => api.fetchBlock(24151710)).thenAnswer((_) async => blockFixture());
    final repo = ChainRepository(api: api, sse: sse, cache: cache);
    await repo.fetchBlock(24151710); await repo.fetchBlock(24151710);
    verify(() => api.fetchBlock(24151710)).called(1);
    repo.dispose();
  });
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `cd ~/digibyte-timechain/app && flutter test test/data/chain_repository_test.dart`
Expected: FAIL — missing file.

- [ ] **Step 3: Implement**

```dart
// app/lib/data/chain_repository.dart
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'chain_api.dart';
import 'models/chain_snapshot.dart';
import 'snapshot_cache.dart';
import 'sse_client.dart';

enum FeedStatus { live, reconnecting, stale }

class TipUpdate {
  const TipUpdate(this.snapshot, this.status);
  final ChainSnapshot snapshot;
  final FeedStatus status;
}

/// Single source of truth for "what is the tip right now".
/// SSE when it works, REST polling while it does not, disk cache when neither does.
class ChainRepository {
  ChainRepository({required ChainApi api, required SseSource sse, required SnapshotCache cache, this.pollInterval = const Duration(seconds: 10)})
      : _api = api, _sse = sse, _cache = cache;

  final ChainApi _api;
  final SseSource _sse;
  final SnapshotCache _cache;
  final Duration pollInterval;

  StreamController<TipUpdate>? _ctrl;
  StreamSubscription<SseEvent>? _sseSub;
  Timer? _poll;
  ChainSnapshot? _last;
  final _blocks = LinkedHashMap<int, ChainSnapshot>();
  static const _maxBlocks = 512;

  Stream<TipUpdate> watchTip() {
    _ctrl ??= StreamController<TipUpdate>.broadcast(onListen: _start, onCancel: _stop);
    return _ctrl!.stream;
  }

  Future<void> _start() async {
    final cached = await _cache.load();
    if (cached != null && _last == null) { _last = cached; _emit(FeedStatus.stale); }
    _sse.state.addListener(_onSseState);
    _sseSub = _sse.events.listen(_onEvent);
    _onSseState();
  }

  void _stop() { _sseSub?.cancel(); _sseSub = null; _sse.state.removeListener(_onSseState); _poll?.cancel(); _poll = null; }

  void _onSseState() {
    if (_sse.state.value == SseState.disconnected) {
      _poll ??= Timer.periodic(pollInterval, (_) => _pollOnce());
    } else {
      _poll?.cancel(); _poll = null;
    }
  }

  Future<void> _pollOnce() async {
    try {
      _last = await _api.fetchTip();
      await _cache.save(_last!);
      _emit(FeedStatus.live);
    } catch (_) {
      if (_last != null) _emit(FeedStatus.reconnecting);
    }
  }

  void _onEvent(SseEvent e) {
    try {
      final json = jsonDecode(e.data) as Map<String, dynamic>;
      if (e.event == 'tip') {
        _last = ChainSnapshot.fromJson(json);
        _cache.save(_last!);
        _emit(FeedStatus.live);
      } else if (e.event == 'mempool' && _last != null) {
        final p = MempoolPatch.fromJson(json);
        if (p.height == null || p.height == _last!.height) { _last = _last!.withPatch(p); _emit(FeedStatus.live); }
      }
    } catch (_) {/* malformed frame: ignore, next tip fixes it */}
  }

  void _emit(FeedStatus s) { final l = _last; if (l != null && !(_ctrl?.isClosed ?? true)) _ctrl!.add(TipUpdate(l, s)); }

  Future<ChainSnapshot> fetchBlock(int height) async {
    final hit = _blocks.remove(height);
    if (hit != null) { _blocks[height] = hit; return hit; }
    final s = await _api.fetchBlock(height);
    _blocks[height] = s;
    if (_blocks.length > _maxBlocks) _blocks.remove(_blocks.keys.first);
    return s;
  }

  void dispose() { _stop(); _sse.close(); _ctrl?.close(); _ctrl = null; }
}
```

- [ ] **Step 4: Run to verify it passes, commit**

Run: `cd ~/digibyte-timechain/app && flutter test test/data/ && flutter analyze`
Expected: 17 tests pass.

```bash
cd ~/digibyte-timechain && git add app/lib/data/chain_repository.dart app/test/data/chain_repository_test.dart && git commit -m "feat(app): ChainRepository merges SSE, polling fallback and disk cache

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 8: State — settings and providers

**Files:**
- Create: `app/lib/state/settings.dart`, `app/lib/state/providers.dart`
- Test: `app/test/state/settings_test.dart`, `app/test/state/providers_test.dart`

**Interfaces:**
- Produces (`settings.dart`): `enum ThemeChoice { dark, light, system }`, `class Settings { ThemeChoice theme; String fiat; }` (freezed-free, plain immutable with `copyWith`), `class SettingsNotifier extends Notifier<Settings> { void setTheme(ThemeChoice); void setFiat(String); }`, `final settingsProvider = NotifierProvider<SettingsNotifier, Settings>`, `final sharedPrefsProvider = Provider<SharedPreferences>` (overridden in main). `const kFiatOptions = ['USD'];`
- Produces (`providers.dart`): `chainApiProvider`, `sseSourceProvider`, `snapshotCacheProvider` (needs `cacheDirProvider = Provider<Directory>` overridden in main), `chainRepositoryProvider`, `tipUpdateProvider = StreamProvider<TipUpdate>`, `selectedHeightProvider = StateProvider<int?>` (null = live), `selectedSnapshotProvider = FutureProvider<ChainSnapshot>` (tip when null, else `fetchBlock`), `isLiveProvider = Provider<bool>`, `nowProvider = StreamProvider<DateTime>` ticking each second.

- [ ] **Step 1: Write the failing tests**

```dart
// app/test/state/settings_test.dart
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
```

```dart
// app/test/state/providers_test.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:digibyte_timechain/data/chain_repository.dart';
import 'package:digibyte_timechain/state/providers.dart';
import '../fixtures/fixtures.dart';

class MockRepo extends Mock implements ChainRepository {}

void main() {
  test('selectedSnapshot follows the tip when live and fetches a block when scrubbed', () async {
    final repo = MockRepo();
    final tips = StreamController<TipUpdate>.broadcast();
    when(() => repo.watchTip()).thenAnswer((_) => tips.stream);
    when(() => repo.fetchBlock(24151710)).thenAnswer((_) async => blockFixture());
    final c = ProviderContainer(overrides: [chainRepositoryProvider.overrideWithValue(repo)]);
    final sub = c.listen(selectedSnapshotProvider, (_, __) {});
    tips.add(TipUpdate(tipFixture(), FeedStatus.live));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(c.read(isLiveProvider), isTrue);
    expect(c.read(selectedSnapshotProvider).value?.height, 24151775);
    c.read(selectedHeightProvider.notifier).state = 24151710;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(c.read(isLiveProvider), isFalse);
    expect(c.read(selectedSnapshotProvider).value?.height, 24151710);
    sub.close();
  });
}
```

- [ ] **Step 2: Run to verify they fail**

Run: `cd ~/digibyte-timechain/app && flutter test test/state/`
Expected: FAIL — missing files.

- [ ] **Step 3: Implement**

```dart
// app/lib/state/settings.dart
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
  bool operator ==(Object o) => o is Settings && o.theme == theme && o.fiat == fiat;
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
```

```dart
// app/lib/state/providers.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config.dart';
import '../data/chain_api.dart';
import '../data/chain_repository.dart';
import '../data/models/chain_snapshot.dart';
import '../data/snapshot_cache.dart';
import '../data/sse_client.dart';

final cacheDirProvider = Provider<Directory>((_) => throw UnimplementedError('override in main'));
final chainApiProvider = Provider<ChainApi>((_) => ChainApi(base: Uri.parse(kApiBase)));
final sseSourceProvider = Provider<SseSource>((ref) => SseClient(uri: ref.watch(chainApiProvider).streamUri));
final snapshotCacheProvider = Provider<SnapshotCache>((ref) => SnapshotCache(ref.watch(cacheDirProvider)));

final chainRepositoryProvider = Provider<ChainRepository>((ref) {
  final repo = ChainRepository(api: ref.watch(chainApiProvider), sse: ref.watch(sseSourceProvider), cache: ref.watch(snapshotCacheProvider));
  ref.onDispose(repo.dispose);
  return repo;
});

final tipUpdateProvider = StreamProvider<TipUpdate>((ref) => ref.watch(chainRepositoryProvider).watchTip());

/// null = live (follow the tip); otherwise the scrubbed height.
final selectedHeightProvider = StateProvider<int?>((_) => null);
final isLiveProvider = Provider<bool>((ref) => ref.watch(selectedHeightProvider) == null);

final selectedSnapshotProvider = FutureProvider<ChainSnapshot>((ref) async {
  final h = ref.watch(selectedHeightProvider);
  if (h == null) {
    final tip = ref.watch(tipUpdateProvider);
    return tip.when(data: (u) => u.snapshot, loading: () => Completer<ChainSnapshot>().future, error: (e, _) => throw e);
  }
  return ref.watch(chainRepositoryProvider).fetchBlock(h);
});

/// One tick per second for the block timer.
final nowProvider = StreamProvider<DateTime>((_) => Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()).startWithNow());

extension _StartWith on Stream<DateTime> {
  Stream<DateTime> startWithNow() async* { yield DateTime.now(); yield* this; }
}
```

- [ ] **Step 4: Run to verify they pass, commit**

Run: `cd ~/digibyte-timechain/app && flutter test test/state/ && flutter analyze`
Expected: 3 tests pass.

```bash
cd ~/digibyte-timechain && git add app/lib/state app/test/state && git commit -m "feat(app): settings persistence and Riverpod providers for tip/selection

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 9: UI — dial painter and Dial widget (goldens)

**Files:**
- Create: `app/lib/ui/dial/dial_painter.dart`, `app/lib/ui/dial/dial.dart`, `app/lib/ui/widgets/status_pill.dart`
- Test: `app/test/ui/dial/dial_test.dart`, goldens `app/test/goldens/dial_dark.png`, `app/test/goldens/dial_light.png`, `app/test/goldens/dial_dark_800.png`

**Interfaces:**
- Consumes: `ChainSnapshot`, `TimechainPalette`, `ring_math.dart`, `formatters.dart`.
- Produces: `class DialPainter extends CustomPainter { DialPainter({required ChainSnapshot snapshot, required TimechainPalette palette}) }` — draws ring 1 (supply, r = 0.465·w, stroke 6), ring 2 (reduction fraction, r = 0.412·w, stroke 5, `palette.ring2`), ring 3 (algo arcs, r = 0.359·w, stroke 8), ring 4 (ticks at r = 0.306·w, one per `recentBlocks`, newest at 12 o'clock), end-dots on rings 1–2, a selected-block dot at tick 0. `class Dial extends StatelessWidget { Dial({required ChainSnapshot snapshot, double size = 340, VoidCallback? onOpenExplorer}) }` — painter + center readout (BLOCK HEIGHT, height, algo badge, fee median in DGB/kB with min/max line, size · tx, explorer link) + two pills (`87.9%`, `69.0%`) positioned at the arc ends. `class StatusPill extends StatelessWidget { StatusPill({required String label, required Color color, bool pulse = false}) }`.

- [ ] **Step 1: Write the failing test**

```dart
// app/test/ui/dial/dial_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digibyte_timechain/ui/dial/dial.dart';
import 'package:digibyte_timechain/ui/theme/timechain_theme.dart';
import '../../fixtures/fixtures.dart';

Widget host(Widget child, TimechainPalette p) => MaterialApp(theme: timechainTheme(p), home: Scaffold(body: Center(child: RepaintBoundary(child: child))));

void main() {
  testWidgets('renders height, algo, fee band and pills for a scrubbed block', (t) async {
    await t.pumpWidget(host(Dial(snapshot: blockFixture()), TimechainPalette.dark));
    expect(find.text('24,151,710'), findsOneWidget);
    expect(find.text('QUBIT'), findsOneWidget);
    expect(find.textContaining('0.1000'), findsOneWidget);
    expect(find.textContaining('min 0.001100'), findsOneWidget);
    expect(find.text('7,579 B · 4 tx'), findsOneWidget);
    expect(find.text('87.9%'), findsOneWidget);
    expect(find.text('69.0%'), findsOneWidget);
  });
  testWidgets('shows dashes for a coinbase-only block and null supply', (t) async {
    final s = tipFixture().copyWith(supply: tipFixture().supply.copyWith(total: null));
    await t.pumpWidget(host(Dial(snapshot: s), TimechainPalette.dark));
    expect(find.textContaining('— DGB/kB'), findsOneWidget);
    expect(find.text('—'), findsWidgets);
  });
  testWidgets('golden: dark', (t) async {
    await t.pumpWidget(host(Dial(snapshot: blockFixture()), TimechainPalette.dark));
    await expectLater(find.byType(Dial), matchesGoldenFile('../../goldens/dial_dark.png'));
  });
  testWidgets('golden: light', (t) async {
    await t.pumpWidget(host(Dial(snapshot: blockFixture()), TimechainPalette.light));
    await expectLater(find.byType(Dial), matchesGoldenFile('../../goldens/dial_light.png'));
  });
  testWidgets('golden: dark at tablet size', (t) async {
    await t.binding.setSurfaceSize(const Size(900, 900));
    await t.pumpWidget(host(Dial(snapshot: blockFixture(), size: 800), TimechainPalette.dark));
    await expectLater(find.byType(Dial), matchesGoldenFile('../../goldens/dial_dark_800.png'));
  });
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `cd ~/digibyte-timechain/app && flutter test test/ui/dial/dial_test.dart`
Expected: FAIL — missing files.

- [ ] **Step 3: Implement**

```dart
// app/lib/ui/widgets/status_pill.dart
import 'package:flutter/material.dart';
import '../theme/timechain_theme.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color, this.pulse = false});
  final String label; final Color color; final bool pulse;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: pulse ? [BoxShadow(color: color.withValues(alpha: 0.25), spreadRadius: 3)] : null)),
    const SizedBox(width: 6),
    Text(label, style: kLabel.copyWith(fontSize: 11, color: color)),
  ]);
}
```

```dart
// app/lib/ui/dial/dial_painter.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/chain_snapshot.dart';
import '../../domain/ring_math.dart';
import '../theme/timechain_theme.dart';

class DialPainter extends CustomPainter {
  DialPainter({required this.snapshot, required this.palette});
  final ChainSnapshot snapshot;
  final TimechainPalette palette;

  static const rSupply = 0.465, rReduction = 0.412, rAlgo = 0.359, rTicks = 0.306;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final w = size.shortestSide;
    final r1 = w * rSupply, r2 = w * rReduction, r3 = w * rAlgo, r4 = w * rTicks;

    Paint stroke(Color col, double width, {StrokeCap cap = StrokeCap.round}) =>
        Paint()..color = col..style = PaintingStyle.stroke..strokeWidth = width..strokeCap = cap;

    // tracks
    for (final (r, sw) in [(r1, 6.0), (r2, 5.0), (r3, 8.0)]) {
      canvas.drawCircle(c, r, stroke(palette.track, sw, cap: StrokeCap.butt));
    }
    // ring 1: supply of cap
    final total = snapshot.supply.total;
    final supplyFrac = total == null ? 0.0 : total / snapshot.supply.cap;
    final s1 = sweepFor(supplyFrac);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r1), kStartAngle, s1, false, stroke(TimechainPalette.brandBlue, 6));
    // ring 2: reduction cycle
    final s2 = sweepFor(snapshot.reduction.fraction);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r2), kStartAngle, s2, false, stroke(palette.ring2, 5));
    // ring 3: algorithm share
    for (final a in algoArcs(snapshot.algoShare24h.asMap, TimechainPalette.algoOrder)) {
      canvas.drawArc(Rect.fromCircle(center: c, radius: r3), a.start, a.sweep, false, stroke(palette.algo(a.key), 8, cap: StrokeCap.butt));
    }
    // ring 4: one tick per recent block, newest at 12 o'clock
    final blocks = snapshot.recentBlocks;
    final n = max(blocks.length, 240);
    for (var i = 0; i < blocks.length; i++) {
      final ang = tickAngle(i, n);
      final len = tickLength(blocks[i].sizeBytes);
      canvas.drawLine(pointOnCircle(c, r4, ang), pointOnCircle(c, r4 - len, ang), stroke(palette.algo(blocks[i].algo), 1.6));
    }
    // selected block marker + arc-end dots
    final dot = Paint()..style = PaintingStyle.fill;
    canvas.drawCircle(pointOnCircle(c, r4 + 5, kStartAngle), 3.5, dot..color = palette.text);
    for (final (r, s, col) in [(r1, s1, TimechainPalette.brandBlue), (r2, s2, palette.ring2)]) {
      final p = pointOnCircle(c, r, kStartAngle + s);
      canvas.drawCircle(p, 6.5, dot..color = palette.bg);
      canvas.drawCircle(p, 5, dot..color = col);
    }
  }

  /// Where the pill for ring 1 / ring 2 should sit (outside the ring).
  static Offset pillOffset(Size size, double radiusFactor, double fraction) {
    final c = Offset(size.width / 2, size.height / 2);
    final p = pointOnCircle(c, size.shortestSide * radiusFactor + 18, kStartAngle + sweepFor(fraction));
    return Offset(p.dx.clamp(42, size.width - 42), p.dy);
  }

  @override
  bool shouldRepaint(DialPainter old) => old.snapshot != snapshot || old.palette != palette;
}
```

```dart
// app/lib/ui/dial/dial.dart
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
    final sz = Size.square(size);
    final supplyFrac = snapshot.supply.total == null ? 0.0 : snapshot.supply.total! / snapshot.supply.cap;
    final fee = snapshot.feeRate;
    return SizedBox.fromSize(
      size: sz,
      child: Stack(clipBehavior: Clip.none, children: [
        CustomPaint(size: sz, painter: DialPainter(snapshot: snapshot, palette: p)),
        Center(
          child: SizedBox(
            width: size * 0.54,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
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
              IconButton(onPressed: onOpenExplorer, iconSize: 16, color: p.muted, constraints: const BoxConstraints(minWidth: 44, minHeight: 44), icon: const Icon(Icons.open_in_new)),
            ]),
          ),
        ),
        _pill(context, DialPainter.pillOffset(sz, DialPainter.rSupply, supplyFrac), snapshot.supply.total == null ? '—' : fmtPercent(supplyFrac)),
        _pill(context, DialPainter.pillOffset(sz, DialPainter.rReduction, snapshot.reduction.fraction), fmtPercent(snapshot.reduction.fraction)),
      ]),
    );
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
```

- [ ] **Step 4: Generate goldens, run, commit**

Run: `cd ~/digibyte-timechain/app && flutter test --update-goldens test/ui/dial/dial_test.dart && flutter test test/ui/dial/dial_test.dart && flutter analyze`
Expected: goldens written to `test/goldens/`, then 5 tests pass. Open `test/goldens/dial_dark.png` and compare against `docs/mockups/2026-09-04-dial/dial-dark.png`: four rings, ticks colored per algorithm, pills at the arc ends. Golden tests render with the test font (Ahem), so text looks like boxes — that is expected.

```bash
cd ~/digibyte-timechain && git add app/lib/ui/dial app/lib/ui/widgets app/test/ui/dial app/test/goldens && git commit -m "feat(app): dial painter and Dial widget with goldens

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 10: UI — tiles

**Files:**
- Create: `app/lib/ui/tiles/header_stats.dart`, `block_timer_tile.dart`, `reward_tile.dart`, `fee_mempool_card.dart`, `footer_stats.dart`, `algo_legend.dart`, `app/lib/ui/tiles/stat.dart` (shared label/value/sub column)
- Test: `app/test/ui/tiles/tiles_test.dart`

**Interfaces:**
- Produces: `Stat({label, value, sub, align: CrossAxisAlignment, mono: true, dim: false})`; `HeaderStats({snapshot, isLive})`; `BlockTimerTile({snapshot, now: DateTime, isLive, blocksBehind: int})`; `RewardTile({snapshot})`; `FeeMempoolCard({snapshot, isLive})`; `FooterStats({snapshot, isLive})`; `AlgoLegend({snapshot})`.

- [ ] **Step 1: Write the failing test**

```dart
// app/test/ui/tiles/tiles_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digibyte_timechain/ui/theme/timechain_theme.dart';
import 'package:digibyte_timechain/ui/tiles/algo_legend.dart';
import 'package:digibyte_timechain/ui/tiles/block_timer_tile.dart';
import 'package:digibyte_timechain/ui/tiles/fee_mempool_card.dart';
import 'package:digibyte_timechain/ui/tiles/footer_stats.dart';
import 'package:digibyte_timechain/ui/tiles/header_stats.dart';
import 'package:digibyte_timechain/ui/tiles/reward_tile.dart';
import '../../fixtures/fixtures.dart';

Widget host(Widget w) => MaterialApp(theme: timechainTheme(TimechainPalette.dark), home: Scaffold(body: SizedBox(width: 390, child: w)));

void main() {
  testWidgets('HeaderStats shows reduction, subsidy and price', (t) async {
    await t.pumpWidget(host(HeaderStats(snapshot: tipFixture(), isLive: true)));
    expect(find.text('#130'), findsOneWidget);
    expect(find.text('253.56'), findsOneWidget);
    expect(find.text('0.00469'), findsOneWidget);
    expect(find.text('213 DGB per USD'), findsOneWidget);
  });
  testWidgets('BlockTimerTile counts seconds when live and shows mined-at when scrubbed', (t) async {
    final s = tipFixture();
    final now = DateTime.fromMillisecondsSinceEpoch((s.time + 9) * 1000, isUtc: true);
    await t.pumpWidget(host(BlockTimerTile(snapshot: s, now: now, isLive: true, blocksBehind: 0)));
    expect(find.text('9s'), findsOneWidget);
    expect(find.text('of 15s target'), findsOneWidget);
    await t.pumpWidget(host(BlockTimerTile(snapshot: blockFixture(), now: now, isLive: false, blocksBehind: 65)));
    expect(find.text('10:40:29'), findsOneWidget);
    expect(find.text('65 behind tip'), findsOneWidget);
  });
  testWidgets('RewardTile adds up and names the pool', (t) async {
    await t.pumpWidget(host(RewardTile(snapshot: blockFixture())));
    expect(find.text('253.56'), findsOneWidget);
    expect(find.text('0.645'), findsOneWidget);
    expect(find.text('254.20'), findsOneWidget);
    expect(find.text('m2pool.com'), findsOneWidget);
    expect(find.text('QUBIT'), findsOneWidget);
  });
  testWidgets('RewardTile shows unknown for an untagged pool', (t) async {
    final s = blockFixture().copyWith(pool: blockFixture().pool.copyWith(tag: null));
    await t.pumpWidget(host(RewardTile(snapshot: s)));
    expect(find.text('unknown'), findsOneWidget);
  });
  testWidgets('FeeMempoolCard shows DGB/kB estimates and mempool figures', (t) async {
    await t.pumpWidget(host(FeeMempoolCard(snapshot: tipFixture(), isLive: true)));
    expect(find.text('DGB / kB'), findsOneWidget);
    expect(find.text('0.01100'), findsOneWidget);
    expect(find.text('0.001100'), findsOneWidget);
    expect(find.text('transactions'), findsOneWidget);
    await t.pumpWidget(host(FeeMempoolCard(snapshot: blockFixture(), isLive: false)));
    expect(find.text('live · not block-specific'), findsOneWidget);
  });
  testWidgets('FooterStats and AlgoLegend', (t) async {
    await t.pumpWidget(host(Column(children: [FooterStats(snapshot: tipFixture(), isLive: true), AlgoLegend(snapshot: tipFixture())])));
    expect(find.text('18.46B'), findsOneWidget);
    expect(find.text('87.89% of 21B'), findsOneWidget);
    expect(find.text('54,225'), findsOneWidget);
    expect(find.text('blocks · ~9.4 days'), findsOneWidget);
    expect(find.text('\$86.6M'), findsOneWidget);
    expect(find.text('SKEIN'), findsOneWidget);
    expect(find.text('21%'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `cd ~/digibyte-timechain/app && flutter test test/ui/tiles/tiles_test.dart`
Expected: FAIL — missing files.

- [ ] **Step 3: Implement**

```dart
// app/lib/ui/tiles/stat.dart
import 'package:flutter/material.dart';
import '../theme/timechain_theme.dart';

class Stat extends StatelessWidget {
  const Stat({super.key, required this.label, required this.value, this.sub = '', this.align = CrossAxisAlignment.start, this.mono = true, this.dim = false});
  final String label, value, sub; final CrossAxisAlignment align; final bool mono, dim;
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Opacity(opacity: dim ? 0.45 : 1, child: Column(crossAxisAlignment: align, mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: kLabel.copyWith(color: p.muted)),
      const SizedBox(height: 2),
      Text(value, style: (mono ? kMono : kLabel.copyWith(letterSpacing: 0)).copyWith(fontSize: 17, color: p.text, height: 1.1)),
      if (sub.isNotEmpty) Text(sub, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: p.muted)),
    ]));
  }
}

class Card2 extends StatelessWidget {
  const Card2({super.key, required this.child, this.padding = const EdgeInsets.all(14)});
  final Widget child; final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(padding: padding, decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.track)), child: child);
  }
}
```

```dart
// app/lib/ui/tiles/header_stats.dart
import 'package:flutter/material.dart';
import '../../data/models/chain_snapshot.dart';
import '../../domain/formatters.dart';
import 'stat.dart';

class HeaderStats extends StatelessWidget {
  const HeaderStats({super.key, required this.snapshot, required this.isLive});
  final ChainSnapshot snapshot; final bool isLive;
  @override
  Widget build(BuildContext context) {
    final usd = snapshot.price?.usd;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Stat(label: 'REDUCTION', value: '#${snapshot.reduction.step}', sub: 'cut 1.116% monthly', mono: false)),
      Expanded(child: Stat(label: 'SUBSIDY', value: fmtDgb(snapshot.reward.subsidy), sub: 'DGB per block', align: CrossAxisAlignment.center)),
      Expanded(child: Stat(label: 'USD / DGB', value: fmtUsdPrice(usd), sub: '${fmtDgbPerUsd(usd)} DGB per USD', align: CrossAxisAlignment.end, dim: !isLive)),
    ]);
  }
}
```

```dart
// app/lib/ui/tiles/block_timer_tile.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/chain_snapshot.dart';
import '../../domain/formatters.dart';
import '../../domain/ring_math.dart';
import '../theme/timechain_theme.dart';

class BlockTimerTile extends StatelessWidget {
  const BlockTimerTile({super.key, required this.snapshot, required this.now, required this.isLive, required this.blocksBehind});
  final ChainSnapshot snapshot; final DateTime now; final bool isLive; final int blocksBehind;
  static const target = Duration(seconds: 15);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final elapsed = Duration(seconds: max(0, now.toUtc().millisecondsSinceEpoch ~/ 1000 - snapshot.time));
    final over = elapsed > target;
    final frac = isLive ? min(1.0, elapsed.inSeconds / target.inSeconds) : 0.0;
    final ringColor = over ? const Color(0xFFF5A524) : p.live;
    return SizedBox(width: 104, height: 104, child: Stack(alignment: Alignment.center, children: [
      CustomPaint(size: const Size.square(104), painter: _RingPainter(frac: frac, track: p.track, color: ringColor)),
      Column(mainAxisSize: MainAxisSize.min, children: isLive
        ? [Text('LAST BLOCK', style: kLabel.copyWith(fontSize: 9, color: p.muted)), Text(fmtElapsed(elapsed), style: kMono.copyWith(fontSize: 20, color: p.text)), Text('of 15s target', style: TextStyle(fontSize: 9, color: p.muted))]
        : [Text('MINED AT', style: kLabel.copyWith(fontSize: 9, color: p.muted)), Text(fmtUtcTimeSec(snapshot.time), style: kMono.copyWith(fontSize: 15, color: p.text)), Text('$blocksBehind behind tip', style: TextStyle(fontSize: 9, color: p.muted))]),
    ]));
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.frac, required this.track, required this.color});
  final double frac; final Color track, color;
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero); const r = 40.0;
    canvas.drawCircle(c, r, Paint()..color = track..style = PaintingStyle.stroke..strokeWidth = 6);
    if (frac > 0) canvas.drawArc(Rect.fromCircle(center: c, radius: r), kStartAngle, sweepFor(frac), false, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 6..strokeCap = StrokeCap.round);
  }
  @override
  bool shouldRepaint(_RingPainter o) => o.frac != frac || o.color != color;
}
```

```dart
// app/lib/ui/tiles/reward_tile.dart
import 'package:flutter/material.dart';
import '../../data/models/chain_snapshot.dart';
import '../../domain/formatters.dart';
import '../theme/timechain_theme.dart';
import 'stat.dart';

class RewardTile extends StatelessWidget {
  const RewardTile({super.key, required this.snapshot});
  final ChainSnapshot snapshot;
  @override
  Widget build(BuildContext context) {
    final p = context.palette; final r = snapshot.reward; final algoColor = p.algo(snapshot.algo);
    Widget cell(String label, String value, CrossAxisAlignment a, {Color? color}) => Column(crossAxisAlignment: a, children: [
      Text(label, style: kLabel.copyWith(fontSize: 9, letterSpacing: 1.2, color: p.muted)), const SizedBox(height: 2),
      Text(value, style: kMono.copyWith(fontSize: 13, color: color ?? p.text)),
    ]);
    return Card2(padding: const EdgeInsets.fromLTRB(14, 12, 14, 12), child: Column(children: [
      Row(children: [
        Expanded(child: cell('SUBSIDY', fmtDgb(r.subsidy), CrossAxisAlignment.start)),
        Expanded(child: cell('+ FEES', fmtDgb(r.fees, decimals: 3), CrossAxisAlignment.center)),
        Expanded(child: cell('= REWARD', fmtDgb(r.total), CrossAxisAlignment.end, color: TimechainPalette.brandBlue)),
      ]),
      Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: p.track)),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('MINED BY', style: kLabel.copyWith(fontSize: 9.5, letterSpacing: 1.2, color: p.muted)),
        Row(children: [
          Text(snapshot.pool.tag ?? 'unknown', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: p.text)),
          const SizedBox(width: 6),
          Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(border: Border.all(color: algoColor), borderRadius: BorderRadius.circular(999)),
            child: Text((TimechainPalette.algoLabels[snapshot.algo] ?? snapshot.algo).toUpperCase(), style: kLabel.copyWith(fontSize: 9, letterSpacing: 1, color: algoColor))),
        ]),
      ]),
    ]));
  }
}
```

```dart
// app/lib/ui/tiles/fee_mempool_card.dart
import 'package:flutter/material.dart';
import '../../data/models/chain_snapshot.dart';
import '../../domain/formatters.dart';
import '../theme/timechain_theme.dart';
import 'stat.dart';

class FeeMempoolCard extends StatelessWidget {
  const FeeMempoolCard({super.key, required this.snapshot, required this.isLive});
  final ChainSnapshot snapshot; final bool isLive;
  @override
  Widget build(BuildContext context) {
    final p = context.palette; final m = snapshot.mempool;
    Widget title(String a, String b) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(a, style: kLabel.copyWith(letterSpacing: 1.6, color: p.muted)), Text(b, style: TextStyle(fontSize: 10, color: p.muted))]);
    Widget est(String label, String value, String sub) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: p.card2, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: kLabel.copyWith(fontSize: 9, letterSpacing: 1.2, color: p.muted)), Text(value, style: kMono.copyWith(fontSize: 20, color: p.text)), Text(sub, style: TextStyle(fontSize: 9.5, color: p.muted))]));
    return Card2(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      title('FEE RATES', 'DGB / kB'), const SizedBox(height: 12),
      Row(children: [
        Expanded(child: est('PRIORITY', fmtFeeDgbPerKb(m?.fees.priority), 'next 2 blocks · ~30 s')), const SizedBox(width: 10),
        Expanded(child: est('ANYTIME', fmtFeeDgbPerKb(m?.fees.anytime), 'within 20 blocks · ~5 min')),
      ]),
      Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: p.track)),
      title('MEMPOOL', isLive ? 'live' : 'live · not block-specific'), const SizedBox(height: 8),
      Row(children: [
        Expanded(child: Stat(label: 'INFLOW', value: m == null ? '—' : m.inflowVbPerSec.toStringAsFixed(0), sub: 'vB / s')),
        Expanded(child: Stat(label: 'UNCONFIRMED', value: m == null ? '—' : fmtHeight(m.txCount), sub: 'transactions', align: CrossAxisAlignment.center)),
        Expanded(child: Stat(label: 'DEPTH', value: m == null ? '—' : m.depthBlocks.toStringAsFixed(m.depthBlocks < 10 ? 1 : 0), sub: 'blocks', align: CrossAxisAlignment.end)),
      ]),
    ]));
  }
}
```

```dart
// app/lib/ui/tiles/footer_stats.dart
import 'package:flutter/material.dart';
import '../../data/models/chain_snapshot.dart';
import '../../domain/formatters.dart';
import 'stat.dart';

class FooterStats extends StatelessWidget {
  const FooterStats({super.key, required this.snapshot, required this.isLive});
  final ChainSnapshot snapshot; final bool isLive;
  @override
  Widget build(BuildContext context) {
    final total = snapshot.supply.total; final r = snapshot.reduction;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Stat(label: 'SUPPLY', value: fmtBillions(total), sub: total == null ? 'scanning…' : '${fmtPercent(total / snapshot.supply.cap, decimals: 2)} of 21B')),
      Expanded(child: Stat(label: 'NEXT CUT', value: fmtHeight(r.blocksUntilNext), sub: 'blocks · ${fmtDaysFromBlocks(r.blocksUntilNext)}', align: CrossAxisAlignment.center)),
      Expanded(child: Stat(label: 'MARKET', value: fmtUsdCompact(snapshot.price?.marketCapUsd), sub: 'USD', align: CrossAxisAlignment.end, dim: !isLive)),
    ]);
  }
}
```

```dart
// app/lib/ui/tiles/algo_legend.dart
import 'package:flutter/material.dart';
import '../../data/models/chain_snapshot.dart';
import '../theme/timechain_theme.dart';

class AlgoLegend extends StatelessWidget {
  const AlgoLegend({super.key, required this.snapshot});
  final ChainSnapshot snapshot;
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Wrap(alignment: WrapAlignment.center, spacing: 14, runSpacing: 8, children: [
      for (final k in TimechainPalette.algoOrder)
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 9, height: 9, decoration: BoxDecoration(shape: BoxShape.circle, color: p.algo(k))), const SizedBox(width: 6),
          Text(TimechainPalette.algoLabels[k]!.toUpperCase(), style: kLabel.copyWith(fontSize: 10.5, letterSpacing: 0.8, color: p.muted)), const SizedBox(width: 4),
          Text('${(snapshot.algoShare24h.share(k) * 100).round()}%', style: kMono.copyWith(fontSize: 10.5, fontWeight: FontWeight.w600, color: p.text)),
        ]),
    ]);
  }
}
```

- [ ] **Step 4: Run to verify it passes, commit**

Run: `cd ~/digibyte-timechain/app && flutter test test/ui/tiles/ && flutter analyze`
Expected: 7 tests pass.

```bash
cd ~/digibyte-timechain && git add app/lib/ui/tiles app/test/ui/tiles && git commit -m "feat(app): header, timer, reward, fee/mempool, footer and legend tiles

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 11: UI — scrubber

**Files:**
- Create: `app/lib/ui/scrubber/scrubber.dart`
- Test: `app/test/ui/scrubber/scrubber_test.dart`

**Interfaces:**
- Produces: `class Scrubber extends StatelessWidget { Scrubber({required int tipHeight, required int? selectedHeight, int window = 240, required ValueChanged<int?> onChanged}) }`. Track maps `[tip − window + 1, tip]` to `[0, 1]`; dragging snaps to whole blocks; releasing with the knob at the right edge (height == tip) reports `null` (live). Prev/next buttons step one block; next at the tip reports `null`. Label under the track: `SCRUB BLOCKS · TIP` or `SCRUB BLOCKS · 65 BACK`.

- [ ] **Step 1: Write the failing test**

```dart
// app/test/ui/scrubber/scrubber_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digibyte_timechain/ui/scrubber/scrubber.dart';
import 'package:digibyte_timechain/ui/theme/timechain_theme.dart';

void main() {
  const tip = 24151775;
  Widget host(int? sel, ValueChanged<int?> on) => MaterialApp(theme: timechainTheme(TimechainPalette.dark), home: Scaffold(body: SizedBox(width: 390, child: Scrubber(tipHeight: tip, selectedHeight: sel, onChanged: on))));

  testWidgets('prev steps back one block; next at the tip returns to live', (t) async {
    final got = <int?>[];
    await t.pumpWidget(host(null, got.add));
    expect(find.text('SCRUB BLOCKS · TIP'), findsOneWidget);
    await t.tap(find.byKey(const Key('scrub-prev')));
    expect(got, [tip - 1]);
    await t.pumpWidget(host(tip - 1, got.add));
    expect(find.text('SCRUB BLOCKS · 1 BACK'), findsOneWidget);
    await t.tap(find.byKey(const Key('scrub-next')));
    expect(got.last, isNull);
  });
  testWidgets('dragging the track snaps to whole blocks and the right edge means live', (t) async {
    final got = <int?>[];
    await t.pumpWidget(host(null, got.add));
    final track = find.byKey(const Key('scrub-track'));
    final box = t.getRect(track);
    await t.dragFrom(box.centerRight, Offset(-box.width / 2, 0));
    await t.pumpAndSettle();
    // half-way along a 240-block window: 119.5 blocks back, rounded to a whole block
    expect((got.last! - (tip - 120)).abs() <= 1, isTrue, reason: 'got ${got.last}');
    await t.dragFrom(box.center, Offset(box.width, 0));
    await t.pumpAndSettle();
    expect(got.last, isNull);
  });
  testWidgets('prev clamps at the window edge', (t) async {
    final got = <int?>[];
    await t.pumpWidget(host(tip - 239, got.add));
    await t.tap(find.byKey(const Key('scrub-prev')));
    expect(got, [tip - 239]);
  });
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `cd ~/digibyte-timechain/app && flutter test test/ui/scrubber/scrubber_test.dart`
Expected: FAIL — missing file.

- [ ] **Step 3: Implement**

```dart
// app/lib/ui/scrubber/scrubber.dart
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
        final w = c.maxWidth;
        void fromDx(double dx) => _set(_floor + ((dx / w).clamp(0.0, 1.0) * (window - 1)).round());
        return GestureDetector(
          key: const Key('scrub-track'),
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (d) => fromDx(d.localPosition.dx),
          onHorizontalDragUpdate: (d) => fromDx(d.localPosition.dx),
          onTapDown: (d) => fromDx(d.localPosition.dx),
          child: SizedBox(height: 56, child: Stack(alignment: Alignment.centerLeft, clipBehavior: Clip.none, children: [
            Positioned(left: 0, right: 0, top: 20, child: Container(height: 3, decoration: BoxDecoration(color: p.track, borderRadius: BorderRadius.circular(2)))),
            Positioned(left: 0, width: w * frac, top: 20, child: Container(height: 3, decoration: BoxDecoration(color: TimechainPalette.brandBlue, borderRadius: BorderRadius.circular(2)))),
            Positioned(left: w * frac - 13, top: 8, child: Container(width: 26, height: 26, decoration: BoxDecoration(shape: BoxShape.circle, color: p.bg, border: Border.all(color: TimechainPalette.brandBlue, width: 4)))),
            Positioned(left: 0, right: 0, top: 40, child: Text(selectedHeight == null ? 'SCRUB BLOCKS · TIP' : 'SCRUB BLOCKS · $_behind BACK', textAlign: TextAlign.center, style: kLabel.copyWith(fontSize: 9.5, letterSpacing: 1.6, color: p.muted))),
          ])),
        );
      })),
      const SizedBox(width: 10),
      btn(const Key('scrub-next'), Icons.chevron_right, () => _set(_current + 1)),
    ]);
  }
}
```

- [ ] **Step 4: Run to verify it passes, commit**

Run: `cd ~/digibyte-timechain/app && flutter test test/ui/scrubber/ && flutter analyze`
Expected: 3 tests pass.

```bash
cd ~/digibyte-timechain && git add app/lib/ui/scrubber app/test/ui/scrubber && git commit -m "feat(app): block scrubber with snap-to-block drag and live return

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 12: Screens, app wiring, integration test

**Files:**
- Create: `app/lib/ui/screens/dial_screen.dart`, `app/lib/ui/screens/settings_screen.dart`, `app/lib/app.dart`; replace `app/lib/main.dart`
- Test: `app/test/ui/screens/dial_screen_test.dart`

**Interfaces:**
- Consumes: all providers, tiles, Dial, Scrubber, StatusPill, `url_launcher` is NOT used (explorer link copies the URL to the clipboard and shows a SnackBar, to stay dependency-light).
- Produces: `DialScreen` (ConsumerWidget), `SettingsScreen`, `TimechainApp` (ConsumerWidget building `MaterialApp` with the theme from settings), `main()` that resolves the documents directory and SharedPreferences and overrides `cacheDirProvider` + `sharedPrefsProvider`.

- [ ] **Step 1: Write the failing test**

```dart
// app/test/ui/screens/dial_screen_test.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:digibyte_timechain/app.dart';
import 'package:digibyte_timechain/data/chain_repository.dart';
import 'package:digibyte_timechain/state/providers.dart';
import 'package:digibyte_timechain/state/settings.dart';
import '../../fixtures/fixtures.dart';

class MockRepo extends Mock implements ChainRepository {}

void main() {
  late MockRepo repo; late StreamController<TipUpdate> tips;
  setUp(() async {
    repo = MockRepo(); tips = StreamController<TipUpdate>.broadcast();
    when(() => repo.watchTip()).thenAnswer((_) => tips.stream);
    when(() => repo.fetchBlock(24151774)).thenAnswer((_) async => blockFixture().copyWith(height: 24151774));
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpApp(WidgetTester t) async {
    final prefs = await SharedPreferences.getInstance();
    // nowProvider is periodic; a fixed value keeps pumpAndSettle from waiting on a live timer.
    await t.pumpWidget(ProviderScope(overrides: [
      chainRepositoryProvider.overrideWithValue(repo),
      sharedPrefsProvider.overrideWithValue(prefs),
      nowProvider.overrideWith((_) => Stream.value(DateTime.fromMillisecondsSinceEpoch((tipFixture().time + 9) * 1000, isUtc: true))),
    ], child: const TimechainApp()));
  }

  testWidgets('shows a loading state, then the live dial, then a scrubbed block', (t) async {
    await t.binding.setSurfaceSize(const Size(390, 1200));
    await pumpApp(t);
    expect(find.text('Connecting to the chain…'), findsOneWidget);
    tips.add(TipUpdate(tipFixture(), FeedStatus.live));
    await t.pump();
    expect(find.text('LIVE'), findsOneWidget);
    expect(find.text('24,151,775'), findsOneWidget);
    await t.tap(find.byKey(const Key('scrub-prev')));
    await t.pump(); await t.pump();
    expect(find.text('VIEWING BLOCK'), findsOneWidget);
    expect(find.text('24,151,774'), findsOneWidget);
    expect(find.text('1 behind tip'), findsOneWidget);
  });
  testWidgets('stale and reconnecting badges', (t) async {
    await t.binding.setSurfaceSize(const Size(390, 1200));
    await pumpApp(t);
    tips.add(TipUpdate(tipFixture(), FeedStatus.stale)); await t.pump();
    expect(find.textContaining('STALE'), findsOneWidget);
    tips.add(TipUpdate(tipFixture(), FeedStatus.reconnecting)); await t.pump();
    expect(find.text('RECONNECTING'), findsOneWidget);
  });
  testWidgets('settings toggles the theme', (t) async {
    await t.binding.setSurfaceSize(const Size(390, 1200));
    await pumpApp(t);
    tips.add(TipUpdate(tipFixture(), FeedStatus.live)); await t.pump();
    await t.tap(find.byIcon(Icons.settings)); await t.pumpAndSettle();
    await t.tap(find.text('Light')); await t.pumpAndSettle();
    final app = t.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme!.brightness, Brightness.light);
    expect(find.text('USD'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `cd ~/digibyte-timechain/app && flutter test test/ui/screens/dial_screen_test.dart`
Expected: FAIL — missing files.

- [ ] **Step 3: Implement**

```dart
// app/lib/ui/screens/settings_screen.dart
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
```

```dart
// app/lib/ui/screens/dial_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config.dart';
import '../../data/chain_repository.dart';
import '../../data/models/chain_snapshot.dart';
import '../../domain/formatters.dart';
import '../../state/providers.dart';
import '../dial/dial.dart';
import '../scrubber/scrubber.dart';
import '../theme/timechain_theme.dart';
import '../tiles/algo_legend.dart';
import '../tiles/block_timer_tile.dart';
import '../tiles/fee_mempool_card.dart';
import '../tiles/footer_stats.dart';
import '../tiles/header_stats.dart';
import '../tiles/reward_tile.dart';
import '../widgets/status_pill.dart';
import 'settings_screen.dart';

class DialScreen extends ConsumerWidget {
  const DialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final tip = ref.watch(tipUpdateProvider);
    final selected = ref.watch(selectedSnapshotProvider);
    final isLive = ref.watch(isLiveProvider);
    final now = ref.watch(nowProvider).value ?? DateTime.now();

    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(child: tip.when(
        loading: () => _message(context, 'Connecting to the chain…'),
        error: (e, _) => _message(context, 'Could not reach the chain feed.\n$e'),
        data: (u) => selected.when(
          loading: () => _body(context, ref, u, u.snapshot, isLive: false, now: now, loadingBlock: true),
          error: (e, _) => _body(context, ref, u, u.snapshot, isLive: false, now: now, blockError: e.toString()),
          data: (s) => _body(context, ref, u, s, isLive: isLive, now: now),
        ),
      )),
    );
  }

  Widget _message(BuildContext context, String text) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: context.palette.muted))));

  Widget _body(BuildContext context, WidgetRef ref, TipUpdate u, ChainSnapshot s, {required bool isLive, required DateTime now, bool loadingBlock = false, String? blockError}) {
    final p = context.palette;
    final tipHeight = u.snapshot.height;
    final behind = tipHeight - s.height;
    final pill = !isLive
        ? StatusPill(label: 'VIEWING BLOCK', color: p.muted)
        : switch (u.status) {
            FeedStatus.live => StatusPill(label: 'LIVE', color: p.live, pulse: true),
            FeedStatus.reconnecting => StatusPill(label: 'RECONNECTING', color: const Color(0xFFF5A524)),
            FeedStatus.stale => StatusPill(label: 'STALE · ${fmtElapsed(now.difference(DateTime.fromMillisecondsSinceEpoch(s.time * 1000)))} AGO', color: const Color(0xFFF5A524)),
          };
    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 28), children: [
      SizedBox(height: 44, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [SvgPicture.asset('assets/brand/digibyte_symbol.svg', width: 30, height: 30), const SizedBox(width: 10), Text('TIMECHAIN', style: kLabel.copyWith(fontSize: 15, letterSpacing: 2.2, color: p.text))]),
        pill,
        IconButton(icon: const Icon(Icons.settings), color: p.muted, onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()))),
      ])),
      const SizedBox(height: 14),
      HeaderStats(snapshot: s, isLive: isLive),
      const SizedBox(height: 20),
      Center(child: Opacity(opacity: loadingBlock ? 0.5 : 1, child: Dial(snapshot: s, onOpenExplorer: () => _copyExplorer(context, s.height)))),
      if (blockError != null) Padding(padding: const EdgeInsets.only(top: 8), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Flexible(child: Text('Could not load that block.', style: TextStyle(color: const Color(0xFFF5A524), fontSize: 12))),
        TextButton(key: const Key('scrub-retry'), onPressed: () => ref.invalidate(selectedSnapshotProvider), child: const Text('Retry')),
      ])),
      const SizedBox(height: 14),
      Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        RichText(text: TextSpan(text: fmtUtcTime(s.time), style: kMono.copyWith(fontSize: 38, letterSpacing: -1, color: p.text), children: [TextSpan(text: '  UTC', style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14, fontWeight: FontWeight.w500, color: p.muted))])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(fmtWeekday(s.time), style: kLabel.copyWith(fontSize: 11, letterSpacing: 1.6, color: p.muted)), Text(fmtUtcDate(s.time), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: p.text))]),
      ]),
      const SizedBox(height: 14),
      Scrubber(tipHeight: tipHeight, selectedHeight: isLive ? null : s.height, onChanged: (h) => ref.read(selectedHeightProvider.notifier).state = h),
      const SizedBox(height: 14),
      Row(children: [BlockTimerTile(snapshot: s, now: now, isLive: isLive, blocksBehind: behind), const SizedBox(width: 12), Expanded(child: RewardTile(snapshot: s))]),
      const SizedBox(height: 14),
      FeeMempoolCard(snapshot: isLive ? s : s.copyWith(mempool: u.snapshot.mempool), isLive: isLive),
      const SizedBox(height: 14),
      FooterStats(snapshot: isLive ? s : s.copyWith(price: u.snapshot.price), isLive: isLive),
      const SizedBox(height: 12),
      AlgoLegend(snapshot: s),
    ]);
  }

  void _copyExplorer(BuildContext context, int height) {
    final url = '$kExplorerBase$height';
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied $url')));
  }
}
```

```dart
// app/lib/app.dart
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
```

```dart
// app/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'state/providers.dart';
import 'state/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final dir = await getApplicationDocumentsDirectory();
  runApp(ProviderScope(overrides: [sharedPrefsProvider.overrideWithValue(prefs), cacheDirProvider.overrideWithValue(dir)], child: const TimechainApp()));
}
```

Note on `themeMode` in `app.dart`: with `themeMode: ThemeMode.light` Flutter uses `theme`, which we set to the chosen palette, so both Dark and Light choices render correctly and `MaterialApp.theme.brightness` reflects the choice; System defers to the platform with `dark`/`light` in their normal slots.

- [ ] **Step 4: Run to verify it passes, then the whole suite, commit**

Run: `cd ~/digibyte-timechain/app && flutter test && flutter analyze`
Expected: all tests green (about 40), no issues.

```bash
cd ~/digibyte-timechain && git add app && git commit -m "feat(app): dial and settings screens, app wiring, main

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 13: Device run, README, handoff notes

**Files:**
- Create: `app/README.md`
- Modify: `docs/superpowers/plans/2026-09-04-flutter-app.md` (append run notes)

- [ ] **Step 1: Run on the Note 9 against production**

The backend routes must already be deployed (backend plan Task 12). Then:

```bash
cd ~/digibyte-timechain/app && flutter devices
flutter run -d <SM-N950U device id> --release
```

Watch for ten minutes: the LIVE pill pulses, the block timer resets on each new block (every 15 s on average, sometimes 1–2 minutes), the tick ring rotates one notch per block, scrubbing back 65 blocks shows VIEWING BLOCK with the mined-at time, and returning the knob to the right edge goes back to LIVE. Turn on airplane mode: the pill turns RECONNECTING within 10 s; turn it off: LIVE resumes within 30 s. Kill and relaunch in airplane mode: the last tip renders with a STALE badge.

If the backend is not deployed yet, run against a local backend from the backend plan's Task 11 Step 6 with the phone on the same network: `flutter run --dart-define=CHAIN_API_BASE=http://<this box's LAN IP>:3999/api`.

- [ ] **Step 2: iOS (on the Mac)**

```bash
cd digibyte-timechain/app && flutter build ios --no-codesign && open -a Simulator && flutter run -d "iPhone 15"
```

Same ten-minute checklist. Record the outcome in the plan file.

- [ ] **Step 3: README**

```markdown
<!-- app/README.md -->
# DigiByte Timechain (app)

Flutter app rendering the DigiByte chain as a live dial. Data: `https://api.digiscope.me/api/chain`
(see `../docs/superpowers/plans/2026-09-04-chain-backend.md`).

    flutter pub get
    dart run build_runner build --delete-conflicting-outputs   # after editing models
    flutter test
    flutter run -d <device> [--dart-define=CHAIN_API_BASE=http://10.0.2.2:3001/api]

Layers: `lib/domain` (pure math + formatting), `lib/data` (models, REST, SSE, cache, repository),
`lib/state` (Riverpod), `lib/ui` (dial painter, tiles, scrubber, screens).
Fees are shown in DGB/kB. Price is the DigiDollar oracle rate (USD only in v1).
Goldens: `flutter test --update-goldens test/ui/dial/dial_test.dart` after an intentional dial change.
```

- [ ] **Step 4: Commit**

```bash
cd ~/digibyte-timechain && git add app/README.md docs/superpowers/plans/2026-09-04-flutter-app.md && git commit -m "docs(app): README and device run notes

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Device run 2026-09-04

Production backend (`api.digiscope.me/api/chain`) is not deployed yet (PR #233 open, unmerged),
so this run used the brief's fallback: the backend branch booted locally on this box
(`/home/polloloco/wt-chain-api/backend`, `node src/server.js`, `PORT=3999`) with `DGB_RPC_HOST`
pointed at an SSH tunnel (`ssh -f -N -L 15022:127.0.0.1:14022 root@129.212.182.152`) to the Adam
VPS mainnet node's RPC port. Backend connected at height 24,152,752 (100% synced) and served
`/api/chain/tip` on both `localhost:3999` and the LAN address `192.168.7.251:3999`.

Device: Samsung SM-N950U (`ce061716640b191c017e`), Android 9 / API 28, on the same LAN.
`flutter run -d ce061716640b191c017e --dart-define=CHAIN_API_BASE=http://192.168.7.251:3999/api`.

**Build blocker (environment, not app code):** the first two build attempts failed with
`Entry FlutterPlugin.class is a duplicate but no duplicate handling strategy has been set` from
Gradle's `:gradle:jar` task inside the Flutter SDK's own `packages/flutter_tools/gradle` module
(`/opt/flutter`, pinned at 3.29.0 stable). Root cause: Gradle's `kotlin-dsl` plugin-accessor
generator emits a synthetic `FlutterPlugin.kt` under
`build/generated-sources/kotlin-dsl-plugins/kotlin/`, which collides by class name (both compile
to a top-level, package-less `FlutterPlugin.class`) with the Groovy-compiled `FlutterPlugin`
class from `src/main/groovy/flutter.groovy`. This reproduced from a clean rebuild
(`--no-build-cache --rerun-tasks`), so it wasn't stale-cache — it's a real defect in this pinned
SDK checkout's own build script. Fixed by adding `tasks.withType<Jar> { duplicatesStrategy =
DuplicatesStrategy.EXCLUDE }` to `/opt/flutter/packages/flutter_tools/gradle/build.gradle.kts`
(a machine-local Flutter SDK file, outside this repo — not committed here). After that, the
debug build succeeded (with an unrelated advisory-only NDK version mismatch warning:
project pinned at NDK 26.3.11579264, `path_provider_android`/`shared_preferences_android` want
27.0.12077973 — did not block the build).

**Observations (screenshots in `.superpowers/sdd/2026-09-04-flutter-app/`):**

- `device-01-live.png` — cold launch. Green pulsing LIVE pill, height 24,152,802, reduction
  #130 tile, USD/DGB tile, full dial (progress ring, algo-share ring, tick ring), block timer
  "31s of 15s target", scrubber row at the tip, reward tile (subsidy/fees/reward, miner
  "unknown"). No RenderFlex overflow, no error state.
- `device-02-live-later.png` — ~90 s later. Height advanced to 24,152,811 (9 blocks), timer
  reset to "8s of 15s target", miner now "CKPool". Confirms live polling/SSE updates render
  correctly.
- `device-03-scrubbed.png` — after tapping the scrubber's prev arrow once. Header switches to
  "VIEWING BLOCK", block stays at 24,152,811, "MINED AT 15:16:24", "1 behind tip" — exactly the
  expected scrub behavior.
- `device-04-live-again.png` — after tapping next repeatedly to catch up. Because mainnet was
  producing blocks faster than the 15 s target during this window (several consecutive ~15–25 s
  blocks), a single "next" tap only advances one block, so it briefly re-showed "3 behind tip"
  and then "1 behind tip" before catching the tip; confirmed back at LIVE (green pill,
  "SCRUB BLOCKS · TIP", height 24,152,818). This is correct incremental-scrub behavior, not a
  bug — the brief's assumption that one tap always returns to live only holds when no new block
  lands between the prev and next taps.
- Airplane-mode toggle (`device-05`..`device-07`, expected RECONNECTING/STALE): **skipped**.
  `adb shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true` returned
  `SecurityException: Permission Denial: not allowed to send broadcast ... from uid=2000` — this
  non-rooted Android 9 device's shell user cannot toggle the actual radio state (only the
  Settings app/system UID may send that protected broadcast). `settings put global
  airplane_mode_on 1` alone does not change connectivity, so it was reverted to `0` immediately
  without exercising RECONNECTING/STALE. This matches the brief's anticipated failure mode
  ("if the broadcast is denied on this device, say so and skip").

**Logcat:** `adb logcat -d | grep -i -E "flutter|timechain|exception|overflow"` showed no Dart
exceptions, no `FATAL EXCEPTION`/`AndroidRuntime` crash, and no `RenderFlex overflow`. The only
finding was a benign, pre-existing `flutter_svg` parse warning —
`unhandled element <style/>; Picture key: Svg loader` — which also appears identically during
`flutter test` (an asset SVG contains a `<style>` tag flutter_svg doesn't support); cosmetic,
not a crash.

**Verification:** `flutter analyze` — no issues. `flutter test` — 60/60 passed.

**iOS:** not run (this box is Linux; iOS builds require a Mac). Deferred per Task 13 scope.

**Cleanup:** `flutter run` process killed, backend (`node src/server.js`) stopped, SSH RPC
tunnel to the Adam VPS closed. Airplane mode left OFF.

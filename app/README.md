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

## Running on a physical Android device

Android 9 (API 28) and below block cleartext (`http://`) traffic by default. A debug-only
manifest override at `android/app/src/debug/AndroidManifest.xml` sets
`android:usesCleartextTraffic="true"` so `flutter run` (debug builds) can reach a local backend
over the LAN; release builds keep HTTPS only. The main manifest declares
`android.permission.INTERNET`, required for release builds too.

Example, pointing at a backend running on this box's LAN IP:

    flutter run -d <device-id> --dart-define=CHAIN_API_BASE=http://192.168.7.251:3999/api

## iOS

Not run on this box (Linux; iOS builds require a Mac). See the plan's device-run notes for
the pending checklist (`flutter build ios --no-codesign && open -a Simulator && flutter run -d "iPhone 15"`).

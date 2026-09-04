# SDD ledger — plan: /home/polloloco/digibyte-timechain/docs/superpowers/plans/2026-09-04-flutter-app.md
Spec: /home/polloloco/digibyte-timechain/docs/superpowers/specs/2026-09-04-digibyte-timechain-design.md
Worktree: /home/polloloco/wt-timechain-app (branch feat/app from main 3a19db0). App under app/.
Backend contract source: PR #233 (JohnnyLawDGB/digibyte-compendium), unmerged/undeployed at start — device run (Task 13) needs it live.

## Pre-flight scan (2026-09-04)
| Pair / task | Produces vs consumes | Finding |
|---|---|---|
| T1↔T9–T12 | TimechainPalette (bg/card/card2/text/muted/track/ring2/live, algo(), algoOrder, algoLabels, brandBlue), kMono, kLabel, PaletteX | match |
| T3↔T9/T10 | ring_math: kStartAngle, sweepFor, pointOnCircle, tickAngle, tickLength, algoArcs/ArcSpan; formatters fmt* names | match |
| T4↔T5–T12 | ChainSnapshot fields; MempoolInfo?/PriceInfo?/FeeRate? nullable; SupplyInfo.total nullable; AlgoShare.asMap/share; MempoolPatch + withPatch | match; backend PR #233 may send mempool:null briefly and 404 {error,tipHeight} above tip — models/ChainApi handle both |
| T5↔T7 | SseSource {events, state, close}; SseState | match |
| T6↔T7 | ChainApi.fetchTip/fetchBlock/streamUri, BlockNotFound, ChainWarmingUp; SnapshotCache.load/save | match |
| T7↔T8/T12 | ChainRepository.watchTip()/fetchBlock()/dispose(); TipUpdate{snapshot,status}; FeedStatus | match |
| T8↔T12 | providers: chainRepositoryProvider, tipUpdateProvider, selectedHeightProvider, selectedSnapshotProvider, isLiveProvider, nowProvider, settingsProvider, sharedPrefsProvider, cacheDirProvider | match; T12 test overrides nowProvider with Stream.value |
| T9↔T12 | Dial(snapshot,size,onOpenExplorer); StatusPill(label,color,pulse) | match |
| T10↔T12 | HeaderStats/BlockTimerTile/RewardTile/FeeMempoolCard/FooterStats/AlgoLegend ctor params | match |
| T11↔T12 | Scrubber(tipHeight, selectedHeight, window, onChanged) | match |
| each task | tests vs code self-consistent (T4 freezed 2.5 on Dart 3.7; T5 MockClient.streaming; T9 goldens use Ahem) | ok |
| T13 | needs deployed backend or local backend on LAN; iOS needs a Mac | environment, not a conflict |

Ruling: fiat setting offers USD only in v1 (price is the DigiDollar oracle, USD) — carried from the plan's Global Constraints; flagged to the user at handoff — cost if wrong: a later FX feed task.

## Tasks
Task 1+2+3: dispatched batched (implementer sonnet), BASE 3a19db0
Task 1: complete (commits 3a19db0..233155c, review clean)
Task 2: complete (commits 233155c..c1c4883, review clean)
Task 3: complete (commits c1c4883..291af60, review clean)
Task 1-3 ⚠ resolved: ReductionSchedule mirrors the backend replica already verified against Core; main.dart wiring is Task 12.
Task 1-3: minor (deferred): TimechainPalette.copyWith ignores its argument; lerp is a snap
Task 1-3: minor (deferred): fmtUsdPrice lacks the sci-notation guard fmtFeeDgbPerKb has
Task 4+5+6: dispatched batched (implementer sonnet), BASE 291af60
Task 4+5+6: implementer DONE_WITH_CONCERNS (dcb36df, d979a5d, 94f6a34; 31 tests): added app/build.yaml (explicit_to_json) and SseClient reuses one http.Client across reconnects (brief's per-attempt factory hung the test because the test factory rebuilt the mock each call). Review dispatched with both deviations to rule on.
Task 4+5+6: review needs fixes; build.yaml ruled necessary+harmless. 2 Important: (1) SseClient single-client reuse deviates from the brief to route around a test-double bug — revert to per-attempt clientFactory and fix the test; (2) plan-mandated: after the last listener cancels, the client can never reconnect.
Ruling: fix both — (2) becomes: onCancel stops the loop (closes the client, state disconnected) but a later listen restarts _run (reset _closed on onListen); explicit close() remains terminal — why: spec §7 reconnect semantics must survive a transient unsubscribe; Riverpod keeps one subscription today but the primitive should not be a trap — cost if wrong: none (test-covered).
Task 4+5+6: minor (deferred): SseClient swallows connection errors with no diagnostics; ChainApi has no close(); brief prose mentions minBackoff/maxBackoff params that its code never had (drop the prose).
Task 5: fix round 1/5 dispatched (resume implementer), FIX_BASE 94f6a34
Task 5: fix round 1/5 (2 addressed, 1 new Important — _start/_stop share one _closed flag; cancel + immediate re-listen can run two _run loops / flip a spurious connected; commits 94f6a34..fad0169)
Ruling: add a generation counter (_gen) captured by each _run; every await re-checks `closed || gen != _gen`; the loop closes only its own client — cost if wrong: none (test-covered).
Task 5: fix round 2/5 dispatched (resume implementer), FIX_BASE fad0169
Task 5: fix round 2/5 (1 addressed, 0 open — generation guard; RED proven; commits fad0169..0c35b14)
Task 5: minor (deferred): the race test returns the same mock from the factory, so identical()-ownership in finally is not independently exercised
Task 4: complete (commits 291af60..dcb36df, review clean)
Task 5: complete (commits dcb36df..d979a5d + fixes fad0169, 0c35b14; review clean after 2 fix rounds)
Task 6: complete (commits d979a5d..94f6a34, review clean)
Task 7+8: dispatched batched (implementer sonnet), BASE 0c35b14
Task 7+8: implementer DONE_WITH_CONCERNS (11c700f, a7aedb5; 40 tests): _start() subscribes to SSE before the async cache load (brief's order dropped sync events); mempool-patched tips not cached (brief's code). Review dispatched.
Task 7+8: review needs fixes; both deviations ruled correct/not-a-defect. 1 Important (plan-mandated): _pollOnce can overlap under Timer.periodic and re-emit stale data as live.
Ruling: add an in-flight guard to _pollOnce (skip while a poll is pending) and make the tip-branch cache save awaited+caught — cost if wrong: none (test-covered).
Task 7+8: minor (deferred): fetchBlock does not de-dup concurrent misses; providers_test never disposes its container; settings build() does not self-heal a bad persisted fiat
Task 7: fix round 1/5 dispatched (resume implementer), FIX_BASE a7aedb5
Task 7: fix round 1/5 (2 addressed, 0 open — poll in-flight guard, guarded cache save; commits a7aedb5..8efd67f)
Task 7: complete (commits 0c35b14..11c700f + fix 8efd67f, review clean after fix round 1)
Task 8: complete (commits 11c700f..a7aedb5, review clean)
Task 9+10+11: dispatched batched (implementer sonnet), BASE 8efd67f
Task 9+10+11: review approved with 2 Important (plan-mandated): RewardTile pool tag unbounded → RenderFlex overflow; goldens lack a palette background and use a 1-block fixture (ring 4 unexercised, not human-verifiable).
Ruling: fix both — Flexible+ellipsis on the tag; golden host wraps Dial in ColoredBox(palette.bg) and uses a 240-block fixture; regenerate goldens — cost if wrong: none (test-only + one layout wrap).
Task 9+10+11: minor (deferred): _RingPainter.shouldRepaint ignores track; Stat sub-labels have no maxLines
Task 9/10: fix round 1/5 dispatched (resume implementer), FIX_BASE eea7c3a
Task 9/10: fix round 1/5 (2 addressed, 0 open — tag ellipsis; goldens on palette bg with ringFixture; commits eea7c3a..d8b592a)
Task 9: complete (commits 8efd67f..b062bb9 + golden fix d8b592a, review clean after fix round 1)
Task 10: complete (commits b062bb9..7e913a5 + fix b9ff9ee, review clean after fix round 1)
Task 11: complete (commits 7e913a5..eea7c3a, review clean)
Task 12: dispatched (implementer sonnet), BASE d8b592a
Task 13 prep: Note 9 SM-N950U attached (adb id ce061716640b191c017e); box LAN IP 192.168.7.251; backend not deployed → device run will use the local wt-chain-api backend on :3999 via the Adam VPS RPC tunnel (port 15022) with --dart-define=CHAIN_API_BASE=http://192.168.7.251:3999/api
Task 12: implementer DONE_WITH_CONCERNS (3d5b41b; 59 tests): 3 adaptations in dial_screen.dart — Flexible wraps on header/UTC rows; FittedBox(scaleDown)+SizedBox(372) around FeeMempoolCard; real isLive in loading/error branches. Review dispatched.
Task 12: review needs fixes; adaptations 1 and 3 ruled benign/correct. 2 Important: (plan-mandated) System theme always dark (theme/darkTheme both dark when choice=system); FittedBox+SizedBox(372) around FeeMempoolCard scales it 358/372 on every 390 px device.
Ruling: (a) app.dart uses theme: light, darkTheme: dark, themeMode: mode (dark/light/system) and the test asserts themeMode too, plus a System case; (b) fix fee_mempool_card.dart title() with Flexible+ellipsis and delete the call-site wrapper; add a 358 px no-overflow test — cost if wrong: none (test-covered).
Task 12: minor (deferred): raw exception interpolated into the error text; Flexible wraps unverified on real fonts (device run will show)
Task 12: fix round 1/5 dispatched (resume implementer), FIX_BASE 3d5b41b
Task 12: fix round 1/5 (2 addressed, 0 open — themeMode mapping; fee card shrinks its own labels; commits 3d5b41b..3932bca)
Task 12: minor (deferred): fee_mempool_card title() texts lack maxLines:1 (may wrap instead of ellipsize)
Task 12: complete (commits d8b592a..3d5b41b + fixes 60ea542, 3932bca; review clean after fix round 1)
Ruling (Task 13): device run uses the unmerged backend branch booted locally (wt-chain-api, :3999, RPC via tunnel :15022) reached over LAN; Android 9 blocks cleartext, so a DEBUG-ONLY manifest (android/app/src/debug/AndroidManifest.xml) enables usesCleartextTraffic — production keeps https — cost if wrong: none for release builds.
Task 13: dispatched (implementer sonnet), BASE 3932bca
Task 13: implementer DONE_WITH_CONCERNS (096f978): device run OK on the Note 9 vs local backend — heights 24,152,802→818 live, LIVE + VIEWING BLOCK pills, scrub/return work, no exceptions/overflows in logcat; airplane-mode checks SKIPPED (non-rooted adb cannot send the protected broadcast); iOS not run (no Mac).
Ruling (side effect outside the worktree): the implementer patched /opt/flutter/packages/flutter_tools/gradle/build.gradle.kts (+9 lines: tasks.withType<Jar> { duplicatesStrategy = EXCLUDE }) to get past a Gradle 8.10 duplicate FlutterPlugin.class jar error in this SDK checkout (3.29.0, 20 commits diverged). KEPT: reverting breaks Android builds on this box; it is a build-tool workaround with no effect on app code — cost if wrong: an unexpected SDK-level change for the user; revert with `cd /opt/flutter && git checkout -- packages/flutter_tools/gradle/build.gradle.kts`. Surface to the user.
Task 13: review dispatched (sonnet), BASE 3932bca
Controller device findings (from device-01/03 screenshots, real fonts) for the final wave:
 A. Brand symbol renders as a black disc — flutter_svg does not apply <style> CSS classes (.st0/.st1/.st2) in assets/brand/digibyte_symbol.svg → inline the fills.
 B. Dial center readout collides with the tick ring under real font metrics ("BLOCK HEIGHT" overlapped) → constrain the center column to the inner radius (FittedBox scaleDown inside a sized box ≈ 0.5·size tall) or tighten line heights.
 C. HeaderStats shows "—" for price when scrubbed; FooterStats gets the live price but HeaderStats does not → pass s.copyWith(price: u.snapshot.price) to HeaderStats as well.
 D. BlockTimerTile labels ("LAST BLOCK", "of 15s target") overlap the 80 px ring under real fonts → FittedBox on the inner column or smaller label font.
Task 13: complete (commits 3932bca..096f978, review clean). Ruling: the "cut-off circular pencil button" the reviewer flagged is the Samsung S Pen Air Command floating icon (system UI), not the app — DROP.
Task 13: minor (deferred): report says "~90 s later" for device-02 but the app clock shows ~120 s
FINAL REVIEW dispatched (opus) at 096f978 (20 commits over main 3a19db0), with device findings A–D for the single fix wave.
FINAL REVIEW (opus, 3a19db0..096f978): With fixes. 0 Critical, 8 Important (#1 no dead-connection detection + starved poll fallback; #2 mempool patch without price wipes price — PLAN DEFECT (Task 4 test asserted it); #3–#6 = device A–D; #7 block-fetch error branch renders the tip as the scrubbed block, raw $e text, untested; #8 no app-lifecycle handling — 1 Hz rebuild in background, no refresh on resume), ~9 Minor. Triage: 1 MUST FIX (raw error text, folded into #7), rest FOLLOW-UP/DROP as listed by the reviewer.
Ruling: single fix wave = A, B, C, D, #1, #2, #7, #8 + one-liners (app label/description "DigiByte Timechain", Icons.content_copy for the copy action, trim a trailing slash on CHAIN_API_BASE, malformed 200 body → ChainApiException) + a 360 dp DialScreen no-overflow smoke test — why: #1/#2 are production hazards, A–D are first-screen defects, the rest are cheap and testable — cost if wrong: a larger single diff to re-review.
Ruling (#2, plan defect): withPatch keeps the existing price when the patch carries none; the Task 4 test expectation changes accordingly.
Ruling (#1): a 60 s no-frame watchdog in SseClient (ping counts) flips to disconnected and reconnects; repository polls eagerly on subscribe and on entering disconnected.
Ruling (#8): AppLifecycleListener pauses the 1 Hz tick while not resumed and calls ChainRepository.refreshNow() on resume (eager poll + SSE reconnect).
Final fix wave dispatched (opus), FIX_BASE 096f978.
Final fix wave: DONE_WITH_CONCERNS (096f978..c58993f, 8 commits; 70 tests). Extra: 5.6 px RewardTile overflow at 360 dp found by the new smoke test and fixed. Re-review (opus) + second device check dispatched in parallel.
Device run 2 (c58993f): A/B/C/D + reward tile all FIXED on the Note 9 (dark + light), heights 24,152,981→984, logcat clean. Screenshots device-11..14 in the workspace.
Controller note (device-11): D is PARTIAL — timer labels still touch the ring stroke (68 px fit width ≈ the chord at the label's vertical offset); a 56–58 px fit width would clear it. To adjudicate after the re-review.
Final re-review (opus): all 8 findings + one-liners ADDRESSED; no new Critical/Important. 7 Minor parked:
Parked — Ruling: eager poll can emit an older tip after a newer SSE tip (window ≈ one poll RTT at start/resume; self-corrects on the next block) — 1-line height guard in _pollOnce for the follow-up PR.
Parked — Ruling: watchdog is blind while `connecting` (send() has no timeout) — add a 15 s send timeout in the follow-up.
Parked — Ruling: dial center box is a square, 1–3 px clearance at 328 px — subtract max tick length in the follow-up.
Parked — Ruling: `_lastRendered == null` error card has no back-to-live; scrubber shows "0 BACK" in the error branch (pre-existing shape).
Parked — Ruling: timing tests use wall clock (flake risk on a loaded box).
Parked — Ruling: D is PARTIAL on device — timer labels still touch the ring stroke; fit width 68→56 in the follow-up.
Parked — Ruling: at 360 dp under the Ahem test font the reward pool tag can ellipsize to zero width (on the real font it renders, see device-11).
BRANCH COMPLETE: feat/app at c58993f (28 commits over main 3a19db0). 70 tests green. Device-verified twice. Unpushed.

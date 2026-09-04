# SDD ledger — plan: /home/polloloco/digibyte-timechain/docs/superpowers/plans/2026-09-04-chain-backend.md
Spec: /home/polloloco/digibyte-timechain/docs/superpowers/specs/2026-09-04-digibyte-timechain-design.md
Worktree: /home/polloloco/wt-chain-api (branch feat/chain-timechain-api from origin/main a2d2fc3). Code under backend/.
node_modules copied from ~/digibyte-compendium/backend. Tests: `npx vitest run <file>`.

## Pre-flight scan (2026-09-04)
| Pair / task | Produces vs consumes | Finding |
|---|---|---|
| T1↔T2 | constants ALGOS, BLOCKS_PER_MONTH, PERIOD_VI_START ← reduction/fees/pools | match |
| T2↔T4 | feeRateFromStats(stats, txCount), poolTagFromCoinbase(hex) ← block-fetcher | match |
| T3↔T4 | store row shape (feeMedian/feeMin/feeMax/poolTag/coinbaseText/prevHash) | match |
| T3↔T5 | getRange newest-first; algoShare counts+blocksCounted ← snapshot | match |
| T1↔T5/T6/T10 | subsidySats bigint ← supplyAtHeight, SupplyTracker, _supplyAt | match (BigInt throughout) |
| T7↔T10 | sampler.last, noteMinedBytes ← ChainService | match |
| T8↔T10 | 'tip' {height, rows}, tipHeight, ensureRow; 'error' listener required | match, listener attached in T10 |
| T9↔T10↔T11 | hub.add(res)→remover; broadcast frame format | match |
| T10↔T11 | ready/getTipSnapshot/getBlockSnapshot; 404 regex /no block at height|not in store/ | match |
| T11↔server.js | publicLimiter (line ~751) precedes mount (~2573); rpcClient import name unverified | verify at T11 |
| T12 deploy | plan says branch `master`; local remote only has `main`; VPS checkout reports `master` | see ruling |
| T5 vs T10 | marketCapUsd computed in assembleSnapshot AND ChainService._withMarketCap | minor duplication, let review weigh |
| each task | tests vs code self-consistent (T6 fixture 18457077640.5 exact; T8/T10 fakes lazy) | ok |

Ruling: base branch is `main` (origin has no `master`); PR targets `main`; deploy step must read the VPS checkout's current branch before pulling — why: remote refs are the fact — cost if wrong: a deploy pull on the wrong branch, caught by the post-deploy curl.

## Tasks
Task 1+2: dispatched batched (implementer haiku), BASE a2d2fc3
Task 1: complete (commits a2d2fc3..cbf8709, review clean)
Task 2: complete (commits cbf8709..979ed46, review clean)
Task 1+2 ⚠ resolved by controller: constants verified against ~/digibyte/src/validation.{h,cpp} + kernel/chainparams.cpp earlier this session (SECONDS_PER_MONTH=2628000, workComputationChangeTarget=1430000, 98884/100000 decay).
Task 1+2: minor (deferred): subsidy.js sub-1-DGB floor branch untested
Task 1+2: minor (deferred): reduction.js and subsidy.js duplicate "months elapsed" formula — consider shared monthsElapsed(height)
Task 1+2: minor (deferred): pools.js needle-shadowing has no guard test
Task 3+4+5: dispatched batched (implementer haiku), BASE 979ed46
Task 3+4+5: review approved; 1 Important (plan-mandated) — supplyAtHeight O(tip−height) per-block loop; route accepts any height → event-loop stall.
Ruling: replace supplyAtHeight with a per-reduction-cycle closed form (≤ ~131 iterations regardless of gap) — why: /api/chain/block/:height is unbounded and the spec's scrubber may request any recent height; a linear walk is a DoS vector — cost if wrong: an arithmetic error in supply for scrubbed blocks, caught by the new cycle-boundary test. Companion ruling for Task 11: heights < 1,430,000 (pre-Period VI) return 400 'height below supported range' since reductionAt/subsidySats throw there.
Task 3+4+5 ⚠ resolved: getblockstats feerate_percentiles order is [10,25,50,75,90] (Bitcoin Core RPC doc), p[2] = median ✓.
Task 3+4+5: minor (deferred): ChainStore keeps this.db unused
Task 5: fix round 1/5 dispatched (resume implementer), FIX_BASE 36f8055
Task 5: fix round 1/5 (1 addressed, 0 open — supplyAtHeight now walks cycles; commits 36f8055..19bc1c5)
Task 3: complete (commits 979ed46..b8d203f, review clean)
Task 4: complete (commits b8d203f..bde72d5, review clean)
Task 5: complete (commits bde72d5..19bc1c5, review clean after fix round 1)
Task 6+7: dispatched batched (implementer haiku), BASE 19bc1c5
Task 6+7: review needs fixes; 2 Important (plan-mandated): PriceSource catch has no logging; MempoolSampler.start() unguarded → timer leak on double start.
Ruling: accept both findings over the plan text — why: spec §7 requires failures to be visible (logged) and the service may be restarted; the plan's code was simply incomplete — cost if wrong: none material (one log line, one guard).
Task 6+7: minor (deferred): SupplyTracker.onBlock O(gap) loop if called after a long gap
Task 6+7: minor (deferred): dgbToSats does a dead split() before the exponent branch
Task 6+7: ⚠ wiring of start()/onBlock()/get() is Task 10 — resolved by controller (Task 10 brief calls each exactly once at start()).
Task 6+7: fix round 1/5 dispatched (resume implementer), FIX_BASE c54e4b2
Task 6+7: fix round 1/5 (2 addressed, 0 open — price log + start guard; commits c54e4b2..535634b)
Task 6: complete (commits 19bc1c5..a8f8f92 + fix 535634b, review clean after fix round 1)
Task 7: complete (commits a8f8f92..c54e4b2 + fix 535634b, review clean after fix round 1)
Task 8+9: dispatched batched (implementer sonnet), BASE 535634b
Task 8+9: review approved with 3 Important (plan-mandated): TipWatcher.start() double-call timer leak; reorg walk exceeding MAX_REORG_WALK emits tip silently; start() awaits full 5,760-block backfill before polling.
Ruling: fix all three — (a) guard start() on _timer; (b) log a warning when the walk does not converge, still emit tip (tip data is valid; only lower rows may be stale); (c) new `syncDepth = 240` option: backfill 240 blocks synchronously, arm polling, backfill the rest in the background, honoring stop() — why: spec §5.2 says the ring must be available within seconds and live blocks must not be missed during boot — cost if wrong: recentBlocks/algoShare24h are briefly partial after boot (blocksCounted reports it).
Task 8+9: minor (deferred): `fresh[fresh.length-1]` unguarded for an empty walk (unreachable today)
Task 8+9: ⚠ 'error' listener attachment is Task 10 — will verify in that review.
Task 8: fix round 1/5 dispatched (resume implementer), FIX_BASE 34ebe26
Task 8: fix round 1/5 (3 addressed, 0 open — idempotent start, background backfill w/ syncDepth=240, reorg-bound warning; commits 34ebe26..3a50bc4)
Task 8: minor (deferred): background _backfill vs _tick reorg walk unsynchronized if syncDepth < MAX_REORG_WALK (unreachable with defaults) — add a comment
Task 8: complete (commits 535634b..53d48ff + fix 3a50bc4, review clean after fix round 1)
Task 9: complete (commits 53d48ff..34ebe26, review clean)
Task 10: dispatched (implementer sonnet), BASE 3a50bc4. Carry: TipWatcher now takes syncDepth (default 240) and exposes backfillDone; ChainService must pass syncDepth through.
Ruling (for Task 11): ChainStore must prepare its statements lazily (memoized `stmts` getter) — why: server.js constructs routers/services at module scope (line ~2574) but migrations (incl. 130 chain_blocks) run inside startServer() → initializeDatabase() (line 3551); eager db.prepare on a missing table would crash boot — cost if wrong: first request pays a one-time prepare; none otherwise. Anchors verified: `import { rpcClient }` line 16; `getDatabase` imported line 701; mount after `app.use('/api/network', networkRouter)` line 2574; start after `digidollarPriceSampler.start()` line 3690; stop inside both SIGTERM (3769) and SIGINT (3775) handlers before process.exit; 404 handler at 3543 (mount must stay above it — it does).
Ruling (for Task 11, from Task 5 review): GET /block/:height with height < 1,430,000 → 400 { error: 'height below supported range', minHeight: 1430000 } — reductionAt/subsidySats are Period VI only.
Task 10: BLOCKED by implementer — plan defect: chain-service.test.js fake getblockstats returns a fixed subsidy (25355810338) at fake height ~1,500,010 where the Period VI schedule (used by SupplyTracker.onBlock) pays 107850000000 sats; expectation 18457077640.5 + 253.558 can never hold.
Ruling: fix the FIXTURE, not the code — fake `getblockstats` returns `subsidy: Number(subsidySats(params[0]))` so the fake node agrees with the schedule (as the real node does), and the expectation becomes closeTo(18457077640.5 + 1078.5, 3) — why: in production getblockstats.subsidy and subsidySats(height) are identical by construction (verified at 24,151,775); the test was lying about the node — cost if wrong: none to production code.
Task 10: re-dispatched (same implementer) with the ruling.
Task 10: review approved with 1 Important: overlapping 'tip' events (rebuild awaits price.get()) can broadcast a stale tip last.
Ruling: serialize _onTip through a promise queue and guard _rebuildTip against assigning an older snapshot — why: spec §5.2 emits one tip per block in order; SSE clients must never see height regress — cost if wrong: tip broadcast latency bounded by price RPC latency (≤ a few hundred ms).
Task 10: minor (deferred): _withMarketCap value discarded when passed through assembleSnapshot (recomputed there) — remove redundancy or comment
Task 10: minor (deferred): syncDepth passthrough / backfillDone untested; _supplyAt roll-forward branch untested; double getRow in _supplyAt loop
Task 10: fix round 1/5 dispatched (resume implementer), FIX_BASE f1808cd
Task 10: fix round 1/5 (1 addressed, 0 open — tip queue + height guard; regression test proven RED on f1808cd; commits f1808cd..afac25b)
Task 10: minor (deferred): queued _onTip work not drained on stop() (harmless: hub cleared, errors logged) — consider a stopped flag
Task 10: minor (deferred): redundant duplicate tip broadcast when the height guard discards a stale rebuild
Task 10: complete (commits 3a50bc4..afac25b, review clean after fix round 1)
Task 11: dispatched (implementer sonnet), BASE afac25b. Carry: lazy ChainStore stmts ruling; min-height 400 ruling; server.js anchors (lines 16, 701, 2574, 3690, 3769/3775).
Task 11: full backend suite on 2add4d9 — 232 files / 1797 tests passed, exit 0 (log: .superpowers/sdd/2026-09-04-chain-backend/full-suite.log)
Task 11: complete (commits afac25b..2add4d9, review clean). ⚠ resolved by controller: getBlockSnapshot throws 'no block at height N' (fetcher) / 'block N not in store' (snapshot) → both match the 404 regex; all ChainStore methods go through the stmts getter; SseHub.broadcast catches write errors.
Task 11: minor (deferred): /stream initial res.write not guarded by res.on('error') — a reset during the first frame could throw
Task 11: minor (deferred): 404 regex is an unanchored substring match on err.message
Task 11: note: smoke test needs tunnel port ≠ 14022 on this box (local mainnet node occupies it); boot needs dummy FUNDRAISING_ADDRESS/TREASURY_ADDRESS env vars (pre-existing import-time singletons)
Task 12: dispatched docs-only (implementer haiku), BASE 2add4d9. PR + deploy steps held for the human (outward-facing).
Task 12 (docs): complete (commit e39be12, docs-only; PR/deploy held for human)
FINAL REVIEW (opus, a2d2fc3..e39be12): With fixes. 2 Critical, 6 Important, ~11 Minor. Deferred-minor triage: 3 MUST FIX (empty-walk guard; _supplyAt branch; 404 regex), rest FOLLOW-UP, 1 DROP.
Ruling: earlier "unreachable today" ruling on the empty reorg walk was WRONG — ensureRow via /block/:height can store tip+1 in the poll gap; reproduced by the reviewer. Fix in the wave.
Ruling: fix wave = C1 empty-walk guard + regression test; C2 start() retry with backoff (5 s→60 s) + test; I3/I5 clamp /block/:height to [1,430,000, tipHeight] → 404 above tip, and classify 'Block height out of range' as 404; I4 single-source supply (advance the SupplyTracker checkpoint to the tip with the schedule; _supplyAt returns null when tipHeight is null); I6 retention = prune rows below tip − 20,160 (3.5 days; covers the 5,760 window + scrub range) once per 5,760 blocks, documented; I7 SseHub evicts on write()===false with writableLength > 1 MB, hub capped at 500 clients (route 503 above); I8 pass logger.warn from server.js and throttle repeated tip-poll failure logs to once per minute; plus one-liners: getBlockSnapshot enforces the 1,430,000 floor, stop() clears _started, docs note mempool may be null briefly and algoShare24h is window-relative.
Ruling: /block/:height stays unbounded BELOW the tip (down to 1,430,000) per spec §7 "scrub past the cache fetches on demand" — amplification is bounded by publicLimiter (≤1,500 RPC calls / 15 min / IP); revisit if abused — cost if wrong: RPC contention on the shared client under a deliberate burst.
Ruling: retention is a plan gap; 20,160-row cap (~6 MB) is the decision — cost if wrong: scrubbing older than 3.5 days re-fetches from RPC (still works).
Final fix wave dispatched (opus), FIX_BASE e39be12.
Final fix wave: DONE_WITH_CONCERNS (commits e39be12..c8ef755; chain dir 79 tests, full suite 232 files / 1810 tests green). Implementer corrected my I6 test tip (1,503,360 is the 5,760 multiple, not 1,502,080).
Parked (follow-up) — Ruling: on an empty reorg walk the watcher adopts the tip without emitting, so that block's mined bytes/supply accounting is skipped and the served tip lags ≤15 s until the next block; supply self-heals via _supplyAt. Improvement: emit `tip` with the adopted row when the height advanced. Not load-bearing; no second fix wave.
Parked (follow-up) — retention prunes only on an exact 5,760 boundary; a restart across it defers pruning ~1 day. Harmless.
Scoped re-review dispatched (opus), FIX_BASE e39be12.
Final re-review (opus): all 8 findings ADDRESSED, no new Critical/Important. Independently re-ran chain-service + tip-watcher tests (18 passed).
Parked (follow-up) — Ruling: ChainService._stopping is never reset, so start() after stop() is a no-op; only callers of stop() are the SIGTERM/SIGINT handlers before process.exit, so unreachable today; one-line fix (`this._stopping = false` at the top of start()) for the follow-up PR. Not load-bearing; no second fix wave.
Parked (follow-up): TipWatcher.start() arms setInterval after its awaits, so stop() during an in-flight successful start leaves a poll timer (pre-existing shape).
Parked (follow-up): 'tip poll recovered' logs on a successful getbestblockhash even if the walk then throws (cosmetic).
BRANCH COMPLETE: feat/chain-timechain-api at c8ef755 (22 commits over origin/main a2d2fc3). Full suite 232 files / 1810 tests green. Unpushed. PR + deploy await the human.

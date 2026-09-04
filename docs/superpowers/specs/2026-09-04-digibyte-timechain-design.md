# DigiByte Timechain — design spec

Date: 2026-09-04
Status: approved in brainstorming, awaiting implementation plan

## 1. Purpose

A mobile app (Android + iOS, Flutter) that shows the live state of the DigiByte
chain as a single "clock face" dial, modelled on timechaincalendar.com but
translated to DigiByte's rules and branded with DigiByte colors and logos.
Data comes from our own infrastructure (the DigiScope backend and the mainnet
node behind it), not from third-party explorers.

Working name: **DigiByte Timechain**. Repo: `digibyte-timechain` (this repo).
The name is a placeholder and may change before store submission.

## 2. Scope of v1

In scope:
- One live screen: the dial, header stats, block timer, reward breakdown,
  fee rates, mempool tiles.
- A scrub bar to step back through recent blocks; every tile that is
  block-specific re-renders for the selected block.
- Settings: theme (dark default, light), fiat currency for the price tiles.
- Offline behaviour: last snapshot shown with a "stale" badge and its age.

Out of scope for v1 (explicitly deferred):
- Search by height / txid / address and any block or tx detail page.
- DigiDollar and oracle tiles (one tile slot is reserved; see §4.3).
- Notifications, widgets, watch faces.
- Historical price for scrubbed blocks (scrubbed blocks show the live price
  tiles greyed out).

## 3. Decisions locked in brainstorming

| # | Decision | Choice |
|---|----------|--------|
| D1 | Platform | Flutter, Android + iOS from one codebase |
| D2 | Data source | New public routes on the DigiScope Express backend (`api.digiscope.me`) |
| D3 | Live feed | Server-sent events (SSE) pushed on new block, with polling fallback |
| D4 | v1 scope | Live dial + scrubber; no search |
| D5 | State management | Riverpod; models with freezed + json_serializable |
| D6 | Backend storage | Existing DigiScope SQLite (better-sqlite3), one new table |

## 4. The dial, translated to DigiByte

DigiByte differs from Bitcoin in ways that make a literal copy wrong:

| Bitcoin concept on the reference site | DigiByte reality | What we show instead |
|---|---|---|
| Halving every 210,000 blocks | Subsidy falls 1% every 10,080 blocks (~monthly) | "Blocks to next reduction" ring |
| Epoch (halving era) | Reduction step number | "Reduction #N" in the header |
| Difficulty adjust every 2016 blocks | DigiShield retargets every block, per algorithm | Algorithm-share ring |
| 21M cap | 21B cap, reached ~2035 | Supply as % of 21B |
| ~10-minute blocks, 144/day | 15-second target, ~5,760/day | Recent-blocks ring covers 240 blocks (~1 h) |
| sats/vB | sat/vB (DGB has segwit) | Same unit, same label |

### 4.1 Rings (outer to inner)

1. **Supply ring.** Full circle = 21,000,000,000 DGB. Arc = minted so far.
   Marker label: supply in billions and % of cap.
2. **Reward-reduction ring.** Full circle = 10,080 blocks. Arc = blocks
   elapsed in the current cycle. Marker label: blocks remaining until the
   next 1% subsidy cut.
3. **Algorithm ring.** Five arcs proportional to each algorithm's share of
   blocks in the last 24 h (5,760 blocks). Colors fixed per algorithm:
   SHA256d, Scrypt, Skein, Qubit, Odocrypt. Legend on tap.
4. **Recent-blocks ring.** 240 ticks, one per block, newest at 12 o'clock
   running clockwise. Tick color = algorithm. Tick length = block size
   relative to 1 MB (min length clamped so empty blocks still show).

When a block is selected in the scrubber, rings 1, 2 and 4 are recomputed
for that height; ring 3 keeps the live 24 h shares (documented in the UI as
"live").

### 4.2 Center and header

Center: block height (large), fee rate median in sat/vB with `[min – max]`
band, block size in MB, tx count, an "open in DigiScope explorer" link.

Header (left): subsidy per block, supply + % of 21B.
Header (right): USD per DGB, DGB per USD, market cap USD.
Header (top-left): "Reduction #N" where N counts 10,080-block steps since
the reduction schedule began. The exact origin height is a backend
constant and must be verified against Core's `GetBlockSubsidy` during
implementation (see §8).

### 4.3 Tiles below the dial

- **Last block** timer: seconds since the selected block, ring fills over
  the 15 s target and keeps counting past it in a warning color.
- **Reward**: subsidy + tx fees = reward, with an algorithm badge and the
  pool tag from the coinbase string ("MINED BY → name"; "unknown" if no
  match).
- **Fee rates**: Priority (next ~2 blocks) and Anytime (~20 blocks), sat/vB.
- **Mempool**: inflow in vB/s, unconfirmed tx count, depth in blocks.
- **Reserved tile**: hidden in v1, wired for DigiDollar supply + oracle
  consensus count in v1.1.

### 4.4 Scrubber

Horizontal bar with prev/next buttons and a draggable knob. Right edge =
tip. Drag resolution = 1 block; the knob snaps to a height. Releasing at the
right edge returns to live mode. In non-live mode the timer tile shows the
block's timestamp instead of a running counter.

## 5. Backend: `chain` module in the DigiScope Express backend

Lives in the DigiScope backend repo (`/opt/digiscope-backend` on the VPS;
first implementation step is cloning it locally). All routes are public and
unauthenticated, rate-limited by the existing nginx config.

### 5.1 Routes

| Route | Purpose |
|---|---|
| `GET /api/chain/tip` | Full snapshot for the current tip (JSON, §5.3) |
| `GET /api/chain/block/:height` | Snapshot for a historical block; price and mempool sections omitted |
| `GET /api/chain/stream` | SSE. Events: `tip` (on new block, full snapshot), `mempool` (every 5 s, mempool + price sections only), `ping` (every 25 s keepalive) |

### 5.2 Data flow

```
node RPC ──poll getbestblockhash every 2 s──▶ TipWatcher
                                                │ new hash
                                                ▼
                                       SnapshotBuilder ──▶ cache (in-memory tip)
                                                │            └──▶ SQLite chain_snapshots
                                                ▼
                                          SSE broadcaster ──▶ clients
MempoolSampler (every 5 s): getmempoolinfo + estimatesmartfee ──▶ SSE `mempool`
PriceSource: reuse DigiScope's existing price fetch (verify in impl, §8)
```

SnapshotBuilder RPC calls per block: `getblockchaininfo`, `getblock <hash> 2`
(for coinbase, size, tx count, algorithm), `getblockstats <height>` (fee
percentiles, total fees, subsidy), `gettxoutsetinfo` is NOT called per block
(too slow); supply is computed from the subsidy schedule and cross-checked
once at startup.

Mempool inflow (vB/s) = delta of cumulative mempool bytes entering, sampled
every 5 s; computed server-side from consecutive `getmempoolinfo` calls plus
the vsize of blocks mined in the window.

### 5.3 Snapshot shape (abridged)

```json
{
  "height": 24123456, "hash": "…", "time": 1788000000,
  "algo": "scrypt", "sizeBytes": 123456, "txCount": 87,
  "feeRate": {"median": 4.1, "min": 1.0, "max": 302.0},
  "reward": {"subsidy": 241.7, "fees": 1.23, "total": 242.93},
  "pool": {"tag": "F2Pool", "raw": "…"},
  "reduction": {"step": 118, "blocksUntilNext": 4021, "cycle": 10080},
  "supply": {"total": 17650000000, "cap": 21000000000},
  "algoShare24h": {"sha256d": 0.2, "scrypt": 0.2, "skein": 0.2, "qubit": 0.2, "odocrypt": 0.2},
  "recentBlocks": [{"height": 24123456, "algo": "scrypt", "sizeBytes": 123456}, …240],
  "mempool": {"txCount": 1234, "vbytes": 456789, "inflowVbPerSec": 210.5, "depthBlocks": 0.5,
              "fees": {"priority": 3.5, "anytime": 0.2}},
  "price": {"usd": 0.0123, "marketCapUsd": 217000000, "asOf": 1788000000}
}
```

### 5.4 Storage

Table `chain_snapshots(height INTEGER PRIMARY KEY, json TEXT, created_at)`.
Backfilled lazily: a request for an uncached height builds it on demand and
stores it. A startup job pre-warms the last 240 heights.

## 6. Flutter app structure

```
lib/
  data/      api_client.dart, sse_client.dart (with backoff + polling fallback),
             models/ (freezed), repositories/chain_repository.dart
  domain/    reduction_schedule.dart, ring_math.dart, formatters.dart  (pure Dart, no Flutter imports)
  ui/        dial/ (CustomPainter rings, center), tiles/, scrubber/, settings/, theme/
  app.dart, main.dart
```

Providers: `tipSnapshotProvider` (stream), `selectedHeightProvider`,
`selectedSnapshotProvider` (derived; tip when live, else fetched),
`settingsProvider` (persisted with shared_preferences).

Branding: DigiByte blue palette (primary `#002352`, accent `#0066CC` —
derived from the public brand kit, verify against the official assets before
final theming) and the ClearBg DigiByte logo files used in the oracle repo.

## 7. Error handling

- SSE drop: exponential backoff 1 s → 30 s, and while disconnected poll
  `/api/chain/tip` every 10 s. UI shows a small "reconnecting" dot.
- No network at launch: load last snapshot from local cache (a JSON file in the app documents directory via path_provider), show "stale · 4m ago" badge.
- Backend RPC failure: routes return 503 with `retryAfter`; the cached tip
  keeps serving until the node recovers; SSE keeps sending `ping`.
- Scrub to a height that fails to build: tile shows an error state with
  retry; scrubber does not lock.

## 8. Testing and verification

Backend:
- Route tests (jest + supertest) against a mocked RPC client: tip, block,
  stream framing, 503 path.
- Snapshot builder unit tests with recorded RPC fixtures from mainnet.
- Verification tasks in the plan: confirm the reduction schedule constants
  against Core's `GetBlockSubsidy`; confirm the node exposes per-block
  `pow_algo` in `getblock` and `getblockstats` is available (index needs);
  confirm DigiScope's existing price source and its refresh interval.

Flutter:
- Unit tests for `reduction_schedule`, `ring_math`, `formatters`.
- Golden tests for the dial at 360 px and 800 px widths, dark and light.
- Widget tests: scrubber snaps to block, live mode resumes at right edge,
  stale badge appears offline.
- Manual: Samsung SM-N950U (API 28) and an iOS simulator; check the 15 s
  timer ring under real block cadence for 10 minutes.

## 9. Deploy

- Backend: merge to the DigiScope backend, `pm2 restart digiscope-backend`,
  nginx location for `/api/chain/stream` with `proxy_buffering off`.
- App: debug builds sideloaded; store submission is a separate later task.

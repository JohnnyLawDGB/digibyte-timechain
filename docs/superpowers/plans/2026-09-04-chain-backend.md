# DigiByte Timechain — Backend `chain` Module Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add three public routes to the DigiScope Express backend — `GET /api/chain/tip`, `GET /api/chain/block/:height`, and an SSE stream `GET /api/chain/stream` — that serve the snapshot JSON the Timechain app renders, built from our own mainnet node.

**Architecture:** A `chain` service directory under `backend/src/services/chain/` holds pure helpers (subsidy schedule, reduction cycle, pool tags, fee-unit conversion), a SQLite-backed block store (one row per block), a tip watcher that polls `getbestblockhash` every 2 s, a mempool sampler every 5 s, an oracle-price source, a supply tracker, and an SSE hub. A thin Express router in `backend/src/controllers/chain.js` takes the service by dependency injection so it is testable with a fake. Snapshots are assembled on demand from stored rows, never cached as blobs.

**Tech Stack:** Node 22 ESM, Express 4, better-sqlite3 (in-memory in tests), vitest + supertest, the existing `rpcClient` (`backend/src/utils/rpcClient.js`) over DigiByte Core v9.26.4 RPC.

**Spec:** `~/digibyte-timechain/docs/superpowers/specs/2026-09-04-digibyte-timechain-design.md` (§5 Backend, §4 for the numbers the snapshot must carry). This plan lives in the Timechain repo; the code lives in the DigiScope monorepo.

## Global Constraints

- Code goes in the DigiScope monorepo at `/home/polloloco/digibyte-compendium/backend` (remote `git@github.com:JohnnyLawDGB/digibyte-compendium.git`). Work on a branch `feat/chain-timechain-api` cut from `master`. Do NOT touch `/opt/digiscope-backend` on the VPS until the deploy task.
- All routes are PUBLIC and unauthenticated. Never import `panopticon-service.js` — Panopticon is private forensics and is not this app's data source.
- Fee unit everywhere in output JSON is **DGB per kB** (`"unit": "DGB/kB"`). Core's `getblockstats` returns sat/vB; convert with `satPerVb / 100000`. Core's `estimatesmartfee` already returns DGB/kB.
- Subsidy schedule is Core's Period VI: `nSubsidy = 2157 * COIN / 2`, then `months = floor((height − 1,430,000) × 15 / 2,628,000)` iterations of `n = n × 98884 / 100000` in integer math, `0` if below 1 DGB. Verified: height 24,151,775 → 25,355,810,338 sats; height 24,206,000 → 25,072,839,494 sats.
- Reduction cycle: `BLOCKS_PER_MONTH = 175,200`, origin height `1,430,000`. Verified: height 24,151,775 → step 130, next cut at 24,206,000, 54,225 blocks to go, fraction 0.6905.
- Supply cap `21,000,000,000` DGB. Block capacity constant for mempool depth: `1,000,000` bytes.
- Algorithm keys in JSON: `sha256d`, `scrypt`, `skein`, `qubit`, `odocrypt` (Core reports `odo`; normalize it).
- Tests: vitest, colocated `*.test.js`, run with `cd backend && npx vitest run <file>` (the backend has its own `vitest.config.js` with `pool: 'forks'`). Mock RPC with a plain object of async functions; never hit a real node in tests.
- Migrations have no ledger and re-run every boot: every migration body must be guarded by an existence check (see `backend/src/models/migrations/129_report_digiscope_identity.js`).
- Commit messages: conventional prefix (`feat:`, `test:`, `docs:`), end with
  `Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>`.

---

## File Structure

| File | Responsibility |
|---|---|
| `backend/src/services/chain/constants.js` | Consensus constants shared by every helper |
| `backend/src/services/chain/subsidy.js` | `subsidySats(height)` — exact Period VI replica |
| `backend/src/services/chain/reduction.js` | `reductionAt(height)` — cycle step, blocks to next cut, fraction |
| `backend/src/services/chain/pools.js` | `poolTagFromCoinbase(hex)` — coinbase string → pool label |
| `backend/src/services/chain/fees.js` | `satPerVbToDgbPerKb(n)` and `feeRateFromStats(stats, nTx)` |
| `backend/src/services/chain/block-fetcher.js` | `fetchBlockRow(rpc, height)` — RPC → one row |
| `backend/src/services/chain/chain-store.js` | `ChainStore` — SQLite rows + meta, range queries, algo share |
| `backend/src/services/chain/snapshot.js` | `assembleSnapshot(store, height, extras)` — rows → API JSON |
| `backend/src/services/chain/supply-tracker.js` | `SupplyTracker` — `gettxoutsetinfo` once, then per-block increments |
| `backend/src/services/chain/mempool-sampler.js` | `MempoolSampler` — 5 s sampling, inflow, depth, fee estimates |
| `backend/src/services/chain/price-source.js` | `PriceSource` — cached `getoracleprice` |
| `backend/src/services/chain/tip-watcher.js` | `TipWatcher` — 2 s poll, reorg-safe ingest, `tip` events |
| `backend/src/services/chain/sse-hub.js` | `SseHub` — client set, broadcast, ping |
| `backend/src/services/chain/chain-service.js` | `ChainService` — wires everything; `getTipSnapshot()`, `getBlockSnapshot()` |
| `backend/src/controllers/chain.js` | `createChainRouter({ service })` — the three routes |
| `backend/src/models/migrations/130_chain_blocks.js` | `chain_blocks` + `chain_meta` tables |
| `backend/src/models/db.js` | register migration 130 |
| `backend/src/server.js` | mount router, start/stop service |

Snapshot JSON produced by `assembleSnapshot` (the contract the Flutter plan consumes):

```json
{
  "height": 24151710, "hash": "…", "prevHash": "…", "time": 1788518429,
  "algo": "qubit", "sizeBytes": 7579, "txCount": 4,
  "feeRate": {"unit": "DGB/kB", "median": 0.10003, "min": 0.0011, "max": 0.1102},
  "reward": {"subsidy": 253.55810338, "fees": 0.64499045, "total": 254.20309383},
  "pool": {"tag": "m2pool.com", "raw": "…/m2pool.com/"},
  "reduction": {"step": 130, "cycle": 175200, "blocksUntilNext": 54290, "nextHeight": 24206000, "fraction": 0.6901},
  "supply": {"total": 18457061165.39, "cap": 21000000000},
  "algoShare24h": {"sha256d": 0.2, "scrypt": 0.2, "skein": 0.2125, "qubit": 0.1833, "odocrypt": 0.2042, "blocksCounted": 240},
  "recentBlocks": [{"height": 24151710, "algo": "qubit", "sizeBytes": 7579, "txCount": 4, "time": 1788518429}],
  "mempool": {"txCount": 0, "vbytes": 0, "inflowVbPerSec": 0, "depthBlocks": 0,
              "fees": {"unit": "DGB/kB", "priority": 0.011, "anytime": 0.0011}, "asOf": 1788519200},
  "price": {"usd": 0.004692, "marketCapUsd": 86600000, "asOf": 1788519180, "isStale": false},
  "isTip": true
}
```

`feeRate` is `null` for a block with only the coinbase. `mempool` and `price` are present only when `isTip` is true. `supply.total` is `null` until the supply tracker has finished its first scan.

---

### Task 1: Consensus constants and the subsidy replica

**Files:**
- Create: `backend/src/services/chain/constants.js`
- Create: `backend/src/services/chain/subsidy.js`
- Test: `backend/src/services/chain/subsidy.test.js`

**Interfaces:**
- Produces: `constants.js` exports `COIN = 100000000n`, `PERIOD_VI_START = 1430000`, `BLOCK_TIME_SECONDS = 15`, `SECONDS_PER_MONTH = 2628000`, `BLOCKS_PER_MONTH = 175200`, `SUPPLY_CAP_DGB = 21000000000`, `BLOCK_CAPACITY_BYTES = 1000000`, `ALGOS = ['sha256d','scrypt','skein','qubit','odocrypt']`, `normalizeAlgo(s)`.
- Produces: `subsidy.js` exports `subsidySats(height: number): bigint` and `subsidyDgb(height: number): number`.

- [ ] **Step 1: Create the branch**

```bash
cd /home/polloloco/digibyte-compendium && git checkout master && git pull --ff-only && git checkout -b feat/chain-timechain-api
```

- [ ] **Step 2: Write the failing test**

```js
// backend/src/services/chain/subsidy.test.js
import { describe, it, expect } from 'vitest';
import { subsidySats, subsidyDgb } from './subsidy.js';
import { normalizeAlgo, ALGOS } from './constants.js';

describe('subsidySats — Core GetBlockSubsidy Period VI replica', () => {
  it('matches the live node at height 24,151,775 (getblockstats.subsidy)', () => {
    expect(subsidySats(24151775)).toBe(25355810338n);
  });
  it('is flat inside a month and steps down at the boundary', () => {
    expect(subsidySats(24151710)).toBe(25355810338n);
    expect(subsidySats(24205999)).toBe(25355810338n);
    expect(subsidySats(24206000)).toBe(25072839494n);
  });
  it('starts at 1078.5 DGB on the first Period VI block', () => {
    expect(subsidySats(1430000)).toBe(107850000000n);
  });
  it('refuses pre-Period-VI heights', () => {
    expect(() => subsidySats(1429999)).toThrow(RangeError);
  });
  it('subsidyDgb converts to a float in DGB', () => {
    expect(subsidyDgb(24151775)).toBeCloseTo(253.55810338, 8);
  });
});

describe('normalizeAlgo', () => {
  it('maps Core names to API keys', () => {
    expect(normalizeAlgo('odo')).toBe('odocrypt');
    expect(normalizeAlgo('sha256d')).toBe('sha256d');
    expect(normalizeAlgo('Scrypt')).toBe('scrypt');
    expect(ALGOS).toEqual(['sha256d', 'scrypt', 'skein', 'qubit', 'odocrypt']);
  });
  it('throws on an unknown algorithm', () => {
    expect(() => normalizeAlgo('groestl')).toThrow(/unknown algo/);
  });
});
```

- [ ] **Step 3: Run test to verify it fails**

Run: `cd /home/polloloco/digibyte-compendium/backend && npx vitest run src/services/chain/subsidy.test.js`
Expected: FAIL — "Failed to resolve import ./subsidy.js".

- [ ] **Step 4: Write the implementation**

```js
// backend/src/services/chain/constants.js
/**
 * DigiByte consensus constants used by the Timechain chain module.
 * Values verified 2026-09-04 against digibyte/src/validation.{h,cpp} and
 * src/kernel/chainparams.cpp (v9.26.4 lineage).
 */
export const COIN = 100000000n;
export const PERIOD_VI_START = 1430000;        // consensus.workComputationChangeTarget
export const BLOCK_TIME_SECONDS = 15;
export const SECONDS_PER_MONTH = 2628000;      // 60*60*24*365/12 (integer)
export const BLOCKS_PER_MONTH = SECONDS_PER_MONTH / BLOCK_TIME_SECONDS; // 175200
export const SUPPLY_CAP_DGB = 21000000000;
export const BLOCK_CAPACITY_BYTES = 1000000;   // "one block" for mempool depth
export const ALGOS = ['sha256d', 'scrypt', 'skein', 'qubit', 'odocrypt'];

const ALGO_ALIASES = { odo: 'odocrypt', odocrypt: 'odocrypt', sha256d: 'sha256d', scrypt: 'scrypt', skein: 'skein', qubit: 'qubit' };

export function normalizeAlgo(name) {
  const key = ALGO_ALIASES[String(name).toLowerCase()];
  if (!key) throw new Error(`unknown algo: ${name}`);
  return key;
}
```

```js
// backend/src/services/chain/subsidy.js
import { COIN, PERIOD_VI_START, BLOCK_TIME_SECONDS, SECONDS_PER_MONTH } from './constants.js';

/**
 * Exact replica of GetBlockSubsidy() Period VI (height >= 1,430,000):
 *   nSubsidy = 2157 * COIN / 2
 *   months   = blocks * 15 / 2,628,000   (integer division)
 *   repeat months times: nSubsidy = nSubsidy * 98884 / 100000
 *   if nSubsidy < COIN: 0
 * BigInt keeps the integer truncation identical to the C++.
 */
export function subsidySats(height) {
  if (!Number.isInteger(height) || height < PERIOD_VI_START) {
    throw new RangeError(`subsidySats supports Period VI only (height >= ${PERIOD_VI_START}), got ${height}`);
  }
  let n = (2157n * COIN) / 2n;
  const months = Math.floor(((height - PERIOD_VI_START) * BLOCK_TIME_SECONDS) / SECONDS_PER_MONTH);
  for (let i = 0; i < months; i++) n = (n * 98884n) / 100000n;
  return n < COIN ? 0n : n;
}

export function subsidyDgb(height) {
  return Number(subsidySats(height)) / 1e8;
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `cd /home/polloloco/digibyte-compendium/backend && npx vitest run src/services/chain/subsidy.test.js`
Expected: PASS, 7 tests.

- [ ] **Step 6: Commit**

```bash
cd /home/polloloco/digibyte-compendium && git add backend/src/services/chain/constants.js backend/src/services/chain/subsidy.js backend/src/services/chain/subsidy.test.js && git commit -m "feat(chain): consensus constants and exact Period VI subsidy replica

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 2: Reduction cycle, pool tags, fee conversion

**Files:**
- Create: `backend/src/services/chain/reduction.js`
- Create: `backend/src/services/chain/pools.js`
- Create: `backend/src/services/chain/fees.js`
- Test: `backend/src/services/chain/reduction.test.js`, `backend/src/services/chain/pools.test.js`, `backend/src/services/chain/fees.test.js`

**Interfaces:**
- Consumes: `constants.js` from Task 1.
- Produces: `reductionAt(height) → { step, cycle, blocksUntilNext, nextHeight, fraction }`; `poolTagFromCoinbase(hex) → { tag: string|null, raw: string }`; `satPerVbToDgbPerKb(n) → number`; `feeRateFromStats(stats, txCount) → { unit, median, min, max } | null`.

- [ ] **Step 1: Write the failing tests**

```js
// backend/src/services/chain/reduction.test.js
import { describe, it, expect } from 'vitest';
import { reductionAt } from './reduction.js';

describe('reductionAt', () => {
  it('reports step 130 and 54,225 blocks to the next cut at 24,151,775', () => {
    const r = reductionAt(24151775);
    expect(r).toEqual({ step: 130, cycle: 175200, blocksUntilNext: 54225, nextHeight: 24206000, fraction: expect.closeTo(0.6905, 4) });
  });
  it('rolls to the next step exactly on the boundary', () => {
    expect(reductionAt(24205999).step).toBe(130);
    expect(reductionAt(24206000)).toMatchObject({ step: 131, blocksUntilNext: 175200, fraction: 0 });
  });
  it('is step 1 at the Period VI origin', () => {
    expect(reductionAt(1430000)).toMatchObject({ step: 1, blocksUntilNext: 175200, fraction: 0 });
  });
  it('refuses pre-Period-VI heights', () => {
    expect(() => reductionAt(1429999)).toThrow(RangeError);
  });
});
```

```js
// backend/src/services/chain/pools.test.js
import { describe, it, expect } from 'vitest';
import { poolTagFromCoinbase } from './pools.js';

// Real coinbase scriptSig of mainnet block 24,151,710 (m2pool.com), captured 2026-09-04.
const M2POOL = '049e867001041da09a6a080c030081ab0500000c2f6d32706f6f6c2e636f6d2f';

describe('poolTagFromCoinbase', () => {
  it('recognises m2pool.com from a real coinbase', () => {
    const r = poolTagFromCoinbase(M2POOL);
    expect(r.tag).toBe('m2pool.com');
    expect(r.raw).toContain('/m2pool.com/');
  });
  it('is case-insensitive and returns null for an unknown miner', () => {
    expect(poolTagFromCoinbase(Buffer.from('/ViaBTC/Mined by x/').toString('hex')).tag).toBe('ViaBTC');
    expect(poolTagFromCoinbase(Buffer.from('/nobody-we-know/').toString('hex')).tag).toBeNull();
  });
  it('strips non-printable bytes from raw', () => {
    expect(poolTagFromCoinbase(M2POOL).raw).toMatch(/^[\x20-\x7e]*$/);
  });
});
```

```js
// backend/src/services/chain/fees.test.js
import { describe, it, expect } from 'vitest';
import { satPerVbToDgbPerKb, feeRateFromStats } from './fees.js';

// getblockstats 24151710 (2026-09-04): percentiles [10003×5], min 110, max 11020 sat/vB
const STATS = { feerate_percentiles: [10003, 10003, 10003, 10003, 10003], minfeerate: 110, maxfeerate: 11020 };

describe('fees', () => {
  it('converts sat/vB to DGB/kB', () => {
    expect(satPerVbToDgbPerKb(10003)).toBeCloseTo(0.10003, 8);
    expect(satPerVbToDgbPerKb(110)).toBeCloseTo(0.0011, 8);
  });
  it('builds a DGB/kB fee band from getblockstats', () => {
    expect(feeRateFromStats(STATS, 4)).toEqual({ unit: 'DGB/kB', median: expect.closeTo(0.10003, 8), min: expect.closeTo(0.0011, 8), max: expect.closeTo(0.1102, 8) });
  });
  it('returns null for a coinbase-only block', () => {
    expect(feeRateFromStats({ feerate_percentiles: [0, 0, 0, 0, 0], minfeerate: 0, maxfeerate: 0 }, 1)).toBeNull();
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd /home/polloloco/digibyte-compendium/backend && npx vitest run src/services/chain/reduction.test.js src/services/chain/pools.test.js src/services/chain/fees.test.js`
Expected: FAIL — three unresolved imports.

- [ ] **Step 3: Write the implementations**

```js
// backend/src/services/chain/reduction.js
import { PERIOD_VI_START, BLOCKS_PER_MONTH } from './constants.js';

/** Where `height` sits in the 175,200-block subsidy-reduction cycle. */
export function reductionAt(height) {
  if (!Number.isInteger(height) || height < PERIOD_VI_START) {
    throw new RangeError(`reductionAt supports Period VI only (height >= ${PERIOD_VI_START}), got ${height}`);
  }
  const n = height - PERIOD_VI_START;
  const months = Math.floor(n / BLOCKS_PER_MONTH);   // identical to Core's blocks*15/2628000
  const nextHeight = PERIOD_VI_START + (months + 1) * BLOCKS_PER_MONTH;
  return {
    step: months + 1,
    cycle: BLOCKS_PER_MONTH,
    blocksUntilNext: nextHeight - height,
    nextHeight,
    fraction: (n % BLOCKS_PER_MONTH) / BLOCKS_PER_MONTH,
  };
}
```

```js
// backend/src/services/chain/pools.js
/** needle (lower-case substring of the coinbase text) → display label */
const KNOWN_POOLS = [
  ['m2pool.com', 'm2pool.com'],
  ['viabtc', 'ViaBTC'],
  ['f2pool', 'F2Pool'],
  ['antpool', 'AntPool'],
  ['prohashing', 'Prohashing'],
  ['zergpool', 'Zergpool'],
  ['zpool', 'zpool'],
  ['nicehash', 'NiceHash'],
  ['mining-dutch', 'Mining-Dutch'],
  ['miningdutch', 'Mining-Dutch'],
  ['digihash', 'DigiHash'],
  ['2miners', '2Miners'],
  ['solopool', 'SoloPool'],
  ['ckpool', 'CKPool'],
];

/** Decode a coinbase scriptSig hex and look for a known pool marker. */
export function poolTagFromCoinbase(hex) {
  const raw = Buffer.from(hex || '', 'hex').toString('latin1').replace(/[^\x20-\x7e]/g, '');
  const lower = raw.toLowerCase();
  for (const [needle, label] of KNOWN_POOLS) {
    if (lower.includes(needle)) return { tag: label, raw };
  }
  return { tag: null, raw };
}
```

```js
// backend/src/services/chain/fees.js
export const FEE_UNIT = 'DGB/kB';

/** Core's getblockstats speaks sat/vB; the app speaks DGB/kB. 1 sat/vB = 1000 sat/kB = 1e-5 DGB/kB. */
export function satPerVbToDgbPerKb(satPerVb) {
  return Number(satPerVb) / 100000;
}

/** Fee band for a block; null when only the coinbase is present (no fee-paying tx). */
export function feeRateFromStats(stats, txCount) {
  if (!stats || txCount <= 1) return null;
  const p = stats.feerate_percentiles || [];
  return {
    unit: FEE_UNIT,
    median: satPerVbToDgbPerKb(p[2] ?? 0),
    min: satPerVbToDgbPerKb(stats.minfeerate ?? 0),
    max: satPerVbToDgbPerKb(stats.maxfeerate ?? 0),
  };
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd /home/polloloco/digibyte-compendium/backend && npx vitest run src/services/chain/`
Expected: PASS, 17 tests across 4 files.

- [ ] **Step 5: Commit**

```bash
cd /home/polloloco/digibyte-compendium && git add backend/src/services/chain && git commit -m "feat(chain): reduction cycle, pool tag lookup, DGB/kB fee conversion

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 3: Migration 130 and the block store

**Files:**
- Create: `backend/src/models/migrations/130_chain_blocks.js`
- Modify: `backend/src/models/db.js` (register after migration 129, just before `db.pragma('foreign_keys = ON')`)
- Create: `backend/src/services/chain/chain-store.js`
- Test: `backend/src/services/chain/chain-store.test.js`

**Interfaces:**
- Produces: `migrate130(db)` idempotent. `class ChainStore { constructor(db); upsertRow(row); getRow(height); latestHeight(); getRange(fromHeight, toHeight); algoShare(fromHeight, toHeight); deleteFrom(height); getMeta(key); setMeta(key, value) }`.
- Row shape (also what Task 4 produces): `{ height, hash, prevHash, time, algo, sizeBytes, txCount, subsidySats, feesSats, feeMedian, feeMin, feeMax, poolTag, coinbaseText }` — `feeMedian/feeMin/feeMax` in DGB/kB or `null`.

- [ ] **Step 1: Write the failing test**

```js
// backend/src/services/chain/chain-store.test.js
import { describe, it, expect, beforeEach } from 'vitest';
import Database from 'better-sqlite3';
import migrate130 from '../../models/migrations/130_chain_blocks.js';
import { ChainStore } from './chain-store.js';

const row = (height, algo = 'qubit', extra = {}) => ({
  height, hash: `h${height}`, prevHash: `h${height - 1}`, time: 1788500000 + height * 15,
  algo, sizeBytes: 500, txCount: 1, subsidySats: 25355810338, feesSats: 0,
  feeMedian: null, feeMin: null, feeMax: null, poolTag: 'm2pool.com', coinbaseText: '/m2pool.com/', ...extra,
});

describe('ChainStore', () => {
  let db, store;
  beforeEach(() => { db = new Database(':memory:'); migrate130(db); migrate130(db); store = new ChainStore(db); });

  it('round-trips a row and reports the latest height', () => {
    store.upsertRow(row(100)); store.upsertRow(row(101));
    expect(store.getRow(101)).toMatchObject({ height: 101, algo: 'qubit', poolTag: 'm2pool.com', feeMedian: null });
    expect(store.latestHeight()).toBe(101);
    expect(store.getRow(999)).toBeNull();
  });
  it('upsert replaces a row at the same height (reorg)', () => {
    store.upsertRow(row(100)); store.upsertRow(row(100, 'skein', { hash: 'other' }));
    expect(store.getRow(100)).toMatchObject({ hash: 'other', algo: 'skein' });
    expect(db.prepare('SELECT COUNT(*) c FROM chain_blocks').get().c).toBe(1);
  });
  it('getRange returns newest first, inclusive, only rows that exist', () => {
    for (const h of [100, 101, 103]) store.upsertRow(row(h));
    expect(store.getRange(100, 103).map(r => r.height)).toEqual([103, 101, 100]);
  });
  it('algoShare counts by algorithm across a range', () => {
    store.upsertRow(row(1, 'sha256d')); store.upsertRow(row(2, 'sha256d')); store.upsertRow(row(3, 'odocrypt')); store.upsertRow(row(50, 'skein'));
    expect(store.algoShare(1, 3)).toEqual({ sha256d: 2, scrypt: 0, skein: 0, qubit: 0, odocrypt: 1, blocksCounted: 3 });
  });
  it('deleteFrom drops the height and everything above it', () => {
    for (const h of [10, 11, 12]) store.upsertRow(row(h));
    store.deleteFrom(11);
    expect(store.latestHeight()).toBe(10);
  });
  it('meta is a string key/value map', () => {
    expect(store.getMeta('supply_sats')).toBeNull();
    store.setMeta('supply_sats', '1845707764049591449'); store.setMeta('supply_sats', '5');
    expect(store.getMeta('supply_sats')).toBe('5');
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /home/polloloco/digibyte-compendium/backend && npx vitest run src/services/chain/chain-store.test.js`
Expected: FAIL — cannot resolve `130_chain_blocks.js`.

- [ ] **Step 3: Write the migration, register it, write the store**

```js
// backend/src/models/migrations/130_chain_blocks.js
/**
 * Migration 130 — Timechain chain module storage.
 *
 * `chain_blocks` holds one light row per block (no tx bodies) so the
 * /api/chain snapshots can be assembled from SQL instead of re-hitting RPC.
 * `chain_meta` is a string key/value map (supply checkpoint etc.).
 *
 * ⚠️ NO MIGRATION LEDGER — every migration re-runs on every boot, so the body
 * is CREATE IF NOT EXISTS only and safe to repeat.
 */
export default function migrate130(db) {
  db.exec(`
    CREATE TABLE IF NOT EXISTS chain_blocks (
      height        INTEGER PRIMARY KEY,
      hash          TEXT    NOT NULL,
      prev_hash     TEXT,
      time          INTEGER NOT NULL,
      algo          TEXT    NOT NULL,
      size_bytes    INTEGER NOT NULL,
      tx_count      INTEGER NOT NULL,
      subsidy_sats  INTEGER NOT NULL,
      fees_sats     INTEGER NOT NULL,
      fee_median    REAL,
      fee_min       REAL,
      fee_max       REAL,
      pool_tag      TEXT,
      coinbase_text TEXT,
      inserted_at   INTEGER NOT NULL DEFAULT (strftime('%s','now'))
    );
    CREATE INDEX IF NOT EXISTS idx_chain_blocks_algo ON chain_blocks(algo, height);
    CREATE TABLE IF NOT EXISTS chain_meta (
      key   TEXT PRIMARY KEY,
      value TEXT NOT NULL
    );
  `);
}
```

In `backend/src/models/db.js`, directly after the migration-129 `try/catch` block and before the `// Re-enable FK enforcement` comment, add:

```js
  // Timechain chain module: light per-block rows + meta (supply checkpoint).
  try {
    const { default: migrate130 } = await import('./migrations/130_chain_blocks.js');
    migrate130(db);
  } catch (error) {
    console.warn('Migration 130 (chain blocks) failed:', error.message);
  }
```

```js
// backend/src/services/chain/chain-store.js
import { ALGOS } from './constants.js';

const toRow = (r) => r && ({
  height: r.height, hash: r.hash, prevHash: r.prev_hash, time: r.time, algo: r.algo,
  sizeBytes: r.size_bytes, txCount: r.tx_count, subsidySats: r.subsidy_sats, feesSats: r.fees_sats,
  feeMedian: r.fee_median, feeMin: r.fee_min, feeMax: r.fee_max, poolTag: r.pool_tag, coinbaseText: r.coinbase_text,
});

export class ChainStore {
  constructor(db) {
    this.db = db;
    this.stmts = {
      upsert: db.prepare(`INSERT INTO chain_blocks
        (height, hash, prev_hash, time, algo, size_bytes, tx_count, subsidy_sats, fees_sats, fee_median, fee_min, fee_max, pool_tag, coinbase_text)
        VALUES (@height, @hash, @prevHash, @time, @algo, @sizeBytes, @txCount, @subsidySats, @feesSats, @feeMedian, @feeMin, @feeMax, @poolTag, @coinbaseText)
        ON CONFLICT(height) DO UPDATE SET hash=excluded.hash, prev_hash=excluded.prev_hash, time=excluded.time, algo=excluded.algo,
          size_bytes=excluded.size_bytes, tx_count=excluded.tx_count, subsidy_sats=excluded.subsidy_sats, fees_sats=excluded.fees_sats,
          fee_median=excluded.fee_median, fee_min=excluded.fee_min, fee_max=excluded.fee_max, pool_tag=excluded.pool_tag, coinbase_text=excluded.coinbase_text`),
      get: db.prepare('SELECT * FROM chain_blocks WHERE height = ?'),
      latest: db.prepare('SELECT MAX(height) h FROM chain_blocks'),
      range: db.prepare('SELECT * FROM chain_blocks WHERE height BETWEEN ? AND ? ORDER BY height DESC'),
      share: db.prepare('SELECT algo, COUNT(*) n FROM chain_blocks WHERE height BETWEEN ? AND ? GROUP BY algo'),
      deleteFrom: db.prepare('DELETE FROM chain_blocks WHERE height >= ?'),
      getMeta: db.prepare('SELECT value FROM chain_meta WHERE key = ?'),
      setMeta: db.prepare('INSERT INTO chain_meta (key, value) VALUES (?, ?) ON CONFLICT(key) DO UPDATE SET value = excluded.value'),
    };
  }
  upsertRow(row) { this.stmts.upsert.run({ ...row, feeMedian: row.feeMedian ?? null, feeMin: row.feeMin ?? null, feeMax: row.feeMax ?? null, poolTag: row.poolTag ?? null, coinbaseText: row.coinbaseText ?? null, prevHash: row.prevHash ?? null }); }
  getRow(height) { return toRow(this.stmts.get.get(height)) ?? null; }
  latestHeight() { return this.stmts.latest.get().h ?? null; }
  getRange(fromHeight, toHeight) { return this.stmts.range.all(fromHeight, toHeight).map(toRow); }
  algoShare(fromHeight, toHeight) {
    const counts = Object.fromEntries(ALGOS.map(a => [a, 0]));
    let total = 0;
    for (const { algo, n } of this.stmts.share.all(fromHeight, toHeight)) { if (algo in counts) counts[algo] = n; total += n; }
    return { ...counts, blocksCounted: total };
  }
  deleteFrom(height) { this.stmts.deleteFrom.run(height); }
  getMeta(key) { return this.stmts.getMeta.get(key)?.value ?? null; }
  setMeta(key, value) { this.stmts.setMeta.run(key, String(value)); }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd /home/polloloco/digibyte-compendium/backend && npx vitest run src/services/chain/chain-store.test.js`
Expected: PASS, 6 tests.

- [ ] **Step 5: Commit**

```bash
cd /home/polloloco/digibyte-compendium && git add backend/src/models/migrations/130_chain_blocks.js backend/src/models/db.js backend/src/services/chain/chain-store.js backend/src/services/chain/chain-store.test.js && git commit -m "feat(chain): migration 130 chain_blocks/chain_meta and ChainStore

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 4: Block fetcher (RPC → row)

**Files:**
- Create: `backend/src/services/chain/block-fetcher.js`
- Test: `backend/src/services/chain/block-fetcher.test.js`

**Interfaces:**
- Consumes: `rpc.getBlockHash(height)`, `rpc.getBlock(hash, 2)`, `rpc.call('getblockstats', [height])` from `backend/src/utils/rpcClient.js`; `poolTagFromCoinbase`, `feeRateFromStats`, `normalizeAlgo`.
- Produces: `fetchBlockRow(rpc, height) → Promise<Row>` (row shape from Task 3) and `fetchBlockRowByHash(rpc, hash)`.

- [ ] **Step 1: Write the failing test**

```js
// backend/src/services/chain/block-fetcher.test.js
import { describe, it, expect, vi } from 'vitest';
import { fetchBlockRow } from './block-fetcher.js';

// Shapes recorded from the v9.26.4 mainnet node on 2026-09-04 (block 24,151,710).
const BLOCK = {
  hash: 'aa', previousblockhash: 'bb', height: 24151710, time: 1788518429, pow_algo: 'qubit', size: 7579, nTx: 4,
  tx: [{ vin: [{ coinbase: '049e867001041da09a6a080c030081ab0500000c2f6d32706f6f6c2e636f6d2f' }] }],
};
const STATS = { subsidy: 25355810338, totalfee: 64499045, feerate_percentiles: [10003, 10003, 10003, 10003, 10003], minfeerate: 110, maxfeerate: 11020 };

function fakeRpc() {
  return {
    getBlockHash: vi.fn(async (h) => (h === 24151710 ? 'aa' : null)),
    getBlock: vi.fn(async (hash, v) => { expect(v).toBe(2); return hash === 'aa' ? BLOCK : null; }),
    call: vi.fn(async (m, params) => { expect(m).toBe('getblockstats'); expect(params).toEqual([24151710]); return STATS; }),
  };
}

describe('fetchBlockRow', () => {
  it('maps RPC output to a store row with DGB/kB fees and a pool tag', async () => {
    const row = await fetchBlockRow(fakeRpc(), 24151710);
    expect(row).toEqual({
      height: 24151710, hash: 'aa', prevHash: 'bb', time: 1788518429, algo: 'qubit', sizeBytes: 7579, txCount: 4,
      subsidySats: 25355810338, feesSats: 64499045,
      feeMedian: expect.closeTo(0.10003, 8), feeMin: expect.closeTo(0.0011, 8), feeMax: expect.closeTo(0.1102, 8),
      poolTag: 'm2pool.com', coinbaseText: expect.stringContaining('/m2pool.com/'),
    });
  });
  it('normalises odo → odocrypt and nulls fees on a coinbase-only block', async () => {
    const rpc = fakeRpc();
    rpc.getBlock = async () => ({ ...BLOCK, pow_algo: 'odo', nTx: 1, size: 386 });
    rpc.call = async () => ({ ...STATS, totalfee: 0, feerate_percentiles: [0, 0, 0, 0, 0], minfeerate: 0, maxfeerate: 0 });
    const row = await fetchBlockRow(rpc, 24151710);
    expect(row).toMatchObject({ algo: 'odocrypt', txCount: 1, feesSats: 0, feeMedian: null, feeMin: null, feeMax: null });
  });
  it('throws when the height does not exist', async () => {
    await expect(fetchBlockRow(fakeRpc(), 99999999)).rejects.toThrow(/no block at height/);
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /home/polloloco/digibyte-compendium/backend && npx vitest run src/services/chain/block-fetcher.test.js`
Expected: FAIL — unresolved import.

- [ ] **Step 3: Write the implementation**

```js
// backend/src/services/chain/block-fetcher.js
import { normalizeAlgo } from './constants.js';
import { poolTagFromCoinbase } from './pools.js';
import { feeRateFromStats } from './fees.js';

/** One RPC round for a block: getblockhash → getblock(2) + getblockstats. */
export async function fetchBlockRow(rpc, height) {
  const hash = await rpc.getBlockHash(height);
  if (!hash) throw new Error(`no block at height ${height}`);
  return fetchBlockRowByHash(rpc, hash, height);
}

export async function fetchBlockRowByHash(rpc, hash, heightHint = null) {
  const block = await rpc.getBlock(hash, 2);
  if (!block) throw new Error(`no block with hash ${hash}`);
  const height = heightHint ?? block.height;
  const stats = await rpc.call('getblockstats', [height]);
  const { tag, raw } = poolTagFromCoinbase(block.tx?.[0]?.vin?.[0]?.coinbase);
  const fee = feeRateFromStats(stats, block.nTx);
  return {
    height, hash: block.hash, prevHash: block.previousblockhash ?? null, time: block.time,
    algo: normalizeAlgo(block.pow_algo), sizeBytes: block.size, txCount: block.nTx,
    subsidySats: Number(stats.subsidy), feesSats: Number(stats.totalfee ?? 0),
    feeMedian: fee?.median ?? null, feeMin: fee?.min ?? null, feeMax: fee?.max ?? null,
    poolTag: tag, coinbaseText: raw,
  };
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd /home/polloloco/digibyte-compendium/backend && npx vitest run src/services/chain/block-fetcher.test.js`
Expected: PASS, 3 tests.

- [ ] **Step 5: Commit**

```bash
cd /home/polloloco/digibyte-compendium && git add backend/src/services/chain/block-fetcher.js backend/src/services/chain/block-fetcher.test.js && git commit -m "feat(chain): fetchBlockRow maps getblock+getblockstats to a store row

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 5: Snapshot assembly

**Files:**
- Create: `backend/src/services/chain/snapshot.js`
- Test: `backend/src/services/chain/snapshot.test.js`

**Interfaces:**
- Consumes: `ChainStore` (Task 3), `reductionAt`, `subsidySats`, `SUPPLY_CAP_DGB`.
- Produces: `assembleSnapshot(store, height, { isTip, tipHeight, supplySats, mempool, price }) → snapshot` (JSON contract in File Structure). `RECENT_BLOCKS = 240`, `BLOCKS_24H = 5760`. `supplyAtHeight(supplySatsAtTip, tipHeight, height) → bigint`.

- [ ] **Step 1: Write the failing test**

```js
// backend/src/services/chain/snapshot.test.js
import { describe, it, expect, beforeEach } from 'vitest';
import Database from 'better-sqlite3';
import migrate130 from '../../models/migrations/130_chain_blocks.js';
import { ChainStore } from './chain-store.js';
import { assembleSnapshot, supplyAtHeight, RECENT_BLOCKS, BLOCKS_24H } from './snapshot.js';

const ALGOS = ['sha256d', 'scrypt', 'skein', 'qubit', 'odocrypt'];
const row = (height, i) => ({
  height, hash: `h${height}`, prevHash: `h${height - 1}`, time: 1788000000 + i * 15, algo: ALGOS[i % 5],
  sizeBytes: 300 + i, txCount: 1, subsidySats: 25355810338, feesSats: 0, feeMedian: null, feeMin: null, feeMax: null, poolTag: 'm2pool.com', coinbaseText: '/m2pool.com/',
});

describe('assembleSnapshot', () => {
  let store; const TIP = 24151775;
  beforeEach(() => {
    const db = new Database(':memory:'); migrate130(db); store = new ChainStore(db);
    for (let i = 0; i < 300; i++) store.upsertRow(row(TIP - i, i));
    store.upsertRow({ ...row(TIP, 0), txCount: 4, sizeBytes: 7579, feesSats: 64499045, feeMedian: 0.10003, feeMin: 0.0011, feeMax: 0.1102 });
  });

  it('builds the tip snapshot with mempool and price attached', () => {
    const s = assembleSnapshot(store, TIP, { isTip: true, tipHeight: TIP, supplySats: 1845707764049591449n, mempool: { txCount: 0 }, price: { usd: 0.004692, asOf: 1, isStale: false } });
    expect(s).toMatchObject({
      height: TIP, isTip: true, algo: 'sha256d', sizeBytes: 7579, txCount: 4,
      feeRate: { unit: 'DGB/kB', median: 0.10003, min: 0.0011, max: 0.1102 },
      reward: { subsidy: 253.55810338, fees: 0.64499045, total: expect.closeTo(254.20309383, 8) },
      pool: { tag: 'm2pool.com' },
      reduction: { step: 130, blocksUntilNext: 54225, nextHeight: 24206000 },
      supply: { total: expect.closeTo(18457077640.4959, 3), cap: 21000000000 },
      mempool: { txCount: 0 },
      price: { usd: 0.004692, marketCapUsd: expect.closeTo(18457077640.4959 * 0.004692, 0) },
    });
    expect(s.recentBlocks).toHaveLength(RECENT_BLOCKS);
    expect(s.recentBlocks[0]).toEqual({ height: TIP, algo: 'sha256d', sizeBytes: 7579, txCount: 4, time: 1788000000 });
    expect(s.recentBlocks[239].height).toBe(TIP - 239);
    expect(s.algoShare24h.blocksCounted).toBe(300);
    expect(s.algoShare24h.sha256d).toBeCloseTo(60 / 300, 6);
  });

  it('omits mempool/price and derives supply for a scrubbed block', () => {
    const s = assembleSnapshot(store, TIP - 65, { isTip: false, tipHeight: TIP, supplySats: 1845707764049591449n, mempool: { txCount: 9 }, price: { usd: 1 } });
    expect(s.isTip).toBe(false);
    expect(s).not.toHaveProperty('mempool');
    expect(s).not.toHaveProperty('price');
    expect(s.feeRate).toBeNull();
    expect(s.supply.total).toBeCloseTo(18457077640.4959 - 65 * 253.55810338, 3);
    expect(s.recentBlocks[0].height).toBe(TIP - 65);
  });

  it('reports supply as null until the tracker has a checkpoint', () => {
    const s = assembleSnapshot(store, TIP, { isTip: true, tipHeight: TIP, supplySats: null, mempool: null, price: null });
    expect(s.supply).toEqual({ total: null, cap: 21000000000 });
    expect(s.price).toBeNull();
  });

  it('throws for a height the store does not have', () => {
    expect(() => assembleSnapshot(store, 5, { isTip: false, tipHeight: TIP, supplySats: null })).toThrow(/not in store/);
  });

  it('supplyAtHeight subtracts the subsidies mined after the requested height', () => {
    expect(supplyAtHeight(100n, TIP, TIP)).toBe(100n);
    expect(supplyAtHeight(100000000000n, TIP, TIP - 2)).toBe(100000000000n - 2n * 25355810338n);
    expect(BLOCKS_24H).toBe(5760);
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /home/polloloco/digibyte-compendium/backend && npx vitest run src/services/chain/snapshot.test.js`
Expected: FAIL — unresolved import `./snapshot.js`.

- [ ] **Step 3: Write the implementation**

```js
// backend/src/services/chain/snapshot.js
import { SUPPLY_CAP_DGB, ALGOS } from './constants.js';
import { reductionAt } from './reduction.js';
import { subsidySats } from './subsidy.js';
import { FEE_UNIT } from './fees.js';

export const RECENT_BLOCKS = 240;   // ~1 h at 15 s
export const BLOCKS_24H = 5760;     // 24 h at 15 s

/** Supply at `height` given the checkpoint at `tipHeight`: subtract every subsidy mined after `height`. */
export function supplyAtHeight(supplySatsAtTip, tipHeight, height) {
  let s = BigInt(supplySatsAtTip);
  for (let h = tipHeight; h > height; h--) s -= subsidySats(h);
  return s;
}

const sats = (n) => Number(n) / 1e8;

export function assembleSnapshot(store, height, { isTip, tipHeight, supplySats, mempool = null, price = null }) {
  const row = store.getRow(height);
  if (!row) throw new Error(`block ${height} not in store`);

  const recent = store.getRange(height - RECENT_BLOCKS + 1, height)
    .map(r => ({ height: r.height, algo: r.algo, sizeBytes: r.sizeBytes, txCount: r.txCount, time: r.time }));

  const share = store.algoShare(height - BLOCKS_24H + 1, height);
  const algoShare24h = { blocksCounted: share.blocksCounted };
  for (const a of ALGOS) algoShare24h[a] = share.blocksCounted ? share[a] / share.blocksCounted : 0;

  const supplyTotal = supplySats == null ? null : sats(supplyAtHeight(supplySats, tipHeight, height));

  const snapshot = {
    height: row.height, hash: row.hash, prevHash: row.prevHash, time: row.time,
    algo: row.algo, sizeBytes: row.sizeBytes, txCount: row.txCount,
    feeRate: row.feeMedian == null ? null : { unit: FEE_UNIT, median: row.feeMedian, min: row.feeMin, max: row.feeMax },
    reward: { subsidy: sats(row.subsidySats), fees: sats(row.feesSats), total: sats(row.subsidySats + row.feesSats) },
    pool: { tag: row.poolTag, raw: row.coinbaseText },
    reduction: reductionAt(height),
    supply: { total: supplyTotal, cap: SUPPLY_CAP_DGB },
    algoShare24h,
    recentBlocks: recent,
    isTip: Boolean(isTip),
  };
  if (isTip) {
    snapshot.mempool = mempool;
    snapshot.price = price ? { ...price, marketCapUsd: supplyTotal == null ? null : supplyTotal * price.usd } : null;
  }
  return snapshot;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd /home/polloloco/digibyte-compendium/backend && npx vitest run src/services/chain/snapshot.test.js`
Expected: PASS, 5 tests.

- [ ] **Step 5: Commit**

```bash
cd /home/polloloco/digibyte-compendium && git add backend/src/services/chain/snapshot.js backend/src/services/chain/snapshot.test.js && git commit -m "feat(chain): assemble API snapshots from stored block rows

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 6: Supply tracker and oracle price source

**Files:**
- Create: `backend/src/services/chain/supply-tracker.js`
- Create: `backend/src/services/chain/price-source.js`
- Test: `backend/src/services/chain/supply-tracker.test.js`, `backend/src/services/chain/price-source.test.js`

**Interfaces:**
- Consumes: `rpc.getTxOutSetInfo()` → `{ height, total_amount }`; `rpc.getOraclePrice()` → `{ price_micro_usd, price_usd, is_stale, last_update_height }` (shape from `backend/src/controllers/digidollar-stats.test.js`); `ChainStore.getMeta/setMeta`.
- Produces: `class SupplyTracker { constructor({ rpc, store, log }); async init(); onBlock(height); get supplySats(): bigint|null; get checkpointHeight(): number|null }`; `class PriceSource { constructor({ rpc, ttlMs = 60000, now = Date.now }); async get() → { usd, asOf, isStale, lastUpdateHeight } | null }`.

- [ ] **Step 1: Write the failing tests**

```js
// backend/src/services/chain/supply-tracker.test.js
import { describe, it, expect, vi } from 'vitest';
import Database from 'better-sqlite3';
import migrate130 from '../../models/migrations/130_chain_blocks.js';
import { ChainStore } from './chain-store.js';
import { SupplyTracker } from './supply-tracker.js';

const mkStore = () => { const db = new Database(':memory:'); migrate130(db); return new ChainStore(db); };

describe('SupplyTracker', () => {
  it('scans gettxoutsetinfo once when no checkpoint exists and persists it', async () => {
    const store = mkStore();
    // total_amount arrives as a JSON double; 18457077640.5 is exactly representable.
    const rpc = { getTxOutSetInfo: vi.fn(async () => ({ height: 24151775, total_amount: 18457077640.5 })) };
    const t = new SupplyTracker({ rpc, store, log: () => {} });
    expect(t.supplySats).toBeNull();
    await t.init();
    expect(rpc.getTxOutSetInfo).toHaveBeenCalledTimes(1);
    expect(t.supplySats).toBe(1845707764050000000n);
    expect(t.checkpointHeight).toBe(24151775);
    expect(store.getMeta('supply_sats')).toBe('1845707764050000000');
    expect(store.getMeta('supply_height')).toBe('24151775');
  });
  it('restores from meta without scanning', async () => {
    const store = mkStore(); store.setMeta('supply_sats', '1000'); store.setMeta('supply_height', '24151775');
    const rpc = { getTxOutSetInfo: vi.fn() };
    const t = new SupplyTracker({ rpc, store, log: () => {} });
    await t.init();
    expect(rpc.getTxOutSetInfo).not.toHaveBeenCalled();
    expect(t.supplySats).toBe(1000n);
  });
  it('adds the subsidy of each new block above the checkpoint, ignoring replays', async () => {
    const store = mkStore(); store.setMeta('supply_sats', '0'); store.setMeta('supply_height', '24151775');
    const t = new SupplyTracker({ rpc: {}, store, log: () => {} });
    await t.init();
    t.onBlock(24151776); t.onBlock(24151776); t.onBlock(24151775);
    expect(t.supplySats).toBe(25355810338n);
    expect(t.checkpointHeight).toBe(24151776);
    expect(store.getMeta('supply_height')).toBe('24151776');
  });
  it('survives a failed scan (stays null, logs, no throw)', async () => {
    const store = mkStore(); const log = vi.fn();
    const t = new SupplyTracker({ rpc: { getTxOutSetInfo: async () => { throw new Error('boom'); } }, store, log });
    await t.init();
    expect(t.supplySats).toBeNull();
    expect(log).toHaveBeenCalledWith(expect.stringContaining('boom'));
  });
});
```

```js
// backend/src/services/chain/price-source.test.js
import { describe, it, expect, vi } from 'vitest';
import { PriceSource } from './price-source.js';

const ORACLE = { price_micro_usd: 4692, price_usd: 0.004692, is_stale: false, last_update_height: 24151700 };

describe('PriceSource', () => {
  it('reads the DigiDollar oracle price and caches it for the TTL', async () => {
    let now = 1000; const rpc = { getOraclePrice: vi.fn(async () => ORACLE) };
    const p = new PriceSource({ rpc, ttlMs: 60000, now: () => now });
    expect(await p.get()).toEqual({ usd: 0.004692, asOf: 1, isStale: false, lastUpdateHeight: 24151700 });
    now = 30000; await p.get();
    expect(rpc.getOraclePrice).toHaveBeenCalledTimes(1);
    now = 61001; await p.get();
    expect(rpc.getOraclePrice).toHaveBeenCalledTimes(2);
  });
  it('treats a zero/negative/absent price as unknown (null), never $0', async () => {
    const p = new PriceSource({ rpc: { getOraclePrice: async () => ({ ...ORACLE, price_usd: 0 }) } });
    expect(await p.get()).toBeNull();
  });
  it('returns the last good value when the RPC fails', async () => {
    let fail = false; const rpc = { getOraclePrice: async () => { if (fail) throw new Error('down'); return ORACLE; } };
    let now = 0; const p = new PriceSource({ rpc, ttlMs: 10, now: () => now });
    const first = await p.get(); fail = true; now = 100;
    expect(await p.get()).toEqual(first);
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd /home/polloloco/digibyte-compendium/backend && npx vitest run src/services/chain/supply-tracker.test.js src/services/chain/price-source.test.js`
Expected: FAIL — unresolved imports.

- [ ] **Step 3: Write the implementations**

```js
// backend/src/services/chain/supply-tracker.js
import { subsidySats } from './subsidy.js';

const META_SATS = 'supply_sats';
const META_HEIGHT = 'supply_height';

/** DGB (a JSON double) → sats as BigInt without going through a >2^53 float. */
export function dgbToSats(dgb) {
  const [whole, frac = ''] = String(dgb).split('.');
  if (/e/i.test(String(dgb))) return BigInt(Math.round(dgb * 1e8)); // absurdly small/large: precision is moot
  return BigInt(whole + frac.padEnd(8, '0').slice(0, 8));
}

/**
 * Circulating supply without calling gettxoutsetinfo per block: one scan
 * establishes a checkpoint (persisted in chain_meta), then every new block
 * adds its schedule subsidy. Drift from unclaimed coinbase value is ignored.
 */
export class SupplyTracker {
  constructor({ rpc, store, log = console.warn }) {
    this.rpc = rpc; this.store = store; this.log = log;
    this._sats = null; this._height = null;
  }
  get supplySats() { return this._sats; }
  get checkpointHeight() { return this._height; }

  async init() {
    const sats = this.store.getMeta(META_SATS); const height = this.store.getMeta(META_HEIGHT);
    if (sats != null && height != null) { this._sats = BigInt(sats); this._height = Number(height); return; }
    try {
      const info = await this.rpc.getTxOutSetInfo();           // slow: full UTXO scan, once
      this._sats = dgbToSats(info.total_amount);
      this._height = Number(info.height);
      this._persist();
    } catch (err) {
      this.log(`[chain] supply scan failed, supply stays unknown: ${err.message}`);
    }
  }

  /** Called by the tip watcher for each newly stored block, in order. */
  onBlock(height) {
    if (this._sats == null || height <= this._height) return;
    for (let h = this._height + 1; h <= height; h++) this._sats += subsidySats(h);
    this._height = height;
    this._persist();
  }

  _persist() { this.store.setMeta(META_SATS, this._sats.toString()); this.store.setMeta(META_HEIGHT, String(this._height)); }
}
```

```js
// backend/src/services/chain/price-source.js
/**
 * DGB/USD from the on-chain DigiDollar oracle (getoracleprice) — the same
 * source the DigiScope frontend uses (src/lib/dgbPrice.js). Same rule:
 * a 0/negative/absent price is UNKNOWN (null), never a real $0.
 */
export class PriceSource {
  constructor({ rpc, ttlMs = 60000, now = Date.now }) {
    this.rpc = rpc; this.ttlMs = ttlMs; this.now = now;
    this._value = null; this._fetchedAt = -Infinity;
  }
  async get() {
    if (this.now() - this._fetchedAt < this.ttlMs) return this._value;
    try {
      const o = await this.rpc.getOraclePrice();
      const usd = Number(o?.price_usd);
      this._value = Number.isFinite(usd) && usd > 0
        ? { usd, asOf: Math.floor(this.now() / 1000), isStale: Boolean(o.is_stale), lastUpdateHeight: o.last_update_height ?? null }
        : null;
      this._fetchedAt = this.now();
    } catch {
      // keep the last good value; retry after the TTL
      this._fetchedAt = this.now();
    }
    return this._value;
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd /home/polloloco/digibyte-compendium/backend && npx vitest run src/services/chain/supply-tracker.test.js src/services/chain/price-source.test.js`
Expected: PASS, 7 tests.

- [ ] **Step 5: Commit**

```bash
cd /home/polloloco/digibyte-compendium && git add backend/src/services/chain/supply-tracker.js backend/src/services/chain/price-source.js backend/src/services/chain/supply-tracker.test.js backend/src/services/chain/price-source.test.js && git commit -m "feat(chain): supply checkpoint tracker and cached oracle price source

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 7: Mempool sampler

**Files:**
- Create: `backend/src/services/chain/mempool-sampler.js`
- Test: `backend/src/services/chain/mempool-sampler.test.js`

**Interfaces:**
- Consumes: `rpc.getMempoolInfo()` → `{ size, bytes }`; `rpc.call('estimatesmartfee', [n])` → `{ feerate?: number /* DGB/kB */ }`; `BLOCK_CAPACITY_BYTES`.
- Produces: `class MempoolSampler { constructor({ rpc, intervalMs = 5000, now = Date.now, log }); async sample() → MempoolSnapshot; noteMinedBytes(bytes); start(onSample); stop(); get last() }`. `MempoolSnapshot = { txCount, vbytes, inflowVbPerSec, depthBlocks, fees: { unit, priority, anytime }, asOf }`.

- [ ] **Step 1: Write the failing test**

```js
// backend/src/services/chain/mempool-sampler.test.js
import { describe, it, expect, vi } from 'vitest';
import { MempoolSampler } from './mempool-sampler.js';

function rpcWith(bytes, size = 3) {
  return {
    getMempoolInfo: vi.fn(async () => ({ size, bytes })),
    call: vi.fn(async (m, [n]) => ({ feerate: n === 2 ? 0.011 : 0.0011 })),
  };
}

describe('MempoolSampler', () => {
  it('maps mempool info and fee estimates into DGB/kB', async () => {
    const s = new MempoolSampler({ rpc: rpcWith(450000, 12), now: () => 10000 });
    expect(await s.sample()).toEqual({ txCount: 12, vbytes: 450000, inflowVbPerSec: 0, depthBlocks: 0.45, fees: { unit: 'DGB/kB', priority: 0.011, anytime: 0.0011 }, asOf: 10 });
  });
  it('computes inflow from the byte delta plus bytes mined in between', async () => {
    let now = 0; let bytes = 1000;
    const rpc = rpcWith(0); rpc.getMempoolInfo = async () => ({ size: 1, bytes });
    const s = new MempoolSampler({ rpc, now: () => now });
    await s.sample();
    now = 5000; bytes = 1500; s.noteMinedBytes(2500);      // +500 sitting, 2500 mined → 3000 vB in 5 s
    expect((await s.sample()).inflowVbPerSec).toBe(600);
    now = 10000; bytes = 0;                                  // drained with nothing mined → clamp at 0
    expect((await s.sample()).inflowVbPerSec).toBe(0);
  });
  it('reports null fee estimates when the estimator has no data', async () => {
    const rpc = rpcWith(0); rpc.call = async () => ({ errors: ['Insufficient data'] });
    expect((await new MempoolSampler({ rpc }).sample()).fees).toEqual({ unit: 'DGB/kB', priority: null, anytime: null });
  });
  it('start() samples on an interval and hands each result to the callback', async () => {
    vi.useFakeTimers();
    const cb = vi.fn(); const s = new MempoolSampler({ rpc: rpcWith(10), intervalMs: 5000 });
    s.start(cb);
    await vi.advanceTimersByTimeAsync(10001);
    expect(cb).toHaveBeenCalledTimes(3);                     // immediate + 2 ticks
    expect(s.last.vbytes).toBe(10);
    s.stop(); await vi.advanceTimersByTimeAsync(5000);
    expect(cb).toHaveBeenCalledTimes(3);
    vi.useRealTimers();
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /home/polloloco/digibyte-compendium/backend && npx vitest run src/services/chain/mempool-sampler.test.js`
Expected: FAIL — unresolved import.

- [ ] **Step 3: Write the implementation**

```js
// backend/src/services/chain/mempool-sampler.js
import { BLOCK_CAPACITY_BYTES } from './constants.js';
import { FEE_UNIT } from './fees.js';

const feeOrNull = (r) => (typeof r?.feerate === 'number' && r.feerate > 0 ? r.feerate : null);

/**
 * Samples the mempool every `intervalMs`. Inflow (vB/s) is the vsize that
 * entered the pool between two samples: (bytes_now − bytes_prev + bytes mined
 * in between) / elapsed, clamped at 0. The tip watcher reports mined bytes
 * through noteMinedBytes().
 */
export class MempoolSampler {
  constructor({ rpc, intervalMs = 5000, now = Date.now, log = console.warn }) {
    this.rpc = rpc; this.intervalMs = intervalMs; this.now = now; this.log = log;
    this._prev = null; this._minedBytes = 0; this._timer = null; this.last = null;
  }
  noteMinedBytes(bytes) { this._minedBytes += bytes; }

  async sample() {
    const t = this.now();
    const [info, prio, any] = await Promise.all([
      this.rpc.getMempoolInfo(),
      this.rpc.call('estimatesmartfee', [2]).catch(() => null),
      this.rpc.call('estimatesmartfee', [20]).catch(() => null),
    ]);
    let inflow = 0;
    if (this._prev) {
      const dt = (t - this._prev.t) / 1000;
      if (dt > 0) inflow = Math.max(0, (info.bytes - this._prev.bytes + this._minedBytes) / dt);
    }
    this._prev = { t, bytes: info.bytes }; this._minedBytes = 0;
    this.last = {
      txCount: info.size, vbytes: info.bytes,
      inflowVbPerSec: Math.round(inflow * 10) / 10,
      depthBlocks: Math.round((info.bytes / BLOCK_CAPACITY_BYTES) * 100) / 100,
      fees: { unit: FEE_UNIT, priority: feeOrNull(prio), anytime: feeOrNull(any) },
      asOf: Math.floor(t / 1000),
    };
    return this.last;
  }

  start(onSample) {
    const tick = () => this.sample().then(onSample).catch((e) => this.log(`[chain] mempool sample failed: ${e.message}`));
    tick();
    this._timer = setInterval(tick, this.intervalMs);
  }
  stop() { if (this._timer) clearInterval(this._timer); this._timer = null; }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd /home/polloloco/digibyte-compendium/backend && npx vitest run src/services/chain/mempool-sampler.test.js`
Expected: PASS, 4 tests.

- [ ] **Step 5: Commit**

```bash
cd /home/polloloco/digibyte-compendium && git add backend/src/services/chain/mempool-sampler.js backend/src/services/chain/mempool-sampler.test.js && git commit -m "feat(chain): mempool sampler with inflow, depth and DGB/kB fee estimates

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 8: Tip watcher with reorg-safe ingest and backfill

**Files:**
- Create: `backend/src/services/chain/tip-watcher.js`
- Test: `backend/src/services/chain/tip-watcher.test.js`

**Interfaces:**
- Consumes: `rpc.call('getbestblockhash')`, `rpc.getBlock(hash, 2)` (for height/prev), `fetchBlockRow`, `fetchBlockRowByHash`, `ChainStore`.
- Produces: `class TipWatcher extends EventEmitter { constructor({ rpc, store, intervalMs = 2000, backfillDepth = 5760, log }); async start(); stop(); async ensureRow(height) → Row; get tipHeight() }`. Emits `'tip'` with `{ height, rows: Row[] }` (rows newly stored this tick, oldest first) and `'error'`.

- [ ] **Step 1: Write the failing test**

```js
// backend/src/services/chain/tip-watcher.test.js
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import Database from 'better-sqlite3';
import migrate130 from '../../models/migrations/130_chain_blocks.js';
import { ChainStore } from './chain-store.js';
import { TipWatcher } from './tip-watcher.js';

/**
 * A lazy fake chain (heights are ~1.5M, so blocks are computed, never stored).
 * Hash of height h is `H<h>` or `H<h>x` once that height has been reorged.
 */
function fakeChain(tip) {
  let top = tip;
  const forked = new Set();
  const hashOf = (h) => (h < 0 ? null : `H${h}${forked.has(h) ? 'x' : ''}`);
  const block = (h) => ({ hash: hashOf(h), previousblockhash: hashOf(h - 1), height: h, time: 1788000000 + h * 15, pow_algo: 'scrypt', size: 400, nTx: 1, tx: [{ vin: [{ coinbase: '00' }] }] });
  const byHash = (hash) => { const m = /^H(\d+)(x?)$/.exec(hash ?? ''); if (!m) return null; const h = Number(m[1]); return h > top || (forked.has(h) ? 'x' : '') !== m[2] ? null : block(h); };
  const rpc = {
    call: vi.fn(async (m) => {
      if (m === 'getbestblockhash') return hashOf(top);
      if (m === 'getblockstats') return { subsidy: 25355810338, totalfee: 0, feerate_percentiles: [0, 0, 0, 0, 0], minfeerate: 0, maxfeerate: 0 };
      throw new Error(`unexpected ${m}`);
    }),
    getBlockHash: vi.fn(async (h) => (h >= 0 && h <= top ? hashOf(h) : null)),
    getBlock: vi.fn(async (hash) => byHash(hash)),
  };
  return {
    rpc,
    mine() { top += 1; },
    reorgTop(depth) { for (let h = top - depth + 1; h <= top; h++) forked.add(h); },
  };
}

describe('TipWatcher', () => {
  let store;
  beforeEach(() => { vi.useFakeTimers(); const db = new Database(':memory:'); migrate130(db); store = new ChainStore(db); });
  afterEach(() => vi.useRealTimers());

  it('backfills the last N blocks on start, newest first, and emits nothing for them', async () => {
    const chain = fakeChain(1_500_010);
    const w = new TipWatcher({ rpc: chain.rpc, store, intervalMs: 2000, backfillDepth: 5, log: () => {} });
    const onTip = vi.fn(); w.on('tip', onTip);
    await w.start();
    expect(store.latestHeight()).toBe(1_500_010);
    expect(store.getRange(0, 2_000_000).map(r => r.height)).toEqual([1_500_010, 1_500_009, 1_500_008, 1_500_007, 1_500_006]);
    expect(onTip).not.toHaveBeenCalled();
    expect(w.tipHeight).toBe(1_500_010);
    w.stop();
  });

  it('stores each new block and emits tip with the new rows oldest-first', async () => {
    const chain = fakeChain(1_500_010);
    const w = new TipWatcher({ rpc: chain.rpc, store, intervalMs: 2000, backfillDepth: 2, log: () => {} });
    const onTip = vi.fn(); w.on('tip', onTip);
    await w.start();
    chain.mine(); chain.mine();
    await vi.advanceTimersByTimeAsync(2000);
    expect(onTip).toHaveBeenCalledTimes(1);
    expect(onTip.mock.calls[0][0].height).toBe(1_500_012);
    expect(onTip.mock.calls[0][0].rows.map(r => r.height)).toEqual([1_500_011, 1_500_012]);
    expect(store.getRow(1_500_012).hash).toBe('H1500012');
    w.stop();
  });

  it('replaces rows on a 2-block reorg', async () => {
    const chain = fakeChain(1_500_010);
    const w = new TipWatcher({ rpc: chain.rpc, store, intervalMs: 2000, backfillDepth: 4, log: () => {} });
    await w.start();
    chain.reorgTop(2);
    await vi.advanceTimersByTimeAsync(2000);
    expect(store.getRow(1_500_010).hash).toBe('H1500010x');
    expect(store.getRow(1_500_009).hash).toBe('H1500009x');
    expect(store.getRow(1_500_008).hash).toBe('H1500008');
    w.stop();
  });

  it('ensureRow fetches and stores a missing historical height on demand', async () => {
    const chain = fakeChain(1_500_010);
    const w = new TipWatcher({ rpc: chain.rpc, store, intervalMs: 2000, backfillDepth: 1, log: () => {} });
    await w.start();
    expect(store.getRow(1_500_000)).toBeNull();
    const row = await w.ensureRow(1_500_000);
    expect(row.height).toBe(1_500_000);
    expect(store.getRow(1_500_000).hash).toBe('H1500000');
    await expect(w.ensureRow(9_999_999)).rejects.toThrow(/no block at height/);
    w.stop();
  });

  it('keeps polling after an RPC error and emits it', async () => {
    const chain = fakeChain(1_500_010);
    const w = new TipWatcher({ rpc: chain.rpc, store, intervalMs: 2000, backfillDepth: 1, log: () => {} });
    const onErr = vi.fn(); w.on('error', onErr);
    await w.start();
    const real = chain.rpc.call; chain.rpc.call = async () => { throw new Error('rpc down'); };
    await vi.advanceTimersByTimeAsync(2000);
    expect(onErr).toHaveBeenCalledWith(expect.objectContaining({ message: 'rpc down' }));
    chain.rpc.call = real; chain.mine();
    await vi.advanceTimersByTimeAsync(2000);
    expect(store.latestHeight()).toBe(1_500_011);
    w.stop();
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /home/polloloco/digibyte-compendium/backend && npx vitest run src/services/chain/tip-watcher.test.js`
Expected: FAIL — unresolved import.

- [ ] **Step 3: Write the implementation**

```js
// backend/src/services/chain/tip-watcher.js
import { EventEmitter } from 'node:events';
import { fetchBlockRow, fetchBlockRowByHash } from './block-fetcher.js';

const MAX_REORG_WALK = 50;

/**
 * Polls getbestblockhash every `intervalMs`. On a new hash, walks back from
 * the tip until it meets a stored row whose hash matches (reorg-safe), stores
 * every block above that point, and emits 'tip' once with the new rows.
 * On start it backfills `backfillDepth` blocks newest-first so the 240-block
 * ring is available within seconds and the 24 h share fills in behind it.
 */
export class TipWatcher extends EventEmitter {
  constructor({ rpc, store, intervalMs = 2000, backfillDepth = 5760, log = console.warn }) {
    super();
    this.rpc = rpc; this.store = store; this.intervalMs = intervalMs; this.backfillDepth = backfillDepth; this.log = log;
    this._timer = null; this._busy = false; this._tipHash = null; this._tipHeight = null;
  }
  get tipHeight() { return this._tipHeight; }

  async start() {
    const hash = await this.rpc.call('getbestblockhash');
    const tip = await fetchBlockRowByHash(this.rpc, hash);
    this.store.upsertRow(tip);
    this._tipHash = tip.hash; this._tipHeight = tip.height;
    for (let h = tip.height - 1; h > tip.height - this.backfillDepth && h >= 0; h--) {
      if (!this.store.getRow(h)) this.store.upsertRow(await fetchBlockRow(this.rpc, h));
    }
    this._timer = setInterval(() => this._tick(), this.intervalMs);
  }
  stop() { if (this._timer) clearInterval(this._timer); this._timer = null; }

  async ensureRow(height) {
    const have = this.store.getRow(height);
    if (have) return have;
    const row = await fetchBlockRow(this.rpc, height);
    this.store.upsertRow(row);
    return row;
  }

  async _tick() {
    if (this._busy) return;
    this._busy = true;
    try {
      const hash = await this.rpc.call('getbestblockhash');
      if (hash === this._tipHash) return;
      // Walk back from the new tip until the stored chain agrees with the node.
      const fresh = [];
      let cursor = hash;
      for (let i = 0; i < MAX_REORG_WALK && cursor; i++) {
        const row = await fetchBlockRowByHash(this.rpc, cursor);
        const stored = this.store.getRow(row.height);
        if (stored && stored.hash === row.hash) break;
        fresh.push(row);
        cursor = row.prevHash;
      }
      fresh.reverse();                                   // oldest first
      for (const row of fresh) this.store.upsertRow(row);
      const top = fresh[fresh.length - 1];
      this._tipHash = top.hash; this._tipHeight = top.height;
      this.emit('tip', { height: top.height, rows: fresh });
    } catch (err) {
      this.log(`[chain] tip poll failed: ${err.message}`);
      this.emit('error', err);
    } finally {
      this._busy = false;
    }
  }
}
```

Note for the implementer: `EventEmitter` throws on an `'error'` emit with no listener, so `ChainService` (Task 10) MUST attach an `'error'` handler.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd /home/polloloco/digibyte-compendium/backend && npx vitest run src/services/chain/tip-watcher.test.js`
Expected: PASS, 5 tests.

- [ ] **Step 5: Commit**

```bash
cd /home/polloloco/digibyte-compendium && git add backend/src/services/chain/tip-watcher.js backend/src/services/chain/tip-watcher.test.js && git commit -m "feat(chain): reorg-safe tip watcher with startup backfill

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 9: SSE hub

**Files:**
- Create: `backend/src/services/chain/sse-hub.js`
- Test: `backend/src/services/chain/sse-hub.test.js`

**Interfaces:**
- Produces: `class SseHub { constructor({ pingMs = 25000 }); add(res) → () => void /* remove */; broadcast(event, data); get size(); stop() }`. Wire format: `event: <name>\ndata: <json>\n\n`; ping is `event: ping\ndata: {"t":<unix>}\n\n`.

- [ ] **Step 1: Write the failing test**

```js
// backend/src/services/chain/sse-hub.test.js
import { describe, it, expect, vi } from 'vitest';
import { SseHub } from './sse-hub.js';

const fakeRes = () => { const chunks = []; return { chunks, write: vi.fn((c) => chunks.push(c)), writableEnded: false }; };

describe('SseHub', () => {
  it('broadcasts framed events to every client and drops removed ones', () => {
    const hub = new SseHub({ pingMs: 0 });
    const a = fakeRes(), b = fakeRes();
    const removeA = hub.add(a); hub.add(b);
    hub.broadcast('tip', { height: 1 });
    expect(a.chunks.join('')).toBe('event: tip\ndata: {"height":1}\n\n');
    removeA();
    hub.broadcast('mempool', { x: 1 });
    expect(a.chunks).toHaveLength(1);
    expect(b.chunks).toHaveLength(2);
    expect(hub.size).toBe(1);
    hub.stop();
  });
  it('pings on an interval and evicts clients whose write throws', () => {
    vi.useFakeTimers();
    const hub = new SseHub({ pingMs: 25000 });
    const good = fakeRes(); const bad = fakeRes(); bad.write = () => { throw new Error('EPIPE'); };
    hub.add(good); hub.add(bad);
    vi.advanceTimersByTime(25000);
    expect(good.chunks[0]).toMatch(/^event: ping\ndata: \{"t":\d+\}\n\n$/);
    expect(hub.size).toBe(1);
    hub.stop(); vi.useRealTimers();
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /home/polloloco/digibyte-compendium/backend && npx vitest run src/services/chain/sse-hub.test.js`
Expected: FAIL — unresolved import.

- [ ] **Step 3: Write the implementation**

```js
// backend/src/services/chain/sse-hub.js
/** Fan-out for server-sent events. Keeps a Set of Express responses. */
export class SseHub {
  constructor({ pingMs = 25000 } = {}) {
    this.clients = new Set();
    this._timer = pingMs > 0 ? setInterval(() => this.broadcast('ping', { t: Math.floor(Date.now() / 1000) }), pingMs) : null;
    if (this._timer?.unref) this._timer.unref();
  }
  get size() { return this.clients.size; }
  add(res) { this.clients.add(res); return () => this.clients.delete(res); }
  broadcast(event, data) {
    const frame = `event: ${event}\ndata: ${JSON.stringify(data)}\n\n`;
    for (const res of this.clients) {
      try { if (res.writableEnded) throw new Error('ended'); res.write(frame); }
      catch { this.clients.delete(res); }
    }
  }
  stop() { if (this._timer) clearInterval(this._timer); this._timer = null; this.clients.clear(); }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd /home/polloloco/digibyte-compendium/backend && npx vitest run src/services/chain/sse-hub.test.js`
Expected: PASS, 2 tests.

- [ ] **Step 5: Commit**

```bash
cd /home/polloloco/digibyte-compendium && git add backend/src/services/chain/sse-hub.js backend/src/services/chain/sse-hub.test.js && git commit -m "feat(chain): SSE hub with ping and dead-client eviction

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 10: ChainService — wiring

**Files:**
- Create: `backend/src/services/chain/chain-service.js`
- Test: `backend/src/services/chain/chain-service.test.js`

**Interfaces:**
- Consumes: everything from Tasks 3–9.
- Produces: `class ChainService { constructor({ rpc, db, log, intervalMs, mempoolIntervalMs, backfillDepth }); async start(); stop(); getTipSnapshot() → snapshot|null; async getBlockSnapshot(height) → snapshot; get hub(); get ready(): boolean }`. Broadcasts `tip` (full tip snapshot) on every new block and `mempool` (`{ height, mempool, price }`) on every sample.

- [ ] **Step 1: Write the failing test**

```js
// backend/src/services/chain/chain-service.test.js
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import Database from 'better-sqlite3';
import migrate130 from '../../models/migrations/130_chain_blocks.js';
import { ChainService } from './chain-service.js';

/** Lazy fake node: blocks are computed from their height (heights are ~1.5M). */
function fakeRpc(tip) {
  const block = (h) => ({ hash: `H${h}`, previousblockhash: h > 0 ? `H${h - 1}` : null, height: h, time: 1788000000 + h * 15, pow_algo: 'skein', size: 500, nTx: 1, tx: [{ vin: [{ coinbase: '2f6d32706f6f6c2e636f6d2f' }] }] });
  const rpc = {
    _tip: tip,
    call: async (m, params) => {
      if (m === 'getbestblockhash') return `H${rpc._tip}`;
      if (m === 'getblockstats') return { subsidy: 25355810338, totalfee: 0, feerate_percentiles: [0, 0, 0, 0, 0], minfeerate: 0, maxfeerate: 0 };
      if (m === 'estimatesmartfee') return { feerate: params[0] === 2 ? 0.011 : 0.0011 };
      throw new Error(m);
    },
    getBlockHash: async (h) => (h >= 0 && h <= rpc._tip ? `H${h}` : null),
    getBlock: async (hash) => { const h = Number(/^H(\d+)$/.exec(hash ?? '')?.[1]); return Number.isInteger(h) && h <= rpc._tip ? block(h) : null; },
    getMempoolInfo: async () => ({ size: 2, bytes: 900 }),
    getOraclePrice: async () => ({ price_usd: 0.004692, is_stale: false, last_update_height: 1 }),
    getTxOutSetInfo: async () => ({ height: tip, total_amount: 18457077640.5 }),
    mine() { rpc._tip += 1; },
  };
  return rpc;
}

describe('ChainService', () => {
  let db, svc;
  beforeEach(() => { vi.useFakeTimers(); db = new Database(':memory:'); migrate130(db); });
  afterEach(() => { svc?.stop(); vi.useRealTimers(); });

  it('is not ready before start and serves the tip after', async () => {
    const rpc = fakeRpc(1_500_010);
    svc = new ChainService({ rpc, db, log: () => {}, backfillDepth: 3 });
    expect(svc.ready).toBe(false);
    expect(svc.getTipSnapshot()).toBeNull();
    await svc.start();
    await vi.advanceTimersByTimeAsync(0);
    const tip = svc.getTipSnapshot();
    expect(svc.ready).toBe(true);
    expect(tip).toMatchObject({ height: 1_500_010, isTip: true, pool: { tag: 'm2pool.com' }, supply: { total: 18457077640.5 } });
    expect(tip.mempool).toMatchObject({ txCount: 2, vbytes: 900, fees: { priority: 0.011, anytime: 0.0011 } });
    expect(tip.price).toMatchObject({ usd: 0.004692 });
  });

  it('broadcasts a fresh tip snapshot on a new block and mempool patches on samples', async () => {
    const rpc = fakeRpc(1_500_010);
    svc = new ChainService({ rpc, db, log: () => {}, backfillDepth: 2, intervalMs: 2000, mempoolIntervalMs: 5000 });
    await svc.start();
    const res = { chunks: [], write(c) { this.chunks.push(c); } };
    svc.hub.add(res);
    rpc.mine();
    await vi.advanceTimersByTimeAsync(2000);
    const tipFrames = res.chunks.filter(c => c.startsWith('event: tip'));
    expect(tipFrames).toHaveLength(1);
    expect(JSON.parse(tipFrames[0].split('data: ')[1])).toMatchObject({ height: 1_500_011, supply: { total: expect.closeTo(18457077640.5 + 253.55810338, 3) } });
    await vi.advanceTimersByTimeAsync(5000);
    const mp = res.chunks.filter(c => c.startsWith('event: mempool'));
    expect(mp.length).toBeGreaterThanOrEqual(1);
    expect(JSON.parse(mp.at(-1).split('data: ')[1])).toMatchObject({ height: 1_500_011, mempool: { txCount: 2 } });
  });

  it('getBlockSnapshot serves a stored height and fetches an unknown one', async () => {
    const rpc = fakeRpc(1_500_010);
    svc = new ChainService({ rpc, db, log: () => {}, backfillDepth: 2 });
    await svc.start();
    expect((await svc.getBlockSnapshot(1_500_009))).toMatchObject({ height: 1_500_009, isTip: false });
    expect((await svc.getBlockSnapshot(1_500_000))).toMatchObject({ height: 1_500_000, isTip: false });
    await expect(svc.getBlockSnapshot(9_999_999)).rejects.toThrow(/no block at height/);
    await expect(svc.getBlockSnapshot(-1)).rejects.toThrow(/invalid height/);
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /home/polloloco/digibyte-compendium/backend && npx vitest run src/services/chain/chain-service.test.js`
Expected: FAIL — unresolved import.

- [ ] **Step 3: Write the implementation**

```js
// backend/src/services/chain/chain-service.js
import { ChainStore } from './chain-store.js';
import { TipWatcher } from './tip-watcher.js';
import { MempoolSampler } from './mempool-sampler.js';
import { PriceSource } from './price-source.js';
import { SupplyTracker } from './supply-tracker.js';
import { SseHub } from './sse-hub.js';
import { assembleSnapshot } from './snapshot.js';

/** Wires store, watcher, sampler, price and supply into the three things the router needs. */
export class ChainService {
  constructor({ rpc, db, log = console.warn, intervalMs = 2000, mempoolIntervalMs = 5000, backfillDepth = 5760, pingMs = 25000 }) {
    this.rpc = rpc; this.log = log;
    this.store = new ChainStore(db);
    this.watcher = new TipWatcher({ rpc, store: this.store, intervalMs, backfillDepth, log });
    this.sampler = new MempoolSampler({ rpc, intervalMs: mempoolIntervalMs, log });
    this.price = new PriceSource({ rpc });
    this.supply = new SupplyTracker({ rpc, store: this.store, log });
    this._hub = new SseHub({ pingMs });
    this._tip = null; this._started = false;
    this.watcher.on('error', () => {});                        // logged inside the watcher
    this.watcher.on('tip', ({ height, rows }) => this._onTip(height, rows));
  }
  get hub() { return this._hub; }
  get ready() { return this._started && this._tip != null; }

  async start() {
    await this.watcher.start();
    // Supply scan is slow (full UTXO set) and must not delay first data.
    this.supply.init().then(() => this._rebuildTip()).catch((e) => this.log(`[chain] supply init: ${e.message}`));
    await this._rebuildTip();
    this.sampler.start(async (mempool) => {
      const price = await this.price.get();
      if (this._tip) { this._tip = { ...this._tip, mempool, price: this._withMarketCap(price) }; }
      this._hub.broadcast('mempool', { height: this._tip?.height ?? null, mempool, price: this._withMarketCap(price) });
    });
    this._started = true;
  }
  stop() { this.watcher.stop(); this.sampler.stop(); this._hub.stop(); }

  getTipSnapshot() { return this._tip; }

  async getBlockSnapshot(height) {
    if (!Number.isInteger(height) || height < 0) throw new Error(`invalid height: ${height}`);
    await this.watcher.ensureRow(height);
    const tipHeight = this.watcher.tipHeight;
    return assembleSnapshot(this.store, height, { isTip: false, tipHeight, supplySats: this._supplyAt(tipHeight) });
  }

  async _onTip(height, rows) {
    for (const r of rows) { this.supply.onBlock(r.height); this.sampler.noteMinedBytes(r.sizeBytes); }
    await this._rebuildTip();
    this._hub.broadcast('tip', this._tip);
  }

  async _rebuildTip() {
    const tipHeight = this.watcher.tipHeight;
    if (tipHeight == null) return;
    const price = await this.price.get();
    this._tip = assembleSnapshot(this.store, tipHeight, {
      isTip: true, tipHeight, supplySats: this._supplyAt(tipHeight),
      mempool: this.sampler.last, price: this._withMarketCap(price),
    });
  }

  /** Supply checkpoint may lag the tip by a block or two while a scan runs; assembleSnapshot handles the delta. */
  _supplyAt(tipHeight) {
    const s = this.supply.supplySats;
    if (s == null) return null;
    const cp = this.supply.checkpointHeight;
    if (cp === tipHeight) return s;
    // checkpoint behind tip (scan finished at an older height): roll forward
    let out = s; for (let h = cp + 1; h <= tipHeight; h++) out += (this.store.getRow(h)?.subsidySats != null ? BigInt(this.store.getRow(h).subsidySats) : 0n);
    return out;
  }

  _withMarketCap(price) {
    if (!price) return null;
    const supply = this._tip?.supply?.total ?? null;
    return { ...price, marketCapUsd: supply == null ? null : supply * price.usd };
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd /home/polloloco/digibyte-compendium/backend && npx vitest run src/services/chain/chain-service.test.js`
Expected: PASS, 3 tests. If the first test's `supply.total` is `null`, the supply scan promise had not resolved before assertion — add `await vi.advanceTimersByTimeAsync(0)` twice (the plan already has one; a second flushes the then-chain).

- [ ] **Step 5: Commit**

```bash
cd /home/polloloco/digibyte-compendium && git add backend/src/services/chain/chain-service.js backend/src/services/chain/chain-service.test.js && git commit -m "feat(chain): ChainService wires watcher, sampler, price, supply and SSE

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 11: Router and server mount

**Files:**
- Create: `backend/src/controllers/chain.js`
- Test: `backend/src/controllers/chain.test.js`
- Modify: `backend/src/server.js` — import near the `networkRouter` import (line ~604); mount next to `app.use('/api/network', networkRouter)` (line ~2573); start the service where the other background services start after the database is initialised (search for `digidollarPriceSampler.start(` or `initializeDatabase()` in the boot sequence and place it after DB init).

**Interfaces:**
- Consumes: `ChainService` (`getTipSnapshot`, `getBlockSnapshot`, `hub`, `ready`).
- Produces: `createChainRouter({ service })`. Routes: `GET /tip` → 200 snapshot | 503 `{ error: 'chain data warming up', retryAfter: 5 }`; `GET /block/:height` → 200 | 400 `{ error: 'invalid height' }` | 404 `{ error: 'block not found' }` | 503; `GET /stream` → SSE, first frame is `event: tip` with the current snapshot when ready.

- [ ] **Step 1: Write the failing test**

```js
// backend/src/controllers/chain.test.js
import { describe, it, expect, vi } from 'vitest';
import express from 'express';
import request from 'supertest';
import { createChainRouter } from './chain.js';
import { SseHub } from '../services/chain/sse-hub.js';

const TIP = { height: 24151775, isTip: true, algo: 'odocrypt' };
function app(overrides = {}) {
  const hub = new SseHub({ pingMs: 0 });
  const service = {
    ready: true, hub,
    getTipSnapshot: () => TIP,
    getBlockSnapshot: vi.fn(async (h) => { if (h === 24151710) return { height: h, isTip: false }; throw new Error(`no block at height ${h}`); }),
    ...overrides,
  };
  const a = express(); a.use('/api/chain', createChainRouter({ service }));
  return { a, service, hub };
}

describe('GET /api/chain/tip', () => {
  it('returns the tip snapshot with no-store caching', async () => {
    const r = await request(app().a).get('/api/chain/tip');
    expect(r.status).toBe(200); expect(r.body).toEqual(TIP);
    expect(r.headers['cache-control']).toBe('no-store');
  });
  it('503s while warming up', async () => {
    const r = await request(app({ ready: false, getTipSnapshot: () => null }).a).get('/api/chain/tip');
    expect(r.status).toBe(503); expect(r.body).toEqual({ error: 'chain data warming up', retryAfter: 5 });
    expect(r.headers['retry-after']).toBe('5');
  });
});

describe('GET /api/chain/block/:height', () => {
  it('serves a block', async () => {
    const r = await request(app().a).get('/api/chain/block/24151710');
    expect(r.status).toBe(200); expect(r.body).toEqual({ height: 24151710, isTip: false });
    expect(r.headers['cache-control']).toBe('public, max-age=3600');
  });
  it('400s on garbage and 404s on a missing height', async () => {
    expect((await request(app().a).get('/api/chain/block/abc')).status).toBe(400);
    expect((await request(app().a).get('/api/chain/block/-5')).status).toBe(400);
    const r = await request(app().a).get('/api/chain/block/99999999');
    expect(r.status).toBe(404); expect(r.body).toEqual({ error: 'block not found' });
  });
  it('503s on an RPC failure', async () => {
    const { a } = app({ getBlockSnapshot: async () => { throw new Error('connect ECONNREFUSED'); } });
    const r = await request(a).get('/api/chain/block/1');
    expect(r.status).toBe(503); expect(r.body).toEqual({ error: 'node unavailable', retryAfter: 5 });
  });
});

describe('GET /api/chain/stream', () => {
  it('sends SSE headers and the current tip as the first frame, then broadcasts', async () => {
    const { a, hub } = app();
    const chunks = [];
    await new Promise((resolve) => {
      const req = request(a).get('/api/chain/stream').buffer(false);
      req.on('response', (res) => {
        expect(res.headers['content-type']).toMatch(/^text\/event-stream/);
        expect(res.headers['x-accel-buffering']).toBe('no');
        res.on('data', (c) => { chunks.push(String(c)); if (chunks.join('').includes('event: mempool')) { req.abort(); resolve(); } });
        setTimeout(() => hub.broadcast('mempool', { x: 1 }), 20);
      });
      req.end(() => {});
    });
    const text = chunks.join('');
    expect(text.startsWith(`event: tip\ndata: ${JSON.stringify(TIP)}\n\n`)).toBe(true);
    expect(text).toContain('event: mempool\ndata: {"x":1}\n\n');
    await new Promise((r) => setTimeout(r, 20));
    expect(hub.size).toBe(0);
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /home/polloloco/digibyte-compendium/backend && npx vitest run src/controllers/chain.test.js`
Expected: FAIL — unresolved import `./chain.js`.

- [ ] **Step 3: Write the router**

```js
// backend/src/controllers/chain.js
/**
 * Timechain chain routes — PUBLIC, unauthenticated.
 *   GET /api/chain/tip            current tip snapshot
 *   GET /api/chain/block/:height  historical snapshot (scrubbing)
 *   GET /api/chain/stream         SSE: tip on new block, mempool every 5 s, ping every 25 s
 * Data comes from our own node via ChainService; never from Panopticon.
 */
import { Router } from 'express';

const WARMING = { error: 'chain data warming up', retryAfter: 5 };
const NODE_DOWN = { error: 'node unavailable', retryAfter: 5 };

export function createChainRouter({ service }) {
  const router = Router();

  router.get('/tip', (req, res) => {
    const tip = service.ready ? service.getTipSnapshot() : null;
    if (!tip) return res.status(503).set('Retry-After', '5').json(WARMING);
    res.set('Cache-Control', 'no-store').json(tip);
  });

  router.get('/block/:height', async (req, res) => {
    const height = Number(req.params.height);
    if (!/^\d+$/.test(req.params.height) || !Number.isSafeInteger(height)) return res.status(400).json({ error: 'invalid height' });
    try {
      const snap = await service.getBlockSnapshot(height);
      res.set('Cache-Control', 'public, max-age=3600').json(snap);
    } catch (err) {
      if (/no block at height|not in store/.test(err.message)) return res.status(404).json({ error: 'block not found' });
      res.status(503).set('Retry-After', '5').json(NODE_DOWN);
    }
  });

  router.get('/stream', (req, res) => {
    res.writeHead(200, {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache, no-transform',
      'Connection': 'keep-alive',
      'X-Accel-Buffering': 'no', // nginx: disable buffering for this response, no config edit
    });
    res.flushHeaders?.();
    const tip = service.ready ? service.getTipSnapshot() : null;
    if (tip) res.write(`event: tip\ndata: ${JSON.stringify(tip)}\n\n`);
    const remove = service.hub.add(res);
    res.on('close', remove);
  });

  return router;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd /home/polloloco/digibyte-compendium/backend && npx vitest run src/controllers/chain.test.js`
Expected: PASS, 6 tests.

- [ ] **Step 5: Mount in server.js**

Add with the other controller imports (next to `import networkRouter from './controllers/network.js';`):

```js
import { createChainRouter } from './controllers/chain.js';
import { ChainService } from './services/chain/chain-service.js';
```

Add next to `app.use('/api/network', networkRouter);`:

```js
// Timechain app feed — public, our own node, no Panopticon.
const chainService = new ChainService({ rpc: rpcClient, db: getDatabase() });
app.use('/api/chain', publicLimiter, createChainRouter({ service: chainService }));
```

`rpcClient` is already imported in server.js as the default export of `./utils/rpcClient.js` — confirm with `grep -n "rpcClient" backend/src/server.js | head -3`; if it is imported under another name, use that name. `getDatabase` is exported by `./models/db.js` and already imported (it is used at the `/api/reports` mount).

In the boot sequence, after the database has been initialised and before/around where other pollers start (grep `digidollarPriceSampler.start` — place immediately after it):

```js
if (process.env.CHAIN_MODULE_ENABLED !== 'false') {
  chainService.start().catch((err) => console.warn('[chain] failed to start:', err.message));
}
```

And in the shutdown handler (grep `SIGTERM` in server.js), add `chainService.stop();` alongside the other stops.

- [ ] **Step 6: Boot the backend locally against the Adam VPS node and smoke the routes**

The local box has no mainnet node; point RPC at the Adam VPS over an SSH tunnel (RPC 14022 is localhost-only there). Read the RPC credentials from `/root/.digibyte/digibyte.conf` on that host:

```bash
ssh -f -N -L 14022:127.0.0.1:14022 root@129.212.182.152
ssh root@129.212.182.152 'grep -E "^rpc(user|password)=" /root/.digibyte/digibyte.conf'
cd /home/polloloco/digibyte-compendium/backend
DGB_RPC_HOST=127.0.0.1 DGB_RPC_PORT=14022 DGB_RPC_USER=<rpcuser> DGB_RPC_PASSWORD=<rpcpassword> PORT=3999 node src/server.js &
sleep 20
curl -s localhost:3999/api/chain/tip | python3 -c 'import sys,json; s=json.load(sys.stdin); print(s["height"], s["algo"], s["reward"], s["reduction"], s["supply"], s["price"] and s["price"]["usd"], len(s["recentBlocks"]))'
curl -s localhost:3999/api/chain/block/24151710 | python3 -c 'import sys,json; s=json.load(sys.stdin); print(s["feeRate"], s["pool"]["tag"])'
timeout 40 curl -sN localhost:3999/api/chain/stream | head -c 2000
```

Expected: tip height ≥ 24,151,775 with 240 recent blocks; the 24151710 block shows `{unit:'DGB/kB', median:0.10003, min:0.0011, max:0.1102}` and `m2pool.com`; the stream prints an `event: tip` frame immediately, `event: mempool` frames every 5 s, and an `event: tip` within ~15–75 s. `supply.total` is `null` for the first minute or two (UTXO scan), then populated. Kill the server and the tunnel afterwards (`pkill -f "node src/server.js"; pkill -f "14022:127.0.0.1:14022"`).

- [ ] **Step 7: Run the whole backend suite**

Run: `cd /home/polloloco/digibyte-compendium/backend && npx vitest run 2>&1 | tail -5`
Expected: all files green (baseline was 194 files / 1468 tests on 2026-08-08; now +11 files).

- [ ] **Step 8: Commit**

```bash
cd /home/polloloco/digibyte-compendium && git add backend/src/controllers/chain.js backend/src/controllers/chain.test.js backend/src/server.js && git commit -m "feat(chain): public /api/chain tip, block and SSE stream routes

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 12: Docs, PR, deploy

**Files:**
- Modify: `backend/README.md` (add an "API: /api/chain" subsection)
- Create: `backend/docs/chain-api.md`

- [ ] **Step 1: Write the API doc**

```markdown
<!-- backend/docs/chain-api.md -->
# /api/chain — Timechain feed

Public, unauthenticated, rate-limited by `publicLimiter` (500 req / 15 min / IP).
Source: our own DigiByte node via `rpcClient`. Fee unit is **DGB per kB**.

| Route | Returns |
|---|---|
| `GET /api/chain/tip` | Snapshot of the chain tip (`isTip: true`, includes `mempool` and `price`). 503 + `Retry-After: 5` while warming up. |
| `GET /api/chain/block/:height` | Snapshot of one block (`isTip: false`, no `mempool`/`price`). 400 bad height, 404 unknown, 503 node down. Cached 1 h. |
| `GET /api/chain/stream` | Server-sent events. First frame: `tip`. Then `tip` on every new block, `mempool` every 5 s (`{height, mempool, price}`), `ping` every 25 s. |

Snapshot fields: see `src/services/chain/snapshot.js`. Verified constants: subsidy schedule
(`subsidy.js`, Period VI, 1.116 %/175,200 blocks), reduction cycle (`reduction.js`).
Supply is a `gettxoutsetinfo` checkpoint in `chain_meta` plus per-block subsidies.
Price is the DigiDollar oracle (`getoracleprice`), cached 60 s, `null` when unknown.
Disable the module with `CHAIN_MODULE_ENABLED=false`.
```

Add to `backend/README.md` under the API section a one-line pointer: `- **/api/chain** — live chain feed for the DigiByte Timechain app, see docs/chain-api.md`.

- [ ] **Step 2: Commit and open the PR**

```bash
cd /home/polloloco/digibyte-compendium && git add backend/docs/chain-api.md backend/README.md && git commit -m "docs(chain): /api/chain feed reference

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>" && git push -u origin feat/chain-timechain-api && gh pr create --base master --title "feat(chain): public /api/chain feed for the DigiByte Timechain app" --body "$(cat <<'EOF'
Adds a self-contained `chain` service + three public routes (tip, block/:height, SSE stream) built from our own node — the data feed for the new DigiByte Timechain mobile app (spec: JohnnyLawDGB/digibyte-timechain).

- Exact Period VI subsidy replica (verified against Core and the live node)
- Reorg-safe tip watcher with 5,760-block backfill, SQLite rows (migration 130)
- Mempool sampler (inflow/depth/fee estimates), oracle price, supply checkpoint
- Fees in DGB/kB throughout
- 40 new vitest tests; no Panopticon dependency

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

- [ ] **Step 3: Deploy after merge**

On the VPS the running checkout is the one PM2 reports; confirm it before pulling:

```bash
ssh -i ~/.ssh/DigitalOcean root@digiscope.me 'pm2 describe digiscope-backend | grep -E "cwd|script path"'
ssh -i ~/.ssh/DigitalOcean root@digiscope.me 'cd <cwd from above> && git fetch && git checkout master && git pull --ff-only && npm ci --omit=dev && pm2 restart digiscope-backend --update-env && sleep 25 && curl -s http://127.0.0.1:3001/api/chain/tip | head -c 300 && echo && timeout 12 curl -sN http://127.0.0.1:3001/api/chain/stream | head -c 400'
curl -s https://api.digiscope.me/api/chain/tip | head -c 300
timeout 40 curl -sN https://api.digiscope.me/api/chain/stream | head -c 600
```

Expected: JSON tip locally and through nginx; the public stream shows `event: tip` immediately and `event: mempool` within 5 s. If the public stream shows nothing for 30 s while the local one works, nginx is buffering despite `X-Accel-Buffering: no` — add `proxy_buffering off;` to the `location /api/chain/stream` block in the `api.digiscope.me` server config and `nginx -s reload`.

- [ ] **Step 4: Record the deployment**

Append to `~/digibyte-timechain/docs/superpowers/plans/2026-09-04-chain-backend.md` a final line `Deployed <date>: <commit sha> on api.digiscope.me` and commit it in the Timechain repo.

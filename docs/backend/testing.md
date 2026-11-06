# Cavia Music — Automated Testing Strategy & Verification Guide

This document details the complete end-to-end testing matrix, failure injection methodology, performance benchmarks, and automated verification suites for Cavia Music.

---

## 1. Test Suite Architecture

Cavia Music contains **121 automated tests** across 7 dedicated test suites covering unit logic, integration boundaries, state machines, and end-to-end user workflows:

```
test/
├── cavia_test.dart                 # Frontend widgets, mini-player transitions, tab navigation (17 tests)
├── cavia_backend_phase1_test.dart   # Drift SQLite local database, repositories, cascade operations (11 tests)
├── cavia_backend_phase2_test.dart   # Supabase auth, outbox queueing, tombstones, multi-user isolation (12 tests)
├── cavia_backend_phase3_test.dart   # Audio engine, media sessions, provider abstraction, search (17 tests)
├── cavia_backend_phase4_test.dart   # Spotify PKCE OAuth, URL parsing, track matching & import (23 tests)
├── cavia_backend_phase5_test.dart   # Offline caching, LRU eviction, SHA-256 integrity, limits (20 tests)
└── cavia_backend_phase6_test.dart   # End-to-end scenarios A-H, failure injection, stress benchmarks (21 tests)
```

**Total**: **121 of 121 tests passing** (0 regressions, 0 flaky tests).

---

## 2. End-to-End User Scenarios (Scenarios A – H)

All 8 foundational workflows are validated via integration tests in [`cavia_backend_phase6_test.dart`](file:///test/cavia_backend_phase6_test.dart):

| Scenario | Objective | Validation Step |
| :--- | :--- | :--- |
| **Scenario A: New Guest** | Unauthenticated user opens app, likes track, creates playlist, reorders entries. | Simulates application cold restart by closing database connection and re-instantiating repositories from the same SQLite file. Confirms 100% persistence. |
| **Scenario B: Offline Guest** | Modifies playlists, likes songs, and updates playback queue with zero connectivity. | Validates that local mutations require zero network availability and remain durable upon restart. |
| **Scenario C: First-time Cloud Sync** | Guest library merges into authenticated user account upon sign-in. | Verifies all guest likes and custom playlists copy cleanly into account outbox; verifies zero duplicates or data loss. |
| **Scenario D: Multi-Device Sync** | Concurrent updates from two devices on the same user account. | Verifies deterministic conflict resolution: tombstone markers permanently prevent resurrected entries even when stale reorders arrive. |
| **Scenario E: Account Switching** | User A creates private playlists, logs out; User B logs in. | Asserts strict multi-tenant database isolation. User B cannot read User A's playlists or likes; User A's data is restored completely when signing back in. |
| **Scenario F: Playback Failures** | Network drops during playback; queue item removed; track skipped. | Asserts typed failure reporting with exact user message (`"This track isn't cached for offline playback."`); verifies queue index advances safely. |
| **Scenario G: Spotify Importing** | Imports Spotify playlist via URL with exact and ambiguous track matches. | Asserts URL validation, ISRC matching, ambiguous candidate handling, and retry deduplication. |
| **Scenario H: Caching & Recovery** | Cache eligible track, toggle off, reject YouTube, clear cache. | Validates that toggling off preserves cached files, YouTube audio caching is rejected, and clearing cache preserves library metadata. |

---

## 3. Failure Injection & Resilience Matrix

The test harness systematically injects transient and permanent failures into service boundaries:

```
[Network Fault Simulator]
      │
      ├──> HTTP 401 Unauthorized    ──> Typed Auth Failure ("Reconnect this music source to continue.")
      ├──> HTTP 403 Forbidden       ──> Typed Permission Failure ("Playback isn't supported for this source.")
      ├──> HTTP 429 Rate Limited    ──> Typed Retry Failure ("Couldn't start playback. Try again.")
      ├──> HTTP 500 Server Error    ──> Enqueue to Outbox with Exponential Backoff
      ├──> Malformed JSON Payload   ──> Throws FormatException; handled as ValidationError
      ├──> Corrupted Cache File     ──> SHA-256 / Size mismatch detected; file purged; state reset
      └──> Invalid Deep Links       ──> Rejected by SpotifyUrlParser without crashing
```

---

## 4. Performance & Stress Benchmarks

Performance tests execute against SQLite database instances in [`cavia_backend_phase6_test.dart`](file:///test/cavia_backend_phase6_test.dart):

1. **Large Playlists (1,000 Entries)**:
   - Batch insertion and positional retrieval of 1,000 playlist entries executes in **< 3,000 ms**.
2. **Large Library Indexing (2,000 Tracks)**:
   - Indexed database query across 2,000 tracks executes in **< 200 ms**.
3. **Rapid Queue Operations**:
   - 50 consecutive randomized operations (skip next, skip previous, toggle shuffle) maintain stable queue bounds without index errors.

---

## 5. Privacy & Security Verification

Tested in `CaviaLogger`:
- **Token Masking**: Bearer tokens (`Bearer BQA1234...`) are automatically converted to `Bearer [REDACTED_TOKEN]`.
- **Secret Redaction**: `client_secret=...` and `password=...` are sanitized to `[REDACTED_SECRET]`.
- **Email Obfuscation**: `user@example.com` is masked to `u***@example.com`.
- **Filesystem Privacy**: Absolute user paths (`C:\Users\Username\...`, `/home/user/...`) are masked to `[USER_HOME]`.
- **Raw SQL Protection**: SQLite internal exceptions are replaced with generic technical messages.

---

## 6. How to Run the Automated Tests

### Run all 121 tests:
```bash
flutter test
```

### Run specific test suites:
```bash
# Phase 6 E2E Integration Suite
flutter test test/cavia_backend_phase6_test.dart

# Phase 5 Offline Caching Suite
flutter test test/cavia_backend_phase5_test.dart

# Phase 4 Spotify Import Suite
flutter test test/cavia_backend_phase4_test.dart

# Static Analysis Check (0 issues required)
flutter analyze
```


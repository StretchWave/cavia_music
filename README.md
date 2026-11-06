# Cavia Music

<p align="center">
  <strong>A premium, local-first music player crafted with Japanese Ink × Liquid Glass aesthetic.</strong>
</p>

<p align="center">
  <img src="assets/images/cover_zenith.jpg" width="600" alt="Cavia Music Preview" />
</p>

---

## 1. Overview

**Cavia Music** is a high-performance, local-first audio player built with Flutter. Engineered from the ground up to operate completely offline without requiring accounts or cloud infrastructure, Cavia Music offers seamless local audio management, hardware-accelerated playback across mobile and desktop platforms, deterministic cloud synchronization via Supabase, and policy-compliant Spotify playlist metadata migration.

### Visual Identity: Japanese Ink × Liquid Glass
- **Deep Sumi Obsidian Palette**: Layered obsidian and midnight-slate surfaces (`#0D0D11`, `#16161E`) provide unmatched visual depth and contrast.
- **Glowing Vermilion Accents**: Precise cinnabar and torii crimson accents (`#FF3B30`, `#E62E2E`) highlight active playback, scrubbing needles, and selection states.
- **Liquid Glass Overlays**: Refined translucent glass surfaces (`BackdropFilter` with 16–24px Gaussian blur) float naturally above sumi-e artwork.
- **Aged Ivory & Kanji Typography**: Elegant Japanese calligraphy accents (蔵 Library, 探 Search, 設定 Settings) paired with pristine typography.

---

## 2. Core Architecture

Cavia Music is built on a strictly layered, decoupled architecture ensuring zero UI coupling to databases, external services, or audio drivers:

```
┌────────────────────────────────────────────────────────────────────────┐
│                          PRESENTATION LAYER                            │
│    LibraryScreen • SearchScreen • FullPlayer • QueueSheet • Settings   │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Reactive ViewModels & Intents
┌───────────────────────────────────▼────────────────────────────────────┐
│                    UI CONTROLLERS (STATE MANAGEMENT)                   │
│   PlaybackController   •   LibraryController   •   SettingsController  │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Domain Interfaces
┌───────────────────────────────────▼────────────────────────────────────┐
│                     DOMAIN & REPOSITORY INTERFACES                     │
│    ITrackRepository   •   IPlaylistRepository   •   ISyncRepository    │
│    ICacheManager      •   ISpotifyImporter      •   IAudioEngine       │
└───────────────┬──────────────────────────────────────────┬─────────────┘
                │ Concrete Implementations                 │
┌───────────────▼─────────────────┐       ┌────────────────▼─────────────┐
│      LOCAL PERSISTENCE LAYER    │       │     CLOUD & REMOTE LAYER     │
│ • Drift (SQLite Relational DB)  │       │ • Supabase Auth (PKCE)       │
│ • SecureStorage (OAuth Tokens)  │       │ • Supabase PostgreSQL (RLS)  │
│ • Disk Cache (LRU + SHA-256)    │       │ • Spotify Web API (PKCE)     │
│ • Offline Outbox Queue          │       │ • LRCLIB / MusicBrainz APIs  │
└─────────────────────────────────┘       └──────────────────────────────┘
```

### Key Technical Pillars
1. **Local-First SQLite Database (Drift)**: Complete relational data model with foreign keys, transactional integrity, and non-destructive versioned migrations (v1 $\to$ v2 $\to$ v3).
2. **Deterministic Conflict Resolution (LWW)**: Two-way cloud synchronization powered by an offline mutation outbox and UTC Last-Write-Wins timestamps, with tombstone tracking to prevent deleted items from reviving.
3. **Cross-Platform Hardware Audio Pipeline**:
   - **Android**: Native ExoPlayer pipeline with foreground audio service notification and lock screen controls via `just_audio` and `audio_service`.
   - **Windows & Linux**: Hardware-accelerated `libmpv` pipeline via `just_audio_media_kit`, integrated with Windows System Media Transport Controls (`smtc_windows`) and Linux D-Bus MPRIS (`audio_service_mpris`).
4. **Storage-Managed Offline Caching**: Independent cache controls with strict LRU (Least Recently Used) automatic eviction, cryptographic SHA-256 file integrity verification, and quota limits.
5. **Spotify Metadata Ingestion**: RFC 7636 Authorization Code with PKCE for importing playlist metadata without scraping or storing client secrets.
6. **Privacy-Preserving Diagnostics (`CaviaLogger`)**: Zero leaks of Bearer tokens, secrets, user emails, filesystem usernames, or raw SQL errors in log streams.

---

## 3. Platform Support Matrix

| Platform | OS Version | Hardware Acceleration | Background Audio | Media Notification / Controls |
| :--- | :--- | :--- | :--- | :--- |
| **Android** | 8.0+ (API 26+) | Hardware AudioTrack / OpenSL ES | Foreground Service with `WAKE_LOCK` | Native Android Media Notification |
| **Windows** | Windows 10 / 11 | DirectSound / WASAPI via `libmpv` | Windows Background Audio | Windows System Media Transport Controls (SMTC) |
| **Linux** | Ubuntu 22.04+ / Arch / Fedora | ALSA / PulseAudio / PipeWire via `libmpv` | System Daemon / MPRIS | D-Bus MPRIS v2 (GNOME / KDE) |

---

## 4. Setup & Installation

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.9.0` or higher)
- [Dart SDK](https://dart.dev/get-dart) (`^3.9.0` or higher)
- **Linux Prerequisites** (Desktop build only):
  ```bash
  sudo apt update && sudo apt install -y libmpv-dev mpv libsecret-1-dev
  ```
- **Windows Prerequisites** (Desktop build only): Visual Studio C++ build tools.

### Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-org/cavia_music.git
   cd cavia_music
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate Drift database code**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Configure environment variables**:
   Copy `.env.example` to `.env` and fill in your Supabase and Spotify credentials:
   ```bash
   cp .env.example .env
   ```

5. **Run the application**:
   ```bash
   # Windows Desktop
   flutter run -d windows

   # Linux Desktop
   flutter run -d linux

   # Android Device / Emulator
   flutter run -d android
   ```

---

## 5. Configuration & Environment Variables

Create a `.env` file in the project root based on `.env.example`:

```env
# ==========================================
# CAVIA MUSIC - ENVIRONMENT CONFIGURATION
# ==========================================

# Supabase Cloud Configuration
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...

# Spotify Web API Integration (PKCE Flow)
# Register at: https://developer.spotify.com/dashboard
SPOTIFY_CLIENT_ID=your_spotify_client_id_here
SPOTIFY_REDIRECT_URI_MOBILE=caviamusic://auth/spotify/callback
SPOTIFY_REDIRECT_URI_DESKTOP=http://127.0.0.1:8888/callback

# Storage & Cache Configuration
DEFAULT_CACHE_QUOTA_MB=2048
AUTO_CACHE_ON_FAVORITE=false
```

---

## 6. Supabase Setup & Cloud Database

Cavia Music uses Supabase PostgreSQL with strict Row-Level Security (RLS). All migrations are versioned under `supabase/migrations/`.

### Applying Migrations
Execute the migrations directly in your Supabase SQL Editor:
- `supabase/migrations/20261105000000_create_cavia_sync_tables.sql`

### Cloud Schema Summary
- **`public.profiles`**: User metadata and cloud preferences.
- **`public.playlists`**: Custom playlists with RLS (`auth.uid() = user_id`).
- **`public.playlist_tracks`**: Track entries indexed by sort order.
- **`public.user_likes`**: Liked track IDs with UTC timestamps for conflict resolution.
- **`public.sync_device_records`**: Client device registrations for push notifications.
- **`public.operation_receipts`**: Idempotent mutation receipt logs.

---

## 7. Spotify Developer Dashboard Setup

To enable Spotify playlist importing:
1. Navigate to the [Spotify Developer Dashboard](https://developer.spotify.com/dashboard) and log in.
2. Click **Create App** and configure:
   - **App Name**: `Cavia Music`
   - **App Description**: `Personal music player and playlist importer`
   - **Redirect URIs**:
     - `caviamusic://auth/spotify/callback` (Android / Mobile)
     - `http://127.0.0.1:8888/callback` (Windows & Linux Desktop)
   - **APIs Used**: `Web API`
3. Copy your **Client ID** into your `.env` file (`SPOTIFY_CLIENT_ID`).
4. **Security Notice**: Cavia Music uses **PKCE (Proof Key for Code Exchange)**. *Never* embed or configure a Spotify Client Secret in the client app.

---

## 8. Automated Testing & Verification

The test suite covers unit, integration, failure injection, and end-to-end system scenarios:

```bash
# Run all tests across the 7 test suites
flutter test

# Run static analysis
flutter analyze
```

### Test Suite Breakdown (121 Passing Tests)
| Test Suite | File | Tests | Focus Area |
| :--- | :--- | :---: | :--- |
| **Phase 1** | `test/cavia_backend_phase1_test.dart` | 11 | Local Drift SQLite database, transactions, cascades, repository CRUD |
| **Phase 2** | `test/cavia_backend_phase2_test.dart` | 12 | Supabase Auth, outbox queuing, offline sync, LWW conflict resolution |
| **Phase 3** | `test/cavia_backend_phase3_test.dart` | 17 | Audio engine abstraction, playlist queueing, seek, interruptions, OS controls |
| **Phase 4** | `test/cavia_backend_phase4_test.dart` | 23 | Spotify PKCE OAuth, token refresh, playlist ingestion, track matching |
| **Phase 5** | `test/cavia_backend_phase5_test.dart` | 20 | Offline disk caching, LRU eviction, SHA-256 integrity, independent Settings toggles |
| **Phase 6** | `test/cavia_backend_phase6_test.dart` | 21 | E2E Scenarios A–H, failure injection (401/403/429/500/corrupt), 1K scale benchmarks, redaction |
| **Core UI** | `test/cavia_test.dart` | 17 | Widget trees, sumi-e canvas rendering, navigation state, UI component safety |
| **Total** | **7 test files** | **121** | **All 121 tests passing (100% success rate, 0 analyzer issues)** |

---

## 9. Comprehensive Backend Documentation

Detailed technical design documents are located in `docs/backend/`:
- [`architecture.md`](docs/backend/architecture.md): System topology, state machines, audio pipelines, and redaction.
- [`data_model.md`](docs/backend/data_model.md): Drift SQLite schema, v1 $\to$ v2 $\to$ v3 migrations, and cloud PostgreSQL tables.
- [`error_handling.md`](docs/backend/error_handling.md): Sealed domain error taxonomy, exact user-facing messages, and circuit breakers.
- [`integration_risks.md`](docs/backend/integration_risks.md): Policy compliance, YouTube/Spotify streaming limitations, and security boundaries.
- [`testing.md`](docs/backend/testing.md): Complete testing guide, failure injection matrix, scale benchmarks, and CI/CD commands.

---

## 10. License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

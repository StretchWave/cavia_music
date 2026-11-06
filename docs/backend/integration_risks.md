# Cavia Music — External Integrations & Feasibility Risk Report

## 1. Executive Summary & Policy Compliance

This report establishes the technical capabilities, legal boundaries, and risk mitigation strategies for all external services relevant to Cavia Music. 

In strict adherence to project directives:
> *"Do not use unofficial stream extraction, scraping, undocumented private endpoints or methods that circumvent authentication, playback restrictions or content protections. If a desired integration cannot legally or technically deliver a requested feature, document the limitation and implement an honest unsupported state rather than pretending it works."*

Cavia Music deprecates and rejects the brittle, unauthorized web scrapers utilized in earlier prototypes (such as `youtube_explode_dart` client bundle extraction or SoundCloud script scrapers). Below is the authoritative evaluation of official integration paths.

---

## 2. YouTube API Capabilities & Restrictions

| Criteria | Assessment |
| :--- | :--- |
| **Official Surface** | YouTube Data API v3 |
| **Authentication** | Google Cloud API Key (Read-only) or OAuth 2.0 (User actions) |
| **Quota & Cost** | 10,000 units/day default allocation (Search = 100 units; Video Details = 1 unit) |

### 2.1 The Streaming Limitation
- **Official Policy**: The YouTube Data API v3 provides **metadata only** (video title, channel/artist name, duration, thumbnails, descriptions, view counts). It **does NOT** provide raw audio or video stream URLs (such as direct MP3, AAC, Opus, or HTTPS `.webm` endpoints).
- **Terms of Service Violation**: YouTube Developer Policies (§ II.A.1, § II.F, § III.E.4) explicitly prohibit:
  1. Separating, downloading, or extracting the audio track from video content.
  2. Playing YouTube audio in the background while the video player or device screen is hidden/off (unless utilizing approved YouTube Premium APIs or official YouTube embedded players).
  3. Circumventing cipher algorithms or accessing internal playback streams.

### 2.2 Unofficial Scrapers (Why They Are Banned)
- Prior open-source players rely on reverse-engineered web client endpoints (`youtube_explode_dart`, `yt-dlp`).
- **Failure Modes**:
  - Google frequently introduces bot verification challenges (Cloudflare / Turnstile / YouTube Proof-of-Work checks).
  - Web client changes cause scraping libraries to fail unexpectedly without notice.
  - Endpoints result in permanent IP bans or HTTP 403 Forbidden errors.
- **Cavia Music Design Decision**:
  - YouTube Data API v3 is utilized strictly for **metadata search, catalogue discovery, and public playlist indexing**.
  - For playback of YouTube-catalogued songs: if an authorized direct audio stream is not present in the user's local library or configured audio endpoint, Cavia Music provides an **honest unsupported state**:
    - Surfaces an informative modal explaining that background raw audio extraction violates platform terms.
    - Offers a single-tap option to launch the video in an official embedded player or open directly in the official YouTube Music application.

---

## 3. Spotify Web API Authorization & Ingestion

| Criteria | Assessment |
| :--- | :--- |
| **Official Surface** | Spotify Web API (`https://api.spotify.com/v1`) |
| **Authentication** | OAuth 2.0 Authorization Code with PKCE (Client-side) or Client Credentials (Server-side via Edge Function) |
| **Rate Limiting** | Tiered rolling 30-second window (HTTP 429 Retry-After) |

### 3.1 Metadata Ingestion vs. Audio Playback
- **Capabilities**:
  - The Spotify Web API allows querying public playlists (`GET /v1/playlists/{playlist_id}`) to retrieve full tracklists, track names, artist names, album titles, durations, release dates, and International Standard Recording Codes (ISRC).
- **Limitations**:
  - **No Raw Streaming**: Spotify Web API **never** provides full-length raw audio files or streamable URLs for playback outside Spotify’s proprietary player.
  - **30-Second Previews Deprecated**: Spotify has systematically phased out public 30-second `preview_url` fields across major record labels.
  - **Spotify Web Playback SDK**: Only functions inside Chromium web browser environments, requires an active Spotify Premium subscription, and controls playback through Widevine DRM.

### 3.2 Cavia Music Ingestion Architecture
- **Pure Metadata Migration**: Cavia Music’s Spotify Import interface functions exclusively as an **intelligent metadata migrator**:
  1. User inputs a public Spotify playlist URL.
  2. Client calls Supabase Edge Function (`spotify-resolver`) using secure app credentials.
  3. The Edge Function fetches track metadata (Title, Artist, Album, ISRC, Duration) and returns a normalized JSON list.
  4. The Cavia Music client imports the tracks into the local SQLite database as a new user playlist.
  5. Playback is resolved against the user's existing local library files or authorized audio resolvers.

---

## 4. Supabase Flutter SDK & Cloud Architecture

| Criteria | Assessment |
| :--- | :--- |
| **SDK Version** | `supabase_flutter: ^2.10.x` |
| **Supported Platforms** | Android, iOS, Windows, macOS, Linux, Web |
| **Authentication** | Email & Password, Magic Link (PKCE), Google OAuth |

### 4.1 Security & Token Management
- **Security Assessment**: Supabase Auth sessions are encrypted and stored in platform-secure storage (`flutter_secure_storage` backed by Android Keystore / Windows Credential Manager).
- **Row-Level Security (RLS)**: Because the client directly talks to PostgreSQL via PostgREST, RLS policies are **mandatory**. All cloud tables enforce:
  ```sql
  CREATE POLICY "Users can only access own data"
  ON table_name FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
  ```
- **Deep Link Handling**: OAuth redirects require registering the custom URI scheme `caviamusic://auth/callback` on Android (`AndroidManifest.xml`) and Windows/Linux URL protocols.

### 4.2 Offline Outbox Synchronization
- **Challenge**: Users may make continuous edits while completely disconnected.
- **Solution**: The `sync_outbox` table in SQLite queues mutations locally. A dedicated `SyncCoordinator` monitors network connectivity via `connectivity_plus`. When connectivity is restored, mutations are batched and executed sequentially using UTC timestamps for Last-Write-Wins (LWW) conflict resolution.

---

## 5. Flutter Audio Engine Packages

| Package | Role | Platform Support | Limitations / Considerations |
| :--- | :--- | :--- | :--- |
| **`just_audio`** | Core mobile audio playback engine | Android, iOS, Web | On desktop (Windows/Linux), standard `just_audio` uses basic platform channels which lack advanced codec support and hardware acceleration. |
| **`just_audio_media_kit`** | Desktop audio playback engine (`libmpv`) | Windows, Linux, macOS | Bundles hardware-accelerated `libmpv`. Provides gapless playback, FLAC, Opus, AAC, and equalizer support. Requires C++ runtime on Windows and `libmpv-dev` on Linux. |
| **`audio_service`** | Background audio & OS controls | Android, iOS, Web, Windows | Runs a background audio isolate on Android, managing persistent media notifications, lock screen art, and system media buttons. |
| **`smtc_windows`** | Windows Media Transport Controls | Windows Desktop | Connects Flutter playback state to Windows 10/11 taskbar media flyout, volume overlays, and keyboard media keys (Play/Pause/Skip). |
| **`audio_service_mpris`** | Linux Media Player Remote Interfacing | Linux Desktop | Implements standard D-Bus MPRIS protocol for GNOME/KDE media widgets. |

---

## 6. Storage & Offline Caching Policy Compliance

In accordance with Phase 5 requirements, caching is strictly bound by source permissions:
1. **Never Cache YouTube Audiovisual Content**: Terms of Service explicitly prohibit separating or storing audio tracks from YouTube.
2. **Never Cache Spotify Protected Content**: Spotify streams are protected by DRM and are metadata-only in Cavia Music; no binary stream cache is ever attempted.
3. **No Redundant User Copies**: Local audio files already on the user's filesystem are played in-place and are **never** copied into the cache directory.
4. **Permitted Sources Only**: Only audio streams from sources with explicit caching rights (e.g. creative commons, user-authorized endpoints, local imports) are cached.
5. **Deterministic Storage Management**: LRU eviction based on access timestamps ensures the disk cache stays strictly within configured boundaries (default 2GB limit), with SHA-256 checksum verification on every completed download.

---

## 7. Platform Credential Storage & Security Boundaries

OAuth tokens and sensitive session materials are secured via hardware-backed platform storage:
- **Android**: `EncryptedSharedPreferences` backed by Android Keystore.
- **Windows**: Windows Credential Manager / DPAPI encryption via `flutter_secure_storage`.
- **Linux**: Secret Service API / `libsecret`.
- **Fallback**: In-memory volatile storage if hardware keystore is unavailable, preventing unencrypted tokens on disk.

---

## 8. Comprehensive Risk Matrix

| Risk ID | Component | Description | Impact | Probability | Mitigation Strategy |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **R-01** | Stream Resolution | Third-party audio streams blocked or rate-limited | High | High | Ban scraping. Use local library files and official streaming APIs. Surface honest unsupported states when audio cannot be legally secured. |
| **R-02** | Spotify Import | User attempts to import private or deleted Spotify playlist | Medium | Medium | Validate URL regex on input. If API returns 404 or 403, display clear user guidance that the playlist must be set to "Public". |
| **R-03** | Cloud Sync | Conflicting playlist edits on two offline devices | Medium | Medium | Deterministic UTC timestamp resolution (Last-Write-Wins). Soft deletes prevent accidental revival of deleted playlists. |
| **R-04** | Desktop Dependencies | Missing `libmpv-dev` on Linux or Visual C++ Redistributable on Windows | High | Low | Bundle dynamic libraries with desktop installer (`distribute_options.yaml`). Provide fallback checks during initialization. |
| **R-05** | Audio Interruption | Android OS kills background audio service under memory pressure | High | Low | Run audio service as a Foreground Service with an active persistent media notification and `WAKE_LOCK`. |
| **R-06** | Local DB Corruption | Abrupt process termination or power loss during SQLite write | High | Low | Enforce WAL (Write-Ahead Logging) mode in SQLite via Drift. Wrap all multi-entity mutations in explicit ACID transactions. |
| **R-07** | Cache Quota Overflow | Large audio downloads exceeding user-configured disk quota | Medium | Low | Active LRU eviction purges oldest unplayed tracks before writing new audio data; downloads abort if free disk < 50MB. |
| **R-08** | Credential Leakage | Tokens or secrets leaking into debug console or logs | High | Low | `CaviaLogger` automatically scrubs Bearer tokens, secrets, emails, and filesystem usernames with regex redaction. |


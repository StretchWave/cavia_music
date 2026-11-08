# CAVIA MUSIC — COMPLETE UI/UX AUDIT & REDESIGN ARCHITECTURE

## 1. Executive Summary & Design Vision

**Cavia Music** is a high-fidelity local and streaming music application built with Flutter. While its functional foundations (Drift/SQLite database, Supabase cloud synchronization, InnerTube audio streaming, audio_service background execution, and LRCLIB synchronized lyrics) are intact, the frontend suffered from significant visual and architectural shortcomings:

1. **Overused Atmospheric Scenery & Heavy Glass**: Full-bleed Japanese scenery images (`bg_library.jpg`, `bg_search.jpg`) were rendered across virtually every screen and sub-screen with conflicting opacities, creating visual clutter and backdrop fatigue. Glass containers were wrapped around basic list items and text rows, compounding GPU load (`BackdropFilter`) and degrading readability.
2. **Broken Navigation & State Destruction**: Switching between primary navigation tabs (Library, Search, Settings) destroyed the active screen instances due to an `AnimatedSwitcher` rebuilding pages from scratch. Search queries, active filter chips, scroll positions, and network results were instantly lost on tab change.
3. **Fragmented Information Architecture**:
   - The Library acted as a 2×2 dashboard of shortcuts rather than a curated music collection.
   - Albums and Artists shortcut tiles opened ad-hoc bottom sheets instead of dedicated collection browsing views.
   - Creating a playlist was intertwined with viewing playlists.
   - Liked Songs lacked batch queue controls and shared artwork hero animations.
4. **Search Interaction Gaps & Dead Handlers**:
   - Filter category switching suffered from query identity race conditions.
   - Online album, artist, and playlist search results had completely empty `onTap: () {}` tap handlers.
   - Internal technical terminology ("Titles from Streams") leaked into user-facing UI.
5. **Player Lifecycle & Transition Defects**:
   - The Full Player overlay was unmounted abruptly on collapse before the slide animation could complete.
   - Waveform scrubbers relied on pseudo-random static heights instead of real interactive seeking.
   - Lyrics auto-scrolling used an arbitrary `index * 72.0` arithmetic approximation that drifted off-screen.
   - Queue overlay was rendered as a full-screen replacement rather than a smooth draggable bottom sheet.
6. **Non-Functional & Misplaced Settings**:
   - Accent color picker did not propagate to `ThemeData` or `CaviaColors`.
   - "Liquid Glass Blur: Enabled" was a non-interactive static row.
   - Crossfade, Gapless Playback, and Volume Normalization toggles persisted preference values without actual audio engine support.
   - Spotify Import was buried in Settings rather than exposed as a collection action in the Library.
7. **Production Data Integrity**:
   - `CaviaApp` defaulted to `autoSeed = true`, populating fake demo tracks, playlists, and queue state on clean launch.

---

## 2. Refined Design System: Japanese Editorial × Restrained Liquid Glass

The redesign embraces a disciplined editorial aesthetic inspired by Japanese sumi-e ink wash, traditional lacquerware, and precision-milled glass audio hardware.

### 2.1 Color Palette
- **Near-Black Charcoal (`0xFF090A0C`)**: Primary background for ambient and content surfaces.
- **Deep Graphite (`0xFF12151B`)**: Card and elevated panel background with subtle warmth.
- **Surface Dark (`0xFF181C24`)**: Interactive surfaces, inputs, and list rows.
- **Vermilion Accent (`0xFFE53935` / `0xFFFF453A`)**: Reserved strictly for primary callouts, playback active state, progress, and selected tabs. Never overused on every border.
- **Aged Ivory (`0xFFF7F4EB`)**: Primary text with high contrast (>13:1 against background).
- **Silver Mist (`0xFF9DA2AC`)**: Secondary text and metadata (WCAG AA compliant >5.5:1).
- **Muted Slatestone (`0xFF6E7480`)**: Supporting metadata, borders, and disabled controls.

### 2.2 Glass Treatment & Surface Restraint
- **Glass Blur**: Applied strategically to floating overlay surfaces only:
  1. Bottom Navigation Dock (`CaviaBottomNav`)
  2. Floating Mini Player (`CaviaMiniPlayer`)
  3. Queue Bottom Sheet (`CaviaQueueSheet`)
  4. Context Menus and Selected Dialogs
- **Solid Dark Surfaces**: Standard list rows, album cards, playlist items, search result rows, and settings groups use crisp semi-transparent solid backgrounds (`0x0AFFFFFF` to `0x14FFFFFF`) with hairline borders (`0x14FFFFFF`), eliminating stacked `BackdropFilter` performance penalties.
- **Scenery Backgrounds**: Scenery images are removed from Search, Settings, Subscreens, and Collections. They are reserved exclusively for:
  1. Library Top Header Banner (atmospheric header with gentle gradient fade)
  2. Full Player Atmosphere (artwork-derived ambient bloom)

### 2.3 Typography Scale (8-point grid rhythm)
- `displayLarge`: 28px, w700, -0.6 letter-spacing, 1.2 line-height (Full Player, Key Hero)
- `displayMedium`: 22px, w700, -0.4 letter-spacing, 1.2 line-height (Page Titles, Dialog Titles)
- `displaySmall`: 18px, w600, -0.2 letter-spacing (Collection & Sheet Headers)
- `titleMedium`: 15px, w600, -0.2 letter-spacing (Track Title, Card Title)
- `bodyMedium`: 14px, w400, 1.4 line-height (General Content, Dialog Body)
- `bodySmall`: 13px, w400, 0.1 letter-spacing (Artist Subtitles, Metadata)
- `labelMedium`: 12px, w600, 0.2 letter-spacing (Buttons, Chips, Badges)
- `labelSmall`: 11px, w500, 0.3 letter-spacing (Timestamps, Status)
- `overline`: 11px, w700, 2.5 letter-spacing (Section Overlines, uppercase)

---

## 3. Component Architecture & Reusable Widget Library

All screens will be constructed using standardized, atomic design components located under `lib/core/components/`:

| Component | Responsibility |
|---|---|
| `CaviaPageHeader` | Standardized header with wordmark, page title, optional actions and back button |
| `CaviaSectionHeader` | Clean editorial section title with optional trailing action ("See All", "Sort", "Filter") |
| `CaviaGlassSurface` | Consolidated single-source-of-truth liquid glass surface with restrained blur, highlight, and optional glow |
| `CaviaArtwork` | Artwork loader supporting network, asset, and cached disk files with fallback, shimmer, and glass arc |
| `CaviaTrackRow` | Standardized track row used across Library, Playlists, Albums, Artists, Search, and Queue |
| `CaviaAlbumCard` | Responsive album card with artwork, title, artist, year, and play-on-hover / tap |
| `CaviaArtistRow` / `CaviaArtistCard` | Circular artist portrait with follow action and track count |
| `CaviaPlaylistCard` | Playlist collection card with composite or dedicated artwork |
| `CaviaSearchField` | Refined search input with debounce, search icon, clear action, and active state feedback |
| `CaviaFilterControl` | Segmented filter bar for All / Songs / Albums / Artists / Playlists |
| `CaviaEmptyState` | Elegant, non-distracting empty state with icon, primary text, and immediate action button |
| `CaviaLoadingState` | Branded minimal loading spinner with contextual caption |
| `CaviaErrorState` | Human-readable failure explanation with retry action |
| `CaviaMiniPlayer` | Persistent, floating or docked playback widget with track details, artwork, progress, and controls |
| `CaviaContextMenu` | Standardized modal bottom sheet or desktop popup for track, album, and playlist actions |
| `CaviaDialog` | Glass-morphic alert and prompt dialog with title, body, and action buttons |
| `CaviaBottomSheet` | Draggable, dismissible modal sheet with drag handle, scrim, and snap points |

---

## 4. Screen Architecture & Navigation Overhaul

### 4.1 Shell Architecture (`MainScaffold`)
- **State Preservation**: Replaced `AnimatedSwitcher` with `IndexedStack` (or persistent keep-alive views) to ensure tab switches never unmount or destroy search queries, active results, or scroll offsets.
- **Adaptive Navigation**:
  - **Mobile (< 768px)**: Floating frosted liquid glass bottom nav dock with SafeArea awareness. Mini player sits directly docked above the nav bar with calculated dynamic clearance.
  - **Tablet (768px – 1024px)**: Expanded navigation rail with spacious content gutters.
  - **Desktop (> 1024px)**: Left-aligned fixed sidebar (240px) with logo, navigation links, quick playlist access, and bottom profile summary. Mini player expands into a persistent desktop playback dock.

### 4.2 Library Navigation & Content Hierarchy
- **Header**: Compact Cavia wordmark, Library title, and immediate actions: Create Playlist (`+`), Import Playlist (`Spotify icon`), and Settings (`gear`).
- **Primary Collection Tabs**: Clean segmented chips:
  1. **Playlists**: Full collection screen with grid/list view toggle, creation button, and track counts.
  2. **Albums**: Full album catalog grid with release year and artist name.
  3. **Artists**: Full artist directory with portrait artwork and followed status.
  4. **Liked Songs**: Dedicated entry point with total duration and quick "Play All" / "Shuffle".
- **Dynamic Content**:
  - **Recently Played**: Shows genuine playback history if available.
  - **Pinned & Favorite Collections**: Quick access cards.
  - **Clean Empty State**: When library has no tracks, shows a minimalist Japanese ink graphic with two direct buttons: "Search Music" and "Import Playlist". No empty horizontal carousels.

### 4.3 Search Architecture & State Machine
- **Explicit State Machine**:
  `Idle` → `Typing` → `Searching` → `Success (Local & Online)` / `NoResults` / `Offline` / `Error`.
- **Cancellation & Debounce**: Superseded queries cancel in-flight HTTP requests and complete completers gracefully.
- **All Tap Handlers Functional**:
  - Song results: Taps call `playback.playNow()` / `playQueue()`.
  - Album results: Taps navigate to `AlbumDetailScreen`.
  - Artist results: Taps navigate to `ArtistDetailScreen`.
  - Playlist results: Taps navigate to `PlaylistDetailScreen` (or resolve online playlist tracks).

### 4.4 Player Expansion & Queue Bottom Sheet
- **Coordinated Shared Transition**:
  - `PlayerOverlayWrapper` keeps the full player mounted through the reverse animation curve (`durationExpansion = 400ms`), preventing sudden dismissals.
  - Seamless transformation from mini player dock to full player.
- **Interactive Scrubber**:
  - Replaces static random bars with a sleek crimson scrub bar with buffer progress, elapsed time, total duration, and touch/drag scrubbing.
- **Queue Bottom Sheet**:
  - Implemented as a proper `DraggableScrollableSheet` with visible drag pill, snap positions (0.6, 0.95), reorderable track list, individual removal, and "Clear Upcoming".
- **Lyrics View**:
  - Uses key-based line measuring or exact scroll positioning to eliminate `index * 72` drift. Manual scroll disables auto-scroll lock until a "Resume Sync" pill is tapped or 5s elapse.

### 4.5 Settings Simplification
- Organized into 5 distinct, compact grouped cards:
  1. **Playback**: Stream quality, cache behavior.
  2. **Storage**: Offline caching switch (does NOT clear data), current cache size in MB/GB, and explicit "Clear Cache" button with confirmation.
  3. **Account & Cloud Sync**: Guest Sanctuary vs Authenticated, last sync time, manual sync trigger.
  4. **Appearance**: Dynamic theme switching (or clean static Dark theme without broken accent toggles).
  5. **About**: Version, licenses, and links.
- Removed decorative non-functional controls (crossfade, normalization, gapless placeholders).
- Removed automatic seeding on production bootstrap (`autoSeed = false`).

---

## 5. Verification Plan
- `flutter analyze`: Zero errors, zero warnings.
- `flutter test`: All 140+ existing tests pass, plus new interaction and navigation regression tests.
- Multi-viewport layout verification: 360px, 390px, 430px, 768px, 1024px, 1440px.


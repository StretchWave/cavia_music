# Cavia Music — Feature & Interaction Inventory

## 1. Overview & Scope

This document provides a comprehensive inventory of every user interaction, system event, state transition, and failure recovery scenario across Cavia Music. Cavia Music is architected around a **local-first paradigm**: all user actions (library modifications, playlist mutations, playback queue reordering, and preference changes) take effect synchronously against the local store, before asynchronously staging change operations into an offline outbox for cloud replication when an authenticated Supabase session is present.

---

## 2. Interaction & Lifecycle Inventory

| Feature | Entry Point | Action | State Before | Expected Result | Alternative Outcomes | Failure Cases | Persistence | Recovery | UI Response |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **App Lifecycle** | OS App Launcher / Icon | Cold start application | Terminated | App initializes SQLite database, restores settings, loads last played song & queue into memory, opens Library (`藏`) | Fresh install: initializes seeded default library (Afterglow) | Corrupted DB file, disk I/O permission denied | Local DB (`app_settings`, `songs`, `playlists`) | Auto-run integrity check, re-seed defaults if corrupted | Displays Japanese Ink splash, transitions into Library within 400ms |
| **App Lifecycle** | OS App Switcher / Window close | App minimized / Window close | Foreground Active | Audio continues playing in background service (Android) or system tray/minimized (Desktop). State persisted | User closed while paused: saves current playhead position | Memory pressure kills OS process | Local DB (`playback_state`) | On resume, restore last state | Window minimizes smoothly, audio notifications remain active |
| **App Lifecycle** | Deep link URL / Custom URI scheme | Receive `caviamusic://auth/callback` or `caviamusic://playlist/{id}` | Any state | Parses query params; if auth callback, completes Supabase PKCE exchange; if playlist link, loads playlist details | Already signed in / Invalid token: ignores or prompts notification | Malformed URI, expired token | Temporary memory -> Secure storage (tokens) | Refresh auth token or show invalid link error | Toast: `"Signed in successfully"` or `"Invalid link"` |
| **Playback** | Mini-Player (Floating capsule) | Tap play/pause button | Paused or Playing | Toggles playback state. Audio handler starts/pauses hardware output. Waveform & animated icon morph | Headset disconnected: audio pauses automatically | Audio focus rejected, device audio driver error | In-memory + Local DB playhead | Retry pipeline or notify audio unavailable | Play/Pause icon animates with concentric vermilion glow |
| **Playback** | Mini-Player (Floating capsule) | Tap anywhere outside play/pause button | Mini-Player docked above bottom bar | Full Player overlay slides smoothly up from bottom with fluid physics curve (`CaviaMotion.durationExpansion`) | Full Player already expanding: animation continues | Layout render constraint overflow | In-memory UI state | Tap chevron down to collapse | Full Player expands into view with ambient album backdrop |
| **Playback** | Full Player (`PAGE 06`) | Tap Chevron Down (`Icons.keyboard_arrow_down_rounded`) | Full Player open | Full Player slides down and collapses into persistent Mini-Player capsule | User drags down via swipe gesture | N/A | In-memory UI state | Tap Mini-Player to re-expand | Smooth collapse transition, underlying screen remains interactive |
| **Playback** | Full Player (`PAGE 06`) | Tap Next Track (`Icons.skip_next_rounded`) | Playing track $N$ in queue | Advances playhead to track $N+1$, fetches stream source, resets position to 0:00, starts playback | If on last track and repeat is `all`: loops to first track. If repeat `off`: stops | Audio source unresolved, HTTP 404/403 | In-memory + Playback history | Auto-fallback to next stream provider or skip to next valid track | Toast if unresolved: `"Source unavailable, skipping..."` |
| **Playback** | Full Player (`PAGE 06`) | Tap Previous Track (`Icons.skip_previous_rounded`) | Position > 3s into track | Seeks to 0:00 of current track and continues playing | If position <= 3s: skips back to track $N-1$ in queue | No previous track: restarts track from 0:00 | In-memory | Re-tap Previous | Smooth seek to 0:00 |
| **Playback** | Full Player (`PAGE 06`) | Drag / Tap Waveform Scrubber | Position at $t_1$ | Playhead seeks to target fraction $t_2$. Waveform highlights elapsed bars in vermilion bright; live duration labels update | User drags off-bounds: clamped to `[0.0, 1.0]` | Audio decoder buffering stall | In-memory playhead | Buffer catches up; resume playback | Waveform visually scrubs in real-time, timestamps update |
| **Playback** | Full Player (`PAGE 06`) | Tap Shuffle Button (`Icons.shuffle_rounded`) | Shuffle OFF | Toggles shuffle state to ON; active icon glows vermilion bright; queue order is randomized while keeping active track current | Shuffle ON: restores original playlist order | N/A | In-memory + User prefs | Toggle again to revert | Icon tints vermilion bright with subtle scale animation |
| **Playback** | Full Player (`PAGE 06`) | Tap Repeat Button (`Icons.repeat_rounded`) | Repeat OFF | Cycles repeat mode: `off` -> `all` (loops queue) -> `one` (loops current song) -> `off` | Reaches end of song: loops according to selected mode | N/A | In-memory + User prefs | Toggle again | Icon switches to `repeat_one` with active vermilion glow |
| **Playback Interruptions** | Hardware Headset / Bluetooth | Unplug headphones / Bluetooth disconnects | Playing audio | `BECOMING_NOISY` broadcast received by audio engine; playback pauses immediately | Audio reconnected: user explicitly presses play to resume | Headphone jack hardware failure | In-memory playhead | User presses Play | Playback pauses, icon updates to Play |
| **Playback Interruptions** | Phone Call / Voice Assistant | Incoming call / Audio Focus loss | Playing audio | Transient focus loss ducks volume; complete focus loss pauses audio; resumes when call terminates | User rejects call: playback resumes immediately | Focus not restored by OS | In-memory | Manual resume by user | UI reflects pause state, resumes smoothly |
| **Playback Controls (OS)** | Android Notification / Windows SMTC / Linux MPRIS | OS transport button (Play, Pause, Skip, Seek) | Any playback state | Dispatches corresponding intent to background `AudioHandler`; updates UI and hardware state synchronously | App in background: OS controls update metadata & art | OS kills service under severe memory limits | Local persistence | Restart app from notification | Media metadata, progress, and artwork render in OS notification |
| **Queue Management** | Full Player Bottom Pill | Tap Queue button (`Icons.queue_music_rounded`) | Queue drawer closed | Opens `QueueSheet` modal with currently playing track highlighted and reorderable Up Next list | Already open: closes sheet | N/A | In-memory | Tap close (`X`) | Glass sheet appears with spring curve |
| **Queue Management** | `QueueSheet` (`PAGE 07`) | Drag track reorder handle (`Icons.drag_handle_rounded`) | Item at index $i$ | Moves track to index $j$; queue array reordered; current song pointer remains consistent | Item dragged out of list: cancels drag | Concurrent track completion during drag | In-memory queue + Local DB outbox | Undo reorder | Item glides physically into new position |
| **Queue Management** | `QueueSheet` (`PAGE 07`) | Tap Remove button (`Icons.remove_circle_outline_rounded`) | Track in queue | Removes track from queue; remaining tracks re-index | Attempting to remove currently playing track: clears track or plays next | N/A | In-memory | Re-add track from library | Track animates out of list smoothly |
| **Queue Management** | `QueueSheet` (`PAGE 07`) | Tap Clear Queue | Multiple tracks in queue | Removes all tracks from queue except the currently playing track | Only 1 track in queue: no-op | N/A | In-memory | Re-queue playlist | Up Next list clears, leaving Now Playing |
| **Lyrics** | Full Player Bottom Pill | Tap Lyrics button (`Icons.lyrics_rounded`) | Lyrics view closed | Opens `LyricsScreen` overlay; parses time-synced lyrics; highlights active line based on current playhead | No lyrics found: shows `"No lyrics available for this track"` | Network timeout fetching lyrics | Local cache / LRCLIB | Fallback to plain text or retry | Synced lyrics screen fades in over ambient background |
| **Lyrics** | `LyricsScreen` (`PAGE 08`) | Tap Mode Switcher (`Icons.sync_rounded`) | Synced mode | Switches display mode between time-synchronized karaoke view and scrollable plain text | Switched to Plain Text: autoscrolling disabled | Formatting error in LRC timestamp | In-memory | Toggle back to Synced | UI switches font size and removes timestamp highlights |
| **Lyrics** | `LyricsScreen` (`PAGE 08`) | User manually scrolls lyrics list | Autoscrolling active | Suspends automatic lyrics auto-scroll for 5 seconds to allow reading; resumes auto-scroll on timer expiry | User taps a lyric line: seeks playhead to that timestamp | N/A | In-memory | Auto-scroll resumes after 5s | Smooth deceleration of list |
| **Library** | Library (`PAGE 01`) | Tap Liked Songs shortcut | Library screen | Navigates to Liked Songs playlist detail view, filtering `songs.where((s) => s.isLiked)` | No liked songs: shows empty state with prompt to like tracks | N/A | Local DB query | Like tracks from search or player | Transitions to `PlaylistDetailScreen` with glowing heart banner |
| **Library** | Any song row / Player | Tap Heart button (`Icons.favorite_rounded`) | Track unliked | Sets `isLiked = true`; writes to local DB; queues Supabase sync task; updates all UI instances reactively | Track already liked: sets `isLiked = false` | Disk write error | Local DB + Cloud sync outbox | Automatic retry outbox | Heart turns vermilion bright; toast: `"Saved to Liked Songs"` |
| **Playlists** | Library (`PAGE 01`) | Tap Create Playlist (`+` button) | Library screen | Opens `CreatePlaylistDialog` glass modal with Name and Description text fields | User cancels: dialog closes | Empty name entered: defaults to `"Untitled Playlist"` | In-memory -> Local DB | Re-open dialog | Dialog appears centered with autofocus |
| **Playlists** | `CreatePlaylistDialog` | Enter name & tap Create | Dialog active | Creates new playlist in local DB; prepends to `playlists` list; dispatches sync outbox event | Name contains invalid characters: sanitizes input | Local SQLite transaction error | Local DB + Cloud sync outbox | Show retry prompt | Dialog dismisses; toast: `"Playlist created"`; appears on screen |
| **Playlists** | `PlaylistDetailScreen` (`PAGE 05`) | Tap Edit Playlist button (`Icons.edit_rounded`) | Playlist screen | Opens `PlaylistEditDialog`; allows modifying playlist title and description | User cancels: no changes saved | Name empty: prevents saving | Local DB + Cloud sync outbox | Cancel and re-edit | Dialog pops; updated title/description render immediately |
| **Playlists** | `PlaylistDetailScreen` (`PAGE 05`) | Tap Delete Playlist (`Icons.delete_outline_rounded`) | Playlist screen | Displays `CaviaDialog` confirmation warning: `"Are you sure? This cannot be undone."` | User cancels: dialog closes, playlist kept | Local DB delete error | Local DB + Cloud sync outbox | Dialog dismissal | On confirm: removes playlist from DB and navigates back |
| **Playlists** | `PlaylistDetailScreen` (`PAGE 05`) | Swipe track row right-to-left | Track in playlist | Reveals red delete background; dismisses item; removes association from `playlist_tracks` | User undoes via snackbar action | DB constraint error | Local DB + Cloud sync outbox | Tap Undo within 4s | Track animates out; toast: `"Removed from playlist"` |
| **Context Menu** | Any song row / 3-dots icon | Tap overflow menu (`Icons.more_vert_rounded`) | List / Player view | Opens `TrackContextMenu` bottom sheet with options: Play Next, Add to Queue, Save/Remove Liked, Add to Playlist | User taps scrim: closes menu | N/A | In-memory | Re-tap menu icon | Frosted glass bottom sheet slides up with song preview header |
| **Context Menu** | `TrackContextMenu` | Tap "Add to Playlist..." | Track menu open | Opens `_showAddToPlaylistSheet` listing all user playlists; tapping a playlist appends the song | Song already in playlist: notifies duplicate or skips | DB write failure | Local DB + Cloud sync outbox | Retry from menu | Bottom sheet pops; toast: `"Added to {Playlist Name}"` |
| **Search** | Bottom Nav / Search tab | Tap Search icon (`Icons.search_rounded`) | Library or Settings active | Switches active navigation tab to Search (`探`); displays search bar and recent searches | Search field already has text: preserves search query | Keyboard opens automatically on mobile | In-memory | Re-tap tab | Search screen fades in with Torii lake background |
| **Search** | Search (`PAGE 02`) | Type in search input field | Recent searches visible | Queries local database & cached catalogue in real time; displays categorised results | Query string empty: restores recent searches list | Search query regex exception | In-memory / Local DB cache | Clear text field | Results list animates in grouped by Songs, Albums, Artists |
| **Search** | Search (`PAGE 02`) | Tap category filter chip (e.g. `Albums`) | `All` category selected | Filters displayed results strictly to matching albums; chip highlights with vermilion fill | Tap chip again or tap `All`: resets filter | No results in category: shows category empty state | In-memory | Tap `All` chip | Selected chip glows vermilion; list updates |
| **Search** | Search (`PAGE 02`) | Tap individual history delete (`Icons.close_rounded`) | Query in history | Removes query item from `search_history` in local DB; re-indexes history list | Tap "Clear all": clears entire history | DB write error | Local DB (`search_history`) | Re-enter query | Item animates out of recent searches list |
| **Spotify Import** | Settings / Import option | Tap "Import from Spotify" | Settings screen | Pushes `SpotifyImportScreen` (`PAGE 10`) onto navigation stack | User cancels: navigates back | Deep link redirect failure | In-memory UI state | Tap Back button | Screen opens with URL input field and sample playlist button |
| **Spotify Import** | `SpotifyImportScreen` (`PAGE 10`) | Paste public Spotify playlist URL & submit | Input active | Validates URL structure (`open.spotify.com/playlist/...`); initiates metadata resolution | URL invalid: displays inline red error text | URL malformed, network offline | In-memory -> Temp cache | Tap "Use Sample URL" or re-paste | Input box outlines red if invalid, or transitions to preview card |
| **Spotify Import** | `SpotifyImportScreen` (`PAGE 10`) | Tap "Import Tracks to Library" | Preview card ready | Starts simulated/real ingestion: creates local playlist, fuzzy-matches tracks, displays linear progress | Network drops mid-import: pauses and offers retry | Third-party rate limit (HTTP 429) | Local DB (`playlists`, `songs`) | Tap "Try Again" | Progress bar animates 0% -> 100%; transitions to Success screen |
| **Settings** | Settings (`PAGE 09`) | Toggle "Offline caching" switch | Caching ON or OFF | Toggles auto-caching flag. **Note:** Turning OFF does NOT delete existing cached files | Caching turned ON: downloads future played tracks | Storage permission denied | Local DB (`app_settings`) | Request storage permission | Switch animates; toast: `"Offline caching enabled"` / `"disabled"` |
| **Settings** | Settings (`PAGE 09`) | Tap "Clear cache" row | Cache holds $X$ GB | Displays `CaviaDialog` modal asking confirmation to delete locally cached audio & artwork | User cancels: cache retained | File system I/O error deleting files | Local cache files + DB | Dismiss dialog | Dialog confirms; cache size resets to `"0 MB"`; toast confirms |
| **Settings** | Settings (`PAGE 09`) | Toggle "Sync" switch | Local-only mode | If not logged in: prompts Supabase Auth modal. If logged in: enables background cloud synchronization | User signs in: triggers initial cloud pull & conflict resolution | Supabase unreachable, invalid credentials | Secure storage + Local DB | Retry connection | Switch toggles; toast: `"Cloud sync connected"` |
| **Settings** | Sub-screens (Playback, Appearance) | Change Accent Color (e.g. Amber/Bamboo) | Vermilion accent active | Updates `CaviaColors.vermilion` dynamic theme token across all components reactively | App restarts: persists selected accent color | N/A | Local DB (`app_settings`) | Select Vermilion to revert | All glowing borders, switches, and highlights switch colors |

---

## 3. Sequence Edge Cases & Interaction Matrices

### 3.1 Scenario A: Like Song While Offline $\rightarrow$ Cloud Sign-In $\rightarrow$ Remote Sync
```
[User Offline]
  │
  ├─ 1. User taps Like on Track "Afterglow"
  │     └─ Local SQLite: `tracks.is_liked = true`, `updated_at = T1`
  │     └─ Outbox: Inserts `MUTATION_LIKE(track_id, is_liked=true, T1)`
  │
[User Connects & Signs In via Supabase]
  │
  ├─ 2. Auth completes; session token stored securely
  ├─ 3. Sync engine scans remote `user_likes` table
  │     ├─ Remote has no record for "Afterglow": Outbox mutation pushed -> Remote updated
  │     └─ Remote has older record (`T0 < T1`): Remote updated with local state (Last-Write-Wins)
  │     └─ Remote has newer record (`T2 > T1`): Local state updated to match remote
  └─ 4. Outbox item deleted on HTTP 200 acknowledgment
```

### 3.2 Scenario B: Create Playlist Offline $\rightarrow$ Delete Before Sync $\rightarrow$ Reconnect
```
[User Offline]
  │
  ├─ 1. User creates Playlist "Nightfall" -> Outbox: `INSERT_PLAYLIST(id_1, T1)`
  ├─ 2. User deletes Playlist "Nightfall" -> Outbox: `DELETE_PLAYLIST(id_1, T2)`
  │
[User Connects to Internet]
  │
  ├─ 3. Outbox squashes operations for `id_1` (Insert followed by Delete = NO-OP)
  └─ 4. Remote database receives zero unnecessary writes; network bandwidth preserved
```

### 3.3 Scenario C: Concurrent Mutations on Two Devices (Conflict Resolution)
```
[Device A (Offline)]                           [Device B (Online)]
  │                                              │
  ├─ Renames Playlist to "Tokyo Rain" (T1)       ├─ Renames Playlist to "Tokyo Mist" (T2)
  │                                              │    └─ Commits to Supabase (T2 > T1)
  │                                              │
[Device A Reconnects (T3 > T2)]                  │
  │                                              │
  ├─ Sync engine checks `updated_at`:            │
  │     Remote (T2) > Local mutation (T1)        │
  ├─ Device A adopts "Tokyo Mist"               │
  └─ Local database updated, UI reflects "Tokyo Mist" without user disruption
```


-- ==============================================================================
-- CAVIA MUSIC — Production Cloud Schema & Security Migration
-- Version: 20261105000000
-- Description: Sets up profiles, playlists, playlist entries, liked tracks,
--              user preferences, sync devices, operation receipts, and tombstones
--              with strict Row Level Security (RLS) guaranteeing multi-tenant isolation.
-- ==============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ------------------------------------------------------------------------------
-- 1. Profiles Table
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL DEFAULT 'Cavia Listener',
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Trigger to automatically create a profile row when a new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, display_name, avatar_url)
    VALUES (
        new.id,
        COALESCE(new.raw_user_meta_data->>'display_name', split_part(new.email, '@', 1), 'Cavia Listener'),
        new.raw_user_meta_data->>'avatar_url'
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ------------------------------------------------------------------------------
-- 2. Sync Devices Table (Tracks active devices per user for sync topology)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.sync_devices (
    id TEXT NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    device_name TEXT NOT NULL DEFAULT 'Unknown Device',
    platform TEXT NOT NULL DEFAULT 'unknown',
    app_version TEXT NOT NULL DEFAULT '0.1.0',
    last_synced_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    PRIMARY KEY (user_id, id)
);

ALTER TABLE public.sync_devices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage their own sync devices"
    ON public.sync_devices FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_sync_devices_user ON public.sync_devices(user_id);

-- ------------------------------------------------------------------------------
-- 3. Playlists Table
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.playlists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL CHECK (char_length(trim(name)) > 0),
    description TEXT NOT NULL DEFAULT '',
    artwork_uri TEXT NOT NULL DEFAULT 'assets/images/cover_zenith.jpg',
    revision BIGINT NOT NULL DEFAULT 1,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    is_system BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.playlists ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read their own non-deleted or tombstoned playlists"
    ON public.playlists FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own playlists"
    ON public.playlists FOR INSERT
    WITH CHECK (auth.uid() = user_id AND NOT is_system);

CREATE POLICY "Users can update their own playlists"
    ON public.playlists FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own non-system playlists"
    ON public.playlists FOR DELETE
    USING (auth.uid() = user_id AND NOT is_system);

CREATE INDEX IF NOT EXISTS idx_playlists_user_updated ON public.playlists(user_id, updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_playlists_user_deleted ON public.playlists(user_id, is_deleted);

-- ------------------------------------------------------------------------------
-- 4. Playlist Entries Table (Independent IDs allow duplicate tracks with ordering)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.playlist_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    playlist_id UUID NOT NULL REFERENCES public.playlists(id) ON DELETE CASCADE,
    track_id TEXT NOT NULL,
    position INTEGER NOT NULL,
    revision BIGINT NOT NULL DEFAULT 1,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    date_added TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.playlist_entries ENABLE ROW LEVEL SECURITY;

-- Security check ensures a user cannot read, insert, update or delete entries in another user's playlist
CREATE POLICY "Users can read entries of their own playlists"
    ON public.playlist_entries FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.playlists p
            WHERE p.id = playlist_entries.playlist_id
            AND p.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert entries into their own playlists"
    ON public.playlist_entries FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.playlists p
            WHERE p.id = playlist_entries.playlist_id
            AND p.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update entries of their own playlists"
    ON public.playlist_entries FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.playlists p
            WHERE p.id = playlist_entries.playlist_id
            AND p.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.playlists p
            WHERE p.id = playlist_entries.playlist_id
            AND p.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete entries of their own playlists"
    ON public.playlist_entries FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.playlists p
            WHERE p.id = playlist_entries.playlist_id
            AND p.user_id = auth.uid()
        )
    );

CREATE INDEX IF NOT EXISTS idx_playlist_entries_playlist_pos ON public.playlist_entries(playlist_id, position ASC);
CREATE INDEX IF NOT EXISTS idx_playlist_entries_track ON public.playlist_entries(track_id);

-- ------------------------------------------------------------------------------
-- 5. Liked Tracks Table
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.liked_tracks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    track_id TEXT NOT NULL,
    is_liked BOOLEAN NOT NULL DEFAULT TRUE,
    revision BIGINT NOT NULL DEFAULT 1,
    date_liked TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(user_id, track_id)
);

ALTER TABLE public.liked_tracks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage their own liked tracks"
    ON public.liked_tracks FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_liked_tracks_user_updated ON public.liked_tracks(user_id, updated_at DESC);

-- ------------------------------------------------------------------------------
-- 6. User Preferences Table (Fine-grained per-setting cloud replication)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.user_preferences (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    offline_caching BOOLEAN NOT NULL DEFAULT TRUE,
    audio_quality TEXT NOT NULL DEFAULT 'Lossless (24-bit / 96kHz FLAC)',
    crossfade BOOLEAN NOT NULL DEFAULT TRUE,
    gapless_playback BOOLEAN NOT NULL DEFAULT TRUE,
    normalize_volume BOOLEAN NOT NULL DEFAULT FALSE,
    accent_color_value BIGINT NOT NULL DEFAULT 4294336040, -- 0xFFFF4528
    artwork_atmosphere BOOLEAN NOT NULL DEFAULT TRUE,
    animation_intensity TEXT NOT NULL DEFAULT 'Smooth',
    revision BIGINT NOT NULL DEFAULT 1,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage their own preferences"
    ON public.user_preferences FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 7. Operation Receipts Table (Idempotency Ledger preventing replay duplication)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.operation_receipts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    device_id TEXT NOT NULL,
    idempotency_key TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    operation_type TEXT NOT NULL,
    applied_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(user_id, idempotency_key)
);

ALTER TABLE public.operation_receipts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users read and create their own operation receipts"
    ON public.operation_receipts FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_operation_receipts_user_key ON public.operation_receipts(user_id, idempotency_key);

-- ------------------------------------------------------------------------------
-- 8. Sync Tombstones Table (Preserves record of deletions to prevent resurrection)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.sync_tombstones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    entity_type TEXT NOT NULL, -- 'playlist', 'playlist_entry', 'liked_track'
    entity_id TEXT NOT NULL,
    deleted_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(user_id, entity_type, entity_id)
);

ALTER TABLE public.sync_tombstones ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage their own tombstones"
    ON public.sync_tombstones FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_tombstones_user_entity ON public.sync_tombstones(user_id, entity_type, entity_id);

-- ------------------------------------------------------------------------------
-- 9. Complete Account Deletion Function
-- ------------------------------------------------------------------------------
-- Safely purges user cloud data if requested from client with auth.uid() verification
CREATE OR REPLACE FUNCTION public.delete_user_account()
RETURNS VOID AS $$
DECLARE
    current_user_id UUID;
BEGIN
    current_user_id := auth.uid();
    IF current_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    -- Cascading foreign keys will clean up playlists, entries, liked tracks, devices, preferences, and receipts
    DELETE FROM public.profiles WHERE id = current_user_id;
    DELETE FROM auth.users WHERE id = current_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


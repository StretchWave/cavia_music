-- ==============================================================================
-- CAVIA MUSIC — Sync RPCs & Schema Extension
-- Version: 20261107000000
-- Description:
--   1. Extends user_preferences with playback_speed & cache_quota_bytes.
--   2. Extends playlists with import anchors (source_provider/source_playlist_id).
--   3. Adds atomic sync_push / sync_pull RPCs so that "apply + receipt" happen
--      inside ONE server transaction (never separately from the app).
--   4. Registers the pushing device in sync_devices.
--
-- Security model: both RPCs derive authorization from auth.uid() exclusively.
-- The client NEVER supplies a user_id that the server trusts; a non-null
-- auth.uid() is required for every row written.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Schema extensions
-- ------------------------------------------------------------------------------

ALTER TABLE public.user_preferences
    ADD COLUMN IF NOT EXISTS playback_speed REAL NOT NULL DEFAULT 1.0 CHECK (playback_speed > 0 AND playback_speed <= 4.0);

ALTER TABLE public.user_preferences
    ADD COLUMN IF NOT EXISTS cache_quota_bytes BIGINT;

ALTER TABLE public.playlists
    ADD COLUMN IF NOT EXISTS source_provider TEXT;

ALTER TABLE public.playlists
    ADD COLUMN IF NOT EXISTS source_playlist_id TEXT;

-- One import per external provider playlist per user (anchors are nullable for
-- locally-created playlists, so it is a PARTIAL unique index).
CREATE UNIQUE INDEX IF NOT EXISTS uq_playlists_user_import
    ON public.playlists(user_id, source_provider, source_playlist_id)
    WHERE source_provider IS NOT NULL AND source_playlist_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_playlists_user_rev ON public.playlists(user_id, revision DESC);

-- ------------------------------------------------------------------------------
-- 2. Atomic push — apply operations AND write idempotency receipts in the same
--    transaction. Replay == receipts exist but nothing is re-applied.
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.sync_push(
    p_device_id TEXT,
    p_operations JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    caller UUID := auth.uid();
    receipts JSONB := '[]'::jsonb;
    op JSONB;
    op_idem_key TEXT;
    op_entity_type TEXT;
    op_entity_id TEXT;
    op_operation_type TEXT;
    op_payload JSONB;
    already_receipt BOOLEAN;
BEGIN
    IF caller IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    -- Register/refresh device presence (device_id is opaque and client owned).
    INSERT INTO public.sync_devices (id, user_id, last_synced_at)
    VALUES (p_device_id, caller, timezone('utc'::text, now()))
    ON CONFLICT (user_id, id) DO UPDATE
        SET last_synced_at = timezone('utc'::text, now());

    IF p_operations IS NULL OR jsonb_array_length(p_operations) = 0 THEN
        RETURN jsonb_build_object('receipts', receipts);
    END IF;

    FOR op IN SELECT * FROM jsonb_array_elements(p_operations) LOOP
        op_idem_key       := op->>'idempotency_key';
        op_entity_type    := op->>'entity_type';
        op_entity_id      := op->>'entity_id';
        op_operation_type := op->>'operation_type';
        op_payload        := COALESCE(op->'payload', '{}'::jsonb);

        SELECT EXISTS (
            SELECT 1 FROM public.operation_receipts r
            WHERE r.user_id = caller AND r.idempotency_key = op_idem_key
        ) INTO already_receipt;

        BEGIN
            IF NOT already_receipt THEN
                CASE op_entity_type
                    WHEN 'playlist' THEN
                        IF op_operation_type = 'delete' THEN
                            UPDATE public.playlists
                               SET is_deleted = TRUE,
                                   revision   = revision + 1,
                                   updated_at = timezone('utc'::text, now())
                             WHERE id = op_entity_id::uuid AND user_id = caller;
                            INSERT INTO public.sync_tombstones (user_id, entity_type, entity_id, deleted_at)
                            VALUES (caller, 'playlist', op_entity_id, timezone('utc'::text, now()))
                            ON CONFLICT (user_id, entity_type, entity_id) DO NOTHING;
                        ELSE
                            INSERT INTO public.playlists (
                                id, user_id, name, description, artwork_uri,
                                revision, is_deleted, created_at, updated_at,
                                source_provider, source_playlist_id
                            ) VALUES (
                                op_entity_id::uuid,
                                caller,
                                COALESCE(NULLIF(trim(op_payload->>'name'), ''), 'Untitled Playlist'),
                                COALESCE(op_payload->>'description', ''),
                                COALESCE(op_payload->>'artwork_uri', 'assets/images/cover_zenith.jpg'),
                                GREATEST(COALESCE((op_payload->>'revision')::bigint, 1), 1),
                                FALSE,
                                timezone('utc'::text, now()),
                                timezone('utc'::text, now()),
                                op_payload->>'source_provider',
                                op_payload->>'source_playlist_id'
                            )
                            ON CONFLICT (id) DO UPDATE SET
                                name        = COALESCE(NULLIF(trim(EXCLUDED.name), ''), public.playlists.name),
                                description = COALESCE(op_payload->>'description', public.playlists.description),
                                artwork_uri = COALESCE(op_payload->>'artwork_uri', public.playlists.artwork_uri),
                                revision    = GREATEST(public.playlists.revision, COALESCE((op_payload->>'revision')::bigint, public.playlists.revision)),
                                is_deleted  = FALSE,
                                source_provider     = COALESCE(op_payload->>'source_provider', public.playlists.source_provider),
                                source_playlist_id  = COALESCE(op_payload->>'source_playlist_id', public.playlists.source_playlist_id),
                                updated_at  = timezone('utc'::text, now());
                        END IF;

                    WHEN 'playlist_entry' THEN
                        IF op_operation_type = 'delete' THEN
                            UPDATE public.playlist_entries
                               SET is_deleted = TRUE,
                                   revision   = revision + 1,
                                   updated_at = timezone('utc'::text, now())
                             WHERE id = op_entity_id::uuid
                               AND EXISTS (SELECT 1 FROM public.playlists p
                                           WHERE p.id = playlist_entries.playlist_id
                                           AND p.user_id = caller);
                            INSERT INTO public.sync_tombstones (user_id, entity_type, entity_id, deleted_at)
                            VALUES (caller, 'playlist_entry', op_entity_id, timezone('utc'::text, now()))
                            ON CONFLICT (user_id, entity_type, entity_id) DO NOTHING;
                        ELSE
                            INSERT INTO public.playlist_entries (
                                id, playlist_id, track_id, position, revision,
                                is_deleted, date_added, updated_at
                            ) VALUES (
                                op_entity_id::uuid,
                                (op_payload->>'playlist_id')::uuid,
                                op_payload->>'track_id',
                                COALESCE((op_payload->>'position')::int, 0),
                                GREATEST(COALESCE((op_payload->>'revision')::bigint, 1), 1),
                                FALSE,
                                COALESCE((op_payload->>'date_added')::timestamptz, timezone('utc'::text, now())),
                                timezone('utc'::text, now())
                            )
                            ON CONFLICT (id) DO UPDATE SET
                                position   = COALESCE((op_payload->>'position')::int, public.playlist_entries.position),
                                revision   = GREATEST(public.playlist_entries.revision, COALESCE((op_payload->>'revision')::bigint, public.playlist_entries.revision)),
                                is_deleted = FALSE,
                                updated_at = timezone('utc'::text, now());
                        END IF;

                    WHEN 'liked_track' THEN
                        INSERT INTO public.liked_tracks (
                            id, user_id, track_id, is_liked, revision,
                            date_liked, updated_at
                        ) VALUES (
                            gen_random_uuid(),
                            caller,
                            COALESCE(op_payload->>'track_id', op_entity_id),
                            COALESCE((op_payload->>'is_liked')::boolean, TRUE),
                            GREATEST(COALESCE((op_payload->>'revision')::bigint, 1), 1),
                            COALESCE((op_payload->>'date_liked')::timestamptz, timezone('utc'::text, now())),
                            timezone('utc'::text, now())
                        )
                        ON CONFLICT (user_id, track_id) DO UPDATE SET
                            is_liked   = COALESCE((op_payload->>'is_liked')::boolean, liked_tracks.is_liked),
                            revision   = GREATEST(liked_tracks.revision, COALESCE((op_payload->>'revision')::bigint, liked_tracks.revision)),
                            date_liked = COALESCE((op_payload->>'date_liked')::timestamptz, liked_tracks.date_liked),
                            updated_at = timezone('utc'::text, now());

                    WHEN 'preference' THEN
                        INSERT INTO public.user_preferences (user_id, updated_at)
                        VALUES (caller, timezone('utc'::text, now()))
                        ON CONFLICT (user_id) DO NOTHING;

                        UPDATE public.user_preferences SET
                            offline_caching      = COALESCE((op_payload->>'offline_caching')::boolean, offline_caching),
                            audio_quality        = COALESCE(op_payload->>'audio_quality', audio_quality),
                            crossfade            = COALESCE((op_payload->>'crossfade')::boolean, crossfade),
                            gapless_playback     = COALESCE((op_payload->>'gapless_playback')::boolean, gapless_playback),
                            normalize_volume     = COALESCE((op_payload->>'normalize_volume')::boolean, normalize_volume),
                            accent_color_value   = COALESCE((op_payload->>'accent_color_value')::bigint, accent_color_value),
                            artwork_atmosphere   = COALESCE((op_payload->>'artwork_atmosphere')::boolean, artwork_atmosphere),
                            animation_intensity  = COALESCE(op_payload->>'animation_intensity', animation_intensity),
                            playback_speed       = COALESCE((op_payload->>'playback_speed')::real, playback_speed),
                            cache_quota_bytes    = COALESCE((op_payload->>'cache_quota_bytes')::bigint, cache_quota_bytes),
                            revision             = revision + 1,
                            updated_at           = timezone('utc'::text, now())
                        WHERE user_id = caller;

                    ELSE
                        RAISE EXCEPTION 'Unsupported entity_type %', op_entity_type;
                END CASE;
            END IF;

            -- Receipt is written in the SAME transaction as the mutation above.
            IF NOT already_receipt THEN
                INSERT INTO public.operation_receipts (user_id, device_id, idempotency_key, entity_type, entity_id, operation_type)
                VALUES (caller, p_device_id, op_idem_key, op_entity_type, op_entity_id, op_operation_type);
            END IF;

            receipts := receipts || jsonb_build_object(
                'idempotency_key', op_idem_key,
                'accepted', TRUE,
                'replay', already_receipt
            );

        EXCEPTION WHEN OTHERS THEN
            -- Per-op failure: report it, keep processing the rest.
            receipts := receipts || jsonb_build_object(
                'idempotency_key', op_idem_key,
                'accepted', FALSE,
                'message', SQLERRM
            );
        END;
    END LOOP;

    RETURN jsonb_build_object('receipts', receipts);
END;
$$;

-- ------------------------------------------------------------------------------
-- 3. Atomic incremental pull — everything a client needs since the watermark.
--    Runs as INVOKER: RLS restricts every row to caller's data.
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.sync_pull(
    p_since TIMESTAMPTZ
)
RETURNS JSONB
LANGUAGE sql
SECURITY INVOKER
SET search_path = public, pg_temp
AS $$
    SELECT jsonb_build_object(
        'server_time', timezone('utc'::text, now()),
        'tombstones', COALESCE(
            (SELECT jsonb_agg(jsonb_build_object(
                'entity_type', t.entity_type,
                'entity_id', t.entity_id,
                'deleted_at', t.deleted_at))
             FROM public.sync_tombstones t
             WHERE t.user_id = auth.uid()
               AND t.deleted_at > COALESCE(p_since, 'epoch'::timestamptz)),
            '[]'::jsonb),
        'playlists', COALESCE(
            (SELECT jsonb_agg(jsonb_build_object(
                'id', p.id, 'name', p.name, 'description', p.description,
                'artwork_uri', p.artwork_uri, 'revision', p.revision,
                'is_deleted', p.is_deleted,
                'source_provider', p.source_provider, 'source_playlist_id', p.source_playlist_id,
                'created_at', p.created_at, 'updated_at', p.updated_at))
             FROM public.playlists p
             WHERE p.user_id = auth.uid()
               AND NOT p.is_deleted
               AND p.updated_at > COALESCE(p_since, 'epoch'::timestamptz)),
            '[]'::jsonb),
        'playlist_entries', COALESCE(
            (SELECT jsonb_agg(jsonb_build_object(
                'id', e.id, 'playlist_id', e.playlist_id, 'track_id', e.track_id,
                'position', e.position, 'revision', e.revision, 'is_deleted', e.is_deleted,
                'date_added', e.date_added))
             FROM public.playlist_entries e
             WHERE EXISTS (SELECT 1 FROM public.playlists p2
                           WHERE p2.id = e.playlist_id AND p2.user_id = auth.uid())
               AND NOT e.is_deleted
               AND e.updated_at > COALESCE(p_since, 'epoch'::timestamptz)),
            '[]'::jsonb),
        'liked_tracks', COALESCE(
            (SELECT jsonb_agg(jsonb_build_object(
                'track_id', l.track_id, 'is_liked', l.is_liked, 'revision', l.revision,
                'date_liked', l.date_liked, 'updated_at', l.updated_at))
             FROM public.liked_tracks l
             WHERE l.user_id = auth.uid()
               AND l.updated_at > COALESCE(p_since, 'epoch'::timestamptz)),
            '[]'::jsonb),
        'preferences', (SELECT jsonb_build_object(
                'offline_caching', up.offline_caching,
                'audio_quality', up.audio_quality,
                'crossfade', up.crossfade,
                'gapless_playback', up.gapless_playback,
                'normalize_volume', up.normalize_volume,
                'accent_color_value', up.accent_color_value,
                'artwork_atmosphere', up.artwork_atmosphere,
                'animation_intensity', up.animation_intensity,
                'playback_speed', up.playback_speed,
                'cache_quota_bytes', up.cache_quota_bytes,
                'revision', up.revision,
                'updated_at', up.updated_at)
            FROM public.user_preferences up
            WHERE up.user_id = auth.uid()
              AND up.updated_at > COALESCE(p_since, 'epoch'::timestamptz))
    );
$$;

-- ------------------------------------------------------------------------------
-- 4. Guard rails
-- ------------------------------------------------------------------------------
-- RLS: all tables already restrict to auth.uid() = user_id (phase 2 migration).
-- Receipts and tombstones tables are referenced by SECURITY DEFINER sync_push;
-- no new policies are needed for the app-facing tables.

GRANT EXECUTE ON FUNCTION public.sync_push(TEXT, JSONB) TO authenticated;
GRANT EXECUTE ON FUNCTION public.sync_pull(TIMESTAMPTZ) TO authenticated;
REVOKE EXECUTE ON FUNCTION public.sync_push(TEXT, JSONB) FROM anon;
REVOKE EXECUTE ON FUNCTION public.sync_pull(TIMESTAMPTZ) FROM anon;

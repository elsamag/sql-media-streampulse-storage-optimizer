-- ============================================================================
-- Enterprise Practice: Elsamag IT Solutions
-- Author & Lead Technical Consultant: Samuel Chinwendu Agu
-- Target System: StreamPulse Media Platform
-- File Name: src/02_seed_metadata.sql
-- Technical Objective: Seed Normalized Media Catalog, Resolution Tiers, and CDN Streaming Assets
-- ============================================================================

-- Step 1: Populate Normalized Resolution Tiers (Lookup Dimension)
INSERT INTO media_resolutions (resolution_id, resolution_label, aspect_ratio, target_bitrate_kbps) 
VALUES
    (1, '4K UHD HDR',   '16:9', 18000),
    (2, '1080p FHD',    '16:9', 6000),
    (3, '720p HD',      '16:9', 3000),
    (4, '480p SD',      '4:3',  1200),
    (5, 'Mobile Ultra', '19.5:9', 900)
ON DUPLICATE KEY UPDATE 
    target_bitrate_kbps = VALUES(target_bitrate_kbps);

-- Step 2: Populate Core Media Catalog Metadata (Master Dimension)
INSERT INTO media_titles (title_id, title_name, release_year, duration_minutes, content_rating) 
VALUES
    (1001, 'CyberPulse: Neon Frontier',   2025, 134, 'PG-13'),
    (1002, 'The Quantum Paradox',        2024, 118, 'R'),
    (1003, 'Echoes of the Deep Ocean',   2023, 92,  'PG'),
    (1004, 'Solar Drift: Orbit 9',       2026, 145, 'PG-13'),
    (1005, 'Silicon Shadows',            2025, 106, 'TV-MA')
ON DUPLICATE KEY UPDATE 
    duration_minutes = VALUES(duration_minutes);

-- Step 3: Populate Relational Streaming Assets (Multi-Tier CDN Mappings)
INSERT INTO streaming_assets (asset_id, title_id, resolution_id, cdn_manifest_url, audio_codec, is_active) 
VALUES
    -- Streams for CyberPulse: Neon Frontier (title_id: 1001)
    (50001, 1001, 1, 'https://cdn.streampulse.io/live/titles/1001/4k_hdr/master.m3u8',   'Dolby Atmos', 1),
    (50002, 1001, 2, 'https://cdn.streampulse.io/live/titles/1001/1080p/master.m3u8',    'AAC',         1),
    (50003, 1001, 3, 'https://cdn.streampulse.io/live/titles/1001/720p/master.m3u8',     'AAC',         1),

    -- Streams for The Quantum Paradox (title_id: 1002)
    (50004, 1002, 1, 'https://cdn.streampulse.io/live/titles/1002/4k_hdr/master.m3u8',   'Dolby Atmos', 1),
    (50005, 1002, 2, 'https://cdn.streampulse.io/live/titles/1002/1080p/master.m3u8',    'E-AC-3',      1),
    (50006, 1002, 4, 'https://cdn.streampulse.io/live/titles/1002/480p/master.m3u8',     'AAC',         1),

    -- Streams for Echoes of the Deep Ocean (title_id: 1003)
    (50007, 1003, 1, 'https://cdn.streampulse.io/live/titles/1003/4k_hdr/master.m3u8',   'Dolby Atmos', 1),
    (50008, 1003, 2, 'https://cdn.streampulse.io/live/titles/1003/1080p/master.m3u8',    'AAC',         1),

    -- Streams for Solar Drift: Orbit 9 (title_id: 1004)
    (50009, 1004, 2, 'https://cdn.streampulse.io/live/titles/1004/1080p/master.m3u8',    'AAC',         1),
    (50010, 1004, 3, 'https://cdn.streampulse.io/live/titles/1004/720p/master.m3u8',     'AAC',         1),
    (50011, 1004, 5, 'https://cdn.streampulse.io/live/titles/1004/mobile/master.m3u8',   'AAC-HE',      1),

    -- Streams for Silicon Shadows (title_id: 1005)
    (50012, 1005, 1, 'https://cdn.streampulse.io/live/titles/1005/4k_hdr/master.m3u8',   'Dolby Atmos', 1),
    (50013, 1005, 2, 'https://cdn.streampulse.io/live/titles/1005/1080p/master.m3u8',    'AAC',         1),
    (50014, 1005, 3, 'https://cdn.streampulse.io/live/titles/1005/720p/master.m3u8',     'AAC',         1),
    (50015, 1005, 4, 'https://cdn.streampulse.io/live/titles/1005/480p/master.m3u8',     'AAC',         0)
ON DUPLICATE KEY UPDATE 
    cdn_manifest_url = VALUES(cdn_manifest_url),
    is_active = VALUES(is_active);

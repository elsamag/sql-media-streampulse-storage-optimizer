-- ============================================================================
-- Enterprise Practice: Elsamag IT Solutions
-- Author & Lead Technical Consultant: Samuel Chinwendu Agu
-- Target System: StreamPulse Media Platform
-- File Name: src/03_catalog_queries.sql
-- Technical Objective: Production Relational Queries for Media Cataloging,
--                      Multi-Tier Manifest Lookup, and Storage Efficiency Auditing
-- ============================================================================

USE streampulse_db;

-- ----------------------------------------------------------------------------
-- Query 1: Active Playback Manifest Resolution Dispatch
-- Purpose: Extract active CDN streaming manifests for player clients by joining
--          media titles with normalized resolution profiles.
-- ----------------------------------------------------------------------------
SELECT 
    t.title_id,
    t.title_name,
    t.content_rating,
    r.resolution_label,
    r.target_bitrate_kbps,
    a.audio_codec,
    a.cdn_manifest_url
FROM media_titles t
INNER JOIN streaming_assets a 
    ON t.title_id = a.title_id
INNER JOIN media_resolutions r 
    ON a.resolution_id = r.resolution_id
WHERE a.is_active = TRUE
ORDER BY t.title_id ASC, r.target_bitrate_kbps DESC;

-- ----------------------------------------------------------------------------
-- Query 2: Title-Level Transcode Profile & Bitrate Aggregation
-- Purpose: Audit encoding depth and maximum streaming quality per title
--          without storing denormalized profile metrics in master catalog tables.
-- ----------------------------------------------------------------------------
SELECT 
    t.title_id,
    t.title_name,
    t.duration_minutes,
    COUNT(a.asset_id) AS total_active_renditions,
    MAX(r.target_bitrate_kbps) AS max_bitrate_kbps,
    MIN(r.target_bitrate_kbps) AS min_bitrate_kbps,
    GROUP_CONCAT(DISTINCT r.resolution_label ORDER BY r.target_bitrate_kbps DESC SEPARATOR ' | ') AS available_tiers
FROM media_titles t
INNER JOIN streaming_assets a 
    ON t.title_id = a.title_id
INNER JOIN media_resolutions r 
    ON a.resolution_id = r.resolution_id
WHERE a.is_active = TRUE
GROUP BY t.title_id, t.title_name, t.duration_minutes
ORDER BY total_active_renditions DESC, t.title_id ASC;

-- ----------------------------------------------------------------------------
-- Query 3: Relational Storage Efficiency & Deduplication Audit
-- Purpose: Calculate memory/disk footprint savings achieved by referencing 
--          1-byte resolution IDs instead of repeated denormalized strings.
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(a.asset_id) AS total_manifest_records,
    SUM(LENGTH(r.resolution_label) + LENGTH(r.aspect_ratio) + 4) AS unnormalized_string_storage_bytes,
    SUM(1) AS normalized_fk_storage_bytes,
    ROUND(
        (1 - (SUM(1) / SUM(LENGTH(r.resolution_label) + LENGTH(r.aspect_ratio) + 4))) * 100, 
        2
    ) AS storage_efficiency_percentage
FROM streaming_assets a
INNER JOIN media_resolutions r 
    ON a.resolution_id = r.resolution_id;

-- ----------------------------------------------------------------------------
-- Query 4: Referential Integrity Diagnostic & Orphan Check
-- Purpose: Proactive audit query verifying that zero streaming asset manifests 
--          reference non-existent titles or resolution profiles.
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(a.asset_id) AS total_evaluated_assets,
    SUM(CASE WHEN t.title_id IS NULL THEN 1 ELSE 0 END) AS orphaned_title_references,
    SUM(CASE WHEN r.resolution_id IS NULL THEN 1 ELSE 0 END) AS orphaned_resolution_references
FROM streaming_assets a
LEFT JOIN media_titles t 
    ON a.title_id = t.title_id
LEFT JOIN media_resolutions r 
    ON a.resolution_id = r.resolution_id;

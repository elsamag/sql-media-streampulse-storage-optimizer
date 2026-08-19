-- ============================================================================
-- Enterprise Practice: Elsamag IT Solutions
-- Author & Lead Technical Consultant: Samuel Chinwendu Agu
-- Target System: StreamPulse Media Platform
-- File Name: src/01_schema_definition.sql
-- Technical Objective: Production Relational DDL for Media Asset Storage
-- ============================================================================

-- Step 0: Clean environment by dropping dependent tables in reverse order
DROP TABLE IF EXISTS streaming_assets;
DROP TABLE IF EXISTS media_resolutions;
DROP TABLE IF EXISTS media_titles;

-- Step 1: Master catalog entity storing core media title metadata
CREATE TABLE media_titles (
    title_id INT PRIMARY KEY AUTO_INCREMENT,
    title_name VARCHAR(150) NOT NULL,
    release_year SMALLINT NOT NULL,
    duration_minutes SMALLINT NOT NULL,
    content_rating VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Step 2: Normalized encoding profile lookup entity
CREATE TABLE media_resolutions (
    resolution_id TINYINT PRIMARY KEY AUTO_INCREMENT,
    resolution_label VARCHAR(20) NOT NULL UNIQUE,
    aspect_ratio VARCHAR(10) NOT NULL,
    target_bitrate_kbps INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Step 3: High-traffic relational bridge linking media titles to encoding assets
CREATE TABLE streaming_assets (
    asset_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    title_id INT NOT NULL,
    resolution_id TINYINT NOT NULL,
    cdn_manifest_url VARCHAR(255) NOT NULL,
    audio_codec VARCHAR(20) DEFAULT 'AAC',
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_title_res (title_id, resolution_id),
    CONSTRAINT fk_streaming_title FOREIGN KEY (title_id) 
        REFERENCES media_titles(title_id) ON DELETE CASCADE,
    CONSTRAINT fk_streaming_res FOREIGN KEY (resolution_id) 
        REFERENCES media_resolutions(resolution_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

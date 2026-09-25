-- Spotify Advanced SQL Analytics
-- PostgreSQL analytical query set
-- Dataset: spotify

-- ============================================================
-- 1. TRACK & CONTENT ANALYSIS
-- ============================================================

-- Tracks with more than 1 billion streams
SELECT track, stream
FROM spotify
WHERE stream > 1000000000
ORDER BY stream DESC;

-- Tracks released as singles
SELECT track, artist, album
FROM spotify
WHERE album_type = 'single';

-- Top 5 tracks by energy
SELECT track, artist, energy
FROM spotify
ORDER BY energy DESC
LIMIT 5;

-- Tracks with liveness above the dataset average
SELECT track, artist, liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify)
ORDER BY liveness DESC;

-- Tracks with energy-to-liveness ratio above 1.2
SELECT track, artist, energy, liveness,
       energy / NULLIF(liveness, 0) AS energy_liveness_ratio
FROM spotify
WHERE energy / NULLIF(liveness, 0) > 1.2
ORDER BY energy_liveness_ratio DESC;


-- ============================================================
-- 2. ARTIST ANALYSIS
-- ============================================================

-- Number of tracks by artist
SELECT artist, COUNT(*) AS track_count
FROM spotify
GROUP BY artist
ORDER BY track_count DESC;

-- Top 3 most-viewed tracks for each artist
WITH ranked_tracks AS (
    SELECT
        artist,
        track,
        views,
        ROW_NUMBER() OVER (
            PARTITION BY artist
            ORDER BY views DESC
        ) AS artist_rank
    FROM spotify
)
SELECT artist, track, views, artist_rank
FROM ranked_tracks
WHERE artist_rank <= 3
ORDER BY artist, artist_rank;


-- ============================================================
-- 3. ALBUM ANALYSIS
-- ============================================================

-- Albums and their artists
SELECT DISTINCT album, artist
FROM spotify
ORDER BY artist, album;

-- Average danceability by album
SELECT album,
       AVG(danceability) AS avg_danceability
FROM spotify
GROUP BY album
ORDER BY avg_danceability DESC;

-- Total views by album
SELECT album,
       SUM(views) AS total_views
FROM spotify
GROUP BY album
ORDER BY total_views DESC;

-- Energy range by album using a CTE
WITH album_energy AS (
    SELECT
        album,
        MAX(energy) AS highest_energy,
        MIN(energy) AS lowest_energy
    FROM spotify
    GROUP BY album
)
SELECT
    album,
    highest_energy,
    lowest_energy,
    highest_energy - lowest_energy AS energy_diff
FROM album_energy
ORDER BY energy_diff DESC;


-- ============================================================
-- 4. ENGAGEMENT ANALYSIS
-- ============================================================

-- Total comments for licensed tracks
SELECT SUM(comments) AS licensed_track_comments
FROM spotify
WHERE licensed = TRUE;

-- Official-video tracks with views and likes
SELECT track, artist, views, likes
FROM spotify
WHERE official_video = TRUE
ORDER BY views DESC;

-- Tracks where Spotify streams exceed YouTube views
SELECT track, artist, stream, views
FROM spotify
WHERE stream > views
ORDER BY stream DESC;

-- Cumulative likes ordered by views
SELECT
    track,
    artist,
    views,
    likes,
    SUM(likes) OVER (
        ORDER BY views
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_likes
FROM spotify
ORDER BY views;


-- ============================================================
-- 5. DATA-DRIVEN SUMMARY QUERIES
-- ============================================================

-- Overall dataset summary
SELECT
    COUNT(*) AS total_tracks,
    COUNT(DISTINCT artist) AS distinct_artists,
    COUNT(DISTINCT album) AS distinct_albums,
    SUM(views) AS total_views,
    SUM(likes) AS total_likes,
    SUM(stream) AS total_streams
FROM spotify;

-- Engagement by album type
SELECT
    album_type,
    COUNT(*) AS tracks,
    AVG(views) AS avg_views,
    AVG(likes) AS avg_likes,
    AVG(comments) AS avg_comments
FROM spotify
GROUP BY album_type
ORDER BY avg_views DESC;

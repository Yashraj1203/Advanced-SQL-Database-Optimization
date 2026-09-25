-- Spotify Query Optimization
-- PostgreSQL
--
-- Objective:
-- Compare a baseline artist-filter query before and after indexing.
--
-- Important:
-- Execution times depend on PostgreSQL version, hardware, cache state,
-- table size, statistics, and the exact query plan.

-- ============================================================
-- 1. BASELINE
-- ============================================================

EXPLAIN ANALYZE
SELECT *
FROM spotify
WHERE artist = 'Macklemore';

-- Review the actual execution plan and record:
--   Planning Time
--   Execution Time
--   Scan type
--
-- Historical benchmark recorded in the original project:
--   Execution Time: 7 ms
--   Planning Time: 0.17 ms


-- ============================================================
-- 2. INDEX DESIGN
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_spotify_artist
ON spotify (artist);

ANALYZE spotify;


-- ============================================================
-- 3. POST-INDEX BENCHMARK
-- ============================================================

EXPLAIN ANALYZE
SELECT *
FROM spotify
WHERE artist = 'Macklemore';

-- Historical benchmark recorded in the original project:
--   Execution Time: 0.153 ms
--   Planning Time: 0.152 ms
--
-- These values are environment-specific and should not be treated
-- as guaranteed results for every PostgreSQL installation.


-- ============================================================
-- 4. INTERPRETATION
-- ============================================================
--
-- The index provides PostgreSQL with an indexed access path for
-- artist-filtered lookups. Use EXPLAIN ANALYZE to verify whether
-- the optimizer actually chooses the index for the current data
-- distribution and table size.

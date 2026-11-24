-- ICT371 Q8 (f): index for one vehicle's trips in a date range
-- vehicle_id (equality) first, trip_on (range) second: the planner can jump to
-- one vehicle's entries and read just the requested dates, in order.
CREATE INDEX IF NOT EXISTS idx_trips_vehicle_trip_on
    ON trips (vehicle_id, trip_on);

ANALYZE trips;
SET enable_seqscan = off;   -- tiny table: force the planner to show the index

EXPLAIN
SELECT trip_id, trip_on, start_odometer, end_odometer
FROM trips
WHERE vehicle_id = 1
  AND trip_on BETWEEN DATE '2026-11-01' AND DATE '2026-11-30';

RESET enable_seqscan;

-- (b) vehicle 1 and 2 due, vehicle 3 not
SELECT vehicle_id, registration, current_odometer, fn_service_due(vehicle_id) AS due
FROM vehicles ORDER BY vehicle_id;
DO $$ BEGIN PERFORM fn_service_due(999);
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Rejected: %', SQLERRM; END $$;

-- (c)/(d) rejections
DO $$ BEGIN CALL pr_record_trip(999, CURRENT_DATE, 0, 10);
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Rejected: %', SQLERRM; END $$;
DO $$ BEGIN CALL pr_record_trip(3, CURRENT_DATE, 8350, 8350);     -- end not greater
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Rejected: %', SQLERRM; END $$;
DO $$ BEGIN CALL pr_record_trip(3, CURRENT_DATE, 9999, 10100);    -- wrong start
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Rejected: %', SQLERRM; END $$;
DO $$ BEGIN INSERT INTO trips (vehicle_id, trip_on, start_odometer, end_odometer)
            VALUES (3, CURRENT_DATE, 8350, 8000);                 -- direct SQL, bad mileage
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Rejected: %', SQLERRM; END $$;

-- valid trip: odometer moves to the end value exactly once
CALL pr_record_trip(3, CURRENT_DATE, 8350, 8500);
SELECT current_odometer FROM vehicles WHERE vehicle_id = 3;       -- 8500

-- (e)
SELECT * FROM v_service_due;

-- (g) alerts for vehicles 1 and 2; run again: still one row each
CALL pr_refresh_service_alerts();
CALL pr_refresh_service_alerts();
SELECT * FROM service_alerts ORDER BY vehicle_id;

-- service vehicle 1 => its alert is removed on the next run
UPDATE vehicles SET last_service_odometer = current_odometer WHERE vehicle_id = 1;
CALL pr_refresh_service_alerts();
SELECT * FROM service_alerts ORDER BY vehicle_id;                 -- only vehicle 2

-- (f) EXPLAIN again now that the tables contain data
ANALYZE trips;
SET enable_seqscan = off;   -- tiny table: force the planner to show the index

EXPLAIN
SELECT trip_id, trip_on, start_odometer, end_odometer
FROM trips
WHERE vehicle_id = 1
  AND trip_on BETWEEN DATE '2026-11-01' AND DATE '2026-11-30';

RESET enable_seqscan;

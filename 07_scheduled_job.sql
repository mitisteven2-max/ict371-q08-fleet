-- ICT371 Q8 (g): pr_refresh_service_alerts + pg_cron
-- flagged_on keeps the date the alert FIRST appeared; km_since_service is refreshed.
CREATE OR REPLACE PROCEDURE pr_refresh_service_alerts()
LANGUAGE plpgsql
AS $$
BEGIN
    -- insert or update one alert per due vehicle
    INSERT INTO service_alerts (vehicle_id, km_since_service, flagged_on)
    SELECT vehicle_id, current_odometer - last_service_odometer, CURRENT_DATE
    FROM vehicles
    WHERE fn_service_due(vehicle_id)
    ON CONFLICT (vehicle_id) DO UPDATE
    SET km_since_service = EXCLUDED.km_since_service;

    -- remove alerts for vehicles that are no longer due (e.g. after a service)
    DELETE FROM service_alerts sa
    WHERE NOT fn_service_due(sa.vehicle_id);
END;
$$;

CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Every Monday at 06:00
SELECT cron.schedule(
    'q08_service_alerts_weekly',
    '0 6 * * 1',
    $$CALL pr_refresh_service_alerts()$$
);

-- Inspect:
-- SELECT jobid, jobname, schedule, command FROM cron.job;
-- SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 5;

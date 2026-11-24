-- ICT371 Q8 (d): BEFORE INSERT trigger on trips
CREATE OR REPLACE FUNCTION trg_fn_trip_odometer()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_current INTEGER;
BEGIN
    IF NEW.start_odometer IS NULL OR NEW.end_odometer IS NULL THEN
        RAISE EXCEPTION 'start_odometer and end_odometer are required';
    END IF;

    -- Lock the vehicle row so two trips cannot start from the same odometer
    SELECT current_odometer INTO v_current
    FROM vehicles WHERE vehicle_id = NEW.vehicle_id
    FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Unknown vehicle_id: %', NEW.vehicle_id;
    END IF;

    IF NEW.start_odometer <> v_current THEN
        RAISE EXCEPTION 'Trip must start at the current odometer % (got %)',
            v_current, NEW.start_odometer;
    END IF;
    IF NEW.end_odometer <= NEW.start_odometer THEN
        RAISE EXCEPTION 'Invalid mileage: end % must be greater than start %',
            NEW.end_odometer, NEW.start_odometer;
    END IF;

    -- Exactly once per inserted row
    UPDATE vehicles
    SET current_odometer = NEW.end_odometer
    WHERE vehicle_id = NEW.vehicle_id;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_trip_odometer ON trips;

CREATE TRIGGER trg_trip_odometer
BEFORE INSERT ON trips
FOR EACH ROW
EXECUTE FUNCTION trg_fn_trip_odometer();

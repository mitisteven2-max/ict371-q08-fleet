-- ICT371 Q8 (a): tables, constraints, vehicles
DROP TABLE IF EXISTS service_alerts, trips, vehicles CASCADE;

CREATE TABLE vehicles (
    vehicle_id             SERIAL PRIMARY KEY,
    registration           VARCHAR(20) NOT NULL UNIQUE,
    current_odometer       INTEGER     NOT NULL CHECK (current_odometer >= 0),
    last_service_odometer  INTEGER     NOT NULL CHECK (last_service_odometer >= 0),
    CONSTRAINT ck_service_not_ahead CHECK (last_service_odometer <= current_odometer)
);

CREATE TABLE trips (
    trip_id         SERIAL PRIMARY KEY,
    vehicle_id      INTEGER NOT NULL REFERENCES vehicles(vehicle_id),
    trip_on         DATE    NOT NULL,
    start_odometer  INTEGER NOT NULL CHECK (start_odometer >= 0),
    end_odometer    INTEGER NOT NULL CHECK (end_odometer >= 0)
);

CREATE TABLE service_alerts (
    vehicle_id        INTEGER PRIMARY KEY REFERENCES vehicles(vehicle_id),
    km_since_service  INTEGER NOT NULL,
    flagged_on        DATE    NOT NULL
);

-- Three different service positions
INSERT INTO vehicles (registration, current_odometer, last_service_odometer) VALUES
    ('BAE 1234', 20000, 14000),   -- 6000 km since service (already due)
    ('BAF 5678', 15000, 10500),   -- 4500 km (not yet due; trips will push it over)
    ('BAG 9012',  8000,  8000);   -- 0 km (just serviced)
-- Trips are loaded in 08_load_data.sql through the procedure

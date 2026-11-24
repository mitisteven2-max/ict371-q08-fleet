# ICT371 Q8 - Transport Fleet Maintenance

**Student:** Steven Miti (202405283)  
**DBMS:** PostgreSQL 13+ with the pg_cron extension

## How to run
Use a fresh database for this question (several questions share table names such as `students`):

```bash
createdb ict371_q08
psql -d ict371_q08 -f run_all.sql
```

Files run in order: schema, function, procedure, trigger, view, index, scheduled job, data load, tests.
The data load (`08_load_data.sql`) runs after the trigger/procedure exist, as the question requires.

| Part | File |
|------|------|
| (a) Tables + seed data | `01_schema_seed.sql`, `08_load_data.sql` |
| (b) Function | `02_function.sql` |
| (c) Procedure | `03_procedure.sql` |
| (d) Trigger | `04_trigger.sql` |
| (e) View | `05_view.sql` |
| (f) Index + EXPLAIN | `06_index.sql` |
| (g) Scheduled job | `07_scheduled_job.sql` |
| Demonstration queries | `09_tests.sql` |

## Index
`idx_trips_vehicle_trip_on ON trips (vehicle_id, trip_on)`

One vehicle's trips in a date range: vehicle_id is an equality match and trip_on a range, so the composite index finds the vehicle then reads only the date range in order.

## Design notes
- pr_record_trip never updates the odometer; the BEFORE INSERT trigger does, exactly once per trip.
- flagged_on keeps the date an alert was first raised; km_since_service is refreshed on each run.
- fn_service_due is the single source of truth for the 5,000 km rule (used by the job).

## Output
_Paste screenshots / output of `09_tests.sql` and the `EXPLAIN` plan here._

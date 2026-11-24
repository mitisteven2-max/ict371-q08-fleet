-- ICT371 Q8 (a): six trips through the procedure (trigger already installed)
-- Each trip starts exactly where the previous one ended.
CALL pr_record_trip(1, DATE '2026-11-03', 20000, 20300);
CALL pr_record_trip(1, DATE '2026-11-10', 20300, 20650);
CALL pr_record_trip(2, DATE '2026-11-04', 15000, 15300);
CALL pr_record_trip(2, DATE '2026-11-11', 15300, 15700);   -- pushes vehicle 2 over 5,000 km
CALL pr_record_trip(3, DATE '2026-11-05',  8000,  8200);
CALL pr_record_trip(3, DATE '2026-11-12',  8200,  8350);

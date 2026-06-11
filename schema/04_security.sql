-- Security — clears all Supabase advisor warnings. Run once in the SQL Editor.
-- Enables RLS on every table (locks the public PostgREST API), makes
-- v_booking_summary respect the caller's permissions, pins function search_path,
-- and revokes public Data-API access to the materialized views. The Spring Boot
-- backend connects as the `postgres` superuser, which owns these objects and
-- bypasses RLS/grants, so the API is unaffected.

ALTER TABLE Users                ENABLE ROW LEVEL SECURITY;
ALTER TABLE Customer             ENABLE ROW LEVEL SECURITY;
ALTER TABLE ServiceProvider      ENABLE ROW LEVEL SECURITY;
ALTER TABLE Admin                ENABLE ROW LEVEL SECURITY;
ALTER TABLE City                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE Area                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE Address              ENABLE ROW LEVEL SECURITY;
ALTER TABLE Category             ENABLE ROW LEVEL SECURITY;
ALTER TABLE Service              ENABLE ROW LEVEL SECURITY;
ALTER TABLE ServiceVariant       ENABLE ROW LEVEL SECURITY;
ALTER TABLE Offers               ENABLE ROW LEVEL SECURITY;
ALTER TABLE ProviderAvailability ENABLE ROW LEVEL SECURITY;
ALTER TABLE ProviderDocument     ENABLE ROW LEVEL SECURITY;
ALTER TABLE Coupon               ENABLE ROW LEVEL SECURITY;
ALTER TABLE Booking              ENABLE ROW LEVEL SECURITY;
ALTER TABLE BookingItem          ENABLE ROW LEVEL SECURITY;
ALTER TABLE BookingStatusLog     ENABLE ROW LEVEL SECURITY;
ALTER TABLE Payment              ENABLE ROW LEVEL SECURITY;
ALTER TABLE Cancellation         ENABLE ROW LEVEL SECURITY;
ALTER TABLE ProviderReview       ENABLE ROW LEVEL SECURITY;
ALTER TABLE ServiceReview        ENABLE ROW LEVEL SECURITY;
ALTER TABLE Complaint            ENABLE ROW LEVEL SECURITY;

ALTER VIEW v_booking_summary SET (security_invoker = on);

ALTER FUNCTION fn_update_provider_avg_rating()
    SET search_path = public, pg_temp;
ALTER FUNCTION place_booking(INT, INT, INT, INT, DATE, TIME, FLOAT, TEXT, INT, INT, FLOAT)
    SET search_path = public, pg_temp;

REVOKE SELECT ON mv_provider_leaderboard FROM anon, authenticated;
REVOKE SELECT ON mv_city_revenue_summary FROM anon, authenticated;

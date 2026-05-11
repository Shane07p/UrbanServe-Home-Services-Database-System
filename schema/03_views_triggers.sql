-- UrbanServe — Views, Trigger & Stored Procedure


-- Trigger: keep ServiceProvider.avg_rating in sync with ProviderReview
CREATE OR REPLACE FUNCTION fn_update_provider_avg_rating()
RETURNS TRIGGER AS $$
DECLARE
    v_provider_id INT;
BEGIN
    v_provider_id := CASE WHEN TG_OP = 'DELETE' THEN OLD.provider_id ELSE NEW.provider_id END;

    UPDATE ServiceProvider
    SET avg_rating = COALESCE(
        (SELECT ROUND(AVG(rating)::numeric, 2) FROM ProviderReview WHERE provider_id = v_provider_id),
        0.0
    )
    WHERE provider_id = v_provider_id;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_provider_avg_rating
AFTER INSERT OR UPDATE OR DELETE ON ProviderReview
FOR EACH ROW EXECUTE FUNCTION fn_update_provider_avg_rating();


-- View: full booking detail for admin dashboards
CREATE OR REPLACE VIEW v_booking_summary AS
SELECT
    b.booking_id,
    b.status                        AS booking_status,
    b.scheduled_date,
    b.scheduled_time,
    b.total_amount,
    cu.customer_id,
    cu.name                         AS customer_name,
    sp.provider_id,
    sp.bio                          AS provider_bio,
    sp.avg_rating                   AS provider_rating,
    ci.city_name,
    ar.area_name,
    ar.pincode,
    COALESCE(cp.code, 'None')       AS coupon_code,
    COALESCE(cp.discount_value, 0)  AS discount_value,
    p.payment_method,
    p.status                        AS payment_status,
    p.paid_at
FROM Booking b
JOIN Customer        cu ON b.customer_id  = cu.customer_id
JOIN ServiceProvider sp ON b.provider_id  = sp.provider_id
JOIN Address         a  ON b.address_id   = a.address_id
JOIN Area            ar ON a.area_id      = ar.area_id
JOIN City            ci ON ar.city_id     = ci.city_id
LEFT JOIN Coupon     cp ON b.coupon_id    = cp.coupon_id
LEFT JOIN Payment    p  ON b.booking_id   = p.booking_id;


-- Materialized view: provider leaderboard by avg rating
-- Refresh: REFRESH MATERIALIZED VIEW mv_provider_leaderboard;
CREATE MATERIALIZED VIEW mv_provider_leaderboard AS
SELECT
    sp.provider_id,
    u.email,
    sp.bio,
    sp.experience_years,
    sp.verification_status,
    COUNT(pr.review_id)                        AS total_reviews,
    ROUND(AVG(pr.rating)::numeric, 2)          AS avg_rating,
    MAX(pr.rating)                             AS highest_rating,
    MIN(pr.rating)                             AS lowest_rating,
    COUNT(DISTINCT b.booking_id)               AS total_bookings
FROM ServiceProvider sp
JOIN Users           u  ON sp.user_id     = u.user_id
LEFT JOIN ProviderReview pr ON sp.provider_id = pr.provider_id
LEFT JOIN Booking    b  ON sp.provider_id = b.provider_id
GROUP BY sp.provider_id, u.email, sp.bio, sp.experience_years, sp.verification_status
ORDER BY avg_rating DESC NULLS LAST, total_reviews DESC;

CREATE UNIQUE INDEX ON mv_provider_leaderboard(provider_id);


-- Materialized view: revenue and booking stats per city
-- Refresh: REFRESH MATERIALIZED VIEW mv_city_revenue_summary;
CREATE MATERIALIZED VIEW mv_city_revenue_summary AS
SELECT
    ci.city_id,
    ci.city_name,
    ci.state,
    COUNT(b.booking_id)                                                          AS total_bookings,
    COUNT(CASE WHEN b.status = 'Completed' THEN 1 END)                          AS completed_bookings,
    COUNT(CASE WHEN b.status = 'Cancelled' THEN 1 END)                          AS cancelled_bookings,
    ROUND(SUM(CASE WHEN p.status = 'Paid' THEN p.amount ELSE 0 END)::numeric, 2) AS total_revenue,
    ROUND(AVG(CASE WHEN p.status = 'Paid' THEN p.amount END)::numeric, 2)        AS avg_booking_value,
    COUNT(DISTINCT b.customer_id)                                                AS unique_customers,
    COUNT(DISTINCT b.provider_id)                                                AS active_providers
FROM City ci
LEFT JOIN Area    ar ON ci.city_id   = ar.city_id
LEFT JOIN Address a  ON ar.area_id   = a.area_id
LEFT JOIN Booking b  ON a.address_id = b.address_id
LEFT JOIN Payment p  ON b.booking_id = p.booking_id
GROUP BY ci.city_id, ci.city_name, ci.state
ORDER BY total_revenue DESC NULLS LAST;

CREATE UNIQUE INDEX ON mv_city_revenue_summary(city_id);


-- Stored procedure: atomically place a booking
-- Inserts Booking + first BookingItem + initial 'Pending' status log
-- Returns the new booking_id
CREATE OR REPLACE FUNCTION place_booking(
    p_customer_id           INT,
    p_provider_id           INT,
    p_address_id            INT,
    p_coupon_id             INT,
    p_scheduled_date        DATE,
    p_scheduled_time        TIME,
    p_total_amount          FLOAT,
    p_special_instructions  TEXT,
    p_service_id            INT,
    p_quantity              INT,
    p_unit_price            FLOAT
)
RETURNS INT AS $$
DECLARE
    v_booking_id INT;
BEGIN
    INSERT INTO Booking (
        customer_id, provider_id, address_id, coupon_id,
        scheduled_date, scheduled_time, total_amount,
        status, special_instructions
    ) VALUES (
        p_customer_id, p_provider_id, p_address_id, p_coupon_id,
        p_scheduled_date, p_scheduled_time, p_total_amount,
        'Pending', p_special_instructions
    )
    RETURNING booking_id INTO v_booking_id;

    INSERT INTO BookingItem (item_no, booking_id, service_id, quantity, unit_price)
    VALUES (1, v_booking_id, p_service_id, p_quantity, p_unit_price);

    INSERT INTO BookingStatusLog (booking_id, status, remarks)
    VALUES (v_booking_id, 'Pending', 'Booking created — awaiting provider confirmation');

    RETURN v_booking_id;
END;
$$ LANGUAGE plpgsql;

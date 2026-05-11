-- ============================================================
-- UrbanServe — Query Test Suite (v2.0)
-- 20 queries: Selection, Projection, Joins, Aggregates,
-- Subqueries, Set Ops, LIKE, IN, EXISTS, Division,
-- LIMIT/OFFSET, GROUP BY, HAVING, new tables (Q18-Q20)
-- ============================================================


-- ============================================================
-- Q1: Simple Selection + Projection
-- List all verified providers with experience and bio,
-- sorted by experience descending.
-- ============================================================
SELECT
    sp.provider_id,
    u.email,
    sp.experience_years,
    sp.bio,
    sp.avg_rating,
    sp.verification_status
FROM ServiceProvider sp
JOIN Users u ON sp.user_id = u.user_id
WHERE sp.verification_status = 'Verified'
ORDER BY sp.experience_years DESC;


-- ============================================================
-- Q2: ORDER BY + LIMIT + OFFSET (Pagination)
-- Page 2 of active services sorted by base price descending.
-- (5 per page — OFFSET 5 skips page 1.)
-- ============================================================
SELECT
    service_id,
    service_name,
    base_price,
    duration
FROM Service
WHERE is_active = TRUE
ORDER BY base_price DESC
LIMIT 5 OFFSET 5;


-- ============================================================
-- Q3: GROUP BY + Aggregate (COUNT, AVG, MIN, MAX)
-- Per-category service stats — useful for catalog dashboard.
-- ============================================================
SELECT
    c.category_name,
    COUNT(s.service_id)                      AS total_services,
    ROUND(AVG(s.base_price)::numeric, 2)     AS avg_price,
    MIN(s.base_price)                        AS cheapest,
    MAX(s.base_price)                        AS most_expensive
FROM Category c
JOIN Service s ON c.category_id = s.category_id
GROUP BY c.category_name
ORDER BY avg_price DESC;


-- ============================================================
-- Q4: HAVING (filter on aggregated groups)
-- Find categories where average service price exceeds 600.
-- ============================================================
SELECT
    c.category_name,
    ROUND(AVG(s.base_price)::numeric, 2) AS avg_price
FROM Category c
JOIN Service s ON c.category_id = s.category_id
GROUP BY c.category_name
HAVING AVG(s.base_price) > 600
ORDER BY avg_price DESC;


-- ============================================================
-- Q5: INNER JOIN (multi-table)
-- Full booking detail — customer name, provider bio,
-- city, status, date and amount. Uses new Booking.status.
-- ============================================================
SELECT
    b.booking_id,
    b.status             AS booking_status,
    cu.name              AS customer_name,
    sp.bio               AS provider_bio,
    ci.city_name,
    ar.area_name,
    b.scheduled_date,
    b.scheduled_time,
    b.total_amount
FROM Booking b
JOIN Customer       cu ON b.customer_id  = cu.customer_id
JOIN ServiceProvider sp ON b.provider_id = sp.provider_id
JOIN Address        a  ON b.address_id   = a.address_id
JOIN Area           ar ON a.area_id      = ar.area_id
JOIN City           ci ON ar.city_id     = ci.city_id
ORDER BY b.scheduled_date ASC;


-- ============================================================
-- Q6: LEFT JOIN (NULLs — bookings without a coupon)
-- Shows all bookings and their coupon code if one was used.
-- ============================================================
SELECT
    b.booking_id,
    cu.name                              AS customer_name,
    b.total_amount,
    b.status,
    COALESCE(cp.code, 'No Coupon')       AS coupon_used,
    COALESCE(cp.discount_value::TEXT, '-') AS discount
FROM Booking b
JOIN Customer cu   ON b.customer_id = cu.customer_id
LEFT JOIN Coupon cp ON b.coupon_id  = cp.coupon_id
ORDER BY b.booking_id;


-- ============================================================
-- Q7: Subquery with IN
-- Customers who have placed at least one booking.
-- ============================================================
SELECT
    customer_id,
    name,
    phone
FROM Customer
WHERE customer_id IN (
    SELECT DISTINCT customer_id
    FROM Booking
)
ORDER BY customer_id;


-- ============================================================
-- Q8: Subquery with NOT IN (Set Difference equivalent)
-- Customers who have NEVER placed a booking.
-- ============================================================
SELECT
    customer_id,
    name,
    phone
FROM Customer
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM Booking
);


-- ============================================================
-- Q9: EXISTS (Semi-Join)
-- Providers who have received at least one review.
-- ============================================================
SELECT
    sp.provider_id,
    sp.bio,
    sp.avg_rating,
    sp.verification_status
FROM ServiceProvider sp
WHERE EXISTS (
    SELECT 1
    FROM ProviderReview pr
    WHERE pr.provider_id = sp.provider_id
)
ORDER BY sp.avg_rating DESC;


-- ============================================================
-- Q10: NOT EXISTS (Anti Semi-Join)
-- Users who have NEVER filed a complaint.
-- ============================================================
SELECT
    u.user_id,
    u.email,
    u.role
FROM Users u
WHERE NOT EXISTS (
    SELECT 1
    FROM Complaint c
    WHERE c.user_id = u.user_id
)
ORDER BY u.role, u.user_id;


-- ============================================================
-- Q11: UNION (Set Union)
-- All customer and provider emails in one list.
-- ============================================================
SELECT u.email, 'Customer' AS user_type
FROM Customer cu
JOIN Users u ON cu.user_id = u.user_id

UNION

SELECT u.email, 'Provider' AS user_type
FROM ServiceProvider sp
JOIN Users u ON sp.user_id = u.user_id

ORDER BY user_type, email;


-- ============================================================
-- Q12: INTERSECT (Set Intersection)
-- Booking IDs that are both Paid AND have a ProviderReview —
-- i.e. fully completed bookings where customer left a review.
-- ============================================================
SELECT booking_id FROM Payment
WHERE status = 'Paid'

INTERSECT

SELECT booking_id FROM ProviderReview;


-- ============================================================
-- Q13: EXCEPT (Set Difference)
-- Providers with Pending documents who have NO Verified docs —
-- i.e. completely unverified providers.
-- ============================================================
SELECT provider_id FROM ProviderDocument
WHERE verification_status = 'Pending'

EXCEPT

SELECT provider_id FROM ProviderDocument
WHERE verification_status = 'Verified';


-- ============================================================
-- Q14: LIKE / ILIKE (Pattern Matching)
-- All services whose name contains 'repair' (case-insensitive).
-- ============================================================
SELECT
    service_id,
    service_name,
    base_price,
    duration
FROM Service
WHERE service_name ILIKE '%repair%'
ORDER BY base_price ASC;


-- ============================================================
-- Q15: Relational Division (NOT EXISTS + NOT EXISTS)
-- Providers who have submitted ALL three required document
-- types: Aadhar, PAN, and License.
-- ============================================================
SELECT
    sp.provider_id,
    sp.bio
FROM ServiceProvider sp
WHERE NOT EXISTS (
    SELECT doc_type FROM (
        VALUES ('Aadhar'), ('PAN'), ('License')
    ) AS required(doc_type)
    WHERE NOT EXISTS (
        SELECT 1
        FROM ProviderDocument pd
        WHERE pd.provider_id   = sp.provider_id
          AND pd.document_type = required.doc_type
    )
);


-- ============================================================
-- Q16: Complex Aggregation + Multiple Joins
-- Provider leaderboard — avg rating, review count, booking count.
-- Only providers with at least 1 review.
-- ============================================================
SELECT
    sp.provider_id,
    sp.bio                                  AS provider_bio,
    sp.avg_rating,
    COUNT(DISTINCT pr.review_id)            AS total_reviews,
    ROUND(AVG(pr.rating)::numeric, 2)       AS computed_avg_rating,
    COUNT(DISTINCT b.booking_id)            AS total_bookings
FROM ServiceProvider sp
JOIN ProviderReview pr ON sp.provider_id = pr.provider_id
JOIN Booking        b  ON sp.provider_id = b.provider_id
GROUP BY sp.provider_id, sp.bio, sp.avg_rating
HAVING COUNT(pr.review_id) >= 1
ORDER BY sp.avg_rating DESC, total_reviews DESC
LIMIT 10;


-- ============================================================
-- Q17: Correlated Subquery
-- For each customer, show their single most expensive booking.
-- ============================================================
SELECT
    cu.customer_id,
    cu.name,
    b.booking_id,
    b.status,
    b.total_amount AS most_expensive_booking
FROM Customer cu
JOIN Booking b ON cu.customer_id = b.customer_id
WHERE b.total_amount = (
    SELECT MAX(total_amount)
    FROM Booking b2
    WHERE b2.customer_id = cu.customer_id
)
ORDER BY most_expensive_booking DESC;


-- ============================================================
-- Q18: City Revenue Summary  [NEW — uses materialized view]
-- Revenue, booking counts, and unique customers per city.
-- Requires: REFRESH MATERIALIZED VIEW mv_city_revenue_summary;
-- ============================================================
SELECT
    city_name,
    state,
    total_bookings,
    completed_bookings,
    cancelled_bookings,
    total_revenue,
    avg_booking_value,
    unique_customers,
    active_providers
FROM mv_city_revenue_summary
ORDER BY total_revenue DESC NULLS LAST;

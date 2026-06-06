# UrbanServe — Performance Design

## Indexes (`schema/02_indexes.sql`)

Indexes are created on all foreign key columns and frequently filtered attributes to speed up JOINs and WHERE clauses.

### Foreign Key Indexes
| Table | Column(s) | Reason |
|---|---|---|
| `Customer` | `user_id` | JOIN with Users |
| `ServiceProvider` | `user_id` | JOIN with Users |
| `Admin` | `user_id` | JOIN with Users |
| `Service` | `category_id`, `city_id` | Filter by category/city |
| `ServiceVariant` | `service_id` | JOIN with Service |
| `Offers` | `provider_id`, `service_id` | M:N lookup |
| `ProviderAvailability` | `provider_id` | Filter by provider |
| `ProviderDocument` | `provider_id` | JOIN with ServiceProvider |
| `Booking` | `customer_id`, `provider_id`, `address_id`, `coupon_id` | All FK joins |
| `BookingItem` | `booking_id`, `service_id` | Composite PK join |
| `BookingStatusLog` | `booking_id` | History lookup |
| `Payment` | `booking_id` | 1:1 join |
| `Cancellation` | `booking_id` | 1:1 join |
| `ProviderReview` | `provider_id`, `booking_id` | JOIN + uniqueness |
| `ServiceReview` | `service_id`, `booking_id` | JOIN + uniqueness |
| `Complaint` | `user_id` | Filter by user |
| `Address` | `area_id` | JOIN with Area |
| `Area` | `city_id` | JOIN with City |

### Filter Indexes
| Table | Column(s) | Reason |
|---|---|---|
| `Booking` | `status` | Filter by booking status (Completed / Cancelled / Pending) |
| `Booking` | `scheduled_date` | Date range queries |
| `Service` | `is_active` | Most queries filter active services only |
| `ServiceProvider` | `verification_status` | Filter verified providers |
| `ProviderDocument` | `verification_status` | Filter verified docs |
| `Payment` | `status` | Filter paid/pending/failed payments |
| `Complaint` | `status`, `priority` | Admin dashboard filtering |

---

## Views (`schema/03_views_triggers.sql`)

### `v_booking_summary` (Regular View)
Joins Booking, Customer, ServiceProvider, City, and Payment into a single flat view used by admin dashboards and reporting queries.

```sql
SELECT b.booking_id, b.status, cu.name AS customer_name,
       sp.bio AS provider_bio, ci.city_name, ar.area_name,
       b.scheduled_date, b.total_amount, p.status AS payment_status
FROM Booking b
JOIN Customer cu    ON b.customer_id  = cu.customer_id
JOIN ServiceProvider sp ON b.provider_id = sp.provider_id
JOIN Address a      ON b.address_id   = a.address_id
JOIN Area ar        ON a.area_id      = ar.area_id
JOIN City ci        ON ar.city_id     = ci.city_id
LEFT JOIN Payment p ON b.booking_id   = p.booking_id;
```

### `mv_provider_leaderboard` (Materialized View)
Pre-computes provider ranking — total reviews, average rating, highest/lowest rating, and total bookings. Backed by a unique index on `provider_id`.

**Refresh when needed:**
```sql
REFRESH MATERIALIZED VIEW mv_provider_leaderboard;
```

### `mv_city_revenue_summary` (Materialized View)
Pre-aggregates booking and revenue stats per city — total bookings, completed/cancelled counts, total revenue (paid payments only), average booking value, unique customers, and active provider count. Backed by a unique index on `city_id`.

**Refresh when needed:**
```sql
REFRESH MATERIALIZED VIEW mv_city_revenue_summary;
```

---

## Trigger

### `trg_update_provider_avg_rating`
Fires **AFTER INSERT / UPDATE / DELETE** on `ProviderReview`. Automatically recalculates and updates `ServiceProvider.avg_rating` for the affected provider — no application-side logic needed.

```sql
-- Effect on ProviderReview change:
UPDATE ServiceProvider
SET avg_rating = (
    SELECT COALESCE(AVG(rating), 0.0)
    FROM ProviderReview
    WHERE provider_id = affected_provider_id
)
WHERE provider_id = affected_provider_id;
```

---

## Stored Procedure

### `place_booking()`
Atomically inserts a Booking row, one BookingItem, and an initial `'Pending'` BookingStatusLog entry — all in a single transaction. Returns the new `booking_id`.

```sql
SELECT place_booking(
    customer_id       := 1,
    provider_id       := 6,
    address_id        := 3,
    coupon_id         := NULL,
    scheduled_date    := '2024-06-01',
    scheduled_time    := '10:00:00',
    total_amount      := 800.0,
    special_instructions := 'Please bring own tools',
    service_id        := 2,
    quantity          := 1,
    unit_price        := 800.0
);
```

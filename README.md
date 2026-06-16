# UrbanServe — Home Services Marketplace Database

## Table of Contents

- [What is UrbanServe?](#what-is-urbanserve)
- [Schema Overview](#schema-overview)
- [Project Structure](#project-structure)
- [REST API](docs/API.md)
- [Performance Design](docs/PERFORMANCE.md)
- [BCNF Proof](docs/bcnf_proof.md)
- [ER Diagram](docs/er_diagram.png)
- [Setup](#setup)
- [Query Index](#query-index)
- [Sample Data](#sample-data)

---

## What is UrbanServe?

UrbanServe connects customers with verified local service professionals for doorstep home services — plumbing, electrical work, AC servicing, deep cleaning, carpentry, laptop repair, salon, and more. The database manages the complete service lifecycle of homerservice management system:

**Browse → Book → Assign → Pay → Review**

---

## Schema Overview

**22 tables across 7 modules — all in BCNF**

| Module | Tables |
|---|---|
| User Profiles | `Users`, `Customer`, `ServiceProvider`, `Admin` |
| Location | `City`, `Area`, `Address` |
| Service Catalog | `Category`, `Service`, `ServiceVariant`, `Offers` |
| Provider Operations | `ProviderAvailability`, `ProviderDocument` |
| Booking Lifecycle | `Coupon`, `Booking`, `BookingItem`, `BookingStatusLog` |
| Transactions | `Payment`, `Cancellation` |
| Feedback & Support | `ProviderReview`, `ServiceReview`, `Complaint` |

### Key Design Decisions

- **Role-based users** — Single `Users` table with separate profile tables for Customer, Provider, and Admin
- **M:N Offers** — `Offers` junction table implements the M:N relationship between `ServiceProvider` and `Service`, with an optional `custom_price` per provider
- **Booking audit trail** — `BookingStatusLog` records every status transition (Pending → Confirmed → In-Progress → Completed)
- **Auto-maintained ratings** — `ServiceProvider.avg_rating` is recalculated automatically via trigger on every review insert, update, or delete
- **Dual review system** — Customers rate the provider (professionalism) and the service (quality) independently
- **Cancellation tracking** — `Cancellation` captures reason, refund amount, and refund status separately from `Payment`

---

## Project Structure

```
urbanserve/
├── schema/
│   ├── 01_ddl.sql              # All 22 tables with constraints (SERIAL PKs, CHECK, NOT NULL)
│   ├── 02_indexes.sql          # Indexes on FK columns and frequently filtered columns
│   └── 03_views_triggers.sql   # Trigger, views, materialized views, stored procedure
├── data/
│   └── seed.sql                # Realistic dataset — 100 bookings, 40 reviews, 15 complaints
├── queries/
│   └── test_queries.sql        # 19 SQL queries covering all major SQL concepts
├── docs/
│   └── er_diagram.png          # ER diagram (Chen notation)
└── README.md
```

---

## Setup

### Prerequisites
- PostgreSQL 14+
- `psql` CLI or pgAdmin

### Run in order

```bash
# 1. Create the database
createdb urbanserve

# 2. Run scripts in order
psql -d urbanserve -f schema/01_ddl.sql
psql -d urbanserve -f schema/02_indexes.sql
psql -d urbanserve -f schema/03_views_triggers.sql
psql -d urbanserve -f data/seed.sql

# 3. Refresh materialized views after seeding
psql -d urbanserve -c "REFRESH MATERIALIZED VIEW mv_provider_leaderboard;"
psql -d urbanserve -c "REFRESH MATERIALIZED VIEW mv_city_revenue_summary;"

# 4. Run test queries
psql -d urbanserve -f queries/test_queries.sql
```

---

## Features

### Trigger
| Trigger | Event | Effect |
|---|---|---|
| `trg_update_provider_avg_rating` | INSERT / UPDATE / DELETE on `ProviderReview` | Auto-recalculates `ServiceProvider.avg_rating` |

### Views
| View | Purpose |
|---|---|
| `v_booking_summary` | Full booking detail — customer, provider, city, payment status |
| `mv_provider_leaderboard` | Top providers ranked by avg rating and review volume |
| `mv_city_revenue_summary` | Total revenue, booking count, and unique customers per city |

### Stored Procedure
```sql
-- Atomically places a booking with its first item and initial status log entry
SELECT place_booking(
    customer_id, provider_id, address_id, coupon_id,
    scheduled_date, scheduled_time, total_amount,
    special_instructions, service_id, quantity, unit_price
);
-- Returns the new booking_id
```

---

## Query Index

| # | Query | Concepts Demonstrated |
|---|---|---|
| Q1 | Verified providers sorted by experience | SELECT, WHERE, ORDER BY |
| Q2 | Active services — page 2 by price | LIMIT, OFFSET |
| Q3 | Per-category price statistics | GROUP BY, COUNT, AVG, MIN, MAX |
| Q4 | Categories with avg price > ₹600 | HAVING |
| Q5 | Full booking details across 6 tables | Multi-table INNER JOIN |
| Q6 | Bookings with and without a coupon | LEFT JOIN, COALESCE |
| Q7 | Customers who have placed a booking | Subquery + IN |
| Q8 | Customers who have never booked | Subquery + NOT IN |
| Q9 | Providers who have received a review | EXISTS |
| Q10 | Users who have never filed a complaint | NOT EXISTS |
| Q11 | All customer and provider emails | UNION |
| Q12 | Paid bookings that also have a review | INTERSECT |
| Q13 | Providers with only unverified documents | EXCEPT |
| Q14 | Services containing the word 'repair' | ILIKE pattern match |
| Q15 | Providers who submitted all 3 doc types | Relational Division |
| Q16 | Provider leaderboard — ratings + bookings | Complex aggregation, multiple joins |
| Q17 | Most expensive booking per customer | Correlated subquery |
| Q18 | City revenue summary | Materialized view query |
| Q19 | Anonymize a user's PII (right-to-erasure) | UPDATE, transaction (BEGIN/ROLLBACK) |

---

## Normalization

All 22 tables are in **BCNF**.

---

## Sample Data

| Table | Rows |
|---|---|
| Users | 30 (10 customers, 10 providers, 10 admins) |
| Cities / Areas / Addresses | 10 / 10 / 20 |
| Categories / Services / Variants | 10 / 20 / 20 |
| Offers (Provider ↔ Service) | 50 |
| Bookings | 100 (60 completed, 20 cancelled, 20 active) |
| Payments | 60 |
| Cancellations | 20 |
| Provider Reviews | 40 |
| Service Reviews | 30 |
| Complaints | 15 |

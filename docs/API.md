# UrbanServe REST API

**Swagger UI:** `https://urbanserve.shane07p.me/swagger-ui.html`  
**OpenAPI spec:** `https://urbanserve.shane07p.me/api-docs`

---

## Endpoints

### Providers

| Method | Path | Description | Parameters |
|---|---|---|---|
| GET | `/api/providers` | All verified providers sorted by experience (years) | — |
| GET | `/api/providers/reviewed` | Providers with at least one review, sorted by rating | — |
| GET | `/api/providers/all-docs-submitted` | Providers who submitted all 3 required docs (Aadhar, PAN, License) — Relational Division | — |
| GET | `/api/providers/leaderboard` | Top 10 providers by avg rating + review count + bookings | — |

### Services

| Method | Path | Description | Parameters |
|---|---|---|---|
| GET | `/api/services` | Active services paginated by price | `page` (default 0), `size` (default 10) |
| GET | `/api/services/search` | Search services by name keyword (ILIKE) | `name` — e.g. `repair` |
| GET | `/api/services/category-stats` | COUNT / AVG / MIN / MAX price per category | — |
| GET | `/api/services/expensive-categories` | Categories with average price above threshold | `minAvgPrice` (default 600) |

### Bookings

| Method | Path | Description | Parameters |
|---|---|---|---|
| GET | `/api/bookings` | Full booking details — customer, provider, city, date, amount | — |
| GET | `/api/bookings/with-coupon` | All bookings with coupon code used or 'No Coupon' (LEFT JOIN + COALESCE) | — |
| GET | `/api/bookings/customers/active` | Customers who placed at least one booking | — |
| GET | `/api/bookings/customers/never-booked` | Customers who have never booked (NOT IN) | — |
| GET | `/api/bookings/most-expensive-per-customer` | Most expensive booking per customer (correlated subquery) | — |

### Cities

| Method | Path | Description | Parameters |
|---|---|---|---|
| GET | `/api/cities/revenue` | Revenue summary per city from materialized view | — |

### Users

| Method | Path | Description | Parameters |
|---|---|---|---|
| GET | `/api/users/no-complaints` | Users who have never filed a complaint (NOT EXISTS) | — |
| GET | `/api/users/all-emails` | All customer and provider emails combined (UNION) | — |

---

## Response Schema Examples

### `GET /api/providers`
```json
[
  {
    "providerId": 7,
    "email": "nitin.tech@gmail.com",
    "experienceYears": 8,
    "bio": "Hardware and software laptop repair specialist. Certified by Dell & HP.",
    "avgRating": 4.68,
    "verificationStatus": "Verified"
  }
]
```

### `GET /api/services/search?name=repair`
```json
[
  {
    "serviceId": 3,
    "serviceName": "AC Repair",
    "basePrice": 500.0,
    "duration": 60
  }
]
```

**404 response when no match:**
```json
{ "message": "No services found matching 'xyz'" }
```

### `GET /api/cities/revenue`
```json
[
  {
    "cityName": "Mumbai",
    "state": "Maharashtra",
    "totalBookings": 18,
    "completedBookings": 12,
    "cancelledBookings": 3,
    "totalRevenue": 28500.00,
    "avgBookingValue": 2375.00,
    "uniqueCustomers": 7,
    "activeProviders": 4
  }
]
```

---

## Error Responses

| Status | When |
|---|---|
| 200 | Success |
| 404 | Search returns no results (only for `/search` and `/expensive-categories`) |
| 500 | Database connection error |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Runtime | Java 17 |
| Framework | Spring Boot 3.2.0 |
| Database client | JdbcTemplate (no ORM) |
| Database | PostgreSQL 15 on Supabase |
| API docs | springdoc-openapi 2.3.0 |
| Hosting | Digital Ocean App Platform |

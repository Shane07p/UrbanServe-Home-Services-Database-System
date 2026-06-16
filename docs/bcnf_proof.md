# BCNF Normalization Proof — UrbanServe

## Definition

A relation R is in **Boyce-Codd Normal Form (BCNF)** if and only if for every non-trivial functional dependency X → Y in R, X is a **superkey** of R.

A relation is in BCNF if it is already in 3NF and there are no overlapping candidate keys causing anomalies. Every relation that is in BCNF is also in 3NF, but not vice versa.

---

## Tables and BCNF Proof

### 1. Users

| Attribute | Type |
|---|---|
| user_id | PK |
| email, password, role, status, created_at | Non-key |

**Functional Dependencies:**
```
user_id → email
user_id → password
user_id → role
user_id → status
user_id → created_at
```

**Candidate Keys:** {user_id}

`user_id` is the only candidate key and therefore a superkey. All FDs have `user_id` on the left-hand side. **Relation is in BCNF.** ✓

---

### 2. Customer

| Attribute | Type |
|---|---|
| customer_id | PK |
| user_id, name, phone | Non-key |

**Functional Dependencies:**
```
customer_id → user_id
customer_id → name
customer_id → phone
```

**Candidate Keys:** {customer_id}

`customer_id` is a candidate key and hence a superkey. All FDs have `customer_id` on the left-hand side. **Relation is in BCNF.** ✓

---

### 3. ServiceProvider

| Attribute | Type |
|---|---|
| provider_id | PK |
| user_id, experience_years, bio, verification_status, avg_rating | Non-key |

**Functional Dependencies:**
```
provider_id → user_id
provider_id → experience_years
provider_id → bio
provider_id → verification_status
provider_id → avg_rating
```

**Candidate Keys:** {provider_id}

`provider_id` is a candidate key and hence a superkey. All FDs have `provider_id` on the left-hand side. **Relation is in BCNF.** ✓

---

### 4. Admin

| Attribute | Type |
|---|---|
| admin_id | PK |
| user_id, admin_role, permissions, department | Non-key |

**Functional Dependencies:**
```
admin_id → user_id
admin_id → admin_role
admin_id → permissions
admin_id → department
```

**Candidate Keys:** {admin_id}

`admin_id` is a candidate key and hence a superkey. All FDs have `admin_id` on the left-hand side. **Relation is in BCNF.** ✓

---

### 5. City

| Attribute | Type |
|---|---|
| city_id | PK |
| city_name, state | Non-key |

**Functional Dependencies:**
```
city_id → city_name
city_id → state
```

**Candidate Keys:** {city_id}

`city_id` is a candidate key and hence a superkey. All FDs have `city_id` on the left-hand side. **Relation is in BCNF.** ✓

---

### 6. Area

| Attribute | Type |
|---|---|
| area_id | PK |
| city_id, area_name, pincode | Non-key |

**Functional Dependencies:**
```
area_id → city_id
area_id → area_name
area_id → pincode
```

**Candidate Keys:** {area_id}

`area_id` is a candidate key and hence a superkey. All FDs have `area_id` on the left-hand side. **Relation is in BCNF.** ✓

---

### 7. Address

| Attribute | Type |
|---|---|
| address_id | PK |
| area_id, street, landmark, label, latitude, longitude | Non-key |

**Functional Dependencies:**
```
address_id → area_id
address_id → street
address_id → landmark
address_id → label
address_id → latitude
address_id → longitude
```

**Candidate Keys:** {address_id}

`address_id` is a candidate key and hence a superkey. All FDs have `address_id` on the left-hand side. **Relation is in BCNF.** ✓

---

### 8. Category

| Attribute | Type |
|---|---|
| category_id | PK |
| category_name, description | Non-key |

**Functional Dependencies:**
```
category_id → category_name
category_id → description
```

**Candidate Keys:** {category_id}

`category_id` is a candidate key and hence a superkey. All FDs have `category_id` on the left-hand side. **Relation is in BCNF.** ✓

---

### 9. Service

| Attribute | Type |
|---|---|
| service_id | PK |
| category_id, service_name, description, base_price, duration, is_active | Non-key |

**Functional Dependencies:**
```
service_id → category_id
service_id → service_name
service_id → description
service_id → base_price
service_id → duration
service_id → is_active
```

**Candidate Keys:** {service_id}

`service_id` is a candidate key and hence a superkey. All FDs have `service_id` on the left-hand side. **Relation is in BCNF.** ✓

---

### 10. ServiceVariant

| Attribute | Type |
|---|---|
| variant_id | PK |
| service_id, variant_name, price, duration | Non-key |

**Functional Dependencies:**
```
variant_id → service_id
variant_id → variant_name
variant_id → price
variant_id → duration
```

**Candidate Keys:** {variant_id}

`variant_id` is a candidate key and hence a superkey. All FDs have `variant_id` on the left-hand side. **Relation is in BCNF.** ✓

---

### 11. ProviderAvailability

| Attribute | Type |
|---|---|
| availability_id | PK |
| provider_id, day_of_week, start_time, end_time | Non-key |

**Functional Dependencies:**
```
availability_id → provider_id
availability_id → day_of_week
availability_id → start_time
availability_id → end_time
```

**Candidate Keys:** {availability_id}, {provider_id, day_of_week}

Both `availability_id` and `(provider_id, day_of_week)` are candidate keys and hence superkeys. All FDs have a superkey on the left-hand side. **Relation is in BCNF.** ✓

---

### 12. ProviderDocument

| Attribute | Type |
|---|---|
| document_id | PK |
| provider_id, document_type, document_url, verification_status | Non-key |

**Functional Dependencies:**
```
document_id → provider_id
document_id → document_type
document_id → document_url
document_id → verification_status
```

**Candidate Keys:** {document_id}

`document_id` is a candidate key and hence a superkey. All FDs have `document_id` on the left-hand side. **Relation is in BCNF.** ✓

---

### 13. Booking

| Attribute | Type |
|---|---|
| booking_id | PK |
| customer_id, provider_id, address_id, coupon_id, scheduled_date, scheduled_time, total_amount, special_instructions, created_at, status | Non-key |

**Functional Dependencies:**
```
booking_id → customer_id
booking_id → provider_id
booking_id → address_id
booking_id → coupon_id
booking_id → scheduled_date
booking_id → scheduled_time
booking_id → total_amount
booking_id → special_instructions
booking_id → created_at
booking_id → status
```

**Candidate Keys:** {booking_id}

`booking_id` is a candidate key and hence a superkey. All FDs have `booking_id` on the left-hand side. **Relation is in BCNF.** ✓

---

### 14. BookingItem

| Attribute | Type |
|---|---|
| (booking_id, item_no) | Composite PK |
| service_id, quantity, unit_price, custom_price | Non-key |

**Functional Dependencies:**
```
(booking_id, item_no) → service_id
(booking_id, item_no) → quantity
(booking_id, item_no) → unit_price
(booking_id, item_no) → custom_price
```

**Candidate Keys:** {booking_id, item_no}

`(booking_id, item_no)` is the composite candidate key and hence a superkey. All FDs have the composite key on the left-hand side. **Relation is in BCNF.** ✓

---

### 15. BookingStatusLog

| Attribute | Type |
|---|---|
| log_id | PK |
| booking_id, status, remarks, timestamp | Non-key |

**Functional Dependencies:**
```
log_id → booking_id
log_id → status
log_id → remarks
log_id → timestamp
```

**Candidate Keys:** {log_id}

`log_id` is a candidate key and hence a superkey. All FDs have `log_id` on the left-hand side. **Relation is in BCNF.** ✓

---

### 16. Payment

| Attribute | Type |
|---|---|
| payment_id | PK |
| booking_id, payment_method, amount, gateway_ref, status, paid_at | Non-key |

**Functional Dependencies:**
```
payment_id → booking_id
payment_id → payment_method
payment_id → amount
payment_id → gateway_ref
payment_id → status
payment_id → paid_at
```

**Candidate Keys:** {payment_id}, {booking_id}

Both `payment_id` and `booking_id` are candidate keys (each booking has exactly one payment record). All FDs have a superkey on the left-hand side. **Relation is in BCNF.** ✓

---

### 17. Cancellation

| Attribute | Type |
|---|---|
| cancel_id | PK |
| booking_id, reason, refund_amount, refund_status, cancelled_at | Non-key |

**Functional Dependencies:**
```
cancel_id → booking_id
cancel_id → reason
cancel_id → refund_amount
cancel_id → refund_status
cancel_id → cancelled_at
```

**Candidate Keys:** {cancel_id}, {booking_id}

Both `cancel_id` and `booking_id` are candidate keys (each booking has at most one cancellation). All FDs have a superkey on the left-hand side. **Relation is in BCNF.** ✓

---

### 18. Coupon

| Attribute | Type |
|---|---|
| coupon_id | PK |
| code, discount_type, min_order, discount_value, usage_limit, valid_from, valid_to | Non-key |

**Functional Dependencies:**
```
coupon_id → code
coupon_id → discount_type
coupon_id → min_order
coupon_id → discount_value
coupon_id → usage_limit
coupon_id → valid_from
coupon_id → valid_to
code → coupon_id
code → discount_type
code → min_order
code → discount_value
code → usage_limit
code → valid_from
code → valid_to
```

**Candidate Keys:** {coupon_id}, {code}

Both `coupon_id` and `code` are candidate keys (coupon codes are globally unique). All FDs have a superkey on the left-hand side. **Relation is in BCNF.** ✓

---

### 19. ProviderReview

| Attribute | Type |
|---|---|
| review_id | PK |
| provider_id, booking_id, rating, comment, created_at | Non-key |

**Functional Dependencies:**
```
review_id → provider_id
review_id → booking_id
review_id → rating
review_id → comment
review_id → created_at
```

**Candidate Keys:** {review_id}, {booking_id}

Both `review_id` and `booking_id` are candidate keys (each booking yields at most one provider review). All FDs have a superkey on the left-hand side. **Relation is in BCNF.** ✓

---

### 20. ServiceReview

| Attribute | Type |
|---|---|
| review_id | PK |
| service_id, booking_id, rating, comment, created_at | Non-key |

**Functional Dependencies:**
```
review_id → service_id
review_id → booking_id
review_id → rating
review_id → comment
review_id → created_at
```

**Candidate Keys:** {review_id}, {booking_id}

Both `review_id` and `booking_id` are candidate keys (each booking yields at most one service review). All FDs have a superkey on the left-hand side. **Relation is in BCNF.** ✓

---

### 21. Complaint

| Attribute | Type |
|---|---|
| complaint_id | PK |
| user_id, subject, description, priority, status, resolution_notes, created_at | Non-key |

**Functional Dependencies:**
```
complaint_id → user_id
complaint_id → subject
complaint_id → description
complaint_id → priority
complaint_id → status
complaint_id → resolution_notes
complaint_id → created_at
```

**Candidate Keys:** {complaint_id}

`complaint_id` is a candidate key and hence a superkey. All FDs have `complaint_id` on the left-hand side. **Relation is in BCNF.** ✓

---

### 22. Offers

| Attribute | Type |
|---|---|
| (provider_id, service_id, city_id) | Composite PK |
| custom_price, is_active | Non-key |

**Functional Dependencies:**
```
(provider_id, service_id, city_id) → custom_price
(provider_id, service_id, city_id) → is_active
```

**Candidate Keys:** {provider_id, service_id, city_id}

The only non-trivial FDs have the full composite key on the left-hand side. Crucially, `provider_id → city_id` does **not** hold — a provider may offer services in multiple cities — so `city_id` is genuinely part of the key and there is no partial dependency. The composite key is a superkey. **Relation is in BCNF.** ✓

---

## Summary

| # | Table | Candidate Keys | BCNF |
|---|---|---|---|
| 1 | Users | {user_id} | ✓ |
| 2 | Customer | {customer_id} | ✓ |
| 3 | ServiceProvider | {provider_id} | ✓ |
| 4 | Admin | {admin_id} | ✓ |
| 5 | City | {city_id} | ✓ |
| 6 | Area | {area_id} | ✓ |
| 7 | Address | {address_id} | ✓ |
| 8 | Category | {category_id} | ✓ |
| 9 | Service | {service_id} | ✓ |
| 10 | ServiceVariant | {variant_id} | ✓ |
| 11 | ProviderAvailability | {availability_id}, {provider_id, day_of_week} | ✓ |
| 12 | ProviderDocument | {document_id} | ✓ |
| 13 | Booking | {booking_id} | ✓ |
| 14 | BookingItem | {booking_id, item_no} | ✓ |
| 15 | BookingStatusLog | {log_id} | ✓ |
| 16 | Payment | {payment_id}, {booking_id} | ✓ |
| 17 | Cancellation | {cancel_id}, {booking_id} | ✓ |
| 18 | Coupon | {coupon_id}, {code} | ✓ |
| 19 | ProviderReview | {review_id}, {booking_id} | ✓ |
| 20 | ServiceReview | {review_id}, {booking_id} | ✓ |
| 21 | Complaint | {complaint_id} | ✓ |
| 22 | Offers | {provider_id, service_id, city_id} | ✓ |

**All 22 relations in the UrbanServe schema are in BCNF.**

For every non-trivial functional dependency X → Y across all tables, X is a superkey of its respective relation. No partial dependencies (violating 2NF) or transitive dependencies through non-key attributes (violating 3NF) exist, confirming that all relations satisfy BCNF.

-- UrbanServe — Indexes
-- Foreign-key columns (for joins + referential-integrity checks) plus the
-- non-key columns actually filtered or sorted by the query set.

CREATE INDEX idx_provider_vstatus     ON ServiceProvider(verification_status);
CREATE INDEX idx_provider_rating      ON ServiceProvider(avg_rating DESC);

CREATE INDEX idx_area_city            ON Area(city_id);

CREATE INDEX idx_address_area         ON Address(area_id);
CREATE INDEX idx_address_customer     ON Address(customer_id);

CREATE INDEX idx_service_category     ON Service(category_id);
CREATE INDEX idx_service_active       ON Service(is_active);
CREATE INDEX idx_service_price        ON Service(base_price);

CREATE INDEX idx_variant_service      ON ServiceVariant(service_id);

CREATE INDEX idx_offers_service       ON Offers(service_id);
CREATE INDEX idx_offers_city          ON Offers(city_id);

CREATE INDEX idx_avail_provider       ON ProviderAvailability(provider_id);

CREATE INDEX idx_doc_provider         ON ProviderDocument(provider_id);
CREATE INDEX idx_doc_vstatus          ON ProviderDocument(verification_status);

CREATE INDEX idx_booking_customer     ON Booking(customer_id);
CREATE INDEX idx_booking_provider     ON Booking(provider_id);
CREATE INDEX idx_booking_address      ON Booking(address_id);
CREATE INDEX idx_booking_coupon       ON Booking(coupon_id);

CREATE INDEX idx_bitem_booking        ON BookingItem(booking_id);
CREATE INDEX idx_bitem_service        ON BookingItem(service_id);

CREATE INDEX idx_bslog_booking        ON BookingStatusLog(booking_id);

CREATE INDEX idx_payment_status       ON Payment(status);

CREATE INDEX idx_prev_provider        ON ProviderReview(provider_id);
CREATE INDEX idx_prev_booking         ON ProviderReview(booking_id);
CREATE INDEX idx_prev_customer        ON ProviderReview(customer_id);

CREATE INDEX idx_srev_service         ON ServiceReview(service_id);
CREATE INDEX idx_srev_booking         ON ServiceReview(booking_id);
CREATE INDEX idx_srev_customer        ON ServiceReview(customer_id);

CREATE INDEX idx_complaint_user       ON Complaint(user_id);
CREATE INDEX idx_complaint_booking    ON Complaint(booking_id);

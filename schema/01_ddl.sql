-- UrbanServe PostgreSQL DDL v2.0
-- 22 tables | BCNF | SERIAL PKs | CHECK + NOT NULL constraints

DROP TABLE IF EXISTS Offers             CASCADE;
DROP TABLE IF EXISTS Complaint          CASCADE;
DROP TABLE IF EXISTS ServiceReview      CASCADE;
DROP TABLE IF EXISTS ProviderReview     CASCADE;
DROP TABLE IF EXISTS Cancellation       CASCADE;
DROP TABLE IF EXISTS Payment            CASCADE;
DROP TABLE IF EXISTS BookingStatusLog   CASCADE;
DROP TABLE IF EXISTS BookingItem        CASCADE;
DROP TABLE IF EXISTS Booking            CASCADE;
DROP TABLE IF EXISTS Coupon             CASCADE;
DROP TABLE IF EXISTS ProviderDocument   CASCADE;
DROP TABLE IF EXISTS ProviderAvailability CASCADE;
DROP TABLE IF EXISTS ServiceVariant     CASCADE;
DROP TABLE IF EXISTS Service            CASCADE;
DROP TABLE IF EXISTS Category           CASCADE;
DROP TABLE IF EXISTS Address            CASCADE;
DROP TABLE IF EXISTS Area               CASCADE;
DROP TABLE IF EXISTS City               CASCADE;
DROP TABLE IF EXISTS Admin              CASCADE;
DROP TABLE IF EXISTS ServiceProvider    CASCADE;
DROP TABLE IF EXISTS Customer           CASCADE;
DROP TABLE IF EXISTS Users              CASCADE;


CREATE TABLE Users (
    user_id     SERIAL PRIMARY KEY,
    email       VARCHAR(100) UNIQUE NOT NULL,
    password    VARCHAR(100) NOT NULL,
    role        VARCHAR(20)  NOT NULL CHECK (role IN ('Customer', 'Provider', 'Admin')),
    status      VARCHAR(20)  NOT NULL DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive', 'Suspended')),
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Customer (
    customer_id SERIAL PRIMARY KEY,
    user_id     INT UNIQUE NOT NULL,
    name        VARCHAR(100) NOT NULL,
    phone       VARCHAR(15)  NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE ServiceProvider (
    provider_id         SERIAL PRIMARY KEY,
    user_id             INT UNIQUE NOT NULL,
    experience_years    INT         NOT NULL DEFAULT 0 CHECK (experience_years >= 0),
    bio                 TEXT,
    avg_rating          FLOAT       NOT NULL DEFAULT 0.0 CHECK (avg_rating >= 0.0 AND avg_rating <= 5.0),
    verification_status VARCHAR(50) NOT NULL DEFAULT 'Pending' CHECK (verification_status IN ('Pending', 'Verified', 'Rejected')),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Admin (
    admin_id    SERIAL PRIMARY KEY,
    user_id     INT UNIQUE NOT NULL,
    admin_role  VARCHAR(50),
    permissions TEXT,
    department  VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE City (
    city_id   SERIAL PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL,
    state     VARCHAR(100) NOT NULL,
    status    VARCHAR(20)  NOT NULL DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive'))
);

CREATE TABLE Area (
    area_id   SERIAL PRIMARY KEY,
    city_id   INT NOT NULL,
    area_name VARCHAR(100) NOT NULL,
    pincode   VARCHAR(10)  NOT NULL,
    status    VARCHAR(20)  NOT NULL DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive')),
    FOREIGN KEY (city_id) REFERENCES City(city_id)
);

CREATE TABLE Address (
    address_id  SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    area_id     INT NOT NULL,
    street      VARCHAR(255) NOT NULL,
    landmark    VARCHAR(255),
    label       VARCHAR(50)  DEFAULT 'Home' CHECK (label IN ('Home', 'Office', 'Other')),
    latitude    FLOAT,
    longitude   FLOAT,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (area_id)     REFERENCES Area(area_id)
);

CREATE TABLE Category (
    category_id   SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description   TEXT
);

CREATE TABLE Service (
    service_id   SERIAL PRIMARY KEY,
    category_id  INT NOT NULL,
    service_name VARCHAR(100) NOT NULL,
    description  TEXT,
    base_price   FLOAT   NOT NULL CHECK (base_price > 0),
    duration     INT     NOT NULL CHECK (duration > 0),
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

CREATE TABLE ServiceVariant (
    variant_id   SERIAL PRIMARY KEY,
    service_id   INT NOT NULL,
    variant_name VARCHAR(100) NOT NULL,
    price        FLOAT NOT NULL CHECK (price > 0),
    duration     INT   NOT NULL CHECK (duration > 0),
    FOREIGN KEY (service_id) REFERENCES Service(service_id)
);

-- Junction table for the M:N Offers relationship (ServiceProvider ↔ Service)
-- A provider can offer a service in multiple cities, so city_id is part of the key.
CREATE TABLE Offers (
    provider_id  INT NOT NULL,
    service_id   INT NOT NULL,
    city_id      INT NOT NULL,
    custom_price FLOAT CHECK (custom_price > 0),
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (provider_id, service_id, city_id),
    FOREIGN KEY (provider_id) REFERENCES ServiceProvider(provider_id),
    FOREIGN KEY (service_id)  REFERENCES Service(service_id),
    FOREIGN KEY (city_id)     REFERENCES City(city_id)
);

CREATE TABLE ProviderAvailability (
    availability_id SERIAL PRIMARY KEY,
    provider_id     INT NOT NULL,
    day_of_week     VARCHAR(20) NOT NULL CHECK (day_of_week IN ('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')),
    start_time      TIME NOT NULL,
    end_time        TIME NOT NULL,
    CHECK (end_time > start_time),
    FOREIGN KEY (provider_id) REFERENCES ServiceProvider(provider_id)
);

CREATE TABLE ProviderDocument (
    document_id         SERIAL PRIMARY KEY,
    provider_id         INT NOT NULL,
    document_type       VARCHAR(50) NOT NULL CHECK (document_type IN ('Aadhar', 'PAN', 'License', 'Certificate', 'Other')),
    description         TEXT,
    file_url            TEXT NOT NULL,
    verification_status VARCHAR(50) NOT NULL DEFAULT 'Pending' CHECK (verification_status IN ('Pending', 'Verified', 'Rejected')),
    uploaded_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (provider_id) REFERENCES ServiceProvider(provider_id)
);

CREATE TABLE Coupon (
    coupon_id      SERIAL PRIMARY KEY,
    code           VARCHAR(50) UNIQUE NOT NULL,
    discount_type  VARCHAR(50) NOT NULL CHECK (discount_type IN ('Flat', 'Percent')),
    min_order      FLOAT NOT NULL DEFAULT 0 CHECK (min_order >= 0),
    discount_value FLOAT NOT NULL CHECK (discount_value > 0),
    usage_limit    INT   NOT NULL CHECK (usage_limit > 0),
    valid_from     DATE  NOT NULL,
    valid_to       DATE  NOT NULL,
    CHECK (valid_to > valid_from)
);

CREATE TABLE Booking (
    booking_id           SERIAL PRIMARY KEY,
    customer_id          INT NOT NULL,
    provider_id          INT NOT NULL,
    address_id           INT NOT NULL,
    coupon_id            INT,
    scheduled_date       DATE NOT NULL,
    scheduled_time       TIME NOT NULL,
    total_amount         FLOAT NOT NULL CHECK (total_amount >= 0),
    status               VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending','Confirmed','In-Progress','Completed','Cancelled')),
    special_instructions TEXT,
    created_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (provider_id) REFERENCES ServiceProvider(provider_id),
    FOREIGN KEY (address_id)  REFERENCES Address(address_id),
    FOREIGN KEY (coupon_id)   REFERENCES Coupon(coupon_id)
);

CREATE TABLE BookingItem (
    item_no      INT NOT NULL,
    booking_id   INT NOT NULL,
    service_id   INT NOT NULL,
    quantity     INT   NOT NULL DEFAULT 1 CHECK (quantity > 0),
    unit_price   FLOAT NOT NULL CHECK (unit_price >= 0),
    custom_price FLOAT CHECK (custom_price >= 0),
    PRIMARY KEY (item_no, booking_id),
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id),
    FOREIGN KEY (service_id) REFERENCES Service(service_id)
);

CREATE TABLE BookingStatusLog (
    log_id     SERIAL PRIMARY KEY,
    booking_id INT NOT NULL,
    status     VARCHAR(50) NOT NULL CHECK (status IN ('Pending','Confirmed','In-Progress','Completed','Cancelled')),
    remarks    TEXT,
    timestamp  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id)
);

CREATE TABLE Payment (
    payment_id     SERIAL PRIMARY KEY,
    booking_id     INT UNIQUE NOT NULL,
    payment_method VARCHAR(50) NOT NULL CHECK (payment_method IN ('UPI', 'Card', 'Cash', 'Wallet')),
    amount         FLOAT NOT NULL CHECK (amount >= 0),
    gateway_ref    VARCHAR(100),
    status         VARCHAR(50) NOT NULL DEFAULT 'Pending' CHECK (status IN ('Paid', 'Pending', 'Failed', 'Refunded')),
    paid_at        TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id)
);

CREATE TABLE Cancellation (
    cancel_id     SERIAL PRIMARY KEY,
    booking_id    INT UNIQUE NOT NULL,
    reason        TEXT NOT NULL,
    refund_amount FLOAT NOT NULL DEFAULT 0 CHECK (refund_amount >= 0),
    refund_status VARCHAR(50) NOT NULL DEFAULT 'Pending' CHECK (refund_status IN ('Refunded', 'Pending', 'Rejected')),
    cancelled_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id)
);

CREATE TABLE ProviderReview (
    review_id   SERIAL PRIMARY KEY,
    provider_id INT NOT NULL,
    booking_id  INT NOT NULL,
    customer_id INT NOT NULL,
    rating      FLOAT NOT NULL CHECK (rating >= 1.0 AND rating <= 5.0),
    comment     TEXT,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (provider_id) REFERENCES ServiceProvider(provider_id),
    FOREIGN KEY (booking_id)  REFERENCES Booking(booking_id),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

CREATE TABLE ServiceReview (
    review_id   SERIAL PRIMARY KEY,
    service_id  INT NOT NULL,
    booking_id  INT NOT NULL,
    customer_id INT NOT NULL,
    rating      FLOAT NOT NULL CHECK (rating >= 1.0 AND rating <= 5.0),
    comment     TEXT,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (service_id)  REFERENCES Service(service_id),
    FOREIGN KEY (booking_id)  REFERENCES Booking(booking_id),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

CREATE TABLE Complaint (
    complaint_id     SERIAL PRIMARY KEY,
    user_id          INT NOT NULL,
    booking_id       INT,
    subject          VARCHAR(100) NOT NULL,
    description      TEXT NOT NULL,
    priority         VARCHAR(20) NOT NULL DEFAULT 'Medium' CHECK (priority IN ('Low', 'Medium', 'High')),
    status           VARCHAR(20) NOT NULL DEFAULT 'Open'   CHECK (status IN ('Open', 'Closed', 'Under Review')),
    resolution_notes TEXT,
    created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)    REFERENCES Users(user_id),
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id)
);

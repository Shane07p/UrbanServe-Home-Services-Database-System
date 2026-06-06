package com.urbanserve.api.controller;

import com.urbanserve.api.dto.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.jdbc.core.DataClassRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/bookings")
@Tag(name = "Bookings", description = "Booking and customer endpoints")
public class BookingController {

    private final JdbcTemplate jdbc;

    public BookingController(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @GetMapping
    @Operation(summary = "Full booking details — customer, provider, city, date, amount")
    public List<BookingDto> getAllBookings() {
        return jdbc.query("""
                SELECT b.booking_id, b.status AS booking_status,
                       cu.name AS customer_name, sp.bio AS provider_bio,
                       ci.city_name, ar.area_name,
                       b.scheduled_date, b.scheduled_time, b.total_amount
                FROM Booking b
                JOIN Customer cu ON b.customer_id = cu.customer_id
                JOIN ServiceProvider sp ON b.provider_id = sp.provider_id
                JOIN Address a ON b.address_id = a.address_id
                JOIN Area ar ON a.area_id = ar.area_id
                JOIN City ci ON ar.city_id = ci.city_id
                ORDER BY b.scheduled_date ASC
                """, DataClassRowMapper.newInstance(BookingDto.class));
    }

    @GetMapping("/with-coupon")
    @Operation(summary = "All bookings showing coupon used or 'No Coupon'")
    public List<BookingCouponDto> getBookingsWithCoupon() {
        return jdbc.query("""
                SELECT b.booking_id, cu.name AS customer_name,
                       b.total_amount, b.status,
                       COALESCE(cp.code, 'No Coupon') AS coupon_used,
                       COALESCE(cp.discount_value::TEXT, '-') AS discount
                FROM Booking b
                JOIN Customer cu ON b.customer_id = cu.customer_id
                LEFT JOIN Coupon cp ON b.coupon_id = cp.coupon_id
                ORDER BY b.booking_id
                """, DataClassRowMapper.newInstance(BookingCouponDto.class));
    }

    @GetMapping("/customers/active")
    @Operation(summary = "Customers who have placed at least one booking")
    public List<CustomerDto> getActiveCustomers() {
        return jdbc.query("""
                SELECT customer_id, name, phone FROM Customer
                WHERE customer_id IN (SELECT DISTINCT customer_id FROM Booking)
                ORDER BY customer_id
                """, DataClassRowMapper.newInstance(CustomerDto.class));
    }

    @GetMapping("/customers/never-booked")
    @Operation(summary = "Customers who have never placed a booking")
    public List<CustomerDto> getNeverBookedCustomers() {
        return jdbc.query("""
                SELECT customer_id, name, phone FROM Customer
                WHERE customer_id NOT IN (SELECT DISTINCT customer_id FROM Booking)
                """, DataClassRowMapper.newInstance(CustomerDto.class));
    }

    @GetMapping("/most-expensive-per-customer")
    @Operation(summary = "Most expensive booking per customer")
    public List<ExpensiveBookingDto> getMostExpensivePerCustomer() {
        return jdbc.query("""
                SELECT cu.customer_id, cu.name, b.booking_id,
                       b.status, b.total_amount AS most_expensive_booking
                FROM Customer cu
                JOIN Booking b ON cu.customer_id = b.customer_id
                WHERE b.total_amount = (
                    SELECT MAX(total_amount) FROM Booking b2
                    WHERE b2.customer_id = cu.customer_id
                )
                ORDER BY most_expensive_booking DESC
                """, DataClassRowMapper.newInstance(ExpensiveBookingDto.class));
    }
}

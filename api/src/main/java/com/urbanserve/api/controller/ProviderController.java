package com.urbanserve.api.controller;

import com.urbanserve.api.dto.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.jdbc.core.DataClassRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/providers")
@Tag(name = "Providers", description = "Service provider endpoints")
public class ProviderController {

    private final JdbcTemplate jdbc;

    public ProviderController(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @GetMapping
    @Operation(summary = "All verified providers sorted by experience")
    public List<ProviderDto> getVerifiedProviders() {
        return jdbc.query("""
                SELECT sp.provider_id, u.email, sp.experience_years,
                       sp.bio, sp.avg_rating, sp.verification_status
                FROM ServiceProvider sp
                JOIN Users u ON sp.user_id = u.user_id
                WHERE sp.verification_status = 'Verified'
                ORDER BY sp.experience_years DESC
                """, DataClassRowMapper.newInstance(ProviderDto.class));
    }

    @GetMapping("/reviewed")
    @Operation(summary = "Providers who have received at least one review")
    public List<ReviewedProviderDto> getReviewedProviders() {
        return jdbc.query("""
                SELECT sp.provider_id, sp.bio, sp.avg_rating, sp.verification_status
                FROM ServiceProvider sp
                WHERE EXISTS (
                    SELECT 1 FROM ProviderReview pr
                    WHERE pr.provider_id = sp.provider_id
                )
                ORDER BY sp.avg_rating DESC
                """, DataClassRowMapper.newInstance(ReviewedProviderDto.class));
    }

    @GetMapping("/all-docs-submitted")
    @Operation(summary = "Providers who have submitted all 3 required documents (Aadhar, PAN, License)")
    public List<DocumentedProviderDto> getFullyDocumentedProviders() {
        return jdbc.query("""
                SELECT sp.provider_id, sp.bio
                FROM ServiceProvider sp
                WHERE NOT EXISTS (
                    SELECT doc_type FROM (VALUES ('Aadhar'), ('PAN'), ('License')) AS required(doc_type)
                    WHERE NOT EXISTS (
                        SELECT 1 FROM ProviderDocument pd
                        WHERE pd.provider_id = sp.provider_id
                          AND pd.document_type = required.doc_type
                    )
                )
                """, DataClassRowMapper.newInstance(DocumentedProviderDto.class));
    }

    @GetMapping("/leaderboard")
    @Operation(summary = "Provider leaderboard — rating, reviews, and total bookings")
    public List<LeaderboardDto> getLeaderboard() {
        return jdbc.query("""
                SELECT sp.provider_id, sp.bio AS provider_bio, sp.avg_rating,
                       COUNT(DISTINCT pr.review_id) AS total_reviews,
                       ROUND(AVG(pr.rating)::numeric, 2) AS computed_avg_rating,
                       COUNT(DISTINCT b.booking_id) AS total_bookings
                FROM ServiceProvider sp
                JOIN ProviderReview pr ON sp.provider_id = pr.provider_id
                JOIN Booking b ON sp.provider_id = b.provider_id
                GROUP BY sp.provider_id, sp.bio, sp.avg_rating
                HAVING COUNT(pr.review_id) >= 1
                ORDER BY sp.avg_rating DESC, total_reviews DESC
                LIMIT 10
                """, DataClassRowMapper.newInstance(LeaderboardDto.class));
    }
}

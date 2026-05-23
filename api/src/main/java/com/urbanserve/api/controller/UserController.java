package com.urbanserve.api.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
@Tag(name = "Users", description = "User and email endpoints")
public class UserController {

    private final JdbcTemplate jdbc;

    public UserController(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @GetMapping("/no-complaints")
    @Operation(summary = "Users who have never filed a complaint")
    public List<Map<String, Object>> getUsersWithNoComplaints() {
        return jdbc.queryForList("""
                SELECT u.user_id, u.email, u.role
                FROM Users u
                WHERE NOT EXISTS (
                    SELECT 1 FROM Complaint c WHERE c.user_id = u.user_id
                )
                ORDER BY u.role, u.user_id
                """);
    }

    @GetMapping("/all-emails")
    @Operation(summary = "Combined list of all customer and provider emails")
    public List<Map<String, Object>> getAllEmails() {
        return jdbc.queryForList("""
                SELECT u.email, 'Customer' AS user_type
                FROM Customer cu JOIN Users u ON cu.user_id = u.user_id
                UNION
                SELECT u.email, 'Provider' AS user_type
                FROM ServiceProvider sp JOIN Users u ON sp.user_id = u.user_id
                ORDER BY user_type, email
                """);
    }
}

-- Seed bootstrap admin user and role assignments.
-- Requires: 01_roles.sql.
-- Existing admin passwords are intentionally not overwritten.

BEGIN;

WITH seed(username, email, display_name, password_hash, is_active, must_change_password, created_at) AS (
    VALUES
    ('admin', 'admin@ginsengfood.local', 'System Admin', 'AQAAAAEAACcQAAAAECvarHxZHDeE/jHy0YDokqitGaU/GsJHQiFrKNf5piiOdLQPTw1QgXybb2I/7uzWbg==', TRUE, FALSE, '2026-04-11T14:54:24.543967+07:00'::timestamptz)
)
UPDATE users u
SET email = s.email,
    display_name = s.display_name,
    is_active = s.is_active,
    must_change_password = s.must_change_password,
    updated_at = NOW()
FROM seed s
WHERE u.username = s.username
  AND u.is_deleted = FALSE;

WITH seed(username, email, display_name, password_hash, is_active, must_change_password, created_at) AS (
    VALUES
    ('admin', 'admin@ginsengfood.local', 'System Admin', 'AQAAAAEAACcQAAAAECvarHxZHDeE/jHy0YDokqitGaU/GsJHQiFrKNf5piiOdLQPTw1QgXybb2I/7uzWbg==', TRUE, FALSE, '2026-04-11T14:54:24.543967+07:00'::timestamptz)
)
INSERT INTO users (username, email, display_name, password_hash, is_active, must_change_password, created_at, is_deleted)
SELECT s.username, s.email, s.display_name, s.password_hash, s.is_active, s.must_change_password, s.created_at, FALSE
FROM seed s
WHERE NOT EXISTS (
    SELECT 1 FROM users u WHERE u.username = s.username AND u.is_deleted = FALSE
);

WITH seed(username, role_code, is_active, created_at) AS (
    VALUES
    ('admin', 'admin', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('admin', 'system-admin', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz)
), resolved AS (
    SELECT u.id AS user_id, r.id AS role_id, s.is_active, s.created_at
    FROM seed s
    JOIN users u ON u.username = s.username AND u.is_deleted = FALSE
    JOIN roles r ON r.code = s.role_code AND r.is_deleted = FALSE
)
UPDATE user_roles ur
SET is_active = r.is_active,
    updated_at = NOW()
FROM resolved r
WHERE ur.user_id = r.user_id
  AND ur.role_id = r.role_id
  AND ur.is_deleted = FALSE;

WITH seed(username, role_code, is_active, created_at) AS (
    VALUES
    ('admin', 'admin', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('admin', 'system-admin', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz)
), resolved AS (
    SELECT u.id AS user_id, r.id AS role_id, s.is_active, s.created_at
    FROM seed s
    JOIN users u ON u.username = s.username AND u.is_deleted = FALSE
    JOIN roles r ON r.code = s.role_code AND r.is_deleted = FALSE
)
INSERT INTO user_roles (user_id, role_id, is_active, created_at, is_deleted)
SELECT r.user_id, r.role_id, r.is_active, r.created_at, FALSE
FROM resolved r
WHERE NOT EXISTS (
    SELECT 1
    FROM user_roles ur
    WHERE ur.user_id = r.user_id
      AND ur.role_id = r.role_id
      AND ur.is_deleted = FALSE
);

COMMIT;

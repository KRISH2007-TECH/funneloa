WITH stage_counts AS (
    SELECT
        step,
        COUNT(DISTINCT user_id) AS users,
        CASE step
            WHEN 'visited_site' THEN 1
            WHEN 'signup_started' THEN 2
            WHEN 'details_filled' THEN 3
            WHEN 'email_verified' THEN 4
            WHEN 'purchase_completed' THEN 5
        END AS stage_order
    FROM funnel_events_sample
    GROUP BY step
),
funnel AS (
    SELECT
        step,
        users,
        LAG(users) OVER (ORDER BY stage_order) AS previous_users
    FROM stage_counts
)
SELECT
    step,
    users,
    CASE
        WHEN previous_users IS NULL THEN 100
        ELSE ROUND(users * 100.0 / previous_users, 2)
    END AS conversion_rate,
    COALESCE(previous_users - users, 0) AS drop_off
FROM funnel
ORDER BY
    CASE step
        WHEN 'visited_site' THEN 1
        WHEN 'signup_started' THEN 2
        WHEN 'details_filled' THEN 3
        WHEN 'email_verified' THEN 4
        WHEN 'purchase_completed' THEN 5
    END;
WITH stage_counts AS (
    SELECT
        step,
        COUNT(DISTINCT user_id) AS users,
        CASE step
            WHEN 'visited_site' THEN 1
            WHEN 'signup_started' THEN 2
            WHEN 'details_filled' THEN 3
            WHEN 'email_verified' THEN 4
            WHEN 'purchase_completed' THEN 5
        END AS stage_order
    FROM funnel_events_sample
    GROUP BY step
),
funnel AS (
    SELECT
        step,
        users,
        LAG(users) OVER (ORDER BY stage_order) AS previous_users,
        LAG(step) OVER (ORDER BY stage_order) AS previous_step
    FROM stage_counts
)
SELECT
    previous_step,
    step AS current_step,
    previous_users - users AS users_lost
FROM funnel
WHERE previous_users IS NOT NULL
ORDER BY users_lost DESC
LIMIT 1;
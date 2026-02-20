-- Seed nedostajućih podataka iz JSON-a
-- Pokretanje: nakon 001_create_schema.sql i 003_seed_user_tperisa22.sql
--
-- Uključuje:
--   - subscription_plans (Premium Monthly, Premium Yearly)
--   - user_subscriptions (tperisa22 yearly plan – finbalancer_premium_yearly)
--
-- Provjereno prazno u JSON-u: goals, subcategories, notification_requests,
-- in_app_notifications, projects – nema podataka za migraciju.

-- ==================== SUBSCRIPTION PLANS ====================
-- Note: paypal_plan_id is added in 010_subscriptions_unified.sql; existing plans get NULL
INSERT INTO subscription_plans (id, name, product_id, apple_product_id, google_product_id, duration, price, currency, is_active) VALUES
('c7902959-75da-4145-8f03-81abcefc499c', 'Premium Monthly', 'finbalancer_premium_monthly', 'finbalancer_premium_monthly', 'finbalancer_premium_monthly', 'monthly', 4.99, 'EUR', TRUE),
('0b21934d-19a5-480e-b0e5-be8321510a64', 'Premium Yearly', 'finbalancer_premium_yearly', 'finbalancer_premium_yearly', 'finbalancer_premium_yearly', 'yearly', 39.99, 'EUR', TRUE)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    product_id = EXCLUDED.product_id,
    apple_product_id = EXCLUDED.apple_product_id,
    google_product_id = EXCLUDED.google_product_id,
    duration = EXCLUDED.duration,
    price = EXCLUDED.price,
    currency = EXCLUDED.currency,
    is_active = EXCLUDED.is_active;

-- ==================== USER SUBSCRIPTIONS ====================
-- tperisa22@gmail.com – Premium Yearly plan (manual grant)
INSERT INTO user_subscriptions (id, user_id, platform, product_id, purchase_token, status, expires_at, cancelled_at, created_at, updated_at, receipt_data, order_id) VALUES
('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'bd2265c8-fc6d-4c8c-beaa-cb37ea4eefa2', 'manual', 'finbalancer_premium_yearly', 'admin_grant', 'active', '2027-02-15 00:00:00+00', NULL, '2026-02-15 00:00:00+00', '2026-02-15 00:00:00+00', NULL, NULL)
ON CONFLICT (id) DO UPDATE SET
    user_id = EXCLUDED.user_id,
    platform = EXCLUDED.platform,
    product_id = EXCLUDED.product_id,
    purchase_token = EXCLUDED.purchase_token,
    status = EXCLUDED.status,
    expires_at = EXCLUDED.expires_at,
    cancelled_at = EXCLUDED.cancelled_at,
    updated_at = EXCLUDED.updated_at;

-- Unified subscription system: purchases, entitlements, webhook deduplication
-- Version 10

-- Add paypal_plan_id to subscription_plans
ALTER TABLE subscription_plans ADD COLUMN IF NOT EXISTS paypal_plan_id VARCHAR(255);

-- ==================== SUBSCRIPTION_PURCHASES ====================
CREATE TABLE IF NOT EXISTS subscription_purchases (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    platform VARCHAR(20) NOT NULL,
    product_code VARCHAR(255) NOT NULL,
    external_id VARCHAR(512) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'active',
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ,
    raw_payload JSONB,
    auto_renew BOOLEAN NOT NULL DEFAULT TRUE,
    cancel_reason VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_purchase_status CHECK (status IN ('active', 'grace', 'on_hold', 'canceled', 'expired', 'refunded'))
);

CREATE INDEX ix_subscription_purchases_user_platform_external
    ON subscription_purchases (user_id, platform, external_id);
CREATE UNIQUE INDEX ix_subscription_purchases_platform_external
    ON subscription_purchases (platform, external_id);

-- ==================== USER_ENTITLEMENTS ====================
CREATE TABLE IF NOT EXISTS user_entitlements (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    is_premium BOOLEAN NOT NULL DEFAULT FALSE,
    premium_until TIMESTAMPTZ,
    source_platform VARCHAR(20),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==================== WEBHOOK_EVENTS ====================
CREATE TABLE IF NOT EXISTS webhook_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider VARCHAR(30) NOT NULL,
    event_id VARCHAR(512) NOT NULL,
    payload_hash VARCHAR(64),
    processed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_webhook_events_provider_event UNIQUE (provider, event_id)
);

CREATE INDEX ix_webhook_events_provider_event ON webhook_events (provider, event_id);

-- ==================== SCHEMA VERSION ====================
INSERT INTO schema_version (version, name, applied_at)
VALUES (10, '010_subscriptions_unified', NOW())
ON CONFLICT (version) DO NOTHING;

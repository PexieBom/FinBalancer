-- FinBalancer PostgreSQL Schema
-- Run this script to create the initial database structure.

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==================== USERS ====================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255),
    display_name VARCHAR(255) NOT NULL,
    google_id VARCHAR(255),
    apple_id VARCHAR(255),
    email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_login_at TIMESTAMPTZ
);

CREATE INDEX ix_users_email ON users (LOWER(email));
CREATE INDEX ix_users_google_id ON users (google_id) WHERE google_id IS NOT NULL;
CREATE INDEX ix_users_apple_id ON users (apple_id) WHERE apple_id IS NOT NULL;

-- ==================== USER_PREFERENCES ====================
CREATE TABLE user_preferences (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    locale VARCHAR(10) NOT NULL DEFAULT 'en',
    currency VARCHAR(10) NOT NULL DEFAULT 'EUR',
    theme VARCHAR(20) NOT NULL DEFAULT 'system'
);

-- ==================== REFRESH_TOKENS ====================
CREATE TABLE refresh_tokens (
    token VARCHAR(512) PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX ix_refresh_tokens_user_id ON refresh_tokens (user_id);

-- ==================== CATEGORIES (built-in) ====================
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    translations JSONB,
    icon VARCHAR(100) NOT NULL DEFAULT '',
    type VARCHAR(20) NOT NULL DEFAULT 'expense'
);

-- ==================== SUBCATEGORIES ====================
CREATE TABLE subcategories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL
);

CREATE INDEX ix_subcategories_category_id ON subcategories (category_id);

-- ==================== CUSTOM_CATEGORIES (user-created) ====================
CREATE TABLE custom_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(20) NOT NULL DEFAULT 'expense',
    icon VARCHAR(100) NOT NULL DEFAULT 'custom'
);

CREATE INDEX ix_custom_categories_user_id ON custom_categories (user_id);

-- ==================== WALLETS ====================
CREATE TABLE wallets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    balance DECIMAL(18, 4) NOT NULL DEFAULT 0,
    currency VARCHAR(10) NOT NULL DEFAULT 'EUR',
    is_main BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX ix_wallets_user_id ON wallets (user_id);

-- ==================== TRANSACTIONS ====================
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount DECIMAL(18, 4) NOT NULL,
    type VARCHAR(20) NOT NULL DEFAULT 'expense',
    category_id UUID NOT NULL,
    subcategory_id UUID REFERENCES subcategories(id) ON DELETE SET NULL,
    wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
    note TEXT,
    tags JSONB DEFAULT '[]',
    project TEXT,
    project_id UUID,
    date_created TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_yearly_expense BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX ix_transactions_user_id ON transactions (user_id);
CREATE INDEX ix_transactions_wallet_id ON transactions (wallet_id);
CREATE INDEX ix_transactions_category_id ON transactions (category_id);
CREATE INDEX ix_transactions_date_created ON transactions (date_created);

-- ==================== GOALS ====================
CREATE TABLE goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    target_amount DECIMAL(18, 4) NOT NULL,
    current_amount DECIMAL(18, 4) NOT NULL DEFAULT 0,
    deadline TIMESTAMPTZ,
    icon VARCHAR(100) NOT NULL DEFAULT 'savings',
    type VARCHAR(50) NOT NULL DEFAULT 'savings',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX ix_goals_user_id ON goals (user_id);

-- ==================== PROJECTS ====================
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    color VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX ix_projects_user_id ON projects (user_id);

-- ==================== WALLET_BUDGETS ====================
CREATE TABLE wallet_budgets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
    budget_amount DECIMAL(18, 4) NOT NULL,
    period_start_day INT NOT NULL DEFAULT 1,
    period_start_date TIMESTAMPTZ,
    period_end_date TIMESTAMPTZ,
    category_id UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, wallet_id)
);

CREATE INDEX ix_wallet_budgets_user_id ON wallet_budgets (user_id);
CREATE INDEX ix_wallet_budgets_wallet_id ON wallet_budgets (wallet_id);

-- ==================== ACCOUNT_LINKS ====================
CREATE TABLE account_links (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    host_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    guest_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status INT NOT NULL DEFAULT 0,
    invited_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    responded_at TIMESTAMPTZ,
    UNIQUE (host_user_id, guest_user_id)
);

CREATE INDEX ix_account_links_host ON account_links (host_user_id);
CREATE INDEX ix_account_links_guest ON account_links (guest_user_id);

-- ==================== NOTIFICATION_REQUESTS (password reset etc.) ====================
CREATE TABLE notification_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL DEFAULT 'PasswordReset',
    token VARCHAR(512) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    used_at TIMESTAMPTZ
);

CREATE INDEX ix_notification_requests_token ON notification_requests (token);
CREATE INDEX ix_notification_requests_user_id ON notification_requests (user_id);

-- ==================== IN_APP_NOTIFICATIONS ====================
CREATE TABLE in_app_notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(100) NOT NULL,
    title VARCHAR(500) NOT NULL,
    body TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    related_id VARCHAR(255),
    action_route VARCHAR(255)
);

CREATE INDEX ix_in_app_notifications_user_id ON in_app_notifications (user_id);
CREATE INDEX ix_in_app_notifications_created_at ON in_app_notifications (created_at DESC);

-- ==================== SUBSCRIPTION_PLANS ====================
CREATE TABLE subscription_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    product_id VARCHAR(255) NOT NULL,
    apple_product_id VARCHAR(255),
    google_product_id VARCHAR(255),
    duration VARCHAR(20) NOT NULL DEFAULT 'monthly',
    price DECIMAL(18, 4) NOT NULL,
    currency VARCHAR(10) NOT NULL DEFAULT 'EUR',
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- ==================== USER_SUBSCRIPTIONS ====================
CREATE TABLE user_subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    platform VARCHAR(20) NOT NULL,
    product_id VARCHAR(255) NOT NULL,
    purchase_token VARCHAR(1024) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    expires_at TIMESTAMPTZ NOT NULL,
    cancelled_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    receipt_data TEXT,
    order_id VARCHAR(255)
);

CREATE INDEX ix_user_subscriptions_user_id ON user_subscriptions (user_id);
CREATE INDEX ix_user_subscriptions_expires_at ON user_subscriptions (expires_at);

-- ==================== UNLOCKED_ACHIEVEMENTS ====================
CREATE TABLE unlocked_achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_key VARCHAR(100) NOT NULL,
    unlocked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, achievement_key)
);

CREATE INDEX ix_unlocked_achievements_user_id ON unlocked_achievements (user_id);

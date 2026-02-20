-- Allow multiple budgets per (user, wallet). Add is_main for dashboard display.
-- Free users: 1 budget. Premium: unlimited (enforced in app).

-- Drop unique (user_id, wallet_id) - PostgreSQL default name
ALTER TABLE wallet_budgets
    DROP CONSTRAINT IF EXISTS wallet_budgets_user_id_wallet_id_key;

ALTER TABLE wallet_budgets
    ADD COLUMN IF NOT EXISTS is_main BOOLEAN NOT NULL DEFAULT FALSE;

-- Ensure at most one is_main per user
CREATE UNIQUE INDEX IF NOT EXISTS ix_wallet_budgets_user_main
    ON wallet_budgets (user_id)
    WHERE is_main = TRUE;

-- Set first budget per user as main (for existing data before migration)
WITH ranked AS (
  SELECT id, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at) AS rn
  FROM wallet_budgets
)
UPDATE wallet_budgets
SET is_main = TRUE
WHERE id IN (SELECT id FROM ranked WHERE rn = 1);

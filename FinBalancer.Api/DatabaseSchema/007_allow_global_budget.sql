-- Allow global budget: wallet_id = 00000000-0000-0000-0000-000000000000 means "all wallets"
-- The FK constraint blocks this because that UUID does not exist in wallets.
-- We drop the FK so global budget can be stored. Referential integrity for real wallet IDs
-- is enforced by the application.

ALTER TABLE wallet_budgets
    DROP CONSTRAINT IF EXISTS wallet_budgets_wallet_id_fkey;

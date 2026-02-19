-- Access tokeni za Bearer auth (perzistencija preko restartova API-ja)
-- Pokretanje: psql -U app -d finbalancer -f 005_add_access_tokens.sql

CREATE TABLE IF NOT EXISTS access_tokens (
    token VARCHAR(512) PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ix_access_tokens_user_id ON access_tokens (user_id);
CREATE INDEX IF NOT EXISTS ix_access_tokens_expires_at ON access_tokens (expires_at);

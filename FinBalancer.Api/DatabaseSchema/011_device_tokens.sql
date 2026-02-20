-- Device tokens za push notifikacije (FCM).
-- Jedan korisnik može imati više uređaja.

CREATE TABLE IF NOT EXISTS device_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(512) NOT NULL,
    platform VARCHAR(20) NOT NULL DEFAULT 'android',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX ix_device_tokens_user_id ON device_tokens (user_id);
CREATE UNIQUE INDEX ix_device_tokens_user_token ON device_tokens (user_id, token);

COMMENT ON TABLE device_tokens IS 'FCM device tokens za slanje push notifikacija';

INSERT INTO schema_version (version, name, applied_at)
VALUES (11, '011_device_tokens', NOW())
ON CONFLICT (version) DO NOTHING;

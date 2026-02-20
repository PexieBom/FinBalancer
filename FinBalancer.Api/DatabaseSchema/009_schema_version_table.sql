-- Tablica za praćenje verzije sheme / primijenjenih migracija.
-- Omogućuje provjeru trenutne verzije baze pri pokretanju API-ja.
-- Svaka sljedeća migracija treba dodati INSERT za svoj version.

CREATE TABLE IF NOT EXISTS schema_version (
    version INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE schema_version IS 'Pregled primijenjenih migracija sheme baze';

INSERT INTO schema_version (version, name, applied_at)
VALUES (9, '009_schema_version_table', NOW())
ON CONFLICT (version) DO NOTHING;

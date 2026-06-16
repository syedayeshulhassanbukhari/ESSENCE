-- Add owner_id to exchange_listings (safe, idempotent)
-- This will create the column and an index. Legacy rows are left NULL per project choice.

BEGIN;

-- Add the owner_id column if it does not exist
ALTER TABLE IF EXISTS exchange_listings
  ADD COLUMN IF NOT EXISTS owner_id text;

-- Create an index for faster lookups by owner_id
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind = 'i' AND c.relname = 'exchange_listings_owner_id_idx'
  ) THEN
    CREATE INDEX exchange_listings_owner_id_idx ON exchange_listings (owner_id);
  END IF;
END$$;

COMMIT;

-- Backfill: per decision, legacy rows will be left NULL so no update statement is run here.

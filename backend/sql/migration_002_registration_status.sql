-- Run once on existing databases (adds approval workflow for new signups).
-- Existing accounts are marked approved so logins keep working.

ALTER TABLE users ADD COLUMN IF NOT EXISTS registration_status TEXT;

UPDATE users
SET registration_status = 'approved'
WHERE registration_status IS NULL;

ALTER TABLE users ALTER COLUMN registration_status SET NOT NULL;
ALTER TABLE users ALTER COLUMN registration_status SET DEFAULT 'pending';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'users_registration_status_check'
  ) THEN
    ALTER TABLE users
      ADD CONSTRAINT users_registration_status_check
      CHECK (registration_status IN ('pending', 'approved', 'rejected'));
  END IF;
END $$;

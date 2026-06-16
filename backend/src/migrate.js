const db = require("./db");

/**
 * Idempotent guard so existing DBs get `registration_status` without manual SQL.
 * Matches backend/sql/migration_002_registration_status.sql
 */
async function ensureUserRegistrationSchema() {
  await db.query("ALTER TABLE users ADD COLUMN IF NOT EXISTS registration_status TEXT;");

  await db.query(`
    UPDATE users
    SET registration_status = 'approved'
    WHERE registration_status IS NULL
  `);

  await db.query("ALTER TABLE users ALTER COLUMN registration_status SET NOT NULL;");
  await db.query("ALTER TABLE users ALTER COLUMN registration_status SET DEFAULT 'pending';");

  await db.query(`
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
  `);
}

/**
 * Matches backend/sql/migration_003_missions.sql
 */
async function ensureMissionsTable() {
  await db.query(`
    CREATE TABLE IF NOT EXISTS missions (
      id BIGSERIAL PRIMARY KEY,
      owner_user_id BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
      name TEXT NOT NULL,
      description TEXT NOT NULL DEFAULT '',
      start_at TIMESTAMPTZ NOT NULL,
      end_at TIMESTAMPTZ NOT NULL,
      priority TEXT NOT NULL DEFAULT 'medium'
        CHECK (priority IN ('low', 'medium', 'high', 'critical')),
      status TEXT NOT NULL DEFAULT 'draft'
        CHECK (status IN ('draft', 'active', 'completed')),
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      CONSTRAINT missions_time_range CHECK (end_at >= start_at)
    );
  `);

  await db.query("CREATE INDEX IF NOT EXISTS idx_missions_owner_user_id ON missions (owner_user_id);");
  await db.query("CREATE INDEX IF NOT EXISTS idx_missions_status ON missions (status);");
}

module.exports = { ensureUserRegistrationSchema, ensureMissionsTable };

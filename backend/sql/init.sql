CREATE TABLE IF NOT EXISTS users (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  pilot_id TEXT,
  role TEXT NOT NULL DEFAULT 'pilot',
  registration_status TEXT NOT NULL DEFAULT 'pending'
    CHECK (registration_status IN ('pending', 'approved', 'rejected')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Seeded admin (password: admin) — always approved.
INSERT INTO users (name, email, password_hash, pilot_id, role, registration_status)
VALUES (
  'Admin Pilot',
  'admin@gmail.com',
  '$2b$10$lVTpxOJANnO7hN/43W/p3uKrdvm07DMMOtFTruS663AWLbIljZzZ2',
  'ADMIN-001',
  'admin',
  'approved'
)
ON CONFLICT (email) DO NOTHING;

-- Optional local test user: pending approval (password: test1234). Remove or change in production.
INSERT INTO users (name, email, password_hash, pilot_id, role, registration_status)
VALUES (
  'Demo Pending Pilot',
  'pending.pilot@local.test',
  '$2b$10$G0VFP.VhZEpbFUlRlsBLw.vmk4s6QcGXWuA/wB4OFatIrgrZg0sFy',
  'PENDING-001',
  'pilot',
  'pending'
)
ON CONFLICT (email) DO NOTHING;

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

CREATE INDEX IF NOT EXISTS idx_missions_owner_user_id ON missions (owner_user_id);
CREATE INDEX IF NOT EXISTS idx_missions_status ON missions (status);

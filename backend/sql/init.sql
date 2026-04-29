CREATE TABLE IF NOT EXISTS users (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  pilot_id TEXT,
  role TEXT NOT NULL DEFAULT 'pilot',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO users (name, email, password_hash, pilot_id, role)
VALUES (
  'Admin Pilot',
  'admin@gmail.com',
  '$2b$10$lVTpxOJANnO7hN/43W/p3uKrdvm07DMMOtFTruS663AWLbIljZzZ2',
  'ADMIN-001',
  'admin'
)
ON CONFLICT (email) DO NOTHING;

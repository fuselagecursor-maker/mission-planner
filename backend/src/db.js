const { Pool } = require("pg");

/**
 * Railway public proxy (rlwy.net) needs TLS.
 * Private network URLs (*.railway.internal) must not use SSL — enabling it breaks the pool.
 */
function sslOption() {
  if (process.env.DB_SSL === "false") return false;
  if (process.env.DB_SSL === "true") return { rejectUnauthorized: false };

  const url = typeof process.env.DATABASE_URL === "string" ? process.env.DATABASE_URL : "";
  if (/rlwy\.net/i.test(url)) {
    return { rejectUnauthorized: false };
  }
  if (/railway\.internal|localhost|127\.0\.0\.1/i.test(url)) {
    return false;
  }

  const host = process.env.DB_HOST || "";
  if (host.includes("rlwy.net")) {
    return { rejectUnauthorized: false };
  }
  if (host.includes("railway.internal") || host === "localhost" || host === "127.0.0.1") {
    return false;
  }

  return false;
}

const pool =
  process.env.DATABASE_URL ?
    new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl: sslOption(),
    })
  : new Pool({
      host: process.env.DB_HOST || "localhost",
      port: Number(process.env.DB_PORT || 5432),
      database: process.env.DB_NAME || "mission_planner",
      user: process.env.DB_USER || "postgres",
      password: process.env.DB_PASSWORD || "",
      ssl: sslOption(),
    });

async function query(text, params) {
  return pool.query(text, params);
}

module.exports = {
  pool,
  query,
};

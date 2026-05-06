const { Pool } = require("pg");

/** Railway/public Postgres often requires TLS; localhost does not. */
function sslOption() {
  if (process.env.DB_SSL === "false") return false;
  if (process.env.DB_SSL === "true") return { rejectUnauthorized: false };
  const host = process.env.DB_HOST || "";
  const fromUrl =
    typeof process.env.DATABASE_URL === "string" && /railway/i.test(process.env.DATABASE_URL);
  if (host.includes("rlwy.net") || fromUrl) {
    return { rejectUnauthorized: false };
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

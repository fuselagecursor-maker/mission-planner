const { Pool } = require("pg");

/**
 * Railway usually injects `DATABASE_URL` when services are linked. It also exposes
 * `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, `PGPASSWORD`. If `DATABASE_URL` is
 * missing at runtime, we must fall back to PG* — otherwise we default to localhost
 * and get ECONNREFUSED.
 */
function resolvedDatabaseUrl() {
  const candidates = [
    process.env.DATABASE_URL,
    process.env.POSTGRES_URL,
    process.env.DATABASE_PRIVATE_URL,
  ];
  for (const c of candidates) {
    if (typeof c === "string" && c.trim().length > 0) return c.trim();
  }
  return "";
}

function discretePgConfig() {
  const host = process.env.DB_HOST || process.env.PGHOST || "localhost";
  const port = Number(process.env.DB_PORT || process.env.PGPORT || 5432);
  const database = process.env.DB_NAME || process.env.PGDATABASE || "postgres";
  const user = process.env.DB_USER || process.env.PGUSER || "postgres";
  const password = process.env.DB_PASSWORD || process.env.PGPASSWORD || "";
  return { host, port, database, user, password };
}

/**
 * Public proxy (rlwy.net) needs TLS. Private *.railway.internal / localhost must not.
 */
function sslConfigForHostOrUrl(text) {
  if (process.env.DB_SSL === "false") return false;
  if (process.env.DB_SSL === "true") return { rejectUnauthorized: false };
  if (!text) return false;
  if (/rlwy\.net/i.test(text)) return { rejectUnauthorized: false };
  if (/railway\.internal|localhost|127\.0\.0\.1/i.test(text)) return false;
  return false;
}

const dbUrl = resolvedDatabaseUrl();

const pool = dbUrl
  ? new Pool({
      connectionString: dbUrl,
      ssl: sslConfigForHostOrUrl(dbUrl),
    })
  : (() => {
      const d = discretePgConfig();
      return new Pool({
        host: d.host,
        port: d.port,
        database: d.database,
        user: d.user,
        password: d.password,
        ssl: sslConfigForHostOrUrl(d.host),
      });
    })();

async function query(text, params) {
  return pool.query(text, params);
}

module.exports = {
  pool,
  query,
};

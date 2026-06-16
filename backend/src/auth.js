const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const db = require("./db");

const router = express.Router();

function jwtSecret() {
  return process.env.JWT_SECRET || "dev_jwt_secret_change_me";
}

function signToken(user) {
  const secret = jwtSecret();
  return jwt.sign(
    {
      sub: user.id,
      email: user.email,
      role: user.role,
    },
    secret,
    { expiresIn: process.env.JWT_EXPIRES_IN || "12h" }
  );
}

function authMiddleware(req, res, next) {
  const header = req.headers.authorization || "";
  const match = /^Bearer\s+(.+)$/i.exec(header);
  if (!match) {
    return res.status(401).json({ message: "missing or invalid authorization header" });
  }
  try {
    const payload = jwt.verify(match[1], jwtSecret());
    req.auth = payload;
    return next();
  } catch {
    return res.status(401).json({ message: "invalid or expired token" });
  }
}

function requireAdmin(req, res, next) {
  if (req.auth && req.auth.role === "admin") {
    return next();
  }
  return res.status(403).json({ message: "admin only" });
}

router.post("/register", async (req, res) => {
  try {
    const { name, email, password, pilotId } = req.body || {};
    if (!name || !email || !password) {
      return res.status(400).json({ message: "name, email and password are required" });
    }
    if (String(password).length < 4) {
      return res.status(400).json({ message: "password must be at least 4 characters" });
    }

    const normalizedEmail = String(email).trim().toLowerCase();
    const existing = await db.query("SELECT id, registration_status FROM users WHERE email = $1", [normalizedEmail]);
    if (existing.rowCount > 0) {
      const row = existing.rows[0];
      if (row.registration_status === "rejected") {
        return res.status(409).json({
          message:
            "this email was rejected. contact an administrator if you need another review.",
        });
      }
      return res.status(409).json({ message: "email already registered" });
    }

    const hash = await bcrypt.hash(String(password), 10);
    const inserted = await db.query(
      `
      INSERT INTO users (name, email, password_hash, pilot_id, role, registration_status)
      VALUES ($1, $2, $3, $4, 'pilot', 'pending')
      RETURNING id, name, email, pilot_id, role, registration_status, created_at
      `,
      [String(name).trim(), normalizedEmail, hash, pilotId ? String(pilotId).trim() : null]
    );

    const user = inserted.rows[0];
    return res.status(201).json({
      message: "Registration submitted. An admin must approve your account before you can sign in.",
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        pilot_id: user.pilot_id,
        role: user.role,
        registration_status: user.registration_status,
        created_at: user.created_at,
      },
    });
  } catch (error) {
    return res.status(500).json({ message: "registration failed", detail: error.message });
  }
});

router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body || {};
    if (!email || !password) {
      return res.status(400).json({ message: "email and password are required" });
    }

    const normalizedEmail = String(email).trim().toLowerCase();
    const result = await db.query(
      `SELECT id, name, email, password_hash, pilot_id, role, registration_status
       FROM users WHERE email = $1`,
      [normalizedEmail]
    );

    if (result.rowCount === 0) {
      return res.status(401).json({ message: "invalid credentials" });
    }

    const user = result.rows[0];
    const ok = await bcrypt.compare(String(password), user.password_hash);
    if (!ok) {
      return res.status(401).json({ message: "invalid credentials" });
    }

    if (user.role !== "admin" && user.registration_status === "pending") {
      return res.status(403).json({
        message: "account pending approval. wait for an administrator to approve your registration.",
      });
    }
    if (user.role !== "admin" && user.registration_status === "rejected") {
      return res.status(403).json({
        message: "registration was rejected. contact an administrator if this is a mistake.",
      });
    }

    const token = signToken(user);
    return res.status(200).json({
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        pilot_id: user.pilot_id,
        role: user.role,
        registration_status: user.registration_status,
      },
    });
  } catch (error) {
    return res.status(500).json({ message: "login failed", detail: error.message });
  }
});

router.get("/admin/pending-registrations", authMiddleware, requireAdmin, async (_req, res) => {
  try {
    const r = await db.query(
      `
      SELECT id, name, email, pilot_id, created_at
      FROM users
      WHERE registration_status = 'pending' AND role = 'pilot'
      ORDER BY created_at ASC
      `
    );
    return res.status(200).json({ pending: r.rows });
  } catch (error) {
    return res.status(500).json({ message: "failed to list pending registrations", detail: error.message });
  }
});

router.post("/admin/pending-registrations/:userId/approve", authMiddleware, requireAdmin, async (req, res) => {
  try {
    const raw = req.params.userId;
    const userId = Number.parseInt(String(raw), 10);
    if (!Number.isFinite(userId)) {
      return res.status(400).json({ message: "invalid user id" });
    }

    const updated = await db.query(
      `
      UPDATE users
      SET registration_status = 'approved'
      WHERE id = $1 AND registration_status = 'pending' AND role = 'pilot'
      RETURNING id, name, email, pilot_id, role, registration_status
      `,
      [userId]
    );

    if (updated.rowCount === 0) {
      return res.status(404).json({ message: "pending pilot not found or already processed" });
    }

    return res.status(200).json({ user: updated.rows[0] });
  } catch (error) {
    return res.status(500).json({ message: "approval failed", detail: error.message });
  }
});

router.post("/admin/pending-registrations/:userId/reject", authMiddleware, requireAdmin, async (req, res) => {
  try {
    const raw = req.params.userId;
    const userId = Number.parseInt(String(raw), 10);
    if (!Number.isFinite(userId)) {
      return res.status(400).json({ message: "invalid user id" });
    }

    const updated = await db.query(
      `
      UPDATE users
      SET registration_status = 'rejected'
      WHERE id = $1 AND registration_status = 'pending' AND role = 'pilot'
      RETURNING id, name, email, pilot_id, role, registration_status
      `,
      [userId]
    );

    if (updated.rowCount === 0) {
      return res.status(404).json({ message: "pending pilot not found or already processed" });
    }

    return res.status(200).json({ user: updated.rows[0] });
  } catch (error) {
    return res.status(500).json({ message: "reject failed", detail: error.message });
  }
});

module.exports = router;

const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const db = require("./db");

const router = express.Router();

function signToken(user) {
  const secret = process.env.JWT_SECRET || "dev_jwt_secret_change_me";
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
    const existing = await db.query("SELECT id FROM users WHERE email = $1", [normalizedEmail]);
    if (existing.rowCount > 0) {
      return res.status(409).json({ message: "email already registered" });
    }

    const hash = await bcrypt.hash(String(password), 10);
    const inserted = await db.query(
      `
      INSERT INTO users (name, email, password_hash, pilot_id, role)
      VALUES ($1, $2, $3, $4, 'pilot')
      RETURNING id, name, email, pilot_id, role
      `,
      [String(name).trim(), normalizedEmail, hash, pilotId ? String(pilotId).trim() : null]
    );

    const user = inserted.rows[0];
    const token = signToken(user);
    return res.status(201).json({ token, user });
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
      "SELECT id, name, email, password_hash, pilot_id, role FROM users WHERE email = $1",
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

    const token = signToken(user);
    return res.status(200).json({
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        pilot_id: user.pilot_id,
        role: user.role,
      },
    });
  } catch (error) {
    return res.status(500).json({ message: "login failed", detail: error.message });
  }
});

module.exports = router;

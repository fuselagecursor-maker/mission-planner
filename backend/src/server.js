const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");

dotenv.config();
const db = require("./db");
const authRoutes = require("./auth");

const app = express();
const port = Number(process.env.PORT || 4000);

app.use(
  cors({
    origin: process.env.CORS_ORIGIN || "*",
  })
);
app.use(express.json());

app.get("/health", async (_req, res) => {
  try {
    await db.query("SELECT 1");
    res.status(200).json({ status: "ok", db: "up" });
  } catch (error) {
    res.status(500).json({ status: "error", db: "down", detail: error.message });
  }
});

app.use("/auth", authRoutes);

app.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log(`Auth backend running on http://localhost:${port}`);
});

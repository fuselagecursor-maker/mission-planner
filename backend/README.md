# Mission Planner Auth Backend (Node + PostgreSQL)

Production-friendly stack choice used here:
- Backend: Node.js + Express
- Database: PostgreSQL
- Auth: JWT + bcrypt password hashes

## 1) Setup

1. Create database:
   - `mission_planner`
2. Copy env:
   - `.env.example` -> `.env`
3. Run SQL:
   - execute `sql/init.sql` on your PostgreSQL database

## 2) Install / Run

```bash
npm install
npm run start
```

Server runs at `http://localhost:4000`.

## 3) Endpoints

- `GET /health`
- `POST /auth/register`
  - body: `{ "name": "...", "email": "...", "password": "...", "pilotId": "..." }`
- `POST /auth/login`
  - body: `{ "email": "...", "password": "..." }`

## Default Admin Credentials

- Email: `admin@gmail.com`
- Password: `admin`

## Production Notes

- Set a strong `JWT_SECRET`.
- Restrict `CORS_ORIGIN` to your domain(s).
- Enforce HTTPS.
- Add refresh tokens and token revocation before release.

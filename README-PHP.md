# Village NetAcad — PHP API + SQLite

The live backend is **`backend-php/`** (PHP 8.1+ and SQLite). The React app in **`frontend/`** talks to `/api/*` on the same host.

The old Node backend in **`backend/`** is deprecated.

## Database

| Item | Location |
|------|----------|
| SQLite file | `backend-php/database.sqlite` |
| Uploads | `backend-php/uploads/` |
| Config | `backend-php/.env` → `DATABASE_PATH`, `UPLOADS_DIR` |

View tables from terminal:

```powershell
cd backend-php
php scripts/peek-db.php
```

Or open `database.sqlite` in [DB Browser for SQLite](https://sqlitebrowser.org/).

## Local dev

**Terminal 1 — API (PHP):**

```powershell
npm run dev:backend
# or: cd backend-php && php -S localhost:5000 -t public public/index.php
```

**Terminal 2 — React:**

```powershell
npm run dev:frontend
# http://localhost:5173  (proxies /api → :5000)
```

## Migrate / seed

```powershell
npm run migrate
# runs: php backend-php/database/migrate.php
```

Default admin: `admin@villagenetacad.com` / `Admin123!`

## Production (Afrihost)

See [deploy/AFRIHOST.md](deploy/AFRIHOST.md) — document root = `backend-php/public/`.

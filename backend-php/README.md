# Village NetAcad — PHP API

Pure PHP replacement for the Node/Express backend. Same `/api/*` routes and JSON responses for the React frontend. No Composer required (Afrihost shared hosting friendly).

## Requirements

- PHP 8.1+ with extensions: `pdo_sqlite`, `json`, `mbstring` (recommended: `curl` for PayFast ITN validation)
- SQLite3

## Setup

```bash
cd backend-php
cp .env.example .env
# Edit .env (JWT_SECRET, PayFast, SMTP, etc.)

php database/migrate.php
```

Default admin after migrate: `admin@villagenetacad.com` / `Admin123!`

## Local development

From `backend-php/`:

```bash
php -S localhost:5000 -t public public/index.php
```

- API: http://localhost:5000/api/...
- Health: http://localhost:5000/health
- Uploads: http://localhost:5000/uploads/...

Point the React app `VITE_API_URL` (or proxy) at `http://localhost:5000`.

## Afrihost / Apache

1. Upload the `backend-php` folder to your hosting account.
2. Set the **document root** to `backend-php/public/` (not the project root).
3. Ensure `.htaccess` is enabled (`mod_rewrite`).
4. Set `DATABASE_PATH` and `UPLOADS_DIR` to writable paths outside `public/` if possible.
5. Run migration once via SSH: `php database/migrate.php`
6. Copy `.env.example` to `.env` and configure production values from `deploy/env.production.template`.

## Environment

| Variable | Description |
|----------|-------------|
| `DATABASE_PATH` | SQLite file path (default: `database.sqlite` in project root) |
| `UPLOADS_DIR` | Product image uploads directory |
| `JWT_SECRET` | Bearer token signing secret |
| `CLIENT_URL` | Frontend URL(s) for CORS and email links |
| `API_URL` | Public API base URL (PayFast notify fallback) |
| `PAYFAST_*` | PayFast merchant credentials and notify URL |

Password hashes from the Node backend (`bcryptjs`) work with PHP `password_verify`.

## Structure

```
backend-php/
  public/index.php      # Front controller, CORS, uploads, routing
  public/.htaccess      # Rewrite to index.php
  bootstrap.php
  lib/                  # Env, Database, Jwt, Auth, Payfast, Mailer, ...
  controllers/          # Route handlers
  routes/Router.php     # All API endpoints
  database/migrate.php
```

## Notes

- PDF admin reports return plain-text `.txt` downloads (no PDF library on shared hosting).
- Email uses PHP `mail()` when SMTP is not configured (logged to error log).
- PayFast `merchant_key` is included in payment form payloads per PayFast custom integration docs.

# Village NetAcad — PHP API (Afrihost)

PHP 8.1+ API for **Afrihost cPanel** shared hosting. Same `/api/*` JSON API for the React frontend. No Composer, no Node.js, no background process.

## Requirements

- PHP 8.1+ with `pdo_sqlite`, `json`, `mbstring`, `curl`, `fileinfo`
- SQLite3

## Setup

```bash
cp .env.example .env
php database/migrate.php
```

Default admin: `admin@villagenetacad.com` / `Admin123!`

## Local development

From project root:

```powershell
npm run dev:backend
```

Or:

```bash
php -S localhost:5000 -t public public/index.php
```

- API: http://localhost:5000/api/...
- Health: http://localhost:5000/health

## Afrihost / cPanel

1. Document root → **`backend-php/public/`**
2. `mod_rewrite` enabled (`.htaccess` in `public/`)
3. Copy `deploy/env.production.template` → `.env` with writable `DATABASE_PATH` / `UPLOADS_DIR` outside `public/`
4. Run `php database/migrate.php` once (SSH) or upload an existing `database.sqlite`

See [../deploy/AFRIHOST.md](../deploy/AFRIHOST.md) or [../deploy/azure/AZURE.md](../deploy/azure/AZURE.md) for Azure App Service.

## Environment

| Variable | Description |
|----------|-------------|
| `DATABASE_PATH` | SQLite file (keep outside `public/` in production) |
| `UPLOADS_DIR` | Product images |
| `JWT_SECRET` | Bearer token signing (32+ chars in production) |
| `CLIENT_URL` | Site URL for CORS and emails |
| `API_URL` | Public API base URL |
| `PAYFAST_*` | PayFast credentials and notify URL |

## Notes

- Admin PDF reports download as plain text on shared hosting (no PDF library).
- Email: configure SMTP in `.env`, or PHP `mail()` fallback.

# Village NetAcad

Community networking academy. The repo holds two runnable services side-by-side
plus the shared Supabase database schema.

```
.
├── frontend/      # TanStack Start + React + Vite + Tailwind  (the website)
├── backend/       # FastAPI + Supabase Python client            (the API)
├── supabase/      # Database migrations + seed data             (shared)
├── .env           # Shared credentials, read by both services
└── .env.example   # Documented variables — copy to .env to start
```

Both services share one `.env` at the project root:

- `frontend/vite.config.ts` sets `envDir: ".."` so Vite picks up the root `.env`.
- `backend/app/config.py` resolves the env file path to `<repo-root>/.env`.

## First-time setup

1. **Configure environment**
   ```powershell
   copy .env.example .env
   # then fill in SUPABASE_URL, VITE_SUPABASE_URL, etc.
   ```

2. **Apply the database schema**
   In the Supabase SQL editor, paste and run `supabase/setup_all.sql` (idempotent).

3. **Install frontend dependencies**
   ```powershell
   cd frontend
   npm install
   ```

4. **Install backend dependencies (creates `backend/.venv`)**
   ```powershell
   cd backend
   .\guard.ps1
   ```

## Day-to-day

Run each service in its own terminal:

```powershell
# terminal 1 — website
cd frontend
npm run dev                          # http://localhost:8080

# terminal 2 — API
cd backend
.\.venv\Scripts\uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
```

## What lives where

### `frontend/`
TanStack Start app. Key folders:

- `src/routes/` — file-based pages (`/`, `/login`, `/register`, `/admin/*`, `/back-office`, etc.)
- `src/components/` — UI components incl. `admin-shell`, `theme-provider`, `site-header`
- `src/hooks/` — `use-auth`, `use-cart`, `use-idle-timeout`
- `src/integrations/supabase/` — generated Supabase client + types
- `src/lib/` — small helpers (formatting, activity-log)

### `backend/`
FastAPI app that proxies admin-side concerns through Supabase with proper RLS.

- `app/main.py` — FastAPI factory, CORS, error handlers
- `app/routers/` — `products`, `categories`, `orders`, `cart`, `notifications`
- `app/config.py` — pydantic-settings, reads `../.env`
- `app/supabase_client.py` — anon and service-role Supabase clients
- `app/notifications.py` — Resend (email) + Twilio (WhatsApp) helpers
- `requirements.txt`, `guard.ps1` — install + bootstrap script

### `supabase/`
- `migrations/` — every SQL change made over the lifetime of the project
- `setup_all.sql` — one consolidated, idempotent script that applies them all
- `seed/` — optional test users and demo data

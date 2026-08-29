# Phase 7 — Dual SMTP (mobile app@ vs website)

**Do NOT create a second `.envMail` file.** One `.env`, two profiles.

Shared API: `public_html/backend-php/`  
Mobile Flutter sends `X-VNA-Client: mobile` (+ `client: mobile` on register).

| Profile | `.env` keys | Who |
|---------|-------------|-----|
| **App** | `APP_SMTP_*` | Your `app@villagenetacad.co.za` — mobile only |
| **Web** | `SMTP_*` | Website team — leave empty until they fill |

## What sends when

| Event | Website call | Mobile app call |
|-------|--------------|-----------------|
| Register welcome | **no** app@ mail | welcome from `app@` |
| Reseller ops notify | skipped (their mail later) | from `app@` to `SITE_EMAIL` |
| Forgot password | uses `SMTP_*` if set (else silent) | uses `APP_SMTP_*` |
| PayFast ITN / paid-order ops | forced `channel=app` → `app@` | same |
| Other Mailer sends | `SMTP_*` (web channel) | `APP_SMTP_*` |

Website browser calls never fall back to `app@`. System hooks (ITN) pass `channel => app` explicitly.

## Live `.env` change (important)

Move `app@` off `SMTP_*` onto `APP_SMTP_*` so website register cannot use it:

```env
SITE_EMAIL=info@villagenetacad.co.za

# Website — empty until website team configures THEIR mailbox
SMTP_HOST=
SMTP_PORT=465
SMTP_USER=
SMTP_PASS=
SMTP_FROM=Village NetAcad

# Mobile app
APP_SMTP_HOST=villagenetacad.co.za
APP_SMTP_PORT=465
APP_SMTP_USER=app@villagenetacad.co.za
APP_SMTP_PASS=YOUR_APP_MAILBOX_PASSWORD
APP_SMTP_FROM=Village NetAcad
```

(Legacy: if `APP_SMTP_*` empty but `SMTP_USER=app@…`, Mailer still treats that as app-only and will **not** use it for website channel.)

## Upload these files

| Local | Live |
|-------|------|
| `Mailer.php` | `public_html/backend-php/lib/Mailer.php` |
| `Request.php` | `public_html/backend-php/lib/Request.php` |
| `AuthController.php` | `public_html/backend-php/controllers/AuthController.php` |
| `index.php` | `public_html/backend-php/public/index.php` (CORS allows `X-VNA-Client`) |

## UAT

1. **Website** register → should **NOT** get welcome from `app@`
2. **App** register (live API) → welcome from `app@`
3. App dialog mentions welcome mail

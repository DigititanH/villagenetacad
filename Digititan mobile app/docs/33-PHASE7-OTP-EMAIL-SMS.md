# Phase 7 — OTP / email / SMS (status)

Branch: `cursor/phase7-smtp-cpanel-09ad` (SMTP resume)  
Earlier park notes were on `cursor/phase7-otp-security-09ad`.

## Current status

| Item | Status |
|------|--------|
| Google Sign-In in app | **Removed** (website has none) |
| Real SMTP Mailer | **This branch** — deploy to **`public_html/backend-php/`** |
| Live “OTP” | Website uses **email verify link** (not 6-digit OTP). SMTP unblocks that mail. |
| SMS OTP | Parked (provider TBD) |
| Lawyer POPI / legal | Parked |
| T&Cs before pay | Parked |
| In-app PayFast | Deferred (v1 = website browser) |

## Critical path lesson
Live API is **`/home/villagenetacad/public_html/backend-php/`**  
(health `uploads_dir`). Edits under `village-netacad/backend-php/` do **not** affect production mail.

## Deploy pack
See `deploy/phase7-smtp-live/README.md`:

1. Upload `Mailer.php` → `public_html/backend-php/lib/`
2. Set `.env` SMTP_* to a **cPanel mailbox** (`localhost` / `mail.villagenetacad.co.za`)
3. Optional `smtp-ping.php` smoke test → **delete after**
4. Register → check verify-email arrives

## Why not Gmail first?
Afrihost often blocks outbound `smtp.gmail.com`. Prefer hosting mailbox SMTP.

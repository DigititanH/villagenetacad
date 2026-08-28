# Phase 7 — OTP / email / SMS (status)

Branch: `cursor/phase7-smtp-app-uat-09ad`

## Decision: one `.env`, two SMTP profiles (no `.envMail`)

| Profile | Keys | Mailbox |
|---------|------|---------|
| Mobile app | `APP_SMTP_*` | `app@villagenetacad.co.za` |
| Website | `SMTP_*` | Website team configures later |

Flutter sends `X-VNA-Client: mobile`. Welcome / app mails only when that client is detected.

Pack: `deploy/phase7-dual-smtp-live/`

## Status

| Item | Status |
|------|--------|
| Google Sign-In | Removed |
| cPanel `app@` SMTP ping | **PASS** |
| Welcome mail (no verify link) | Mobile-only |
| Dual SMTP split | Implement + upload |
| SMS OTP | Parked |
| POPI / T&Cs before pay | Parked |

## App UAT

| # | Step | Pass? |
|---|------|-------|
| S1–S5 | Register + inbox + sign-in | **PASS** |
| M1 | Website register → **no** `app@` welcome | |
| M2 | App register → welcome from `app@` | |
| M3 | `.env` uses `APP_SMTP_*` for app@ | |

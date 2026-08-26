# Phase 7 — OTP / email / SMS (status)

Branch: `cursor/phase7-otp-security-09ad`  
Base: Phase 6.

## Current status

| Item | Status |
|------|--------|
| Google Sign-In in app | **Removed** (website has none) |
| Gmail SMTP / App Password live mail | **On hold** — host/Gmail path not finished; Mailer reverted to previous `mail()` version |
| SMS OTP | Parked (provider TBD) |
| Lawyer POPI / legal | Parked |
| T&Cs before pay | Parked |
| In-app PayFast | Deferred (v1 = website browser) |

## Gmail SMTP — parked notes (for later)

When we resume:

1. Prefer **cPanel mailbox** SMTP (`localhost` / `mail.villagenetacad.co.za`) if Afrihost blocks `smtp.gmail.com`.
2. Or finish Gmail App Password + real SMTP `Mailer` + deploy to  
   `/public_html/village-netacad/backend-php/lib/Mailer.php`.
3. Do **not** leave `public/smtp-test.php` on production.

Until then: leave `SMTP_*` in `.env` as-is or empty; app/website auth stays email+password without relying on inbox OTP mail.

## Done in this branch so far

- App login matches website (no Google button).
- Docs updated; Gmail live send reverted / on hold.

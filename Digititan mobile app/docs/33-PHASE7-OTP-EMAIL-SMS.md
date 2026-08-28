# Phase 7 — OTP / email / SMS (status)

Branch: `cursor/phase7-smtp-app-uat-09ad`  
Related: `cursor/phase7-smtp-cpanel-09ad` (SMTP Mailer pack)

## Current status

| Item | Status |
|------|--------|
| Google Sign-In in app | **Removed** (website has none) |
| cPanel mailbox SMTP (`app@villagenetacad.co.za`) | **LIVE** — ping UAT passed 28 Aug 2026 |
| Register email | **Welcome message** (no verify link) — upload `deploy/phase7-welcome-mail-live/` |
| In-app OTP code screen | Dummy / offline only |
| SMS OTP | Parked (provider TBD) |
| Lawyer POPI / legal | Parked |
| T&Cs before pay | Parked |
| In-app PayFast | Deferred (v1 = website browser) |

## Live SMTP (passed)

```env
SITE_EMAIL=info@villagenetacad.co.za
SMTP_HOST=villagenetacad.co.za
SMTP_PORT=465
SMTP_USER=app@villagenetacad.co.za
SMTP_PASS=<mailbox password>
SMTP_FROM=Village NetAcad
```

## App UAT — register → mail

| # | Step | Pass? |
|---|------|-------|
| S1 | Login screen loads (no Google) | **PASS** |
| S2 | Register → customer with a new email | **PASS** |
| S3 | Account created dialog | **PASS** |
| S4 | Inbox mail from `app@` | **PASS** (verify-link version) |
| S5 | Sign in works | **PASS** |

### Welcome-mail re-check (after upload)
| # | Step | Pass? |
|---|------|-------|
| W1 | Register new customer | |
| W2 | Inbox subject **Welcome to Village NetAcad** — no confirm link | |
| W3 | App dialog says welcome mail (not verify link) | |

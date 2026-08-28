# Phase 7 — OTP / email / SMS (status)

Branch: `cursor/phase7-smtp-app-uat-09ad` (live mailbox + Mailer UAT)  
Related: `cursor/phase7-smtp-cpanel-09ad` (SMTP Mailer pack)

## Current status

| Item | Status |
|------|--------|
| Google Sign-In in app | **Removed** (website has none) |
| cPanel mailbox SMTP (`app@villagenetacad.co.za`) | **LIVE** — ping UAT passed 28 Aug 2026 |
| Live verify-email on register (`Mailer`) | Ready for app UAT |
| In-app OTP code screen | Dummy / offline only — live API uses **email link** (website parity) |
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

- Mailer: real SMTP AUTH (not PHP `mail()`) under `public_html/backend-php/lib/Mailer.php`
- Ping: `"ok": true` → `shichabonkuna22@gmail.com` (28 Aug 2026)
- **Delete** `public/smtp-ping.php` after testing

## App UAT — register → verify mail

```powershell
cd S:\WORK\VillageNetAcad
.\INSTALL-PHASE8-LEDGER.ps1
cd mobile
flutter run --no-dds --dart-define=API_BASE_URL=https://villagenetacad.co.za
```

| # | Step | Pass? |
|---|------|-------|
| S1 | Login screen loads (no Google) | |
| S2 | Register → customer with a **new** email you can open | |
| S3 | Dialog: **Account created** + check inbox for `app@` verify link | |
| S4 | Inbox has **Verify your Village NetAcad account** from `app@` | |
| S5 | Open link (website) → verified; sign in on app works | |

Dummy / no `API_BASE_URL`: Register still opens **OTP screen** (Email/SMS picker + demo code) — presentation only.

## Still parked

- Live SMS OTP provider
- Lawyer POPI
- T&Cs before pay

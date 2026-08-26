# Phase 8 — Reseller production (slice 1)

**Branch:** `cursor/phase8-reseller-production-09ad`  
**Base:** `cursor/phase7-otp-security-09ad`

## Goal of this slice
Live **buyer verify** + **server-enforced** withdraw rules (R100 + last calendar day). Wire the mobile app to the live reseller APIs for verify / profile / sales / withdraw.

## Done in repo

### Backend (`backend-php/`)
- `GET /api/resellers/verify/{code}` — public, no auth, no wallet/email secrets  
  Returns: `code`, `name`, `academy`, `status`, `approved`, `active`
- `POST /api/resellers/withdraw` — rejects amount ≤ 0, **&lt; R100**, and any day that is **not** the last calendar day (UTC via `gmdate`)

### Mobile
- `HttpResellerRepository` — profile, sales, commissions, withdraw, **verifyCode**
- Clients CRM still empty / throws (no live API yet)
- `injection.dart` uses `HttpResellerRepository` when `AppConfig.useLiveApi`
- Profile + checkout pass `resellerRepository` into `VerifyResellerScreen`

## Not in this slice (later Phase 8)
- Live `VNA-B-*` / `VNA-C-*` issuance (live codes are often `VNA-{hex}` today)
- Full **53 / 26 / 21** split accounting on the server
- Live clients CRM (bought / pending / confirmed)
- Full month-end statement from live ledger beyond profile + sales lists

## Production deploy (when ready)
Upload only the live tree under `public_html/village-netacad/backend-php/`:
- `controllers/ResellersController.php`
- `routes/Router.php`

Do **not** edit duplicate trees under `public_html/backend-php/` or root `public_html/.env`.

## App UAT (after deploy)
```
cd mobile
flutter pub get
flutter run --no-dds --dart-define=API_BASE_URL=https://villagenetacad.co.za
```

1. Profile → **Verify a reseller** → enter a real `referral_code` from Admin  
2. Expect name + approved/pending result (no secrets)  
3. Bad code → not found  
4. Reseller withdraw (last day of month only, ≥ R100) — server returns clear error otherwise  

## Laptop sync
Run `INSTALL-PHASE8.ps1` from `S:\WORK\VillageNetAcad`.

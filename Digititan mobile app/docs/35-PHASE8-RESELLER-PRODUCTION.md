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

## Not in slice 1 (moved to slice 2 — see `38-PHASE8-LEDGER-CLIENTS.md`)
- Live `VNA-B-*` / `VNA-C-*` issuance — **done on register UX branch**
- Full **53 / 26 / 21** split accounting on fulfill — **slice 2**
- Live clients CRM — **slice 2**
- Month-end statement API — **slice 2**

## Slice 2 branch
`cursor/phase8-ledger-clients-09ad` — deploy pack `deploy/phase8-ledger-clients-live/`

## Production deploy (when ready)

**Live API tree (confirmed via `/health` uploads_dir):**  
`public_html/backend-php/`  
(not `public_html/village-netacad/backend-php/` — that copy is a stale duplicate)

- **`controllers/ResellersController.php`** — safe to overwrite with Phase 8 file (adds `verify()` + R100/last-day withdraw gates).
- **`routes/Router.php`** — **do not overwrite wholesale**. Live Router has extra routes (CCNA, products admin, etc.) that are not in this repo zip.  
  **Only add** this line in the Resellers section:

```php
self::get('/api/resellers/verify/{code}', fn ($p) => ResellersController::verify($p));
```

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

### Slice 1 UAT status (26 Aug 2026) — **PASSED**
- Live verify: real code `VNA-2D23BA54` + fake code  
- App verify with live code  
- Withdraw locked (not last day)  
- Simulate month-end → R50 → min R100  
- Simulate month-end → R100 → last-calendar-day server gate  
- (Successful payout not required for slice 1 — needs commission balance later)

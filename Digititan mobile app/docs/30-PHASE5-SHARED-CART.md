# Phase 5 — Shared cart + website checkout

Branch: `cursor/phase5-shared-cart-09ad`  
Base: Phase 4 (`cursor/phase4-shared-accounts-09ad`).

## What shipped

| Item | Notes |
|------|--------|
| Live catalogue | `GET /api/products` when `API_BASE_URL` is set |
| Shared cart | `GET/POST/PUT/DELETE /api/cart` (same cart as website) |
| Checkout | Opens `…/cart` in the system browser for **PayFast on the website** |
| My orders | `GET /api/orders/my-orders` |
| Dummy path | Unchanged for decks (no `API_BASE_URL`) |

## Run (production)

```powershell
cd S:\WORK\VillageNetAcad\mobile
flutter run --no-dds --dart-define=API_BASE_URL=https://villagenetacad.co.za
```

## UAT checklist

1. Sign in with a real website account.
2. Store tab shows **live** products (not only demo bags).
3. Add an item → snackbar **Added to shared cart**.
4. Cart → **Complete on website (PayFast)** → browser opens `/cart`.
5. Sign in on the website with the **same** account if prompted; cart should match.
6. Pay (or leave pending) on the website.
7. App → Profile → **My orders** → order appears.

## Laptop sync

```powershell
cd S:\WORK\VillageNetAcad
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/DigititanH/villagenetacad/cursor/phase5-shared-cart-09ad/Digititan%20mobile%20app/INSTALL-PHASE5.ps1?v=1" -OutFile .\INSTALL-PHASE5.ps1 -Headers @{ "Cache-Control" = "no-cache" }
powershell -ExecutionPolicy Bypass -File .\INSTALL-PHASE5.ps1
```

## Out of scope (later)

- Full catalogue polish / wishlist / stock UX → **Phase 6**
- In-app PayFast → **Phase 7**

# Phase 6 — Store parity (live catalogue)

Branch: `cursor/phase6-store-parity-09ad`  
Base: Phase 5 (`cursor/phase5-shared-cart-09ad`).

## What shipped

| Item | Notes |
|------|--------|
| Product images | `Product.imageUrl` + `ProductImage` on Home / Store / Cart / detail |
| Stock | Stock count + out-of-stock on detail |
| Sizes / colours | Choice chips; passed into `POST /api/cart` |
| Wishlist | `GET /api/wishlist` + `POST /api/wishlist/toggle`; Profile → Wishlist |
| Order status | Pipeline UI: placed → paid → processing → shipped → delivered |
| Empty live catalogue | Still falls back to samples (production DB may have 0 products) |
| Login → checkout return | App “Complete on website” opens `/checkout`; login uses `?next=/checkout` |

## Run

```powershell
cd S:\WORK\VillageNetAcad\mobile
flutter run --no-dds --dart-define=API_BASE_URL=https://villagenetacad.co.za
```

## Laptop sync

```powershell
cd S:\WORK\VillageNetAcad
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/DigititanH/villagenetacad/cursor/phase6-store-parity-09ad/Digititan%20mobile%20app/INSTALL-PHASE6.ps1?v=1" -OutFile .\INSTALL-PHASE6.ps1 -Headers @{ "Cache-Control" = "no-cache" }
powershell -ExecutionPolicy Bypass -File .\INSTALL-PHASE6.ps1
```

## Done when

App catalogue matches the website store (images, variants, wishlist, real statuses) — **requires products in Admin**.

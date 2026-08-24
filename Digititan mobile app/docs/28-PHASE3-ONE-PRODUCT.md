# Phase 3 — One Village NetAcad product

Branch: `cursor/phase3-one-product-09ad`  
Base: Phase 2 story branch.

## Included

| Item | Where |
|------|--------|
| Store CTA → Village NetAcad shop | Store tab / product detail → `https://villagenetacad.co.za/shop` |
| Become a Reseller | Profile (customer) |
| Become an Ambassador | Profile (customer) |
| Demo role switch (decks) | Profile expansion; Ops/Reseller swap icon |
| Profile hat switch (approved) | Switch to Reseller dashboard / Ambassador view after Ops approval |
| Home equal pillars | Bottom nav keeps Training / Academies / Store equal (Home layout unchanged) |

## Laptop install

```powershell
cd S:\WORK\VillageNetAcad
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/DigititanH/villagenetacad/cursor/phase3-one-product-09ad/Digititan%20mobile%20app/INSTALL-PHASE3.ps1" -OutFile .\INSTALL-PHASE3.ps1
powershell -ExecutionPolicy Bypass -File .\INSTALL-PHASE3.ps1
cd mobile
flutter clean
flutter pub get
flutter run
```

## Demo

1. `customer@demo.com` / `demo123`
2. Home → three equal pillars
3. Store → **Open Village NetAcad shop**
4. Profile → Become a Reseller / Become an Ambassador
5. Profile → Demo role switch (optional for decks)

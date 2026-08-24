# Phase 2 — Finish the presentation story

Branch: `cursor/phase2-presentation-story-09ad`  
Dummy data is fine.

## Included

| Item | Where to try |
|------|----------------|
| Returns (7-day after delivery) | `customer@demo.com` → My orders → `ORD-DEMO-DELIVERED` → Request return |
| Review after delivered | Same order → Leave a review |
| Reseller QR + verify | Reseller dashboard QR; Profile → Verify reseller → `VNA-B-LERATO` |
| SMS + Email OTP | Register OTP / Payment OTP channel picker |
| LMS gender fields | Training interest / Academy register forms |
| Ambassador apply + verify + no-cash | Profile → Become / Verify ambassador |
| Academy performance rankings | Academies → leaderboard icon |
| Purchase T&Cs + Pinnacle warranty | Product detail |
| Simulated notifications | Profile → Notifications |

## Laptop install

```powershell
cd S:\WORK\VillageNetAcad
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/DigititanH/villagenetacad/cursor/phase2-presentation-story-09ad/Digititan%20mobile%20app/INSTALL-PHASE2.ps1" -OutFile .\INSTALL-PHASE2.ps1
powershell -ExecutionPolicy Bypass -File .\INSTALL-PHASE2.ps1
cd mobile
flutter clean
flutter pub get
flutter run
```

## Stakeholder walk (Done when)

Returns → Review → Verify reseller → OTP (SMS) → LMS interest → Ambassador → Academy league  
without explaining a gap.

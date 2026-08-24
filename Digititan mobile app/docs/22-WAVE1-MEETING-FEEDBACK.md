# Wave 1 — Meeting feedback 24 Aug 2026

**Status: Done** (install on laptop). Remaining work → `docs/25-PHASES-WAVE2-WAVE3.md`

| # | Item | Status |
|---|------|--------|
| 1 | Bigger login logo | Done — `DigititanBrandHeader(hero: true)` ~248px |
| 7 | Min withdraw R100 | Done — button disabled under R100 + clear error |
| 8 | Legal drafts (T&Cs, privacy, security, returns) | Done — Profile → Legal & privacy; POPI in Wave 3 |
| 6 | Academy/org register with Digititan (not Cisco-only) | Done — Academies → + → register form |
| 9 | App icon = Village NetAcad | Done — `flutter_launcher_icons` from programme mark |

## Remaining phases (do next, in order)

| Phase | What |
|-------|------|
| **Wave 2A** | Reseller QR + buyer verify + PHP API |
| **Wave 2B** | Email + SMS OTP |
| **Wave 2C** | LMS learner fields (name, gender, email) |
| **Wave 2D** | In-app PayFast (same as Digititan Store) |
| **Wave 3A–C** | Security → POPI lawyer copy → launch checklist |

Full detail: **`docs/25-PHASES-WAVE2-WAVE3.md`**

## Pull Wave 1 on laptop

```powershell
cd S:\WORK\VillageNetAcad
# use INSTALL-WAVE1.ps1 / INSTALL-WAVE1-WITHDRAW-MIN.ps1 from DigititanH branch
cd mobile
flutter pub get
flutter run
```

## Demo
1. Login — larger Village NetAcad logo  
2. Profile → Legal & privacy  
3. Academies → + → Register academy / org  
4. Reseller → Withdraw — under R100 blocked + red error  
5. Launcher — Village NetAcad icon  

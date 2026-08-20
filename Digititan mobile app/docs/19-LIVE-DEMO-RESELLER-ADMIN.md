# LIVE DEMO — Reseller / Ops Admin / Super Admin

Updated: 20 Aug 2026

Run this on your laptop from PowerShell, then click through the steps below.

## 0) Sync + run (from your prompt)

```powershell
cd "S:\WORK\Digititan mobile app"

# Pull the journey branch (if this folder is a git clone of villagenetacad)
git fetch origin
git checkout cursor/reseller-apply-client-pipeline-09ad
git pull origin cursor/reseller-apply-client-pipeline-09ad

cd mobile
flutter pub get
flutter run
```

If `git` is not set up on `S:\`, download the installer instead:

```powershell
cd "S:\WORK\Digititan mobile app"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/DigititanH/villagenetacad/cursor/reseller-apply-client-pipeline-09ad/Digititan%20mobile%20app/INSTALL-RESELLER-JOURNEY.ps1" -OutFile ".\INSTALL-RESELLER-JOURNEY.ps1"
powershell -ExecutionPolicy Bypass -File .\INSTALL-RESELLER-JOURNEY.ps1
cd mobile
flutter run
```

Use Chrome / Windows / Android emulator — any device Flutter lists is fine.

---

## Demo accounts (password always `demo123`)

| Button / email | Role |
|---|---|
| **Sign in as Reseller** → `reseller@demo.com` | Approved reseller (`VNA-B-LERATO`) |
| **Sign in as Ops Admin** → `ops@demo.com` | Day-to-day admin (no Payouts) |
| **Sign in as Super Admin** → `super@demo.com` | Ops + Payouts + Activity |
| **Sign in as Customer** → `customer@demo.com` | Shopper / checkout with code |
| `admin@demo.com` | Same as Ops (legacy alias) |

---

## Walkthrough 1 — Ops Admin (2 min)

1. Login screen → **Sign in as Ops Admin**
2. Tabs: Dashboard · Orders · Resellers · Products · Codes  
   (no Payouts / Activity)
3. **Resellers** → see pending applications (seeded + any you applied)
4. Open one → **Approve** → choose Centre (`VNA-C-*`) or Beneficiary (`VNA-B-*`)
5. **Codes** tab → see issued codes
6. Logout

## Walkthrough 2 — Super Admin (1 min)

1. **Sign in as Super Admin**
2. Same as Ops **plus** **Payouts** and **Activity**
3. Logout

## Walkthrough 3 — Approved reseller shortcut (2 min)

1. **Sign in as Reseller**
2. Dashboard → code **`VNA-B-LERATO`** (copy button)
3. **Clients** → tap a client → change status (pending / confirmed / bought / didNotBuy)
4. **Add client** (FAB) → add a lead
5. **Sales** → existing commissions
6. Logout

## Walkthrough 4 — Full journey Apply → Approve → Clients → Sale (the important one)

### A. Apply
1. Login → **Register**
2. Name: `Sipho Test` · Email: `sipho.test@demo.com` · Password: `demo1234`
3. Register as **Reseller** · Academy optional
4. **Apply as reseller** → OTP **`123456`**
5. Land on **Application pending** → Logout

### B. Ops approve
6. **Sign in as Ops Admin** → **Resellers** → Approve **Sipho Test** → Beneficiary
7. Note the code shown in the snackbar (e.g. `VNA-B-SIPHO`) → Logout

### C. Reseller unlocked
8. Login with `sipho.test@demo.com` / `demo1234` (or tap refresh if already open)
9. Dashboard shows the new code → **Add client** → set statuses

### D. Sale via code
10. Logout → **Sign in as Customer**
11. Store → add to prototype cart → Checkout
12. Enter Sipho’s code (or `VNA-B-LERATO`) → Apply → Pay → OTP **`654321`**
13. Logout → Reseller (Sipho or demo) → **Sales** shows the commission

---

## OTPs (prototype)

| What | Code |
|---|---|
| Register / email verify | `123456` |
| Payment | `654321` |

Both also print in the `flutter run` console.

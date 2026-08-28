# Launch-gate — Role smoke UAT

**Date:** 28 Aug 2026  
**App:** live API (`API_BASE_URL=https://villagenetacad.co.za`)  
**Branch:** `cursor/phase8-ledger-clients-09ad`

Run on phone/emulator:

```powershell
cd S:\WORK\VillageNetAcad
.\INSTALL-PHASE8-LEDGER.ps1
cd mobile
flutter pub get
flutter run --no-dds --dart-define=API_BASE_URL=https://villagenetacad.co.za
```

Use **real live accounts** (not `@demo.com` — those only work without `API_BASE_URL`).

---

## A — Customer — **PASS** (28 Aug 2026)

| # | Step | Pass? |
|---|------|-------|
| A1 | Login as customer / buyer | PASS |
| A2 | Home loads (store + training visible) | PASS |
| A3 | Store → open a product → see price/image | PASS |
| A4 | Profile → **My orders** → see order(s) with product name/image | PASS |
| A5 | Profile → **Verify a reseller** → `VNA-B-067FA503` → approved | PASS |
| A6 | Training tab → course list → enrol CTA opens browser | PASS |

---

## B — Reseller (seller) — **PASS** (28 Aug 2026)

Login as approved seller for **`VNA-B-067FA503`**.

| # | Step | Pass? |
|---|------|-------|
| B1 | Reseller dashboard opens | PASS |
| B2 | Wallet shows live balance (R5.30 after order 18) | PASS |
| B3 | Clients tab loads; can add / change status | PASS |
| B4 | Earnings statement opens for current month | PASS |
| B5 | Verify / profile shows code `VNA-B-067FA503` | PASS |
| B6 | Withdraw gate (not last day / R100 min) | PASS |

---

## C — Reseller (centre) — **PASS** (28 Aug 2026)

Login as **`VNA-C-3D1342F6`**.

| # | Step | Pass? |
|---|------|-------|
| C1 | Dashboard / wallet live (R2.60 after order 18) | PASS |
| C2 | Statement shows centre share | PASS |

---

## D — Ops Admin — **PASS** (28 Aug 2026)

Login: **`admin@villagenetacad.com`** / **`Admin123!`**

**Fix shipped:** app now uses `HttpAdminRepository` when `API_BASE_URL` is set (was stuck on `DummyAdminRepository` seed data).

Live API check (same endpoints the app calls):

| Endpoint | Result |
|----------|--------|
| `POST /api/auth/login` (admin) | OK |
| `GET /api/admin/dashboard` | 65 users, 18 orders, revenue R1070, 1 product |
| `GET /api/orders/admin/all` | Order **18** paid R5 + `VNA-B-067FA503` (matches website) |
| `GET /api/products` | **UAT R5 TEST** (id 8) |
| `GET /api/resellers/admin/all` | **3** reseller profiles |

| # | Step | Pass? |
|---|------|-------|
| D1 | Ops shell opens (not customer shell) | PASS |
| D2 | Orders list is live (not demo seed) | PASS |
| D3 | Resellers list loads (live) | PASS |
| D4 | Products list matches live catalogue | PASS |
| D5 | Withdrawals queue loads (may be empty) | PASS |

---

## E — Super Admin — **N/A** (28 Aug 2026)

Live DB has no separate `super` role (`admin` / `reseller` / `customer` only).  
API `role: admin` → app **Ops Admin**. Same account covers Ops; mark Super as N/A on live.

---

## Result

- [x] Customer PASS  
- [x] Reseller PASS  
- [x] Centre PASS  
- [x] Ops PASS  
- [x] Super N/A (same as Ops on live)  

**Overall: PASSED** (28 Aug 2026)

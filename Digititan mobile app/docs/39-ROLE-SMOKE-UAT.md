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

## A — Customer

| # | Step | Pass? |
|---|------|-------|
| A1 | Login as customer / buyer | |
| A2 | Home loads (store + training visible) | |
| A3 | Store → open a product → see price/image | |
| A4 | Profile → **My orders** → see order(s) with product name/image | |
| A5 | Profile → **Verify a reseller** → `VNA-B-067FA503` → approved | |
| A6 | Training tab → course list → enrol CTA opens browser | |

Notes: ______________________________________

---

## B — Reseller (seller)

Login as approved seller for **`VNA-B-067FA503`** (or switch hat if same account is both customer + reseller).

| # | Step | Pass? |
|---|------|-------|
| B1 | Reseller dashboard opens | |
| B2 | Wallet shows **R5.30** (or current balance) | |
| B3 | Clients tab loads; can add / change status | |
| B4 | Earnings statement opens for current month | |
| B5 | Verify / profile shows code `VNA-B-067FA503` | |
| B6 | Withdraw: if **not** last calendar day → blocked; if last day → R100 min enforced | |

Notes: ______________________________________

---

## C — Reseller (centre) — optional same day

Login as **`VNA-C-3D1342F6`** centre.

| # | Step | Pass? |
|---|------|-------|
| C1 | Dashboard / wallet **R2.60** (or current) | |
| C2 | Statement shows centre share lines | |

Notes: ______________________________________

---

## D — Ops Admin

Login as live **ops** / admin account.

| # | Step | Pass? |
|---|------|-------|
| D1 | Ops shell opens (not customer shell) | |
| D2 | Orders list loads (incl. recent paid R5) | |
| D3 | Resellers / pending applications list loads | |
| D4 | Products list loads | |
| D5 | Withdrawals queue loads (may be empty) | |

Notes: ______________________________________

---

## E — Super Admin

Login as live **super** account (if different from Ops).

| # | Step | Pass? |
|---|------|-------|
| E1 | Super shell opens | |
| E2 | Same ops queues visible | |
| E3 | Any Super-only actions visible (config / elevated) without crash | |

If you only have one admin account that covers both, mark E = same as D and note that.

Notes: ______________________________________

---

## Result

- [ ] Customer PASS  
- [ ] Reseller PASS  
- [ ] Ops PASS  
- [ ] Super PASS (or N/A — same as Ops)  

**Overall:** ☐ PASSED · ☐ FAILED  

Failed steps / screenshots: ______________________________________

When done, paste this section back to the agent so docs/PR can be ticked.

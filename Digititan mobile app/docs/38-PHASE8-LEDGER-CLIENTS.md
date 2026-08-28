# Phase 8 slice 2 — 53/26/21 ledger + clients CRM + month statement

**Branch:** `cursor/phase8-ledger-clients-09ad`  
**Base:** `cursor/phase9-wait-website-09ad`  
**Live tree:** `public_html/backend-php/` only  
**Also on this branch:** PayFast ITN auto-fulfill harden (`PayfastController`) — see `docs/34-PHASE7-PAYFAST-ITN.md`.  
**Still not touched:** SMTP

## Live deploy status (28 Aug 2026): **DEPLOYED + UAT PASSED**
- phpMyAdmin: `reseller_clients` + `commissions.party` / `share_percent`  
- PHP uploaded: `ResellersController`, `OrderFulfillment`, `Router`, hardened `PayfastController`  
- App: sync this branch (includes reseller Independent/Affiliated/Centre register UX)

### Mobile UAT (28 Aug 2026): **PASSED**
1. Approved reseller login — PASS  
2. Clients tab — PASS  
3. Add client — PASS  
4. Change status (pending → bought) — PASS  
5–6. Earnings statement (Dashboard → Earnings statement) — PASS  
7–8. Profile / verify — covered / OK  

### Paid 53/26/21 + ITN auto-fulfill UAT (28 Aug 2026): **PASSED**
- Order **17**: recover once → seller R2.65 / centre R1.30 / digititan R1.05  
- Order **18**: PayFast → ITN → **auto** `paid` (no `_fulfill_once`) → wallets **R5.30** / **R2.60**  
- Referral `VNA-B-067FA503` · centre `VNA-C-3D1342F6` · academy Nkuna Centre  
- My Orders list shows product name/image — OK on live

## What we built

### 1. Auto 53 / 26 / 21 ledger (`OrderFulfillment.php`)
On paid fulfill (same call ITN already makes — **ITN file unchanged**):

| Seller type | Wallet credits | Digititan ledger row |
|-------------|----------------|----------------------|
| Independent `VNA-B-*` (no academy) | Seller **53%** | Rest (~47%) |
| Affiliated `VNA-B-*` (academy set) | Seller **53%** + matched centre **26%** | **21%** |
| Centre `VNA-C-*` | That centre **26%** | Rest (~74%) |

Centre match: approved `VNA-C-*` whose `academy` **or** registration name equals the affiliate’s `academy` string.

### 2. Clients CRM
- Table `reseller_clients`
- `GET/POST /api/resellers/clients`, `PUT /api/resellers/clients/{id}`
- App `HttpResellerRepository` wired (add + status)
- Paid order with matching client email → status `bought`

### 3. Month-end statement
- `GET /api/resellers/statement?month=YYYY-MM`
- App **Earnings statement** uses live period totals + line list (falls back to profile summary if API missing)

## Deploy pack
`deploy/phase8-ledger-clients-live/` — README + migration + PHP files.

App: `INSTALL-PHASE8-LEDGER.ps1`

## UAT (after live upload + migration)
**Clients + statement UAT PASSED (28 Aug 2026).**  
**Paid 53/26/21 + ITN auto-fulfill UAT PASSED (28 Aug 2026).**  

## Still later
- Stronger centre link than name match (store centre referral code at register)
- Ops Digititan 21% dashboard
- Full multi-month PDF statements

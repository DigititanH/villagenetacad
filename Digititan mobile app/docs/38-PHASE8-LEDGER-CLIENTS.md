# Phase 8 slice 2 — 53/26/21 ledger + clients CRM + month statement

**Branch:** `cursor/phase8-ledger-clients-09ad`  
**Base:** `cursor/phase9-wait-website-09ad`  
**Live tree:** `public_html/backend-php/` only  
**Not touched:** PayFast ITN, `notify.php`, SMTP

## Live deploy status (28 Aug 2026): **DEPLOYED**
- phpMyAdmin: `reseller_clients` + `commissions.party` / `share_percent`  
- PHP uploaded: `ResellersController`, `OrderFulfillment`, `Router`  
- App: sync this branch (includes reseller Independent/Affiliated/Centre register UX)

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
1. Clients: add → list → change status → reload  
2. Statement: open Earnings statement → month header  
3. Ledger (careful): one test paid order with affiliated referral + matching centre name → seller + centre wallets; Digititan line in statement  

## Still later
- Stronger centre link than name match (store centre referral code at register)
- Ops Digititan 21% dashboard
- Full multi-month PDF statements

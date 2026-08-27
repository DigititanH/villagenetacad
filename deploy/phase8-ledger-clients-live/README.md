# Phase 8 slice 2 — ledger + clients + statement (live pack)

**Does not touch PayFast / ITN / notify.php.** Only fulfillment + reseller APIs.

## 1. MySQL (phpMyAdmin) — run once

File: `migration.sql`

Creates `reseller_clients` and adds `commissions.party` + `share_percent`.  
If `ALTER` says duplicate column, the party columns already exist — OK.

## 2. Upload overwrite (`public_html/backend-php/` only)

| Local pack file | Live path |
|-----------------|-----------|
| `ResellersController.php` | `controllers/ResellersController.php` |
| `OrderFulfillment.php` | `lib/OrderFulfillment.php` |
| `Router.php` | `routes/Router.php` |

`Router.php` in this pack is the Phase 8 live-compatible router (CCNA + products admin) **plus** clients/statement routes. Safe to overwrite that live Router if it still matches the Phase 8 pack.  

If live Router has diverged, **do not** overwrite — only **ADD** these three lines in the Resellers section:

```php
self::get('/api/resellers/statement', [ResellersController::class, 'statement']);
self::get('/api/resellers/clients', [ResellersController::class, 'clients']);
self::post('/api/resellers/clients', [ResellersController::class, 'addClient']);
self::put('/api/resellers/clients/{id}', fn ($p) => ResellersController::updateClient($p));
```

## 3. App sync

```powershell
cd S:\WORK\VillageNetAcad
# after pulling INSTALL-PHASE8-LEDGER.ps1 from this branch
.\INSTALL-PHASE8-LEDGER.ps1
```

Branch: `cursor/phase8-ledger-clients-09ad`

## 4. What this does

| Piece | Behaviour |
|-------|-----------|
| **Ledger** | On paid order fulfill: seller 53% (or centre 26% if VNA-C). Affiliated (academy set) also credits matched VNA-C centre 26% + Digititan ledger 21%. |
| **Clients** | CRUD at `/api/resellers/clients`. Paid order with matching client email → status `bought`. |
| **Statement** | `GET /api/resellers/statement?month=YYYY-MM` + app Earnings statement. |

Centre match: approved `VNA-C-*` whose `academy` or registration `name` equals the affiliate’s `academy` string.

## 5. Smoke

1. Add client in app → appears after reload  
2. Change status → persists  
3. Earnings statement → month header + totals (may be R0 if no sales)  
4. (Optional) Sandbox/dev fulfill with referral → seller + centre wallets move; **no** ITN change required if you use existing paid path

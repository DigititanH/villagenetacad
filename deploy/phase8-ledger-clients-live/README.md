# Phase 8 slice 2 — live upload (your files enhanced)

Your pasted live `ResellersController.php` + `Router.php` match the Phase 8 slice 1 base.
This pack is that base **plus** clients / statement / share totals / 53-26-21 fulfill.

**You did not paste `OrderFulfillment.php`** — pack file is the standard live fulfill enhanced for multi-party credit only. PayFast / ITN / `notify.php` are **not** in this pack.

---

## Does migration (#1) affect live production?

**Yes — it runs on the live MySQL database.**

But it is **additive only**:
- Creates new table `reseller_clients` (empty)
- Adds columns `party` + `share_percent` on `commissions` (existing rows stay; default `seller`)
- Does **not** delete orders, wallets, users, or PayFast data
- Does **not** change how money is taken from customers

Safe pattern: export/backup DB in cPanel first, then run SQL.  
If `ALTER` errors with “duplicate column”, those columns already exist — ignore and continue.

Until you also upload the PHP files, the new table/columns just sit unused.

---

## Download (PowerShell → Downloads)

```powershell
cd $env:USERPROFILE\Downloads
$b = "cursor/phase8-ledger-clients-09ad"
$base = "https://cdn.jsdelivr.net/gh/DigititanH/villagenetacad@$b/deploy/phase8-ledger-clients-live"
Invoke-WebRequest -Uri "$base/ResellersController.php" -OutFile "ResellersController.php"
Invoke-WebRequest -Uri "$base/OrderFulfillment.php" -OutFile "OrderFulfillment.php"
Invoke-WebRequest -Uri "$base/Router.php" -OutFile "Router.php"
Invoke-WebRequest -Uri "$base/migration.sql" -OutFile "migration.sql"
dir ResellersController.php, OrderFulfillment.php, Router.php, migration.sql
```

## Upload (`public_html/backend-php/` only)

1. phpMyAdmin → run `migration.sql`
2. Overwrite:
   - `controllers/ResellersController.php`
   - `lib/OrderFulfillment.php`
   - `routes/Router.php` (your paste + 4 new reseller routes — safe if live still matches Phase 8 pack)

## App sync (VS Code terminal on laptop)

```powershell
cd S:\WORK\VillageNetAcad
irm "https://cdn.jsdelivr.net/gh/DigititanH/villagenetacad@cursor/phase8-ledger-clients-09ad/Digititan%20mobile%20app/INSTALL-PHASE8-LEDGER.ps1" -OutFile "INSTALL-PHASE8-LEDGER.ps1"
.\INSTALL-PHASE8-LEDGER.ps1
cd mobile
flutter pub get
flutter run --no-dds --dart-define=API_BASE_URL=https://villagenetacad.co.za
```

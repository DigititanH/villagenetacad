# Phase 7 — PayFast ITN live pack

**Live API tree only:** `public_html/backend-php/`  
**Do NOT edit:** `public_html/village-netacad/backend-php/` (stale duplicate)

## Wrong vs right folders

| Path | Role |
|------|------|
| `public_html/backend-php/` | Live API + `.env` + `lib/Payfast.php` |
| `public_html/payfast/notify.php` | Public legacy ITN URL PayFast already calls |
| `public_html/backend-php/payfast/` | **WRONG** for ITN — a stub here does nothing for live payments |
| `public_html/village-netacad/...` | **WRONG** — stale duplicate |

Live status today still shows:

```text
GET https://villagenetacad.co.za/api/payfast/status
→ notify_url: https://www.villagenetacad.co.za/payfast/notify.php
```

API route already works:

```text
POST https://villagenetacad.co.za/api/payfast/notify → OK
```

## What this pack does

1. `.env` — point ITN at the API route  
2. `lib/Payfast.php` — normalize legacy `…/payfast/notify.php` → `/api/payfast/notify`  
3. `public_html/payfast/notify.php` — forward old URL into the real controller (marks orders paid)

## Steps (cPanel File Manager / FTP)

### 1) Edit `.env` (required)

File: **`public_html/backend-php/.env`**

Set / replace:

```env
PAYFAST_NOTIFY_URL=https://villagenetacad.co.za/api/payfast/notify
```

Keep existing `PAYFAST_MERCHANT_ID`, `PAYFAST_MERCHANT_KEY`, `PAYFAST_PASSPHRASE`, `PAYFAST_SANDBOX`.

### 2) Upload `Payfast.php` (required)

Overwrite:

`public_html/backend-php/lib/Payfast.php`

### 3) Upload legacy forwarder (required if PayFast still uses notify.php)

Overwrite:

`public_html/payfast/notify.php`

**Not** `public_html/backend-php/payfast/notify.php`.

That file must `require` `../backend-php/bootstrap.php` and call `PayfastController::notify()`.

If you only have a stub that logs `$_POST` and echoes "PayFast ITN endpoint active", replace it — it never marks orders paid.

### 4) PayFast dashboard (optional but good)

Notify URL:

`https://villagenetacad.co.za/api/payfast/notify`

## Smoke

```text
https://villagenetacad.co.za/api/payfast/status
```

Expect:

```json
"notify_url":"https://villagenetacad.co.za/api/payfast/notify"
```

Then: small paid checkout → My Orders → payment status **paid**.

## Download (jsDelivr)

```powershell
cd $env:USERPROFILE\Downloads
$base = "https://cdn.jsdelivr.net/gh/DigititanH/villagenetacad@cursor/phase7-payfast-itn-09ad/deploy/phase7-itn-live"
Invoke-WebRequest -Uri "$base/Payfast.php" -OutFile "Payfast.php"
Invoke-WebRequest -Uri "$base/notify.php" -OutFile "notify.php"
dir Payfast.php, notify.php
```

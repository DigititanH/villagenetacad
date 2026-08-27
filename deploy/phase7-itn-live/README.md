# Phase 7 — PayFast ITN live pack

**Live tree only:** `public_html/backend-php/`  
**Do NOT edit:** `public_html/village-netacad/backend-php/` (stale duplicate — burns deploys)

## Live today (before fix)

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
3. Optional `public_html/payfast/notify.php` — keep old URL working by calling the same controller  

## Steps (cPanel / Afrihost File Manager or FTP)

### 1) Edit `.env` (required)

File: **`public_html/backend-php/.env`**

Set (or replace) this line:

```env
PAYFAST_NOTIFY_URL=https://villagenetacad.co.za/api/payfast/notify
```

Keep your existing `PAYFAST_MERCHANT_ID`, `PAYFAST_MERCHANT_KEY`, `PAYFAST_PASSPHRASE`, `PAYFAST_SANDBOX`.

### 2) Upload `Payfast.php` (required)

Overwrite:

`public_html/backend-php/lib/Payfast.php`

### 3) Upload legacy `notify.php` (recommended)

Overwrite:

`public_html/payfast/notify.php`

(so any PayFast dashboard still using the old path still hits the real controller)

### 4) PayFast dashboard (if you use Integration settings)

Notify URL should be:

`https://villagenetacad.co.za/api/payfast/notify`

## Smoke

```text
https://villagenetacad.co.za/api/payfast/status
```

Expect:

```json
"notify_url":"https://villagenetacad.co.za/api/payfast/notify"
```

Then: small paid checkout → order shows **paid** in My Orders (ITN fired).

## Download (jsDelivr)

```powershell
cd $env:USERPROFILE\Downloads
$base = "https://cdn.jsdelivr.net/gh/DigititanH/villagenetacad@cursor/phase7-payfast-itn-09ad/deploy/phase7-itn-live"
Invoke-WebRequest -Uri "$base/Payfast.php" -OutFile "Payfast.php"
Invoke-WebRequest -Uri "$base/notify.php" -OutFile "notify.php"
dir Payfast.php, notify.php
```

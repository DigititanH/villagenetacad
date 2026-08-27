# Phase 7 — PayFast ITN (notify URL)

**Status: READY TO DEPLOY** on the **live** tree only.

## Critical path

Live API = **`public_html/backend-php/`**

Wrong (stale duplicate — do not edit):

`public_html/village-netacad/backend-php/`

## Goal

After PayFast payment, ITN hits:

`https://villagenetacad.co.za/api/payfast/notify`

so orders mark as **paid**.

## Live before fix

```text
GET /api/payfast/status
notify_url = https://www.villagenetacad.co.za/payfast/notify.php
```

`POST /api/payfast/notify` already returns `OK`.

## Deploy pack

See `deploy/phase7-itn-live/README.md`.

1. Edit `public_html/backend-php/.env` → `PAYFAST_NOTIFY_URL=https://villagenetacad.co.za/api/payfast/notify`
2. Upload `Payfast.php` → `public_html/backend-php/lib/Payfast.php`
3. Upload `notify.php` → `public_html/payfast/notify.php` (legacy forwarder)

## Smoke

1. `https://villagenetacad.co.za/api/payfast/status` → `notify_url` ends with `/api/payfast/notify`
2. Small paid checkout on site
3. My Orders → payment status **paid**

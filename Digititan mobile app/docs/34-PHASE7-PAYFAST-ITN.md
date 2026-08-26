# Phase 7 — PayFast ITN (notify URL)

## What
After a customer pays, PayFast calls your server (**ITN**) so the order is marked paid.

Correct URL for this app:

`https://villagenetacad.co.za/api/payfast/notify`

## Problem
Live `.env` had the legacy path:

`https://www.villagenetacad.co.za/payfast/notify.php`

That does not update orders through the current PHP API.

## Code fix (this branch)
`Payfast::getNotifyUrl()` rewrites legacy `/payfast/notify.php` → `/api/payfast/notify`  
so new checkouts send the right ITN URL even before `.env` is edited.

## Ops (cPanel) — still do this
Edit `/public_html/village-netacad/backend-php/.env`:

```env
PAYFAST_NOTIFY_URL=https://villagenetacad.co.za/api/payfast/notify
API_URL=https://villagenetacad.co.za
CLIENT_URL=https://villagenetacad.co.za
```

Upload updated `backend-php/lib/Payfast.php` (and `PayfastController.php` if present on this branch).

Then open `/api/payfast/status` — `notify_url` should end with `/api/payfast/notify`.

## UAT
1. Buy a small live item (or sandbox if you flip back temporarily).  
2. Complete PayFast.  
3. App → My orders → payment status paid / order appears.  
4. Admin → Orders → same order paid.

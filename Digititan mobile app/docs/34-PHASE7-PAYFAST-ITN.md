# Phase 7 — PayFast ITN (notify URL) — PARKED

**Status: on hold** — do not change production `.env` / `Payfast.php` until leadership is ready.

## What it is
After PayFast payment, ITN hits your server so orders mark as paid.

Target URL (when we resume):

`https://villagenetacad.co.za/api/payfast/notify`

Live today may still show legacy:

`…/payfast/notify.php`

## When we resume
1. Edit only `village-netacad/backend-php/.env` + matching `lib/Payfast.php` (same tree as live site).
2. Set `PAYFAST_NOTIFY_URL=https://villagenetacad.co.za/api/payfast/notify`
3. Deploy normalize/`getNotifyUrl` fix from this branch if needed.
4. Confirm `/api/payfast/status` then do a small paid UAT → My orders.

Until then: leave production PayFast as-is.

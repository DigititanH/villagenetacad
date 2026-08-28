# Phase 10 — In-app notifications (order paid / status / reseller sale)

**Status:** Implemented on `cursor/phase8-ledger-clients-09ad` (28 Aug 2026).  
**No SMTP** — inbox only (`notifications` table + Profile / Reseller bell).

## Events
| Event | Who gets a row |
|--------|----------------|
| Order paid (`OrderFulfillment`) | Buyer + seller referral + centre (if affiliated) |
| Ops status / tracking update | Buyer |

## Live upload
See `deploy/phase10-notifications-live/README.md`.

## App
`INSTALL-PHASE8-LEDGER.ps1` then Profile → Notifications (or Reseller app bar bell).

## UAT
1. Upload PHP + ensure `notifications` table  
2. Backfill order 18 once **or** place a new R5 paid order  
3. Buyer + seller + centre each open Notifications and see the matching titles  
4. Ops changes order status → buyer sees “Order update”

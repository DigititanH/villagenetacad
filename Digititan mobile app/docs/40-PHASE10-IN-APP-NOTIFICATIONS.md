# Phase 10 — In-app notifications (order paid / status / reseller sale)

**Status:** Live UAT **PASSED** (28 Aug 2026) on `cursor/phase8-ledger-clients-09ad`.  
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

## UAT — **PASSED** (28 Aug 2026)

Live API + order **18** backfill + Ops status change.

| # | Step | Pass? |
|---|------|-------|
| N1 | Buyer → Notifications → **Payment confirmed** | PASS |
| N2 | Seller `VNA-B-067FA503` → bell → **Reseller sale confirmed** | PASS |
| N3 | Centre `VNA-C-3D1342F6` → bell → **Centre share earned** | PASS |
| N4 | Tap row → marks read | PASS |
| N5 | Ops changes order status → buyer sees **Order update** | PASS |

Optional (not required for gate): N6 new R5 paid order auto-creates rows without backfill.

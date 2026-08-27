# Phase 7 — OTP / email / SMS — **PARKED**

**Status: parked** — resume at work with the team (not a solo prod change).

Branch kept ready: `cursor/phase7-smtp-cpanel-09ad` (PR #18, draft)  
Deploy pack already written: `deploy/phase7-smtp-live/`

## Why parked
Team needs to own mailbox / `.env` / Afrihost SMTP together. Not urgent vs consulting on reseller B/C rules.

## When you resume (with the team)
1. **Live tree only:** `public_html/backend-php/` (not `village-netacad/backend-php/`)
2. Prefer **cPanel mailbox** SMTP (`localhost` or `mail.villagenetacad.co.za`) — Gmail often blocked on Afrihost
3. Upload pack from `deploy/phase7-smtp-live/README.md` (`Mailer.php` + optional keyed `smtp-ping.php`, then **delete** ping)
4. Live auth uses a **verify-email link**, not a 6-digit app OTP

## Still parked separately
| Item | Status |
|------|--------|
| SMS OTP | Provider TBD |
| Lawyer POPI / legal | Parked |
| T&Cs before pay | Parked |
| PayFast ITN notify URL | See `34-PHASE7-PAYFAST-ITN.md` |
| Google Sign-In | Removed from app (website has none) |

Do **not** leave `smtp-ping.php` on production if it was ever uploaded.

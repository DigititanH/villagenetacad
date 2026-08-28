# Phase 7 — OTP / email / SMS (status)

Branch: `cursor/phase7-smtp-app-uat-09ad`

## Decision: one `.env`, two SMTP profiles (no `.envMail`)

| Profile | Keys | Mailbox |
|---------|------|---------|
| Mobile app | `APP_SMTP_*` | `app@villagenetacad.co.za` |
| Website | `SMTP_*` | Website team configures later |

Flutter sends `X-VNA-Client: mobile`. App transactional mail uses `channel=app`.

Packs: `deploy/phase7-dual-smtp-live/` · `deploy/phase7-app-emails-live/`  
Windows sync: `INSTALL-PHASE7-SMTP.ps1`

## Email + in-app (hand-in-hand with the mobile app)

| Event | Email (app@) | In-app inbox |
|-------|----------------|--------------|
| Customer register (app) | Welcome | — |
| Reseller apply (app) | Pending review (“We…”) | — |
| Reseller approved (Ops) | Code + how reselling works | Reseller approved |
| Order paid | Customer confirmation + seller/centre sale notice | Payment / sale / centre |
| Order status change | Customer status email | Order update |

## Status

| Item | Status |
|------|--------|
| Dual SMTP + welcome | **PASS** |
| Reseller pending / approved / sale / order emails | Implemented — upload `phase7-app-emails-live` then UAT |
| SMS OTP | Parked |
| POPI / T&Cs before pay | Parked |

## App UAT — dual SMTP **PASSED** (28 Aug 2026)

| # | Step | Pass? |
|---|------|-------|
| M1–M3 | Website vs app welcome split | **PASS** |
| F3a–c | Three reseller apply paths | **PASS** (API + app) |

### Next UAT after email pack upload
| # | Step |
|---|------|
| E1 | Reseller apply → pending mail wording (“We…”) |
| E2 | Ops approve → approval mail with referral code |
| E3 | Paid order with referral → customer + reseller emails |
| E4 | Ops status shipped/delivered → customer email |

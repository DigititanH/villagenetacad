# Meeting feedback backlog (Oct 2026)

Source: stakeholder meeting Q&A. Status reflects what is in this prototype vs what still needs live PHP/MySQL + launch work.

| # | Feedback | Decision / approach | Prototype status |
|---|----------|---------------------|------------------|
| 1 | Login logo bigger | Increase brand header size on login | Done |
| 2 | OTP via SMS as well as email | Channel choice: Email / SMS (demo codes unchanged) | Done (demo) |
| 3 | Tighten security | Encryption in transit/at rest, stronger auth, audit trail — see `23-SECURITY-AND-LEGAL.md` | Spec + demo notes |
| 4 | Buyer: is reseller legit? | Everyone in DB; QR / code verify returns reseller details (PHP public verify API) | Done (demo + PHP) |
| 5 | LMS: store learner full name, gender, email | Capture on training / academy interest forms → DB for LMS sync | Done (demo fields) |
| 6 | New academies: register with us, not Cisco-only | In-app org/academy registration so Digititan keeps the lead | Done (messaging + form) |
| 7 | Minimum withdrawal | **R100** minimum for now | Done |
| 8 | Legal: T&Cs, privacy, security, returns, POPI | In-app legal pages + launch legal review | Done (draft copy) |
| 9 | Documentation | This backlog + locked decisions + security/legal doc | Done |
| 10 | App icon = Village NetAcad programme | Use Village NetAcad mark as launcher icon on build | Spec (asset on laptop) |
| 11 | Checkout = same gateway as Digititan Store | **PayFast** (same merchant path as website) | Wired in messaging + PHP |
| 12 | Payment happens in the app as well | In-app checkout → PayFast (not website-only) | Decision flipped; demo PayFast step |
| 13 | Launch: everything up, minor polish | Pre-launch checklist in this doc | Checklist below |

## Product decision flips from this meeting

1. **In-app payment is required** — Phase 1 is no longer “samples only + website checkout only”. App checkout uses the **same PayFast gateway** as `shop.digititan.co.za`.
2. **Academy registration stays in Digititan** — Cisco NetAcad signup may still happen later for LMS, but **first capture is with us** so we do not lose academy details.
3. **Reseller trust for buyers** — public verify by referral code / QR (approved status, name, academy, code type). Aligns with Karabo: everyone in DB + QR.

## Reseller legitimacy (buyer POV)

1. Reseller is approved in DB (Ops Admin).
2. Reseller shares **referral code** and **QR** (`vna://verify/{CODE}`).
3. Buyer opens **Verify reseller** (Profile / Checkout) or scans QR → sees name, status, code type, academy.
4. Live API: `GET /api/resellers/verify/{code}` (public, no secrets).

## Pre-launch checklist (item 13)

- [ ] PayFast live keys + notify URL reachable from PayFast
- [ ] SMS OTP provider (or Twilio/Africa’s Talking) + email OTP
- [ ] HTTPS + TLS everywhere; hashed passwords; session tokens
- [ ] Legal pages lawyer-reviewed (POPI, returns, T&Cs)
- [ ] Village NetAcad app icon on Android/iOS
- [ ] Learner fields synced to LMS export/API
- [ ] Min withdraw R100 enforced server-side
- [ ] Reseller QR deep link / verify page on web + app
- [ ] Academy org queue visible to Ops Admin
- [ ] Smoke test: login → shop → PayFast → OTP → order → reseller balance → month-end withdraw

## Demo codes (unchanged)

- Password: `demo123`
- Email/SMS OTP: `123456`
- Payment OTP: `654321`
- Fast sale code: `VNA-B-LERATO`

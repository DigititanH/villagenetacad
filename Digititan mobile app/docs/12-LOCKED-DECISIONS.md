# Locked product decisions (from leadership feedback)

Updated: Phases Wave 1–3 — 24 Aug 2026  
Roadmap: `docs/25-PHASES-WAVE2-WAVE3.md`

## V1 users
- Beneficiaries
- Academies
- Shoppers

## Store
- App shows sample products (until live catalogue is filled in Admin)
- Website shop: `https://villagenetacad.co.za/shop` (Phase 3 — not shop.digititan.co.za)
- **v1 payments (locked):** browse / cart in app → **pay on the website** (system browser).  
  Prefer this over in-app PayFast / WebView to reduce Play Store & App Store rejection risk  
  (especially if digital courses/goods are sold — Apple/Google often require their IAP).  
- Same **PayFast merchant** as the website (money still PayFast; just not embedded in the app yet).  
- **In-app PayFast / store IAP:** deferred until leadership answers digital-goods + console ownership; not required for Phase 7 go-live.

## Desktop
- Downloadable Windows/Mac app required (Flutter desktop later)

## Training / LMS
- Information + registration in-app
- Learning in separate LMS
- **Wave 2C:** store learner full name, gender, email for LMS alignment

## Academies (Wave 1)
- New academies / orgs **register with Digititan first**
- Cisco NetAcad may follow — do **not** Cisco-only redirect
- **ASC registration:** same Microsoft Form as the website (Home → ASC Registration).
  App opens that form in the browser — do not maintain a separate shortened in-app form.

## Reseller model
- Codes: Beneficiary (VNA-B) / Centre (VNA-C)
- Month-end withdrawals only
- **Minimum withdrawal: R100** (Wave 1 — button blocked under R100)
- Split: **53%** / **26%** / **21%**
- **Wave 2A:** buyer verifies reseller via QR / code (DB + PHP API)

## OTP
- **Wave 2B:** Email **and** SMS channel choice  
- **Phase 7 email:** Gmail SMTP / live inbox OTP **on hold** (host path TBD).  
- **Google Sign-In:** removed from the app for now (website has no Google login).  
- **Phase 7 SMS:** provider not chosen yet (Africa’s Talking / Twilio / Clickatell).  
- **Parked in Phase 7:** lawyer POPI, T&Cs-before-pay (do after email OTP works).

## Returns
- 7 days after delivery

## Legal
- Wave 1: draft T&Cs, privacy, security, returns in-app
- **Wave 3B:** POPI Act full copy (lawyer) — later stage

## Branding (Wave 1)
- Larger login Village NetAcad logo
- App icon = Village NetAcad programme mark

## Security & launch
- **Wave 3A:** encryption, stronger auth, hardening
- **Wave 3C:** everything up — launch checklist in `25-PHASES-WAVE2-WAVE3.md`

## Ambassador
- Website only (not mobile V1)

## Remaining phases (summary)
1. **Wave 2A** QR / verify reseller  
2. **Wave 2B** SMS + email OTP  
3. **Wave 2C** LMS learner fields  
4. **Wave 2D** PayFast on **website** (app opens browser) — in-app PayFast deferred (store compliance)  
5. **Wave 3A–C** Security → POPI → launch checklist  

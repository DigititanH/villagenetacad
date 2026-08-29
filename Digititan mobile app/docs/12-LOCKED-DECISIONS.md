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

## Training / courses / Cisco (updated 27 Aug 2026)
- Company has **no own LMS** for now — association is with **Cisco NetAcad**.
- **Courses catalogue (v1):** **hardcoded in app** to match the website (same as live `/courses` — not MySQL).
- **Free / Cisco pathway:** “Enroll” → system browser → **Cisco NetAcad** URL; learners under **Village NetAcad** on Cisco’s side (website/Cisco ops see enrolments there).
- **Paid courses (CCNA R550 × 6 PayFast):** app opens website **`https://villagenetacad.co.za/courses/enrol`** (same idea as shop → website PayFast). **No in-app PayFast.**
- Do **not** put a full courses catalogue in MySQL for v1.

## Academies (updated 27 Aug 2026)
- New academies / orgs **register with Digititan first**
- Cisco NetAcad may follow for learning — do **not** invent a parallel LMS in the app
- **ASC registration:** same Microsoft Form as the website (Home → ASC Registration) until website provides an academies API
- **Academies DB / API:** website did **not** have academies in MySQL; they are **introducing** it.  
  App waits to call academies like customers/resellers until website ships the API.  
  **Contact: Khanyi** (website) — do not build a separate academies backend in the app first.
- When academies exist in DB, enrolments under Village NetAcad / academy structure follow website + Cisco process (not a new MySQL courses catalogue)

## Training / LMS (older Wave 2C note)
- Information + registration in-app; learning on Cisco / external
- **Wave 2C:** learner full name, gender, email — only when website/DB path exists (tied to academies work with Khanyi)

## Reseller model
- Codes: **VNA-B-*** (beneficiary / independent) vs **VNA-C-*** (centre) — issued at register
- Independent (no centre): **53%** seller · rest Digititan
- Affiliated with centre: **53%** seller · **26%** centre · **21%** Digititan (auto on fulfill when live ledger deployed)
- Register as centre: **26%** centre · rest Digititan
- Month-end withdrawals only (**server-enforced** in Phase 8 slice 1)
- **Minimum withdrawal: R100** (UI + **server** in Phase 8 slice 1)
- Clients CRM + monthly statement API — Phase 8 slice 2
- **Wave 2A / Phase 8 slice 1:** buyer verifies reseller via code → `GET /api/resellers/verify/{code}`

## OTP
- **Wave 2B:** Email **and** SMS channel choice  
- **Phase 7 email:** cPanel `app@villagenetacad.co.za` SMTP **LIVE** (28 Aug 2026). Live path = verify **link** in inbox (website parity); in-app OTP code screen = dummy only.  
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

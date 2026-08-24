# Locked product decisions (from leadership feedback)

Updated: meeting feedback Oct 2026

## V1 users
- Beneficiaries / resellers
- Academies / organisations
- Shoppers (customers)

## Store & payments
- App shows catalogue samples **and** supports **in-app checkout**
- Checkout uses the **same payment gateway as the Digititan Store website: PayFast**
- Website shop remains available: `https://www.shop.digititan.co.za/`
- Attribution: reseller referral code / QR on checkout

## Desktop
- Downloadable Windows/Mac app required (Flutter desktop later)

## Training / LMS
- Information + registration in-app
- Learning happens in separate LMS
- Learner records store **full name, gender, email** (and phone) for LMS alignment

## Academies
- New academies / NPOs **register in Digititan first** (we keep the lead)
- Cisco NetAcad onboarding may follow; do **not** only redirect to Cisco (we would lose visibility)

## Reseller model
- Different codes for centres and beneficiaries
- Independent seller contributions → general programme support account
- Month-end: **Digititan pays all resellers**
- **Withdrawals: last calendar day of the month only**
- **Minimum withdrawal: R100** (for now)
- Reseller app shows **only money due to them** (53% or Centre 26%)
- Bank auto-debit: later (not V1)
- Withdrawals still need Super Admin approval after request
- **Locked split of each attributed sale:**
  - Reseller / Beneficiary **53%**
  - Centre **26%**
  - Digititan / Village NetAcad **21%**
- Buyer trust: **QR / code verify** shows approved reseller details from DB

## OTP
- **Email and SMS** both supported (channel choice)

## Returns
- 7 days after delivery

## Legal
- In-app Terms, Privacy (POPI), Security, Returns — see `23-SECURITY-AND-LEGAL.md`

## Academy performance
- Categories: Registrations, Sales, Completions

## Ambassador
- Website only (not mobile V1)

## Branding
- App icon = Village NetAcad programme mark
- Login: large Village NetAcad logo + Powered by DIGITITAN

## Still waiting / launch blockers
- Live PayFast merchant + notify URL
- Live SMS provider
- Lawyer-reviewed legal copy
- Full LMS API sync
- Production security hardening (see checklist in `22-MEETING-FEEDBACK-BACKLOG.md`)

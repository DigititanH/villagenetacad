# Stakeholder email — Month-end prototype scope (in / out)

**Suggested subject:** Digititan / Village NetAcad mobile prototype — what to expect by month-end (in scope & out of scope)

Copy/paste and adjust names as needed.

---

Dear [Leadership / Product team],

I am writing ahead of our month-end review so we can confirm that I have understood the Digititan / Village NetAcad mobile vision correctly — and so you can flag anything I may have missed or misinterpreted.

Below is a clear summary of **what the prototype will demonstrate by month-end**, **what it will not yet include**, and **how the current build works**. The goal is alignment: if something important is missing from “in scope,” or if something in “out of scope” should actually be in V1, please tell me now so we can adjust before we move into live data and production integrations.

---

## Purpose of this prototype

This is a **working product prototype** (not a slide deck). It shows the end-to-end user journeys for the three pillars — **Training · Academies · Store** — plus **Reseller** and **Admin** operations, on a single Flutter codebase (Android now; iOS/desktop later).

It uses **demo data** so we can walk through flows safely in a presentation. After your feedback, the next technical step I propose is connecting a **real database / API** (so sample content becomes live content). **Real OTP emails and Google Sign-In** I am deliberately leaving in the product backlog for **after the presentation**, so we keep some production work planned and do not over-claim what is live by month-end.

---

## In scope by month-end (what to expect)

### 1) Who can use it (roles)
- **Customer / beneficiary / shopper** journeys  
- **Reseller** journeys  
- **Admin** (second-level ops) journeys  
- One-tap demo logins for walkthroughs  

### 2) Training
- Browse programmes / training offers  
- View details  
- **Register interest** (information + registration only)  
- Learning content itself stays in the **separate LMS** (as agreed)

### 3) Academies
- Interactive **South Africa map** by province  
- Tap a province → list of academies + location pins  
- Tap an academy → **location, programmes, events they host**, status  
- Register / apply interest  
- Organisation (NPO/Academy) registration form  

### 4) Store
- **Sample products** inside the app (catalogue / demo cart / simulated checkout for prototype)  
- **Full shopping** opens the live Digititan Store website:  
  `https://www.shop.digititan.co.za/`  
- Simulated payment OTP in-app (prototype only — not a live payment gateway)

### 5) Reseller model (sustainability)
- Referral code, clients, commissions, monthly statement  
- Withdrawal request flow  
- Messaging aligned to: **Digititan pays resellers at month-end (with approval)**  
- Different codes for centres vs beneficiaries (represented in prototype logic/copy)

### 6) Admin
- Dashboard overview  
- Update order status  
- Approve reseller applications (issue code)  
- Update product pricing (ops without developers)

### 7) Branding / presentation readiness
- Village NetAcad logo + “powered by DIGITITAN”  
- Digititan colour theme applied for demos  

### 8) Platform direction (shown / planned)
- Flutter = one codebase for Android + iOS  
- Desktop (Windows/Mac downloadable app) remains a committed direction; Android is the primary demo target for month-end  

---

## Out of scope by month-end (what not to expect yet)

Please do **not** expect these as live/production by month-end:

1. **Real Google Sign-In** (Firebase) — stub only  
2. **Real OTP emails / SMS** (Gmail SMTP or gateway) — demo OTPs in console / fixed demo codes only  
3. **Live payment gateway** — simulation only; production shopping path is the website  
4. **Full live product catalogue & checkout inside the app** — samples in-app; full shop on website  
5. **LMS / course learning inside the mobile app** — registration/info only  
6. **Ambassador flows in mobile V1** — website only (as locked)  
7. **Donations** — out of scope  
8. **Bank auto-debit** — later (not V1)  
9. **Production App Store / Play Store public release** — prototype / internal demo  
10. **Fully polished final brand book / every screen pixel-perfect** — brand foundation is in; continuous polish can continue  

**Intentionally kept in the backlog after presentation:** real OTP + email delivery, then fuller production auth. **Next after your GO on scope:** real **database / API** connection (so academies, products, and registrations become live data).

---

## How it works (simple architecture for non-technical stakeholders)

```
User opens the app
    → Login (demo accounts / stub Google)
    → Role decides the home experience (Customer / Reseller / Admin)

Customer:
  Training  → browse → register interest
  Academies → SA map → province → academy → events/programmes/location → apply
  Store     → sample products OR open Digititan Store website for full shopping

Reseller:
  Code, clients, commissions, statement, withdrawal request

Admin:
  Orders, reseller approvals, product prices
```

Technically: **UI → use-cases → repository interfaces → data**.  
Today the data layer is **dummy/demo**. After presentation alignment, we swap that layer to a **real database/API** without throwing away the screens and flows you approve.

Website + mobile are one ecosystem direction (shared identity later). Month-end prototype proves the **journeys and business rules**, not every production integration.

---

## Open questions (please confirm or correct)

If any of these should change V1 scope, reply on them:

1. Exact reseller **commission percentages**  
2. Preferred OTP channel later (email / SMS / gateway) — after presentation  
3. Are **3 / 6 month payment plans** required in mobile V1?  
4. Do we need **academy comparison** (this academy vs others) in V1?  
5. Any academy / product / province data that **must** appear in the demo that is not there yet?  
6. Anything in “out of scope” that leadership actually expects **by month-end**?

---

## What I need from you

Please reply with one of:

- **Aligned** — this matches our vision; proceed to presentation, then database/API  
- **Aligned with changes** — list corrections below  
- **Not aligned** — we need a scope workshop before presentation  

Your corrections now are more valuable than polish later. I would rather adjust understanding before we connect live data.

Thank you  
[Your name]  
Digititan / Village NetAcad mobile prototype  

---

## Internal note (for you, not in the email)
- After they confirm: unhold **database only**  
- Keep **OTP + emails** in backlog until after presentation  
- Leave intentional backlog items so the product roadmap stays visible  

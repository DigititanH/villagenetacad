# Presentation guide — Digititan / Village NetAcad mobile prototype

**For:** Monday stakeholder walkthrough (show what exists → collect comments)  
**Password for all demo accounts:** `demo123`  
**OTPs:** Email / register `123456` · Payment `654321`  
**Fast sale code:** `VNA-B-LERATO`

Use this as your speaking notes. Say the **one-liners** out loud; keep the **why** ready if they ask.

---

## 0) Opening (60–90 seconds)

### What this is
> “This is a **working Flutter prototype** of the Digititan / Village NetAcad mobile app. It demonstrates the three pillars — **Training, Academies, Store** — plus the **Reseller sustainability model** and **Ops / Super Admin** operations. Everything you see is clickable end-to-end with demo data.”

### What this is not (say this early — it builds trust)
> “It is **not** production yet. No live database, no real Google Sign-In, no live payment gateway, no real OTP emails. Those are intentional backlog items. After your comments, the next technical step I recommend is connecting a **real database/API** so these same screens run on live content.”

### Why we built it this way
> “I locked the journeys and business rules first — so you can comment on **product logic**, not on unfinished integrations. The architecture separates UI from data, so we can swap demo data for a real backend without throwing away the flows you approve.”

---

## 1) The big picture — how the system hangs together

```
LOGIN (role)
    │
    ├─ Customer ──► Home · Training · Academies · Store · Profile
    ├─ Reseller ──► Pending shell  OR  Dashboard · Clients · Sales
    ├─ Ops Admin ─► Dashboard · Orders · Resellers · Codes · Products
    └─ Super Admin ► everything Ops has + Payouts + Activity
```

**Connection rule (say this once):**
> “Customer, Reseller, and Admin share the same in-memory demo hub. When a customer checks out with a reseller code, the reseller’s Sales and balance update, and Admin sees the order. That proves the journeys are connected — not three separate mock screens.”

### Locked money model (every attributed sale)

| Slice | % | Who gets it in the model |
|---|---|---|
| Beneficiary / individual reseller | **53%** | Seller with `VNA-B-*` code |
| Centre | **26%** | Seller with `VNA-C-*` code (centre org) |
| Digititan / Village NetAcad | **21%** | Programme / Digititan share |

**Reseller UI rule (locked):**
> “Resellers only see **money due to them** — their share. They do not see full sale totals or other parties’ slices. That matches the decision that Digititan pays resellers at month-end.”

**Withdrawal rule (locked):**
> “Withdrawals unlock only on the **last calendar day** of the month. Reseller enters an amount; **Super Admin** must approve. Bank auto-debit is **not** V1.”

---

## 2) Roles — what each does and why

### Customer (`customer@demo.com`)
**Job:** Experience the three pillars as a beneficiary / shopper.  
**Can:** Browse training, map academies, see sample store, demo checkout with a reseller code.  
**Cannot / not yet:** Live LMS learning inside the app; full production shopping in-app.

**Why this role exists:** Leadership locked V1 users as beneficiaries, academies, and shoppers — with shopping production path on the **website**.

### Reseller (`reseller@demo.com` — already approved, code `VNA-B-LERATO`)
**Job:** Sell / refer using a personal code; manage clients; earn their share; withdraw at month-end.  
**Can:** Apply (new accounts), wait for approval, copy code, add/update clients, see sales (own commission), request withdrawal.  
**Cannot:** Issue codes, edit products/prices, change order status (Ops does that).

**Why:** Sustainability model — independent sellers support the programme; Digititan pays them monthly with control.

### Ops Admin (`ops@demo.com`)
**Job:** Day-to-day operations without needing Super Admin.  
**Can:** Orders, products (price / promo), approve/reject resellers + issue `VNA-B` / `VNA-C` codes, view codes.  
**Cannot:** Approve payouts or see Super Activity alone.

**Why dual admin:** Ops should not be blocked waiting for Super for routine work.

### Super Admin (`super@demo.com`)
**Job:** Oversight + money out the door.  
**Can:** Everything Ops can do **plus Payouts** and **Activity**.  
**Why:** Separation of duties — Ops runs the system; Super controls withdrawals.

---

## 3) Codes — explain this carefully (common question)

| Code | Who | Earns |
|---|---|---|
| `VNA-B-*` | **Individual** reseller (e.g. Sipho, Lerato) | **53%** |
| `VNA-C-*` | **Centre / academy organisation** as seller | **26%** |

**Thinking to say:**
> “If Sipho is an individual, he gets a **B** code even if he is linked to a centre. We do **not** give him a C code just because of the link. C codes are for when the **centre itself** is the seller.”

**Honest gap (if asked about linked centre 26%):**
> “The rule is captured in the model and copy. In this prototype you will see the seller’s share clearly in the reseller wallet. A separate centre wallet screen for the linked 26% is not the focus of today’s walkthrough — happy to take that as feedback.”

---

## 4) Screens by role — what / why / how

### A) Login
**Shows:** Village NetAcad logo · Powered by DIGITITAN · email/password · demo login details (collapsed).  
**Why:** Presentation-clean entry; manual login looks more like a real product than four big role buttons.  
**How:** Email + `demo123` routes you into the correct shell by role.

---

### B) Customer — Home
**Shows:** Greeting · programme recruiting CTA · best sellers · promotions · featured training.  
**Why:** First screen should sell the programme and surface store highlights, not a wall of prototype notes.  
**How:** Pulls programmes, training offers, and products flagged best-seller / promo.

### C) Customer — Training
**Shows:** Catalogue of offers → detail → register interest.  
**Why:** Locked decision — **information + registration only**; learning stays in a separate LMS.  
**How:** Interest is recorded in demo state (lead for Admin / follow-up later).

### D) Customer — Academies
**Shows:** SA map by province → academies / pins → detail (location, programmes, events, active/inactive) → interest / org register.  
**Why:** Academies are a V1 pillar; map makes geography tangible for stakeholders.  
**How:** Province tap filters; academy detail is the “place” story.

### E) Customer — Store
**Shows:** Sample catalogue (with promo ~~was~~ now pricing) · button to open Digititan Store website.  
**Why:** Locked — **samples in-app**; **full shopping on** `https://www.shop.digititan.co.za/`.  
**How:** Demo cart/checkout exists only to prove reseller-code attribution; production path is the website CTA.

### F) Customer — Product detail / Cart / Checkout / Payment OTP
**Shows:** Product info, sale price if promo, demo cart, referral code field, payment OTP.  
**Why:** Prove “sale with code → reseller earns” without claiming a live payment gateway.  
**How:** Enter code (e.g. `VNA-B-LERATO`) → Pay → OTP `654321` → order attributed in shared demo hub.

### G) Customer — Profile
**Shows:** Identity, orders, logout; demo reference collapsed.  
**Why:** Clean account screen; cheat sheet available if you forget OTPs mid-demo.

---

### H) Reseller — Application pending
**Shows:** Waiting state until Ops approves.  
**Why:** Real process is Apply → Approve → Code — not instant self-service codes.  
**How:** New reseller register lands here; Refresh after Ops approval unlocks the full shell.

### I) Reseller — Dashboard
**Shows:** Referral code (copy) · earnings due to you · month-end lock / simulate toggle · withdraw · statement.  
**Why:** Reseller should feel “this is my money, locked until month-end.”  
**How:** Balance = sum of their commission share only. Simulate month-end is **demo-only** so you can show withdraw when today is not the last day.

### J) Reseller — Clients
**Shows:** Leads with status pipeline: pending → confirmed → bought / didNotBuy.  
**Why:** Resellers manage a sales pipeline, not just a code.  
**How:** Add client (FAB) · tap to change status.

### K) Reseller — Sales
**Shows:** Attributed sales with **commission only** (+R…).  
**Why:** Reinforces “you only see your share.”  
**How:** Appears after a customer checkout with their code.

---

### L) Ops — Dashboard
**Shows:** Metric tiles (orders, revenue, pending resellers, products, withdrawals…).  
**Why:** Ops needs a glance at workload.  
**How:** Aggregated from demo hub.

### M) Ops — Orders
**Shows:** Live demo orders; tap to update status.  
**Why:** Day-to-day order ops without developers.

### N) Ops — Resellers
**Shows:** Pending applications · Approve (pick Beneficiary vs Centre) · Reject.  
**Why:** Gatekeeping + correct code type is a business control.  
**How:** Approve issues `VNA-B-*` or `VNA-C-*` and unlocks that reseller.

### O) Ops — Codes
**Shows:** Issued codes list.  
**Why:** Audit / visibility of what was issued.

### P) Ops — Products
**Shows:** Catalogue · edit price · promo was/now · stock long-press.  
**Why:** Ops can run specials without a developer.  
**How:** Promo dialog captures **Was** + **Now** so Store/Home show strikethrough pricing.

### Q) Super — Payouts / Activity
**Shows:** Withdrawal requests to approve/reject · activity log.  
**Why:** Money-out control + oversight trail.

---

## 5) Recommended Monday walkthrough (≈12–15 min + comments)

Do **not** try to show everything. Aim for clarity, then ask for comments.

### Act 1 — Frame (1–2 min)
1. Opening pitch (section 0).  
2. Show login briefly · mention demo accounts · password `demo123`.

### Act 2 — Customer pillars (3–4 min)
1. Login `customer@demo.com`.  
2. **Home** — programme CTA + promos (mention strikethrough if visible).  
3. **Training** — “info + interest; LMS separate.”  
4. **Academies** — map → one province → one academy.  
5. **Store** — samples + “full shop is the website” (open or point at URL).

### Act 3 — Money story (5–6 min) — the heart
**Short path (safer if time is tight):**
1. Logout → `reseller@demo.com` → show code `VNA-B-LERATO` + earnings tile.  
2. Logout → Customer → Store → demo cart → checkout with `VNA-B-LERATO` → OTP `654321`.  
3. Back to Reseller → **Sales** updated · balance reflects **53%** thinking.  
4. Toggle **Simulate month-end** → Withdraw → logout → `super@demo.com` → **Payouts**.

**Optional full path (if they want process):**
Register new reseller → pending → Ops Approve as Beneficiary → Refresh → then sale.

### Act 4 — Ops control (2 min)
1. `ops@demo.com` → Resellers / Products promo · “Ops works without Super.”  
2. `super@demo.com` → “Super adds Payouts + Activity.”

### Act 5 — Close (1–2 min)
> “That’s the prototype scope. I want your comments on: (1) journeys, (2) split rules, (3) what must change before we connect a real database. Explicitly out for now: live Google, live OTP email, live payments, bank auto-debit, LMS inside the app.”

---

## 6) Decision log — “why we did it this way”

| Decision | Why |
|---|---|
| Samples in-app + website for full shop | Leadership locked shoppers’ production path on Digititan Store site |
| Training = info + interest only | Learning stays in separate LMS |
| Dual Ops / Super | Day-to-day ops must not wait on Super; payouts stay controlled |
| B vs C codes | Individuals vs centre organisations earn different locked slices |
| Reseller sees only own share | Avoid confusion; matches “Digititan pays you your due” |
| Withdrawals last day only | Month-end payout discipline; Super still approves |
| Demo OTPs / stub Google | Don’t over-claim production auth before presentation |
| Shared demo hub (not real DB yet) | Prove connected journeys first; swap data layer after GO |
| Promo was/now | Ops can run specials; UI shows the price change clearly |
| Presentation UI polish | Meeting is about product thinking — screens should not look like a debug dump |

---

## 7) Likely questions — short answers

**“Is shopping live in the app?”**  
No — samples + demo checkout for attribution. Live shop is the website.

**“Where does learning happen?”**  
Separate LMS. App registers interest.

**“When do resellers get paid?”**  
Month-end (last calendar day request) → Super approves. Digititan pays; bank auto-debit later.

**“Why 53 / 26 / 21?”**  
Locked leadership split for attributed sales. B-code sellers earn 53%; C-code centre sellers earn 26%; Digititan 21%.

**“Is this production-ready?”**  
No — prototype for comment. Next: real DB/API after alignment; real OTP/Google after that.

**“Can Ops change prices without developers?”**  
Yes — Products tab (and promo was/now).

**“What about donations / ambassador?”**  
Out of mobile V1 (ambassador website-only as locked).

---

## 8) Accounts cheat sheet (print or keep open)

| Role | Email | Password |
|---|---|---|
| Customer | `customer@demo.com` | `demo123` |
| Reseller | `reseller@demo.com` | `demo123` |
| Ops Admin | `ops@demo.com` | `demo123` |
| Super Admin | `super@demo.com` | `demo123` |

| Demo code | Meaning |
|---|---|
| `VNA-B-LERATO` | Seeded beneficiary reseller code (53%) |
| OTP `123456` | Register / email verify |
| OTP `654321` | Payment |

---

## 9) After Monday — what you ask them for

End by requesting concrete comments on:

1. Any journey that feels wrong or missing  
2. Split / code rules (B vs C, month-end)  
3. Store boundary (website vs in-app)  
4. Priority for next build: **database/API** vs other  

Write their comments down live. That becomes your next sprint input.

---

*Companion docs:* `12-LOCKED-DECISIONS.md` · `18-RESELLER-CODES-AND-DUAL-ADMIN.md` · `17-STAKEHOLDER-EMAIL-MONTH-END-SCOPE.md`

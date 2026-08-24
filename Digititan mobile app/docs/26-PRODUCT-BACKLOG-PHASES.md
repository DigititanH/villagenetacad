# Village NetAcad — Product backlog (Phases 1–12)

Updated: 24 Aug 2026  
Includes **meeting Waves 1–3** folded into the existing phase plan (not parallel tracks).

| Legend | Meaning |
|--------|---------|
| **[Wave 1]** | Meeting polish — **done** (install on laptop) |
| **[Wave 2]** | Meeting trust / OTP / LMS / PayFast story — now inside Phases **2, 7, 8, 9** |
| **[Wave 3]** | Meeting security / POPI / launch — now inside Phases **4, 7, 8, 10** + Launch gate |
| *(open)* | Leadership still needs to lock |

---

## How to read the order

| Phases | Kind of work |
|--------|----------------|
| **1** | They can see the product (**Wave 1 done**) |
| **2–3** | Dummy / presentation depth + one brand |
| **4–6** | Wire live website API (accounts, cart, catalogue) |
| **7–8** | Real money + reseller rules (**Wave 2 money + Wave 3 security land here**) |
| **9–10** | Real academies/training + notifications/ops (**LMS live + launch polish**) |
| **11–12** | Desktop + finance add-ons |
| **Launch gate** | Everything up before store / wide release (**Wave 3 checklist**) |

**Phase 4–5** = website and app are actually one system.  
Everything after that is production depth, not more dummy tabs.

---

## Phase 1 — They can see the product

**Status: Done** (plus Wave 1 meeting polish).

Original Phase 1 prototype + meeting Wave 1:

| Item | Source | Status |
|------|--------|--------|
| Role journeys (Customer / Reseller / Ops / Super) | Phase 1 | Done |
| Bigger login logo | **[Wave 1]** | Done |
| Min withdraw R100 (UI blocked + clear error) | **[Wave 1]** | Done |
| Legal drafts (T&Cs, privacy, security, returns) | **[Wave 1]** | Done — POPI full copy later |
| Academy/org register with Digititan (not Cisco-only) | **[Wave 1]** | Done |
| App icon = Village NetAcad | **[Wave 1]** | Done |

**Done when:** stakeholders can open the app and walk the core story without empty shells.

---

## Phase 2 — Finish the presentation story

Original leftover journeys; **dummy data is fine**.  
**Meeting Wave 2 prototype items are added here** so Monday / stakeholder walks don’t need “we’ll do that later.”

### Original Phase 2
- Returns / refund request (7-day window after delivery)
- Product review prompt after delivered + review form
- Ambassador apply + under-review + public verify + “never pay cash to individuals”
- Academy performance dashboard (registrations / sales / completions)
- Academy comparison / rankings (basic)
- Purchase T&Cs (international 1–2 months) + Pinnacle warranty copy
- Simulated notifications: order status, review ask, reseller sale confirm

### Add from meeting Wave 2 (still dummy OK)
| Meeting # | Work | Notes |
|-----------|------|--------|
| **4** | Reseller **QR** + buyer **Verify reseller** | Everyone in DB; scan/code → name, status, academy |
| **2** | OTP channel picker: **Email + SMS** | Demo codes OK until provider live |
| **5** | LMS learner fields on forms | Full name, **gender**, email stored in DemoHub |

### Suggested Phase 2 build order (logical)
1. Returns / refund (7-day)  
2. Review after delivered  
3. **[Wave 2]** Verify reseller + QR  
4. **[Wave 2]** SMS/Email OTP picker  
5. **[Wave 2]** LMS fields on training/academy interest  
6. Ambassador apply / verify / no-cash copy  
7. Academy performance + rankings  
8. Purchase T&Cs + Pinnacle warranty  
9. Simulated notifications  

**Done when:** stakeholders can walk  
Returns → Review → **Verify reseller** → OTP (SMS option) → LMS interest → Ambassador → Academy league  
without you explaining a gap.

*(Open)* Ambassador: locked notes said website-only V1; Phase 2 list brings it into the app for the story — confirm with leadership.

---

## Phase 3 — Make it feel like one Village NetAcad product

Still prototype, but stop looking like a separate Digititan app.

- Match website branding (dark + burnt orange, Village NetAcad logo) instead of Digititan blue/green  
- Store CTA opens **Village NetAcad shop**, not `shop.digititan.co.za`  
- Profile: Become a Reseller / Become an Ambassador  
- Demo role-switch only if still needed for decks  
- Home: keep Training / Academies / Store equal  

### Checkout story — decision to lock *(open)*

| Source | Says |
|--------|------|
| This Phase 3 (older plan) | No in-app PayFast — “Complete on website” |
| Meeting **[Wave 2]** #10–11 | Same gateway as Digititan Store (**PayFast**) + **payment in the app** |

**Orderly approach (recommended):**
1. **Phase 3:** unify brand + store URL; checkout CTA can still say “same PayFast as the website.”  
2. **Phase 5:** shared cart; default path = pay on website (ecosystem already works).  
3. **Phase 7:** live PayFast + OTP; **then** add in-app PayFast (WebView / hosted) if leadership confirms meeting #11.

Do **not** build two different gateways.

**Done when:** a stakeholder can’t tell the app and site are two different brands.

---

## Phase 4 — Shared accounts (real ecosystem)

First engineering phase. Absorbs early **[Wave 3]** auth basics.

- Point the app at production `/api`  
- Same email/password as the website (`registrations` + `logins`)  
- JWT in secure storage; `GET /auth/me` on launch  
- Register customer / reseller + academy name against the live API  
- Reseller pending until admin approves (website already does this)  
- Drop dummy `customer@demo.com` for UAT (keep staging DB if needed)  
- **[Wave 3]** Passwords never stored in app plaintext; HTTPS only to API  

**Done when:** website register → app login with the same details (and the reverse).

---

## Phase 5 — Shared cart + checkout on the website

- App `POST /api/cart` (server cart, not phone RAM)  
- Checkout opens live site login → Cart  
- Same items on the website; **PayFast stays on the web** for this phase  
- App My Orders reads `GET /api/orders/my-orders`  
- Optional: `?next=/cart` on website login  

**Meeting note:** In-app PayFast waits for **Phase 7** unless leadership insists earlier.

**Done when:** add hoodie in the app → pay on the site → order appears in the app.

---

## Phase 6 — Store parity (live catalogue)

- Products, prices, stock, images from MySQL  
- Product detail: sizes/colours like the website  
- Wishlist (API exists; app doesn’t yet)  
- Order tracking from real pending / processing / shipped / delivered  
- Admin product/price/promo edits via same admin APIs  

**Done when:** the app catalogue is the real store, not sample SKUs.

---

## Phase 7 — Payments, security, policy (live)

This is where **meeting Wave 2 money** and **Wave 3 security / OTP / legal final** become real.

### From original Phase 7
- Approved gateway = **PayFast** (already on the website)  
- OTP: decide SMS / email / gateway *(open — meeting wants Email + SMS)*  
- T&Cs accepted before pay  
- Returns policy enforced (7 days / wording *(open)*)  
- Warranty messaging = Pinnacle  
- No cash / no pay-an-ambassador copy in checkout  

### Add from meeting Wave 2 + Wave 3
| Meeting # | Work | Notes |
|-----------|------|--------|
| **10** | Same PayFast merchant as website | One gateway only |
| **11** | Payment via the app as well | In-app WebView / hosted PayFast **after** website path is solid |
| **2** | Live SMS + email OTP | Provider + rate limit + expiry |
| **3** | Tight security | TLS, hashed passwords, role authz, PayFast ITN signature verify, audit log |
| **8** | Lawyer-ready legal + **POPI** | Replace Wave 1 drafts |

**Done when:** money only moves through PayFast, with T&Cs + OTP + security signed off.

---

## Phase 8 — Reseller production

### Original
- Live referral codes (`VNA-B-*` / `VNA-C-*`)  
- Independent seller → programme-support bucket  
- Split **53 / 26 / 21** locked  
- Clients statuses from real orders + leads  
- Earnings + Digititan 21% for ops/statements  
- Month-end statement from real sales  
- Withdrawals last calendar day + Super Admin approval (live)  

### Add from meeting
| Meeting # | Work | Notes |
|-----------|------|--------|
| **4** | Live QR / verify API | `GET /api/resellers/verify/{code}` in production |
| **7** | Min withdraw **R100** server-side | Wave 1 UI already done |

**Done when:** a centre and an independent seller each show a real month-end number, and a buyer can verify the reseller is legit.

---

## Phase 9 — Academies + training (live, not dummy)

### Original
- Academy list/map from a real table (new backend if website lacks it)  
- Active / inactive, recruitment dates, courses  
- Academy + NPO registration → admin queue (not console)  
- Training interest / programme apply stored per user  
- Online vs in-person registration links  
- Later: recommend academies by interest  

### Add from meeting
| Meeting # | Work | Notes |
|-----------|------|--------|
| **5** | Learner **full name, gender, email** in DB | Align / export to LMS |
| **6** | Academy register with us first | Wave 1 form → live admin queue (not Cisco-only) |

**Done when:** map → province → academy is real data; applications hit an inbox; LMS fields exist in DB.

---

## Phase 10 — Notifications + ops admin without developers

### Original
- Payment confirmation  
- Order status changes  
- Delivered → please review  
- Reseller sale confirmation  
- Recruitment callouts on Home  
- Ops Admin: products, promos, prices, orders, reseller approval, academy content, ambassador queue  
- Super Admin: system/config  

### Add from meeting Wave 3
| Meeting # | Work | Notes |
|-----------|------|--------|
| **12** | Minor polish everywhere | Empty states, errors, copy, icons |
| **12** | Ops can run without a developer | Queues for academy orgs, resellers, withdrawals |

**Done when:** ops can run a week without a developer and users see status in the app.

---

## Launch gate — “everything up” **[Wave 3]**

Run this **after Phases 7–10 are green**, before pushing Phase 11 hard or public launch.

- [ ] PayFast live keys + notify URL reachable  
- [ ] SMS + email OTP live (or documented fallback)  
- [ ] HTTPS everywhere; passwords hashed; sessions revoke on logout  
- [ ] Legal + POPI lawyer-reviewed  
- [ ] Village NetAcad app icon on store builds  
- [ ] Learner fields sync/export path to LMS  
- [ ] Min withdraw R100 enforced **server-side**  
- [ ] Reseller QR / verify works on web + app  
- [ ] Academy org queue visible to Ops  
- [ ] Smoke: login → shop → PayFast → OTP → order → reseller balance → month-end withdraw ≥ R100  
- [ ] Smoke every role: Customer / Reseller / Ops / Super  

**Done when:** launching does not depend on “we’ll fix that minor thing later.”

---

## Phase 11 — Desktop + same services beyond the phone

Locked: downloadable Windows/Mac later.

- Flutter desktop (folders exist) **or** web/desktop shell of the same API  
- Same login, store, training, academies, reseller  

**Done when:** a parent can do the same jobs on a PC without Android/iOS.

---

## Phase 12 — Money extras *(almost all open)*

- 3-month / 6-month payment plans *(undecided)*  
- Bank auto-debit from reseller accounts *(not V1 in locked notes)*  
- Incentives/vouchers for top academies  
- Full financial accountability reporting *(deferred)*  

**Done when:** leadership picks yes/no; then build. **Do not start before Phase 7–8.**

---

## After 12 / not a phase until leadership locks

1. Exact primary audience (not “everyone”)  
2. Final return-window wording  
3. Confirm PayFast as the partner (website already uses it)  
4. OTP channel — meeting leans **Email + SMS**  
5. Ambassador: website-only vs in-app (Phase 2 list)  
6. Donations — out of scope unless reversed  
7. LMS / course playback — training stays info + register; **data fields** still required (Phase 2 → 9)  
8. Shared login is one API (Phase 4), not a data migration  
9. **In-app PayFast vs website-only** — meeting vs older Phase 3/5 *(resolve in Phase 7)*  

---

## Meeting Waves → Phase map (quick)

| Meeting item | Wave | Lives in phase |
|--------------|------|----------------|
| Bigger logo, R100 withdraw UI, legal drafts, academy register-first, app icon | 1 | **Phase 1** (done) |
| Reseller QR / buyer verify | 2 | **Phase 2** (demo) → **Phase 8** (live) |
| SMS + email OTP | 2 | **Phase 2** (UI) → **Phase 7** (live) |
| LMS name / gender / email | 2 | **Phase 2** (forms) → **Phase 9** (DB/LMS) |
| Same PayFast + pay in app | 2 | **Phase 3** (brand/story) → **Phase 5** (web pay) → **Phase 7** (live + in-app) |
| Tight security | 3 | **Phase 4** (basics) + **Phase 7** (full) |
| POPI / final legal | 3 | **Phase 7** + Launch gate |
| Everything up / minor polish | 3 | **Phase 10** + **Launch gate** |

---

## What to do next (orderly)

1. **Phase 2** — finish presentation story **including** Wave 2 demo items (QR verify → SMS OTP → LMS fields), then Returns/Review/Ambassador/Academy league.  
2. **Phase 3** — one brand; lock checkout decision for later Phase 7.  
3. **Phase 4–6** — real API, cart, catalogue.  
4. **Phase 7–8** — live PayFast, security, OTP, reseller verify + R100 server-side.  
5. **Phase 9–10** — live academies/LMS fields + ops.  
6. **Launch gate** — checklist green.  
7. **Phase 11–12** — desktop + money extras only after leadership yes.

**Suggested immediate build:** Phase 2 item — **Reseller QR + Verify reseller** (answers the meeting’s biggest trust question first).

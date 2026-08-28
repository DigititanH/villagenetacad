# Village NetAcad — Product backlog (Phases 1–12)

Updated: 24 Aug 2026  
**Meeting Waves 1–3 are folded into these phases** (not a second roadmap).

| Tag | Meaning |
|-----|---------|
| **[W1]** | Meeting Wave 1 — demo polish (**done**) |
| **[W2]** | Meeting Wave 2 — trust / OTP / LMS / PayFast story |
| **[W3]** | Meeting Wave 3 — security / POPI / launch readiness |
| *(open)* | Leadership still needs to lock |

---

## How to read this

| Phases | Kind of work |
|--------|----------------|
| **1** | They can see the product (**[W1] done**) |
| **2–3** | Dummy screens so the stakeholder story is complete (**[W2] demo items live in Phase 2**) |
| **4–6** | Wire the live website API (accounts, cart, catalogue) (**[W3] auth basics start in Phase 4**) |
| **7–8** | Real money + reseller rules (**[W2] live PayFast/OTP + [W3] security; [W2] QR live in Phase 8**) |
| **9–10** | Real academies/training + notifications/ops (**[W2] LMS fields live in Phase 9; [W3] polish in Phase 10**) |
| **Launch gate** | Everything up before public / store push (**[W3] checklist**) |
| **11–12** | Desktop + finance add-ons |

**Phase 1** = they can see the product.  
**Phase 4–5** = website and app are actually one system.  
Everything after that is production depth, not more dummy tabs.

---

## Phase 1 — They can see the product

**Status: Done** (+ meeting Wave 1).

- Role journeys (Customer / Reseller / Ops / Super)  
- **[W1]** Bigger login logo  
- **[W1]** Min withdraw **R100** (button disabled under R100 + clear error)  
- **[W1]** Legal drafts (T&Cs, privacy, security, returns) — POPI full copy later  
- **[W1]** Academy/org register with Digititan first (not Cisco-only)  
- **[W1]** App icon = Village NetAcad programme  

**Done when:** stakeholders can open the app and walk the core story without empty shells.

---

## Phase 2 — Finish the presentation story

Original leftover journeys; **still dummy data is fine**.  
**Meeting Wave 2 prototype pieces are added here** so the walk doesn’t have “we’ll do that later.”

### Original Phase 2
- Returns / refund request (7-day window after delivery)  
- Product review prompt after delivered + review form  
- Ambassador apply + under-review + public verify + “never pay cash to individuals”  
- Academy performance dashboard (registrations / sales / completions)  
- Academy comparison / rankings (basic)  
- Purchase T&Cs (international 1–2 months) + Pinnacle warranty copy  
- Simulated notifications: order status, review ask, reseller sale confirm  

### Meeting Wave 2 — add to Phase 2 (dummy OK)
| Meeting | Work | Why here |
|---------|------|----------|
| **#4** | Reseller **QR** + buyer **Verify reseller** | Answers “is this reseller legit?” in the demo story |
| **#2** | OTP channel picker: **Email + SMS** | Stakeholder can see SMS option (demo codes OK) |
| **#5** | LMS learner fields on forms | Full name, **gender**, email in DemoHub |

### Phase 2 build order (logical)
1. Returns / refund (7-day)  
2. Review after delivered  
3. **[W2]** Verify reseller + QR  
4. **[W2]** SMS / Email OTP picker  
5. **[W2]** LMS fields on training / academy interest  
6. Ambassador apply / verify / no-cash copy  
7. Academy performance + rankings  
8. Purchase T&Cs + Pinnacle warranty  
9. Simulated notifications  

**Done when:** stakeholders can walk  
Returns → Review → **Verify reseller** → OTP (SMS option) → LMS interest → Ambassador → Academy league  
without you explaining a gap.

*(Open)* Ambassador: older lock said website-only V1; Phase 2 brings it into the app for the story — confirm with leadership.

---

## Phase 3 — Make it feel like one Village NetAcad product

Still prototype, but stop looking like a separate Digititan app.

- Match website branding (dark + burnt orange, Village NetAcad logo) instead of Digititan blue/green  
- Store CTA opens **Village NetAcad shop**, not `shop.digititan.co.za`  
- Profile: Become a Reseller / Become an Ambassador  
- Demo role-switch only if you still need it for decks  
- Home: keep Training / Academies / Store equal  

### Checkout story — **locked for v1** (store compliance)

| Source | Says |
|--------|------|
| Older Phase 3 / 5 | No in-app PayFast — “Complete on website” |
| Meeting **[W2] #10–11** | Same gateway (**PayFast**) + optional payment in the app |
| **Investigation (Play / App Store)** | Digital goods often require Apple/Google IAP; in-app PayFast = higher rejection risk |

**Locked approach (v1):**
1. Browse / add to cart **in the app**.  
2. **Pay on the website** (system browser → `/cart` → Proceed to Checkout → PayFast).  
3. Do **not** embed PayFast (or WebView checkout) in the app for v1.  
4. Revisit in-app pay / store IAP only after: digital vs physical goods classification, Play/Apple account ownership, and leadership sign-off.

Do **not** build two gateways. Website PayFast remains the only money path for now.

**Done when:** a stakeholder can’t tell the app and site are two different brands.

### Phase 3 delivery note
Implemented on branch `cursor/phase3-one-product-09ad`: Village NetAcad shop URL, Profile Become Reseller/Ambassador, deck demo role-switch, equal Home pillars. Full burnt-orange website theme polish can continue if leadership wants a tighter visual match.

---

## Phase 4 — Shared accounts (real ecosystem)

First engineering phase. Absorbs early **[W3]** auth hygiene.

- Point the app at production `/api`  
- Same email/password as the website (`registrations` + `logins`)  
- JWT in secure storage; `GET /auth/me` on launch  
- Register customer / reseller + academy name against the live API  
- Reseller pending until admin approves (website already does this)  
- Drop dummy `customer@demo.com` for UAT (keep a staging DB if needed)  
- **[W3]** HTTPS only; no plaintext passwords in the app  

**Done when:** website register → app login with the same details (and the reverse).

### Phase 4 delivery note
Branch `cursor/phase4-shared-accounts-09ad`: shared accounts verified both ways on production (website↔app login + app register→website). Live UI hides demo credentials. Remaining: staging/HTTPS policy if needed; then **Phase 5** shared cart.

---

## Phase 5 — Shared cart + checkout on the website

What you described earlier.

- App opens website `/cart` (no website frontend deploy). User taps Proceed to Checkout on the site.  
- Same items on the website when live products exist; **PayFast stays on the web for this phase**  
- App My Orders reads `GET /api/orders/my-orders`  

**Parked — needs website frontend permission (do when allowed):**  
After app “Complete on website”, login must return to **`/cart` or `/checkout`** (not home).  
Implement `?next=` on Login + Cart/ProtectedRoute; prefer return to **`/checkout`** so PayFast is one step closer. Until then: log in on the site first, then open cart from the app.

**Meeting note:** In-app PayFast is **deferred** (store compliance). v1 = pay on website.

**Done when:** add hoodie in the app → pay on the site → order appears in the app.

### Phase 5 delivery note
Branch `cursor/phase5-shared-cart-09ad`: live products + server cart + website PayFast checkout CTA + my-orders from API. Dummy store remains when `API_BASE_URL` is empty.

---

## Phase 6 — Store parity (live catalogue)

- Products, prices, stock, images from MySQL (not dummy bags/kits)  
- Product detail: sizes/colours like the website  
- Wishlist (API exists on the website; app doesn’t have it)  
- Order tracking statuses from real pending / processing / shipped / delivered  
- Admin product/price/promo edits on the website (or app calling the same admin APIs)  

**Done when:** the app catalogue is the Digititan / Village NetAcad store, not sample SKUs.

### Phase 6 delivery note
Branch `cursor/phase6-store-parity-09ad`: product images, sizes/colours into cart, wishlist screen, order status pipeline. Still depends on live products existing in MySQL for full production UAT.

---

## Phase 7 — Payments, security, policy (live)

Where **[W2] money/OTP** and **[W3] security/legal** become real.

### Payment path (locked for v1)
- Money moves via **website PayFast** only (app → browser cart/checkout).  
- **No** in-app PayFast / WebView checkout in Phase 7 unless leadership re-opens store-compliance (digital goods → likely Apple/Google IAP).  
- Same PayFast merchant as the website; configure live keys + notify URL on the **server/website**. **Live keys done (UAT).**

### PayFast ITN — **UAT PASSED** (28 Aug 2026)
- Live `notify.php` → `PayfastController::notify()` → `OrderFulfillment`  
- Order 18 auto-`paid`; affiliated R5 → seller R2.65 + centre R1.30 (+ prior order 17)  
- See `docs/34-PHASE7-PAYFAST-ITN.md` and `docs/38-PHASE8-LEDGER-CLIENTS.md`.

### Parked / later in Phase 7
- Live email OTP (Gmail/cPanel SMTP) — **on hold**  
- SMS OTP: provider TBD  
- Lawyer POPI / legal (replace drafts)  
- T&Cs must be accepted before pay  
- Returns policy wording polish  
- Full security audit log pass  

### Meeting inserts
| Meeting | Work | Notes |
|---------|------|--------|
| **#10 [W2]** | Same PayFast merchant as the website | **Done** (live) |
| **#11 [W2]** | Payment via the app as well | **Deferred** — v1 stays browser checkout |
| **#2 [W2]** | Live SMS + email OTP | **On hold** |
| **#3 [W3]** | Tight security | ITN notify **UAT PASSED** 28 Aug; more later |
| **#8 [W3]** | Lawyer-ready legal + **POPI** | **Parked** |

**Done when:** money only moves through website PayFast, with T&Cs + OTP + security signed off (in-app pay not required for done).

---

## Phase 8 — Reseller production

**Slice 1 (this branch):** live verify API + server R100 / last-day withdraw + app `HttpResellerRepository`.

### Original
- Live referral codes (`VNA-B-*` / `VNA-C-*`) — **issued at register** (UAT passed 27 Aug 2026)  
- Independent seller → Digititan programme-support — **53% at register + fulfill**  
- Beneficiary under a centre: sales split **53 / 26 / 21** — **OrderFulfillment + clients + statement** (slice 2)  
- Clients: bought / pending / confirmed / did not buy — **live API + app** (slice 2)  
- Reseller sees their earnings; Digititan 21% for ops/statements — **statement + profile share totals** (slice 2)  
- Month-end statement from real sales — **GET /api/resellers/statement** (slice 2)  
- Withdrawals last calendar day + Super Admin approval (live, not DemoHub) — **slice 1: server gate done**  

**Slice 2 branch:** `cursor/phase8-ledger-clients-09ad` — live deployed + **UAT PASSED** (clients + statement + paid 53/26/21 + ITN auto-fulfill, 28 Aug 2026). See `docs/38-PHASE8-LEDGER-CLIENTS.md`.  

### Meeting inserts
| Meeting | Work | Notes |
|---------|------|--------|
| **#4 [W2]** | Live QR / verify API | **Slice 1:** `GET /api/resellers/verify/{code}` + app wired |
| **#7 [W1→live]** | Min withdraw **R100** server-side | **Slice 1:** enforced in `ResellersController::withdraw` (+ last calendar day) |

**Done when:** a centre and an independent seller can each show a real month-end number, **and** a buyer can verify the reseller is legit.

**Slice 1 done when:** verify works on live API + app; withdraw rejects &lt; R100 and non–last-day.

**Slice 1 UAT (26 Aug 2026): PASSED** — live verify, app verify, withdraw locked / R50 / R100 last-day gates.

---

## Phase 9 — Academies + training (live, not dummy)

**Status (27 Aug 2026):**  
- **Slice A — UAT PASSED:** website-parity courses, photos, light theme, pagination, Cisco / website enrol.  
- **Slice B — WAIT:** academies table/API (**Khanyi** / website).

### Blockers / owners
| Item | Owner | Action |
|------|--------|--------|
| Academies table + API on live site | **Khanyi** (website) | App calls API like customers/resellers **when ready** |
| Cisco NetAcad enrol linking | Website / Cisco ops team | Free enrol → Cisco; learner under Village NetAcad; they see enrolments in Cisco DB |
| Paid CCNA (R550 × 6) | Website page already | App opens **`https://villagenetacad.co.za/courses/enrol`** (browser), same pattern as shop cart |

### Slice A — what we *can* implement now (app)
1. **Hardcoded courses list** in the app (mirror live website catalogue — free Skills/NetAcad titles + CCNA pathway).  
2. **Free course CTA:** open Cisco `enrollUrl` in the system browser (same as website).  
3. **Paid CCNA CTA:** open website **`/courses/enrol`** (PayFast Subscribe form on site) — **no in-app PayFast**.  
4. Optional: course detail screen with “Enroll on Cisco” vs “Pay on website” based on course type.  
5. Keep Training tab / Home featured training aligned with this static catalogue (replace pure DemoHub fiction where it conflicts).

### What Phase 9 is *not* (v1)
- Putting courses into MySQL / building a courses API  
- Building a Village NetAcad LMS inside the app  
- In-app PayFast for CCNA / course fees  
- Inventing academies DB in the mobile repo before Khanyi’s API  

### Slice B — once website academies API exists
- Consume academies API (list / province / active)  
- Academy / NPO register → admin queue (if provided; until then ASC Microsoft Form)  
- Optional later: learner name/gender/email when DB path exists  

### Original backlog (Slice B+)
- Academy list/map from a real table  
- Active / inactive, recruitment dates, academy metadata  
- Meeting **#5**: learner full name, gender, email in DB when path exists  
- Meeting **#6**: academy register with us first → live admin queue  

**Slice A done when:** app shows website-parity courses; free enrol → Cisco; paid CCNA → website `/courses/enrol`.  
**Slice A UAT (27 Aug 2026): PASSED** — theme, photos, filters, pagination, enrol CTAs.  
**Phase 9 done when:** Slice A + academies from website API + enrol rules above.

---

## Phase 10 — Notifications + ops admin without developers

**Ops Admin live wire (28 Aug 2026): PASSED** — `HttpAdminRepository` on branch `cursor/phase8-ledger-clients-09ad`; role smoke D PASS. See `docs/39-ROLE-SMOKE-UAT.md`.

**In-app notifications (28 Aug 2026):** order paid / status / reseller sale → `notifications` table + Profile inbox. See `docs/40-PHASE10-IN-APP-NOTIFICATIONS.md`. Upload pack: `deploy/phase10-notifications-live/`.

### Still open in Phase 10
- Ambassador queue + academy org queue on live API (thin / empty today)  
- Super Admin as distinct role (live DB only has `admin`)  
- Push / email when SMTP is ready (in-app already covers the three sale events)  

### Original
- Payment confirmation  
- Order status changes  
- Delivered → please review  
- Reseller sale confirmation  
- Recruitment / “we’re looking for young people” on Home  
- Ops Admin: products, promos, prices, order status, reseller approval + deactivate/lockout, academy content, ambassador queue + list + deactivate  
- Super Admin: system/config (devs)  

### Meeting Wave 3 insert
| Meeting | Work | Notes |
|---------|------|--------|
| **#12 [W3]** | All minor elements polished | Empty states, errors, copy, icons |
| **#12 [W3]** | Ops can run without a developer | Queues for academy orgs, resellers, withdrawals |

**Done when:** ops can run a week without a developer and users see status in the app.

---

## Launch gate — “everything up” **[W3]**

Run **after Phases 7–10 are green**, before hard-pushing Phase 11 or public launch.  
This is meeting item **#12** as a checklist, not a separate “Wave 3 project.”

- [x] PayFast live keys + notify URL reachable — **ITN auto-fulfill UAT PASSED 28 Aug 2026**  
- [ ] SMS + email OTP live (or documented fallback)  
- [ ] HTTPS everywhere; passwords hashed; sessions revoke on logout  
- [ ] Legal + POPI lawyer-reviewed  
- [ ] Village NetAcad app icon on store builds  
- [ ] Learner fields sync/export path to LMS  
- [x] Min withdraw R100 enforced **server-side** — Phase 8 slice 1 UAT PASSED  
- [x] Reseller QR / verify works on web + app — Phase 8 slice 1 UAT PASSED  
- [ ] Academy org queue visible to Ops  
- [x] Smoke: login → shop → PayFast → order → reseller balance — **PASSED 28 Aug** (OTP email still parked)  
- [x] Smoke every role: Customer / Reseller / Ops / Super — **PASSED 28 Aug** (Super = N/A on live; see `docs/39-ROLE-SMOKE-UAT.md`)  

**Done when:** launching does not depend on “we’ll fix that minor thing later.”

---

## Phase 11 — Desktop + “same services beyond the phone”

Locked: downloadable Windows/Mac later. Meeting example: Standard Bank desktop.

- Flutter desktop (folders exist, not a product yet)  
- Or a proper web/desktop shell of the same API  
- Same login, store, training, academies, reseller  

**Done when:** a parent can do the same jobs on a PC without installing Android/iOS.

---

## Phase 12 — Money extras (almost all still “open decisions”)

- 3-month / 6-month payment plans (in v1 or not — undecided)  
- Bank auto-debit from reseller accounts (not V1 in locked notes)  
- Incentives/vouchers for top academies  
- Full financial accountability reporting (meeting deferred this)  

**Done when:** leadership picks yes/no; then build. **Don’t start this before Phase 7–8.**

---

## After 12 / still not a phase until leadership locks it

1. Exact primary audience (not “everyone”)  
2. Final return-window wording  
3. Confirm PayFast as the partner (website already uses it)  
4. OTP channel — meeting leans **Email + SMS**  
5. Whether ambassador stays website-only (locked V1) or comes into the app (Phase 2 list)  
6. Donations — out of scope unless they reverse that  
7. LMS / actual course playback — training is info + register only; **fields still required** (Phase 2 → 9)  
8. Shared login is not “data migration”; it’s one API (Phase 4)  
9. **In-app PayFast vs website-only** — **locked website-only for v1** (store compliance); revisit later  

---

## Meeting Waves → Phase map (one glance)

| Meeting item | Wave | Demo / story | Live / production |
|--------------|------|--------------|-------------------|
| Logo, R100 UI, legal drafts, academy register-first, app icon | 1 | **Phase 1** (done) | — |
| Reseller QR / buyer verify | 2 | **Phase 2** | **Phase 8** |
| SMS + email OTP | 2 | **Phase 2** (picker) | **Phase 7** (live) |
| LMS name / gender / email | 2 | **Phase 2** (forms) | **Phase 9** (DB / LMS) |
| Same PayFast + pay in app | 2 | **Phase 3** (story) | **Phase 5** web checkout **= v1**. In-app pay deferred |
| Tight security | 3 | — | **Phase 4** (basics) + **Phase 7** (full) |
| POPI / final legal | 3 | — | **Phase 7** + Launch gate |
| Everything up / minor polish | 3 | — | **Phase 10** + **Launch gate** |

---

## What to do next (orderly)

1. **Phase 2** — finish presentation story **including [W2]** (QR verify → SMS OTP → LMS fields), then Returns / Review / Ambassador / Academy league.  
2. **Phase 3** — one brand; note checkout decision for Phase 7.  
3. **Phase 4–6** — real API, cart, catalogue.  
4. **Phase 7–8** — live PayFast, security, OTP, reseller verify + R100 server-side.  
5. **Phase 9–10** — live academies / LMS fields + ops.  
6. **Launch gate** — checklist green.  
7. **Phase 11–12** — desktop + money extras only after leadership yes.

**Suggested immediate build:** Phase 2 — **Reseller QR + Verify reseller** (biggest meeting trust question).

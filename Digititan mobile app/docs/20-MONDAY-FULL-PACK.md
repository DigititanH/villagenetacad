# MONDAY FULL PACK — Digititan / Village NetAcad mobile prototype

**Use this one document on Monday.**  
Print pages **A (cheat sheet)** and keep the rest open on a second screen.

| | |
|---|---|
| **Goal** | Show what exists → explain thinking → collect comments |
| **Not the goal** | Claim production / live PayFast / live DB |
| **Password (all demos)** | `demo123` |
| **Email OTP** | `123456` |
| **Payment OTP** | `654321` |
| **Fast sale code** | `VNA-B-LERATO` |

---

# PART A — One-page cheat sheet (print this)

## Logins
| Role | Email | Password |
|---|---|---|
| Customer | `customer@demo.com` | `demo123` |
| Reseller | `reseller@demo.com` | `demo123` |
| Ops Admin | `ops@demo.com` | `demo123` |
| Super Admin | `super@demo.com` | `demo123` |

## Money (say once)
Sale with code → **53%** B-code seller · **26%** C-code centre · **21%** Digititan  
Reseller sees **only their share** · Withdraw **last day of month** · Super approves

## Demo order (12–15 min)
1. Frame (Part B opening)  
2. Customer: Home → Training → Academies → Store (+ website)  
3. Money: Reseller `VNA-B-LERATO` → Customer checkout + code → Sales → simulate month-end → Super Payouts  
4. Ops vs Super (30 sec)  
5. Ask comments (Part I)

## If stuck
- OTP payment = `654321`  
- Code = `VNA-B-LERATO`  
- “This is Phase 1 prototype of locked mobile decisions — not a 1:1 website clone yet.”

---

# PART B — Opening (memorise almost verbatim) — 90 sec

> Thank you. Today I’m showing the **mobile prototype** for Digititan / Village NetAcad as it stands.
>
> This is a **working Flutter demo**, not slides only. You’ll see Customer, Reseller, Ops Admin, and Super Admin journeys so you can comment on **flows and business rules**.
>
> Two important frames:
> 1. I studied the **live website** (shop, PayFast, referrals, admin).  
> 2. For **Phase 1 mobile**, leadership also locked decisions that are **not identical** to today’s web — especially store-on-website, **53/26/21** with B/C codes, Ops vs Super, and donations out of mobile V1.
>
> What’s in the app is a **clickable Phase 1 prototype** of those locked rules, with demo data. It is **not** production and **not** yet wired to the live PHP API / PayFast.
>
> I need your **comments**: what feels right, what’s missing, what to change before we connect a real database.

**Pause.** Then: overview → live demo → comments.

---

# PART C — What this is / is not

### This is
- Flutter prototype (Android demo; iOS/desktop direction later)
- End-to-end journeys with **shared demo data** (roles actually connect)
- Alignment tool for Training · Academies · Store + reseller sustainability + dual admin

### This is not (yet)
- Play/App Store release  
- Live PayFast / bank debit  
- Real MySQL / PHP API connection  
- Real OTP email/SMS or Google Sign-In  
- Full LMS inside the app  
- Donations / ambassador in mobile V1  

**Interrupt one-liner:**  
> “Clickable prototype with locked rules. Integrations after we confirm journeys.”

---

# PART D — Roles (memorise these lines)

## Customer — `customer@demo.com`
**Does:** Browse Training, find Academies on the map, see sample Store, demo-checkout with a reseller code.  
**Why:** V1 users include beneficiaries / shoppers; app is the entry to the ecosystem.  
**Say:** “Customer experiences the three pillars. Production shopping is the website; app proves discovery + attribution.”

## Reseller — `reseller@demo.com` (code `VNA-B-LERATO`)
**Does:** Apply → wait → get code → manage clients → earn share on sales → withdraw at month-end.  
**Why:** Sustainability — sellers support the programme; Digititan pays them monthly with control.  
**Say:** “They only see money due to them. They don’t issue codes — Ops does.”

## Ops Admin — `ops@demo.com`
**Does:** Orders, products/prices/promos, approve resellers, issue B or C codes.  
**Why:** Day-to-day must not wait for Super.  
**Say:** “Ops runs the system. Super guards money out.”

## Super Admin — `super@demo.com`
**Does:** Everything Ops can do + **Payouts** + **Activity**.  
**Why:** Separation of duties.

### B vs C (say carefully)
| Code | Who | Earns |
|---|---|---|
| `VNA-B-*` | Individual / beneficiary | **53%** |
| `VNA-C-*` | Centre organisation as seller | **26%** |

> “If Sipho is an individual linked to a centre, he still gets **B**. C is when the centre itself is the seller.”

---

# PART E — How the system connects

```
LOGIN → role shell
  Customer  → Home · Training · Academies · Store · Profile
  Reseller  → Pending  OR  Dashboard · Clients · Sales
  Ops       → Dashboard · Orders · Resellers · Codes · Products
  Super     → Ops + Payouts + Activity
```

**Connection rule (say once):**  
> “Customer, Reseller, and Admin share one demo hub. Checkout with a code updates Reseller Sales and Admin Orders. That proves the journeys are connected — not three fake apps.”

```
Customer uses code at checkout
        → order recorded
        → reseller commission (their %)
        → Digititan 21% tracked
        → Admin sees order
```

**Architecture one-liner:**  
> “UI → use-cases → repositories → data. Today data is demo. After GO we swap in the real API without throwing away screens.”

---

# PART F — Every screen: what / why / how

## Login
**What:** Logo · Powered by DIGITITAN · email/password · Demo login details (collapsed).  
**Why:** Clean presentation entry; manual login looks like a real product.  
**How:** Role on the account routes into the correct shell.

## Customer — Home
**What:** Hi + programme CTA · best sellers · promotions (~~was~~ now) · featured training.  
**Why:** First screen sells the programme, then store/training.  
**How:** Flags on products (`isBestSeller`, `onPromotion`) + programme list.

## Customer — Training
**What:** Offer list → detail → register interest.  
**Why:** Locked — info + interest only; LMS separate (same spirit as web “courses aren’t an LMS”).  
**How:** Interest saved in demo state.

## Customer — Academies
**What:** SA map → province → academies/pins → detail → interest / org register · Active/Inactive.  
**Why:** Academies are a V1 pillar; map makes SA footprint real.  
**How:** Province filter → academy detail.

## Customer — Store
**What:** Sample catalogue · promo pricing · Open Digititan Store website.  
**Why:** Locked — samples in-app; full shop on `https://www.shop.digititan.co.za/`.  
**How:** Demo cart exists only to prove reseller attribution.

## Customer — Product / Cart / Checkout / Payment OTP
**What:** Detail, cart, referral code, pay, OTP `654321`.  
**Why:** Prove sale→commission without claiming live PayFast.  
**How:** Code applied → place order → attribute sale in demo hub.

## Customer — Profile
**What:** Name, role, orders, logout · demo reference collapsed.  
**Why:** Account home; OTPs available if you forget mid-demo.

## Reseller — Pending
**What:** Waiting for Ops approval.  
**Why:** Real gate — no self-issued codes.  
**How:** After Ops Approve + Refresh → dashboard unlocks.

## Reseller — Dashboard
**What:** Code (copy) · earnings due to you · month-end lock · Simulate month-end · Withdraw · statement.  
**Why:** “My money, locked until month-end.”  
**How:** Balance = own commission only. Simulate is demo-only.

## Reseller — Clients
**What:** Leads · status pending / confirmed / bought / didNotBuy.  
**Why:** Pipeline, not just a code.  
**How:** FAB add · tap to update status.

## Reseller — Sales
**What:** Product · client · date · **+R commission only**.  
**Why:** Reinforces share-only UI.  
**How:** Filled when customer checks out with their code.

## Ops — Dashboard
**What:** Metric tiles (orders, revenue, pending resellers, products, withdrawals).  
**Why:** Glance at workload.

## Ops — Orders
**What:** Orders · update status.  
**Why:** Day-to-day ops without developers.

## Ops — Resellers
**What:** Pending apps · Approve (Beneficiary vs Centre) · Reject.  
**Why:** Control who sells + which % slice.

## Ops — Codes
**What:** Issued codes list.  
**Why:** Visibility / audit.

## Ops — Products
**What:** Price edit · promo Was/Now · stock.  
**Why:** Ops runs specials without a developer.  
**How:** Was > Now → strikethrough on Store/Home.

## Super — Payouts / Activity
**What:** Approve/reject withdrawals · activity log.  
**Why:** Money-out control + oversight.

---

# PART G — Live demo scripts (click-by-click)

## G1 — Customer pillars (~4 min)

1. Login `customer@demo.com` / `demo123`  
2. **Home** — “Programme first, then promos and training.”  
3. **Training** — open one → “Interest only; LMS separate.”  
4. **Academies** — pick a province → open one academy.  
5. **Store** — show samples / promo → “Full shop is the website” → open or show URL.  
6. Logout.

## G2 — Money story FAST path (~5 min) — DO THIS

1. Login `reseller@demo.com` → show **`VNA-B-LERATO`** · “Beneficiary = 53%.”  
2. Glance Clients + Sales.  
3. Note balance. Logout.  
4. Login `customer@demo.com` → Store → add to demo cart → Checkout.  
5. Enter `VNA-B-LERATO` → Apply → Pay → OTP **`654321`**.  
6. Logout → Reseller → **Sales** updated · balance up.  
7. Toggle **Simulate month-end** → Withdraw (enter amount).  
8. Logout → `super@demo.com` → **Payouts** → show approve.  

**Say while doing it:**  
> “This is the sustainability loop: code → sale → share → month-end pay with Super control.”

## G3 — Full apply path (only if they ask) (~6 min)

1. Register new reseller (unique email) → OTP `123456` → Pending.  
2. Ops → Resellers → Approve → **Beneficiary**.  
3. Reseller login/refresh → new `VNA-B-…` code.  
4. Customer checkout with that code → Sales updates.

## G4 — Ops vs Super (~2 min)

1. `ops@demo.com` — no Payouts tab · Products promo Was/Now.  
2. `super@demo.com` — Payouts + Activity.  
**Say:** “Ops moves fast; Super guards money out.”

---

# PART H — Website vs Phase 1 (say this if challenged)

| Topic | Live website | Phase 1 mobile (built) |
|---|---|---|
| Shop | Full shop + PayFast | Samples + website CTA; demo checkout |
| Commission | ~10% rate on profile | **53 / 26 / 21** + B/C codes |
| Admin | One admin | Ops + Super |
| Donations | Core | Out of mobile V1 |
| Data | PHP + MySQL + JWT | Demo hub (not API yet) |
| Reseller pending | 403 can’t login | Login → pending screen |
| Withdraw | API exists; little/no web UI | Month-end + Super (meetings) |

**Line:**  
> “Website research = correct. Phase 1 mobile followed **meeting locks**, not a pixel-clone of the PHP shop. Next decision: clone API shop, or keep locked mobile rules and sync data.”

---

# PART I — Locked decisions & why

| Decision | Why |
|---|---|
| Samples in-app; shop on website | One ecosystem; don’t rebuild full shop in V1 mobile |
| Training = interest only | LMS separate |
| 53/26/21 + B/C | Locked sustainability model |
| Reseller sees only own share | Clear “money due to you” |
| Withdraw last day + Super | Month-end discipline |
| Dual Ops/Super | Speed + control |
| Demo OTPs / stub Google / no DB yet | Safe comments meeting; integrations after GO |
| Donations / ambassador out of mobile V1 | Locked / website |

---

# PART J — Out of scope (say calmly)

- Real OTP gateway  
- Real Google Sign-In  
- Real DB/API (recommended **next** after comments)  
- Live PayFast in the app  
- Bank auto-debit  
- Donations / ambassador in mobile  
- Public store release  

> “Backlog by design so today is about journeys and rules.”

---

# PART K — Ask for comments (take notes)

1. Does Customer (Training / Academies / Store) match how people should enter?  
2. Is apply → approve → code → sale → month-end withdraw correct?  
3. Is **53 / 26 / 21** still the split to build?  
4. Any change to Ops vs Super?  
5. Should Phase 2 **call the PHP/PayFast API like the website**, or keep **locked mobile rules**?  
6. What must be next (priority order)?  
7. What should **not** be in V1?

---

# PART L — Close (30 sec)

> Thanks — I’ll write up today’s comments, update what’s locked vs changed, and propose the next build (likely real database/API once journeys are confirmed).

---

# PART M — Likely Q&A (short answers)

**Is this production?** No — prototype for decisions.  
**Can people buy in the app?** Samples + demo checkout for attribution; real shop = website.  
**Where is learning?** Separate LMS.  
**When are resellers paid?** Last day request → Super approves → Digititan pays.  
**Why not 10% like the website?** Meeting locked 53/26/21 for mobile Phase 1 — please confirm.  
**Why two admins?** Ops day-to-day; Super money-out.  
**Is data real?** Demo hub so roles connect in the room.  
**What’s next?** Your comments → then persistence/API; auth/payments sequenced after unless you reprioritise.

---

# PART N — Pre-flight (Sunday / Monday morning)

- [ ] `flutter run` launches  
- [ ] All 4 logins work  
- [ ] Customer: Home, Training, Academies, Store, website link  
- [ ] Money path: `VNA-B-LERATO` → checkout → Sales → simulate withdraw → Super Payouts  
- [ ] Ops: Resellers + Products  
- [ ] This doc open; Part A printed  
- [ ] Browser ready: https://www.shop.digititan.co.za/  
- [ ] Water / notes app for comments  

### Sync app (if needed)

```powershell
cd "S:\WORK\Digititan mobile app"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/DigititanH/villagenetacad/cursor/presentation-frontend-clean-09ad/Digititan%20mobile%20app/INSTALL-PRESENTATION-CLEAN.ps1" -OutFile ".\INSTALL-PRESENTATION-CLEAN.ps1" -Headers @{ "Cache-Control" = "no-cache" }
.\INSTALL-PRESENTATION-CLEAN.ps1
cd mobile
flutter clean
flutter pub get
flutter run
```

### Get this doc onto the laptop

```powershell
cd "S:\WORK\Digititan mobile app"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/DigititanH/villagenetacad/cursor/presentation-guide-monday-09ad/Digititan%20mobile%20app/docs/20-MONDAY-FULL-PACK.md" -OutFile ".\docs\20-MONDAY-FULL-PACK.md" -Headers @{ "Cache-Control" = "no-cache" }
notepad .\docs\20-MONDAY-FULL-PACK.md
```

---

# PART O — Comment capture sheet (fill during meeting)

| # | Topic | Their comment | Action (keep / change / later) |
|---|---|---|---|
| 1 | Customer pillars | | |
| 2 | Reseller journey | | |
| 3 | 53/26/21 split | | |
| 4 | Ops vs Super | | |
| 5 | Website clone vs locked mobile | | |
| 6 | Next build priority | | |
| 7 | Out of V1 | | |

---

*Related:* `12-LOCKED-DECISIONS.md` · `18-RESELLER-CODES-AND-DUAL-ADMIN.md` · `17-STAKEHOLDER-EMAIL-MONTH-END-SCOPE.md`

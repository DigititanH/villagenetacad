# Monday presentation pack — Digititan / Village NetAcad mobile prototype

**Audience:** leadership / product giving comments on what exists so far  
**Goal:** show a working prototype, explain decisions, collect feedback — not claim production  
**Updated:** 21 Aug 2026

Use this document with the live app on your laptop. Work with your agent **step by step** (Step 1 → Step 10). Do not try to memorise everything at once.

---

## Step map (A–Z)

| Step | What you do | Time |
|---|---|---|
| **1** | Frame the meeting (opening script) | ~2 min |
| **2** | Say what this is / is not | ~1 min |
| **3** | Explain how the system works (simple) | ~2 min |
| **4** | Walk the three pillars (Customer) | ~4–5 min |
| **5** | Walk reseller sustainability model | ~5–6 min |
| **6** | Walk Ops + Super Admin | ~3 min |
| **7** | Call out locked decisions & why | ~2 min |
| **8** | Explicitly list out-of-scope / backlog | ~1 min |
| **9** | Ask for comments (structured) | ~5–10 min |
| **10** | Close + next steps | ~1 min |

**Total talk + demo:** ~25–35 min + Q&A.

---

## Demo accounts (password always `demo123`)

| Role | Email | What to show |
|---|---|---|
| Customer | `customer@demo.com` | Home, Training, Academies, Store |
| Reseller | `reseller@demo.com` | Code `VNA-B-LERATO`, clients, sales, withdraw |
| Ops Admin | `ops@demo.com` | Orders, products, approve resellers, codes |
| Super Admin | `super@demo.com` | Everything Ops has + **Payouts** + **Activity** |

| Prototype OTP | Code |
|---|---|
| Register / email verify | `123456` |
| Payment | `654321` |

| Fast sale code | `VNA-B-LERATO` (already on `reseller@demo.com`) |

---

## STEP 1 — Opening script (say this almost verbatim)

> Thank you for the time. Today I’m presenting the **mobile prototype** for Digititan / Village NetAcad as it stands so far.
>
> This is a **working product demo**, not slides only. It shows the main user journeys on Flutter — Customer, Reseller, Ops Admin, and Super Admin — so you can react to the flows and the business rules, not just mockups.
>
> What I need from you today is **comments**: what feels right, what’s missing, and anything I may have misunderstood from earlier decisions.
>
> I’ll cover: how the system is structured, a live walkthrough, why certain decisions were locked, what’s deliberately still backlog, then I’ll open for feedback.

**Then pause.** Ask: “Any preference on order — overview first, or straight into the live app?”  
Default if they say nothing: overview (Step 2–3) then live demo (Step 4–6).

---

## STEP 2 — What this is / is not

### This is
- A **Flutter mobile prototype** (Android demo target; same codebase later for iOS / desktop direction)
- **End-to-end journeys** with demo data so we can click through safely
- Alignment tool: prove we understood **Training · Academies · Store** + **reseller sustainability** + **dual admin**

### This is not (yet)
- Production app on Play Store / App Store
- Live payments / bank debit
- Real database with live academy / product data
- Real OTP emails or Google Sign-In
- Full LMS inside the app

**One-liner if interrupted:**  
> “It’s a clickable prototype with locked business rules. Integrations come after we confirm the journeys.”

---

## STEP 3 — How the system works (keep it simple)

### Product shape
```
Customer app     → Training · Academies · Store · Profile
Reseller app     → Apply / Dashboard · Clients · Sales · Withdraw
Ops Admin        → Orders · Products · Reseller approve · Codes
Super Admin      → Ops + Payouts + Activity log
```

### Technical shape (one sentence each)
- **One Flutter app**, role-based shells after login  
- **Shared in-memory demo hub** so Customer sale → Reseller commission → Admin order actually connect in the demo  
- **Store policy:** samples in-app; full shopping = Digititan Store website (`https://www.shop.digititan.co.za/`)  
- **Training policy:** info + register interest only; learning stays in separate LMS  

### Money model (draw this on a whiteboard if you can)

```
Attributed sale (customer used reseller code)
        │
        ├── 53%  → Beneficiary reseller (VNA-B-*)
        ├── 26%  → Centre (VNA-C-* seller, or linked centre share)
        └── 21%  → Digititan / Village NetAcad
```

- Reseller screen shows **only money due to them**  
- Withdrawals: **last calendar day of the month** → Super Admin approves  
- Bank auto-debit: **not V1**

---

## STEP 4 — Live demo: Customer (three pillars)

**Login:** `customer@demo.com` / `demo123`

### 4A Home
- Greeting + programme CTA (“Now recruiting”)  
- Best sellers + promotions (promo shows ~~was~~ now when on special)  
- Featured training  

**Say:** “Home is the landing composition — programme first, then store highlights and training.”

### 4B Training
- Browse offers → open detail → register interest  
**Say:** “We don’t put the LMS in the app. This is discovery + interest capture.”

### 4C Academies
- SA map → province → academy list/pins → detail → interest / org register  
**Say:** “Academies are discoverable by geography; performance categories later if you want them in V1.”

### 4D Store
- Sample catalogue + promo pricing  
- Button / link opens **live Digititan Store website**  
- In-app cart/checkout exists for **prototype attribution demo only**  

**Say:** “Leadership decision: production shopping is the website. The app proves the journey and reseller code attribution.”

---

## STEP 5 — Live demo: Reseller model (core story)

### Option A — Fast path (recommended if time is tight)
1. Login `reseller@demo.com` / `demo123`  
2. Show code **`VNA-B-LERATO`** (Beneficiary → earns **53%**)  
3. Clients tab — pipeline statuses  
4. Sales — commissions (their share only)  
5. Dashboard balance → toggle **Simulate month-end** → Withdraw  
6. Logout → `super@demo.com` → **Payouts** → approve/reject  

### Option B — Full journey (if they want apply→approve)
1. Register new reseller → pending  
2. Ops `ops@demo.com` → Resellers → Approve → **Beneficiary** or **Centre**  
3. Reseller refresh → code unlocks  
4. Customer checkout with that code → OTP `654321`  
5. Reseller Sales updates  

### What to say about B vs C codes
| Code | Who | Earns |
|---|---|---|
| `VNA-B-*` | Individual / beneficiary seller | **53%** |
| `VNA-C-*` | Centre organisation as seller | **26%** |

**Important line:**  
> “If Sipho is an individual linked to a centre, he still gets a **B** code. We don’t give him a C code just because of the link.”

---

## STEP 6 — Live demo: Ops vs Super

| | Ops (`ops@demo.com`) | Super (`super@demo.com`) |
|---|---|---|
| Orders / products / prices / promos | Yes | Yes |
| Approve resellers + issue codes | Yes | Yes |
| Payouts | No | **Yes** |
| Activity log | No | **Yes** |

**Say:** “Day-to-day ops should not need Super Admin. Super is oversight and money-out approval.”

Also show quickly: Products → promo Was/Now (strikethrough pricing).

---

## STEP 7 — Locked decisions & why (talk track)

| Decision | Why (your words) |
|---|---|
| Store samples in-app; shop on website | Don’t rebuild the shop; mobile + web = one ecosystem |
| Training = info + interest only | LMS already exists; app drives discovery |
| 53 / 26 / 21 split | Locked sustainability model for attributed sales |
| Reseller sees only their share | Avoid confusion; they don’t need full P&L in V1 |
| Withdraw last day of month + Super approve | Controlled month-end payout discipline |
| Dual admin (Ops / Super) | Ops moves fast; Super guards payouts |
| Demo data + fixed OTPs | Safe presentation; real channels after feedback |
| Google Sign-In / real OTP / DB / bank debit later | Don’t over-claim; keep production work after comments |

---

## STEP 8 — Out of scope (say out loud)

Do **not** apologise — frame as intentional:

- Real OTP delivery (SMS/email gateway)  
- Real Google Sign-In  
- Real database / API  
- Live payment gateway / bank auto-debit  
- Ambassador / donations in mobile V1  
- Desktop downloadable app (direction locked; not this demo’s focus)  

**Line:**  
> “These are backlog by design so Monday is about journeys and rules, not unfinished integrations.”

---

## STEP 9 — Ask for comments (structured)

Ask these exactly (take notes):

1. **Does the Customer path (Training / Academies / Store) match how you want people to enter the ecosystem?**  
2. **Is the reseller apply → approve → code → sale → month-end withdraw sequence correct?**  
3. **Is 53 / 26 / 21 still the split we should build to?**  
4. **Any change to Ops vs Super responsibilities?**  
5. **What must be in the next build after this prototype (priority order)?**  
6. **Anything here that should NOT be in V1?**

---

## STEP 10 — Close

> Thanks — I’ll capture today’s comments and come back with an updated backlog: what stays locked, what changes, and the next technical step (likely real database/API once journeys are confirmed).

---

## Likely questions — short answers

**“Is this in production?”**  
No — prototype with demo data for decision-making.

**“Can people buy in the app?”**  
Sample / demo checkout for attribution. Real shopping is the Digititan Store website.

**“Where does learning happen?”**  
Separate LMS. App = browse + register interest.

**“When do resellers get paid?”**  
They request withdraw on the last day of the month; Super Admin approves. Digititan pays resellers (bank auto-debit later).

**“Why two admins?”**  
Ops runs day-to-day. Super approves money out and sees activity.

**“Is the data real?”**  
No — shared demo memory so roles talk to each other in the presentation.

**“What’s next after Monday?”**  
Incorporate comments → lock changes → then real persistence/API; OTP/Google/payments stay sequenced after that unless you reprioritise.

---

## Pre-flight checklist (Sunday night / Monday morning)

- [ ] App launches on emulator or device  
- [ ] Login with all four accounts works  
- [ ] Customer: Home / Training / Academies / Store + website link  
- [ ] Reseller: `VNA-B-LERATO`, clients, sales, simulate month-end withdraw  
- [ ] Super: Payouts tab visible  
- [ ] Ops: Resellers + Products promo  
- [ ] This doc open on a second screen or printed 1–2 pages of cheat sheet  
- [ ] Browser ready for `https://www.shop.digititan.co.za/`  

### Sync (if laptop not current)

```powershell
cd "S:\WORK\Digititan mobile app"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/DigititanH/villagenetacad/cursor/presentation-frontend-clean-09ad/Digititan%20mobile%20app/INSTALL-PRESENTATION-CLEAN.ps1" -OutFile ".\INSTALL-PRESENTATION-CLEAN.ps1" -Headers @{ "Cache-Control" = "no-cache" }
.\INSTALL-PRESENTATION-CLEAN.ps1
cd mobile
flutter clean
flutter pub get
flutter run
```

---

## How we’ll work with your agent (step by step)

Reply with the step number when you’re ready, e.g. **“Step 1”** or **“Step 5 rehearse”**.

| You say | Agent does |
|---|---|
| Step 1 | Rehearse opening; tighten wording |
| Step 4 | Click-by-click Customer rehearsal |
| Step 5 | Reseller money story rehearsal |
| Q&A | Drill likely questions |
| Cheat sheet | One-page printable only |
| Change X after comments | Update app / docs from Monday feedback |

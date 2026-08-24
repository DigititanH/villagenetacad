# MONDAY DEEP PACK — Village NetAcad / Digititan mobile prototype

**Repo:** https://github.com/shichabonkuna22-star/VillageNetAcad  
**Purpose:** Speak in detail. Receive comments. Explain what the system does, how it works, what happens when someone does X, who sees it on the other end, and why decisions were made.

**How to use this doc**
- Present **one role at a time**. Everything for that role is in one section (who they are + every screen + what happens when + live walkthrough).
- When you change role, say out loud what the **other side** already saw or will see.
- Demo password for all accounts: **`demo123`**
- Email / register OTP: **`123456`** · Payment OTP: **`654321`** · Fast code: **`VNA-B-LERATO`**

---

# 0) Frame the meeting (say this first)

## What you are showing
A **working Flutter mobile prototype** for Village NetAcad powered by Digititan. It demonstrates:

1. The three customer pillars — **Training · Academies · Store**
2. The **Reseller sustainability** model (apply → approve → code → sale → month-end withdraw)
3. **Ops Admin** day-to-day control and **Super Admin** money-out oversight

Everything in this build uses **shared in-memory demo data** (`DemoHub`). That means: if a Customer checks out with a reseller code, the Reseller’s Sales and balance update, and Ops sees the order — in the **same app run**. That is intentional: you are proving journeys are connected, not three separate fake screens.

## What you are NOT claiming
- Not Play Store / App Store production
- Not connected to the live Village NetAcad MySQL / PHP API yet
- Not live PayFast, not real email OTP, not real Google Sign-In
- Not a pixel-clone of every website feature (donations, wishlist, reviews, etc.)

## Two sources of truth you must name (or comments get messy)

| Source | What it is | How mobile Phase 1 relates |
|---|---|---|
| **Live website** (React + PHP) | Full shop, PayFast, ~10% commission, one Admin, donations | Studied for understanding; **not fully cloned** in Phase 1 |
| **Meeting / locked mobile decisions** | Samples in-app + website shop, **53/26/21**, B/C codes, Ops vs Super, donations out | **This is what the prototype implements** |

**Line to say:**
> “I reverse-engineered the live website so I understand production. Phase 1 mobile follows **locked meeting decisions**, which differ in places from today’s web. After your comments we decide what stays locked, then we connect the **same backend** so web and mobile share real accounts and carts.”

## Shared money model (draw once)

```
Customer pays for an attributed sale (used a valid reseller code)
        │
        ├── 53%  → Beneficiary seller (code VNA-B-*)
        ├── 26%  → Centre slice (VNA-C-* seller earns this slice;
        │           also tracked when a B-sale has a linked centre rule)
        └── 21%  → Digititan / Village NetAcad
```

**Reseller UI rule:** they only ever see **money due to them** (53% if B, 26% if C). They do **not** see full order total or Digititan’s 21% on their dashboard.

**Withdraw rule:** last calendar day of the month (demo has a simulate toggle) → Super Admin must approve. Bank auto-debit = not V1.

---

# 1) LOGIN (everyone starts here)

## What the screen is for
Clean entry into the prototype. Brand first so the room sees Village NetAcad + Digititan, then email/password so the login feels like a product — not four giant “fake role” buttons.

## What you see
- Top strip: `Presentation demo · sample data · mobile + website ecosystem`
- Logo: `VillageNetAcadTransparentBackground.png`
- Text: **Powered by** → **DIGITITAN**
- Email + Password fields
- **Sign in**
- **Google (stub)**
- **Create account / apply as reseller**
- Collapsed **Demo login details** (accounts, OTPs, fast code)

## Why this design
- Presentation polish: stakeholders judge seriousness from the first screen.
- Manual login forces you to show real role routing (Customer vs Reseller vs Ops vs Super).
- Demo details are collapsed so the screen is not a wall of prototype notes — but you still have the cheat sheet if you forget mid-demo.

## How routing works after a successful login
The account’s **role** decides the shell:

| Email | Role | Shell you land in |
|---|---|---|
| `customer@demo.com` | Customer | Bottom nav: Home · Training · Academies · Store · Profile |
| `reseller@demo.com` | Reseller (already approved) | Tabs: Dashboard · Clients · Sales |
| `ops@demo.com` | Ops Admin | Tabs: Dashboard · Orders · Resellers · Codes · Products (**no** Payouts) |
| `admin@demo.com` | Ops (legacy alias) | Same as Ops |
| `super@demo.com` | Super Admin | Everything Ops has **+ Payouts + Activity** |

## What happens when…

### Wrong email or password
- Red error: **Invalid email or password**
- Nobody else sees anything. No DemoHub change.

### Google (stub)
- Always signs in as the demo **Customer** (`customer@demo.com`).
- Say: “Stub only — real Google Sign-In is backlog after presentation.”

### Create account / apply as reseller
- Opens Register (covered under Customer register path and Reseller apply path below).

### Logout from any shell
- Returns to Login.
- **Important:** DemoHub data from this app run **stays in memory** until you kill the app. So a sale you just made is still there when you log in as Reseller/Ops. Restarting the app reseeds defaults.

---

# 2) CUSTOMER — full section
*(Who they are + every screen + cause/effect + walkthrough — present this as one block)*

## 2.0 Who is the Customer?

**Demo login:** `customer@demo.com` / `demo123`

### Job in the system
The Customer is the person entering the Digititan / Village NetAcad ecosystem through the **three pillars**:
1. **Training** — discover programmes, register interest (learning itself is in a separate LMS)
2. **Academies** — find centres on a South Africa map, apply / register interest, org forms
3. **Store** — browse sample merchandise; full purchase path is the Digititan Store **website**

### Why this role exists (decision)
Leadership locked V1 users as beneficiaries, academies, and shoppers — with **production shopping on the website**. The mobile Customer experience is the entry + discovery layer, plus a **prototype checkout** only so we can prove reseller-code attribution in the room.

### What the Customer can do in Phase 1
- Browse Home, Training, Academies, Store
- Register interest in training / academies / org
- Open live Digititan Store website
- Use **demo cart → checkout → payment OTP** with an optional reseller code
- See their own orders (for purchases made as this email in this session)

### What the Customer cannot do / does not see
- Live PayFast card payment inside the app
- Other people’s orders
- Reseller commission math as a “wallet”
- Ops/Super tools

### Say this when you open Customer
> “Customer experiences the three pillars. Production shopping is the website. The in-app cart is here to prove discovery and reseller attribution — not to replace PayFast.”

---

## 2.1 Customer — Home

### What you see
- Greeting: **Hi {FirstName}**
- Subtitle: Training · Academies · Store
- **Programme hero** (dark block): “Now recruiting” + programme title/subtitle + **Register interest**
- **Best sellers** list (products flagged best seller)
- **Promotions** list (products on promo — may show ~~was~~ now)
- **Featured training** short list

### Why
First screen must sell the **programme**, then surface store highlights and training — not a dump of prototype instructions.

### How it works
- Programmes / training offers / products load from demo repositories backed by DemoHub.
- Best sellers = `isBestSeller`
- Promotions = `onPromotion` (and strikethrough if `compareAtPrice` > price)

### What happens when…

| You do this | What happens on screen | Who else is affected |
|---|---|---|
| Tap programme hero / Register interest | Jumps to **Training** tab | — |
| Tap a best seller / promo row | Opens **Product detail** | — |
| Tap featured training | Opens **Training detail** | — |
| Ops earlier changed a promo price | After reload/reopen Home, ~~was~~ now updates | Customer Store/Product also show new price |

### Decision note
Home was cleaned for presentation so stakeholders see a product landing, not a debug checklist.

---

## 2.2 Customer — Training

### What you see
- List of training offers (category · level · hours · Recruiting if open)
- Detail: summary + **Register interest**

### Why (locked decision)
> Training in the app = **information + registration of interest only**. Actual learning happens in a **separate LMS**. Same spirit as the website: course cards are not a full LMS.

### How
Submitting interest appends a `trainingInterests` record in DemoHub and writes an activity log line.

### What happens when…

| You do this | Customer sees | Other end |
|---|---|---|
| Open an offer | Detail screen | — |
| Tap **Register interest** and submit | Dialog **Interest registered** / Thanks | DemoHub stores the lead; Activity log gets `Training interest: …`; Ops/Super dashboard **Open leads** style counts can rise; there is **no dedicated Admin “Leads” tab** in this shell — Super **Activity** is where you show the trail |
| Try to “start the course” in-app | You can’t — by design | Explain LMS is separate |

### Say
> “We capture intent here. Delivery of learning stays in the LMS — that was a locked decision so we don’t rebuild an LMS inside mobile V1.”

---

## 2.3 Customer — Academies

### What you see
- Interactive **South Africa map** by province
- Active / Inactive filter
- Academy list / pins for the selected province
- Academy detail: location, programmes, events, status
- Path to register interest / apply
- Path to **Register NPO / Academy** (organisation form)

### Why
Academies are a V1 pillar. The map makes the national footprint real for stakeholders who think geographically.

### How
Province selection filters academies. Detail drives interest / org registration into DemoHub (`academyInterests`, `orgApplications`).

### What happens when…

| You do this | Customer sees | Other end |
|---|---|---|
| Tap a province / pin | Filtered academies | — |
| Open an **Active** academy → register/apply | Success dialog **Application submitted** (or similar) | Lead stored; Activity log; open-leads metrics |
| Open an **Inactive** academy | Copy like registration closed; no apply button | Protects against applying to inactive centres |
| Submit **Register NPO / Academy** | Organisation submitted confirmation | `orgApplications` pending in DemoHub; Activity log |

### Decision note
Website academies story is weaker/static; mobile went **further** on map discovery because meetings treated Academies as a first-class pillar.

---

## 2.4 Customer — Store (catalogue)

### What you see
- Quiet notice: browse samples here; full shopping on Digititan Store website
- Button **Open Digititan Store** + underlined URL `https://www.shop.digititan.co.za/`
- Sample catalogue (featured best sellers/promos first)
- Promo items can show **~~old price~~ new price**

### Why (locked decision)
> App shows **sample products only**. Full shopping opens the **Digititan Store website**. Mobile + website = one ecosystem — we do not rebuild the entire production shop inside Phase 1 mobile.

### How
- Catalogue from DemoHub products
- Website open uses a platform browser channel; if it fails, URL is copied / dialog shown

### What happens when…

| You do this | Customer sees | Other end |
|---|---|---|
| Tap **Open Digititan Store** | Browser opens (or copy/dialog fallback); snackbar about opening site | Real website — separate from demo hub |
| Tap a product | Product detail | — |
| Ops toggled promo / changed price earlier | Catalogue shows updated price / strikethrough after refresh | Proves Ops can run specials without developers |

### Say
> “If you want to buy for real, you leave to the live shop. Inside the app we keep samples plus a demo checkout only to prove reseller codes.”

---

## 2.5 Customer — Product detail

### What you see
- Name, category, price (with strikethrough if promo)
- “On promotion” when applicable
- Summary
- Notice that full purchase is on the website
- **Open Digititan Store**
- **Add to demo cart**
- **View demo cart**

### What happens when…

| You do this | Customer sees | Other end |
|---|---|---|
| Add to demo cart (in stock) | Snackbar **Added to demo cart** | Item sits in process-local cart (same app run). **Not** visible to Ops as an order yet |
| Add when out of stock | Button disabled | Ops long-press stock toggle is how stock flips |
| View demo cart | Cart screen | — |

---

## 2.6 Customer — Cart → Checkout → Payment OTP → Order

This is the **money-story bridge** to Reseller and Admin. Walk it slowly.

### Cart — what you see
- Lines with unit price (sale price if promo), qty, line total
- + / − quantity
- Total
- **Checkout**
- Empty state: Cart is empty

### Checkout — what you see
- Buyer identity
- Lines / total
- **Reseller referral code** field + Apply
- Pay / continue to payment OTP
- Prototype payment notes

### Payment OTP — what you see
- Enter OTP (demo = **`654321`**)
- Confirm

### Order detail (just placed) — what you see
- **Sale confirmed (prototype payment + OTP).**
- If code used: attribution line with split reminder **Beneficiary 53% · Centre 26% · Digititan/VNA 21%**
- If no code: **No reseller code on this order.**
- Status timeline (placed → payment confirmed → processing…)

### Why demo checkout exists
Not to claim live payments. To prove in one room:

> Customer uses code → Reseller earns their share → Ops sees the order.

### How attribution works (exact)

1. Customer applies a code that matches an **approved** issued code (e.g. `VNA-B-LERATO`).
2. Payment OTP `654321` succeeds → order created status **`paid`**, cart cleared.
3. `DemoHub.attributeSale` runs:
   - Seller cut: **53%** if B-code, **26%** if C-code → added to that reseller’s **balance** + **Sales** row (`+R…`)
   - Centre 26% and Digititan 21% tracked internally (reseller UI does **not** show those as their money)
   - Matching / new client for buyer marked **`bought`**
   - Activity log writes the three-way split line
4. Ops **Orders** list gains the order; revenue metrics move.

### Worked example (say the numbers)
Headset on promo at **R399**, code **`VNA-B-LERATO`** (Beneficiary):

| Slice | % | Amount | Who sees it |
|---|---|---|---|
| Seller (Demo Reseller) | 53% | **R211.47** | Reseller Dashboard balance + Sales `+R211.47` |
| Centre | 26% | R103.74 | Internal / tracked — not a reseller wallet line in UI |
| Digititan | 21% | R83.79 | Internal — not on reseller screen |
| Customer | — | Paid R399 | Their order total / My Orders |

### What happens when… (checkout matrix)

| You do this | Customer sees | Reseller sees (after you log in as them) | Ops / Super see |
|---|---|---|---|
| Apply **valid** code | Hint like `Applied VNA-B-LERATO (Beneficiary) — …` | — yet | — |
| Apply **invalid** code | `Invalid or inactive reseller code` | nothing | nothing |
| Pay with **wrong OTP** | `Invalid payment OTP` — **no order** | nothing | nothing |
| Pay with **`654321`** + valid code | Order success + attribution copy | New **Sale**, balance ↑, client → **bought** | New **Order**, revenue ↑, Activity sale line |
| Pay with **`654321`** and **no** code | Order success, “No reseller code…” | no commission | Order without referral |
| Only add to cart, never pay | Cart has items | nothing | nothing (no order) |

### Decision notes to defend
- **Website** requires referral for non-admin checkout and uses PayFast.  
- **Phase 1 mobile** uses optional code + OTP simulation because meetings locked “samples in-app / full shop on website,” and the room needs a safe attribution demo.
- Ask for a comment: keep optional demo checkout, or later force redirect-only to website cart (shared API).

---

## 2.7 Customer — Profile / My Orders

### Profile — what you see
- Avatar initial, name, email, role label
- **My orders**
- **Logout**
- Collapsed **Demo reference** (OTPs, password, store URL)

### My Orders — what you see
- Orders where **buyer email = this customer**
- Tap → order detail / timeline

### What happens when…

| You do this | Effect | Other end |
|---|---|---|
| Open My Orders after a successful checkout as this user | Your new `ORD-…` appears | Same order is on Ops Orders |
| Expect to see seeded `ORD-DEMO-1001` | You **won’t** on `customer@demo.com` — that seed belongs to `aisha@example.com` | Don’t confuse yourself mid-demo |
| Ops changes order status | After reopen/refresh, timeline can show `Status → …` | Ops did it from Orders tab |
| Logout | Back to Login; DemoHub keeps session data until app kill | Next role login still sees connected data |

---

## 2.8 Customer — Register path (from Login)

### Register as Customer
1. Name, email, password, role = Customer  
2. Create account → OTP screen (prototype OTP **`123456`**, also printed in Flutter console)  
3. Wrong OTP → Invalid OTP  
4. Correct OTP → email verified → land in **Customer shell**

### What others see
Nothing until this customer generates leads/orders. No reseller profile created.

---

## 2.9 LIVE WALKTHROUGH — Customer block (do this on Monday)

**Timebox ~4–5 minutes** (plus money bridge if combined with Reseller).

1. Login `customer@demo.com` / `demo123`  
2. **Home** — programme CTA, point at promos ~~was~~ now if visible  
3. **Training** — open one → Register interest → show success dialog → say LMS is separate  
4. **Academies** — pick a province → open an academy → mention Active/Inactive  
5. **Store** — samples + website button (optionally open site)  
6. **Product** → Add to demo cart → Cart → Checkout  
7. Enter `VNA-B-LERATO` → Apply → Pay → OTP `654321` → show order attribution line  
8. Profile → My orders → confirm the order  
9. **Logout** — tell the room: “Now we open the same sale from the Reseller side.”

---

# 3) RESELLER — full section

## 3.0 Who is the Reseller?

**Demo login (already approved):** `reseller@demo.com` / `demo123`  
**Seeded code:** **`VNA-B-LERATO`** (Beneficiary → earns **53%**)  
**Seeded academy link:** Lesedi Labatu Academy (example)

### Job in the system
Grow sales through a personal referral code, manage a client pipeline, earn **only their share**, and withdraw at month-end under Super approval.

### Why this role exists (decision)
Sustainability model: independent sellers support the programme. Digititan pays resellers at month-end with control. Resellers are **not** full admins — they don’t issue codes or edit catalogue prices.

### Say
> “They only see money due to them. They don’t issue codes — Ops does. Month-end withdraw still needs Super Admin.”

### B vs C (memorise — people will ask)

| Code | Who gets this code | Seller earns |
|---|---|---|
| `VNA-B-*` | **Individual** / beneficiary reseller (Sipho, Lerato) | **53%** |
| `VNA-C-*` | **Centre / academy organisation** as the seller | **26%** |

**Critical line:**
> “If Sipho is an individual linked to a centre, he still gets a **B** code. We do **not** give him a C code just because of the link. C is when the centre itself is the seller.”

**Honest gap if asked “where does the linked centre see their 26%?”**  
> “The split is modelled and logged. This prototype focuses the reseller wallet on **the seller’s share**. A separate centre wallet screen is feedback I’m happy to take.”

---

## 3.1 Becoming a Reseller (Apply → Pending → Approved)

### Path A — Full journey (when they want process)
1. Login screen → **Create account / apply as reseller**  
2. Register: role **Reseller**, optional academy name  
3. Apply → OTP `123456`  
4. Land in **Reseller shell — Application pending** only (no Dashboard/Clients/Sales yet)

**What DemoHub did**
- Pending application row for Ops
- Reseller profile `status=pending`, code placeholder `PENDING`, balances 0
- Activity: awaiting Ops Admin approval

**What Ops sees immediately (if they log in next)**
- Resellers tab: new pending person
- Dashboard **Pending resellers** count ↑

### Path B — Fast path (recommended for time)
Skip apply. Login `reseller@demo.com` — already approved with `VNA-B-LERATO`.

---

## 3.2 Reseller — Pending screen

### What you see
- Hourglass / pending copy
- Name, email, academy if any
- Explanation that Ops must approve and issue B or C code
- **Check approval status** (refresh)
- Application summary

### What happens when…

| You do this | Reseller sees | Other end |
|---|---|---|
| Refresh while still pending | Same pending UI | — |
| Ops Approves as Beneficiary/Centre, then you Refresh | Tabs unlock to Dashboard · Clients · Sales; real code appears | Codes tab lists the code |
| Ops **Rejects** (long-press), then you Refresh | **Application rejected** | Removed from pending queue |
| Try to add clients while pending | Can’t — FAB hidden; APIs guard approved-only | — |

### Why pending exists
Real gate. Codes are business credentials — not self-service.

---

## 3.3 Reseller — Dashboard (approved)

### What you see
- Greeting + status / academy
- **Referral code** card with copy button
- Big earnings hero: **Your earnings · 53%** (or Centre · 26%) and **R balance**
- Lock line: locked until last day **or** withdrawal open today
- Switch: **Simulate month-end** (demo only)
- **Withdraw**
- **Earnings statement**

### Why
Reseller should feel: “This is my money. It’s locked until month-end. Digititan still approves payout.”

### How balance is calculated
Balance = sum of seller commission credits − amounts already requested for withdrawal (request deducts immediately; reject restores).

### What happens when…

| You do this | Reseller sees | Other end |
|---|---|---|
| Copy code | Snackbar `{code} copied` | Customer can paste that code at checkout |
| Open statement | Dialog: share-only explanation + earnings narrative | — |
| Toggle **Simulate month-end** ON | Withdraw unlocks even if today isn’t month-end | Demo-only — say that out loud |
| Tap Withdraw while locked | Disabled / snackbar about last calendar day | No payout row |
| Withdraw amount ≤ balance while open | Snackbar **Withdrawal requested — Super Admin must approve**; balance **drops immediately** by that amount | Super **Payouts** gets a pending row; Ops sees withdrawals **count** on dashboard but **cannot** approve |
| Withdraw amount > balance | Error | nothing |
| Customer earlier bought with your code | Balance already higher; Sales has rows | That was attribution |

### Withdraw mental model (say carefully)
> “When I request withdraw, the money leaves my available balance right away and sits as a pending payout for Super Admin. If Super rejects, it comes back. If Super approves, it stays out — that’s the payout confirmation.”

---

## 3.4 Reseller — Clients

### What you see
- List of leads (name, email, interest, status)
- FAB **Add client**
- Tap row → change status

### Statuses
`pending` → `confirmed` → `bought` / `didNotBuy`

### Why
Resellers manage a **pipeline**, not only a code. Meetings wanted client tracking.

### What happens when…

| You do this | Reseller sees | Other end |
|---|---|---|
| Add client | Snackbar **Client added**; row appears | Activity log |
| Change status | Snackbar `{name} → {status}` | Activity log |
| Customer checks out with your code using that email / new buyer | Client forced/created as **`bought`** | Links sales to pipeline |

---

## 3.5 Reseller — Sales

### What you see
- Product, client, date, optional code
- Trailing **`+R{commission}`** = **seller share only**

### Why
Reinforces locked UI rule: never show full sale price as “yours.”

### What happens when…
A successful attributed checkout appears here automatically. Empty state tells you to have a customer use your code.

---

## 3.6 LIVE WALKTHROUGH — Reseller + money (core story)

**Fast path (~5–6 min) — do this**

1. After Customer checkout with `VNA-B-LERATO`, login `reseller@demo.com`  
2. Dashboard — show code, show balance increase, say “53% only”  
3. Sales — show `+R…` line for the new sale  
4. Clients — show buyer moved/created as bought (if applicable)  
5. Toggle **Simulate month-end** → Withdraw → enter amount → confirm snackbar  
6. Logout → Super Admin → **Payouts** (see section 5)

**Full apply path (only if asked)**  
Register new reseller → pending → Ops Approve Beneficiary → Refresh → then sale.

---

# 4) OPS ADMIN — full section

## 4.0 Who is Ops Admin?

**Login:** `ops@demo.com` / `demo123`  
(Alias `admin@demo.com` = same role)

### Job
Day-to-day operations **without waiting for Super**:
- Watch workload (dashboard)
- Update order statuses
- Approve / reject reseller applications and issue **B or C** codes
- See issued codes
- Manage products: price, promo was/now, stock, add product

### Why dual admin (decision)
> Ops must move fast. Super exists so **money out** and oversight aren’t the same person’s only gate for every tiny task.

### Say
> “Ops runs the system. Super guards money out.”

### What Ops cannot do
- **No Payouts tab** — cannot approve withdrawals
- **No Activity tab** (Super only) — though Ops actions still write logs Super can read

---

## 4.1 Ops — Dashboard

### What you see
- Name / email
- Metric tiles: Orders, Revenue, Pending orders, Pending resellers, Products, Withdrawals (count)
- Quiet tip about VNA-B-LERATO walkthrough

### What happens when…
Metrics recompute from DemoHub when you load/refresh. A customer sale raises Orders/Revenue. A reseller apply raises Pending resellers. A withdraw request raises Withdrawals count — but Ops still can’t act on payouts.

---

## 4.2 Ops — Orders

### What you see
- Order id, buyer, status, total, referral code if any
- Tap to change status (`pending` / `processing` / `shipped` / `delivered` / `cancelled` style set in app)

### What happens when…

| You do this | Ops sees | Other end |
|---|---|---|
| Update status | Snackbar `{id} → {status}`; timeline entry | Customer order detail can show updated status line after reopen |
| Look at attributed order | Code visible on subtitle | Matches reseller sale |

---

## 4.3 Ops — Resellers (approve / reject)

### What you see
- Pending applications list
- **Approve** action
- Reject via **long-press** (easy to miss — say it)

### Approve dialog (say the options out loud)
- **Beneficiary → VNA-B-*** — individual earns **53%**
- **Centre → VNA-C-*** — centre org earns **26%**

### What happens when…

| You do this | Ops sees | Reseller sees after Refresh | Codes tab |
|---|---|---|---|
| Approve Beneficiary | Snackbar with new `VNA-B-…` code + tip | Pending → full Dashboard with that code; Clients/Sales unlock | New code listed |
| Approve Centre | Snackbar with `VNA-C-…` | Same unlock; earnings labelled Centre 26% | New code listed |
| Long-press Reject | Pending row gone | Application rejected screen | no code issued |

### Decision note
Issuing the correct code type is a **business control**, not a cosmetic label. Wrong code type = wrong %.

---

## 4.4 Ops — Codes

### What you see
Read-only list of issued codes (includes seeded `VNA-B-LERATO` + approvals from this session).

### Why
Audit / visibility — who is allowed to attribute sales.

---

## 4.5 Ops — Products

### What you see
- Product rows with stock/promo/best-seller hints and price widget
- Offer icon = promo
- Price icon = edit price
- FAB **Add product**
- Long-press = toggle stock

### Promo Was / Now
Dialog captures **Was** (struck through) and **Now** (selling price). Now must be lower than Was.

### What happens when…

| You do this | Ops sees | Customer sees (Store/Home/Product after refresh) |
|---|---|---|
| Lower price while tracking compare-at | Updated price | ~~was~~ now if on promo |
| Mark promo with was/now | PROMO flag | Strikethrough pricing |
| Remove promo | Flag cleared; compare-at cleared | Single price |
| Long-press stock off | Out of stock | Add to cart disabled |
| Add product | New row | Appears in sample catalogue |

### Why
Ops can run specials and fix prices **without a developer** — locked operational need.

---

## 4.6 LIVE WALKTHROUGH — Ops (~2–3 min)

1. Login `ops@demo.com`  
2. Dashboard — point at metrics after the customer sale  
3. Orders — open the new order, maybe change status once  
4. Resellers — explain Approve B vs C (approve a pending if you created one)  
5. Products — show promo was/now quickly  
6. Explicitly say: “No Payouts here — that’s Super.”  
7. Logout

---

# 5) SUPER ADMIN — full section

## 5.0 Who is Super Admin?

**Login:** `super@demo.com` / `demo123`

### Job
Everything Ops can do, **plus**:
- **Payouts** — approve / reject reseller withdrawal requests
- **Activity** — chronological log of important demo events

### Why
Separation of duties. Day-to-day ops ≠ final authority on money leaving reseller balances.

---

## 5.1 Super — Payouts

### What you see
- Pending withdrawal requests (reseller email, amount)
- Approve / Reject actions

### What happens when…

| You do this | Super sees | Reseller sees after Refresh |
|---|---|---|
| **Approve** | Request leaves pending; Activity log “approved” | Balance stays reduced (payout confirmed) |
| **Reject** | Request rejected; Activity “funds returned” | Balance **restored** by that amount |

### Tie-back line
> “Reseller asked to withdraw → money reserved → I confirm or return it.”

---

## 5.2 Super — Activity

### What you see
Newest-first log lines, e.g.:
- Reseller applications / approvals / rejections
- Sale attribution with three-way split amounts
- Withdrawal request / approve / reject
- Training/academy interest style events
- Product changes (depending on what was logged)

### Why
Oversight trail for the demo — proves the system recorded what happened across roles.

---

## 5.3 LIVE WALKTHROUGH — Super (~1–2 min)

1. Login `super@demo.com`  
2. Show tabs include **Payouts** and **Activity** (Ops does not)  
3. Payouts — approve or reject the withdraw from Reseller demo  
4. Activity — scroll the sale + withdraw lines  
5. Optional: show you can still do Ops tasks (orders/products) as Super

---

# 6) Cross-role cheat sheet (keep visible)

| If this happens… | Customer | Reseller | Ops | Super |
|---|---|---|---|---|
| Training / academy interest | Success dialog | — | Lead counts / no dedicated leads tab | Activity line |
| Add to cart only | Cart fills | — | — | — |
| Checkout + OTP + **code** | Order + attribution copy | Sale + balance ↑ + client bought | Order + revenue | Activity sale split |
| Checkout + OTP, **no code** | Order, no attribution | — | Order without code | Activity/order |
| Reseller apply | — | Pending shell | Pending resellers ↑ | Activity |
| Ops approve B/C | — | Refresh unlocks code | Codes list grows | Activity |
| Ops reject | — | Rejected screen | Pending cleared | Activity |
| Reseller withdraw request | — | Balance down; awaiting Super | Withdrawals count ↑ | Payouts row |
| Super approve payout | — | Balance stays down | count down | Activity |
| Super reject payout | — | Balance restored | count down | Activity |
| Ops promo/price | Store shows new price | — | Products updated | maybe Activity |

---

# 7) Locked decisions & why (comment bait)

| Decision | Why you made / followed it | Comment to request |
|---|---|---|
| Samples in-app; full shop on website | Don’t rebuild production shop in V1 mobile; one ecosystem with `shop.digititan.co.za` | Keep? Or full in-app shop later via API? |
| Training = interest only | LMS already exists / separate | OK? |
| 53 / 26 / 21 + B/C codes | Meeting-locked sustainability model (differs from website ~10%) | **Confirm numbers** |
| Reseller sees only own share | Clarity; Digititan pays them their due | OK? |
| Withdraw last day + Super approve | Month-end discipline; separation of duties | OK? |
| Dual Ops / Super | Ops speed + Super control | OK? |
| Donations / ambassador out of mobile V1 | Locked / website-first | OK? |
| Demo data + fixed OTPs | Safe presentation; don’t over-claim | Next = real DB/API? |
| Demo checkout OTP instead of PayFast | Prove attribution without live payments | Later = redirect to website cart on shared API? |

---

# 8) Website vs Phase 1 (if challenged)

| Topic | Live website | This Phase 1 mobile |
|---|---|---|
| Accounts / cart sharing | PHP API + MySQL | Demo hub only (not API yet) |
| Shop | Full shop + PayFast | Samples + website CTA + demo OTP checkout |
| Commission | ~10% profile rate | **53/26/21** + B/C |
| Admin | One admin | Ops + Super |
| Donations | Yes | Out of mobile V1 |
| Reseller pending | Often can’t login (403) | Can login → pending UI |
| Withdraw | API exists; weak/no web UI | Month-end + Super (meetings) |

**Future sharing model (say if asked about data migration):**  
Don’t copy two databases. Point mobile at the **same API**. Same login → same server cart → checkout can open website with cart already filled.

---

# 9) Out of scope (say calmly, don’t apologise)

- Real OTP email/SMS gateway  
- Real Google Sign-In  
- Real DB / PHP API connection  
- Live PayFast inside the app  
- Bank auto-debit  
- Donations / ambassador in mobile  
- Public store release  
- Full website parity (wishlist, reviews, search parity, etc.)

> “Backlog by design so today is about journeys and rules.”

---

# 10) Ask for comments (write answers down)

1. Does the Customer path (Training / Academies / Store) match how people should enter?  
2. Is apply → approve → code → sale → month-end withdraw correct?  
3. Is **53 / 26 / 21** still the split to build?  
4. Any change to Ops vs Super?  
5. Phase 2: **call the live PHP/PayFast API like the website**, or keep **locked mobile rules** and sync data?  
6. Priority order for next build?  
7. What must **not** be in V1?

---

# 11) Close

> Thanks — I’ll capture today’s comments, update what’s locked vs changed, and propose the next build. My recommendation after journey sign-off is connecting the **shared production API** so website and mobile use the same accounts and carts.

---

# 12) Pre-flight checklist

- [ ] App runs  
- [ ] All four logins work  
- [ ] Customer interest + store + checkout with `VNA-B-LERATO` + OTP `654321`  
- [ ] Reseller sees sale + can simulate withdraw  
- [ ] Super Payouts visible; Ops has no Payouts  
- [ ] This doc open; cheat accounts visible  
- [ ] Browser ready for https://www.shop.digititan.co.za/  

### Demo accounts (password always `demo123`)
| Role | Email |
|---|---|
| Customer | `customer@demo.com` |
| Reseller | `reseller@demo.com` |
| Ops | `ops@demo.com` |
| Super | `super@demo.com` |

---

# 13) Comment capture sheet

| # | Topic | Their comment | Action (keep / change / later) |
|---|---|---|---|
| 1 | Customer pillars | | |
| 2 | Reseller journey | | |
| 3 | 53/26/21 + B/C | | |
| 4 | Ops vs Super | | |
| 5 | Website clone vs locked mobile | | |
| 6 | Shared API / cart redirect next | | |
| 7 | Out of V1 | | |

---

*Companion locked docs in this repo:* `12-LOCKED-DECISIONS.md` · `18-RESELLER-CODES-AND-DUAL-ADMIN.md` · `19-LIVE-DEMO-RESELLER-ADMIN.md`

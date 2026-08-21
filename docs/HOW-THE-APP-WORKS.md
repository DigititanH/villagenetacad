# How Village NetAcad works

This document explains the **existing web application** in this repository: what it is, who uses it, how the pieces talk to each other, and the business rules a mobile app must copy.

There is almost no product documentation in the repo besides deploy guides. Everything below is reverse-engineered from the React frontend (`frontend/`) and PHP API (`backend-php/`).

If you are building a mobile app that behaves like the website, also read:

- [MOBILE-APP-GUIDE.md](./MOBILE-APP-GUIDE.md) — screen-by-screen map and what to reuse
- [API.md](./API.md) — full HTTP contract (auth, bodies, status codes)

---

## What the product is

**Village NetAcad** (branded “Village Netacad powered by Digititan”) is a South African **education + shop + fundraising** platform.

It is **not** a course-delivery LMS. Courses on the site are marketing content (static cards + external Google/Microsoft registration forms). The live, data-driven parts of the app are:

1. **Merchandise shop** — branded products, cart, checkout, PayFast payment
2. **Donations** — donate to a named academy, paid via PayFast
3. **Reseller programme** — academies/resellers get a referral code; they earn commission on shop orders
4. **Admin back-office** — products, orders, users, donations, reseller approval

Currency is **ZAR** (displayed as `R`). Contact email is `info@villagenetacad.co.za`.

Default seeded admin (after migrate): `admin@villagenetacad.com` / `Admin123!`

---

## High-level architecture

```
┌─────────────────────────┐         JSON /api/*          ┌──────────────────────────┐
│  React SPA (Vite)       │  Bearer JWT + CORS           │  PHP 8.1+ API            │
│  frontend/src           │ ───────────────────────────► │  backend-php/            │
│                         │                              │  custom router, no       │
│  localStorage: token,   │  POST form (hidden fields)   │  Composer / Node on host │
│  user, referral code    │ ───────────────────────────► │                          │
└─────────────────────────┘         PayFast hosted pay   └────────────┬─────────────┘
                                                                      │
                         PayFast ITN (server-to-server)               │
                         POST /api/payfast/notify  ◄──────────────────┤
                                                                      │
                                                                      ▼
                                                           MySQL / MariaDB
                                                           + file uploads
```

**Production hosting:** one PHP process serves both the built React files (`frontend/dist` copied into `backend-php/public`) and the JSON API. There is **no Node.js on the server**. Document root is `backend-php/public`.

**Local development:** Vite on `:5173` proxies `/api`, `/uploads`, `/health` to PHP on `:5000`.

```
frontend/          React 18 + Vite + Tailwind + react-router-dom + axios
backend-php/      Front-controller public/index.php → Router.php → controllers
deploy/            Afrihost cPanel + Azure App Service packaging
```

The API is a **hand-rolled PHP router**. There is no Laravel/Symfony. Classes autoload from `lib/`, `controllers/`, `routes/`.

---

## Three user roles

| Role | How they get it | What they can do |
|------|-----------------|------------------|
| `customer` | Register with Account Type = Customer. Auto-approved. JWT issued immediately. | Shop, cart, checkout (must supply a reseller referral code), wishlist, reviews, orders, donate, contact |
| `reseller` | Register with Account Type = Reseller + academy name. **Pending** until an admin approves. No JWT until approved. | After approval: same as customer, plus dashboard with referral code, commissions, referred sales |
| `admin` | Seeded / assigned in DB. Cannot self-register as admin. | Everything, plus product CRUD, order status/tracking, user roles/approval, donations reports, reseller approve/reject/suspend. Checkout **does not** require a referral code |

Login redirects:

- admin → `/admin/dashboard`
- reseller → `/reseller/dashboard`
- customer → `/`

Pending or declined resellers cannot log in (`403`). If they somehow have a token but `is_approved !== "approved"`, the reseller routes show a pending screen instead of the dashboard.

---

## Screens (web routes)

Public marketing (mostly static, from `frontend/src/data/digititanAbout.js`):

| Path | Page | Backed by API? |
|------|------|----------------|
| `/` | Home — slideshow, stats, services, CTAs | No |
| `/about` | About Digititan / Village NetAcad | No |
| `/courses` | Four course cards + pillars + **external** registration forms | No |
| `/contact` | Form + email/phone/map | `POST /api/contact` |
| `/health` | Frontend health check | optional |

Shop & money:

| Path | Page | API |
|------|------|-----|
| `/shop` | Product grid, search, category, sort, add-to-cart | products, cart |
| `/shop/:slug` | Product detail, size/color, wishlist, reviews | products, cart, wishlist, reviews |
| `/cart` | Server cart (login required) | cart |
| `/checkout` | Address + referral + PayFast (login required) | orders, payfast |
| `/wishlist` | Saved products (login required; **not in navbar**) | wishlist |
| `/my-orders` | Order list (login required) | orders |
| `/donation` | Amount presets, academy name, PayFast | donations, payfast |
| `/payment/success` | Return from PayFast; polls order until paid | orders / donations |
| `/payment/cancel` | PayFast cancel | none |

Auth:

| Path | Page |
|------|------|
| `/login` | Email + password |
| `/register` | Name, email, password, role, academy (if reseller) |
| `/forgot-password` | Sends email if account exists |

**Missing frontend pages (API exists, UI does not):** `/verify-email`, `/reset-password`. Emails still link there.

Admin (`role=admin`, sidebar layout):

- `/admin/dashboard` — KPI cards + monthly revenue/orders charts
- `/admin/products` — create/edit/delete products (multipart image upload)
- `/admin/orders` — list, status, tracking
- `/admin/users` — search, role, approve, delete
- `/admin/donations` — list + CSV/PDF-as-text reports
- `/admin/resellers` — approve / reject / suspend

Reseller (`role=reseller`, sidebar layout):

- `/reseller/dashboard` — total earned, commission %, referral code + shop link ` /shop?ref=CODE `
- `/reseller/sales` — orders attributed via commission rows

---

## Authentication

- Passwords: bcrypt cost 12, stored in `logins` (not in `registrations`).
- Token: **HS256 JWT** signed with `JWT_SECRET`, default expiry `7d`. Payload is `{ id, exp, iat }` where `id` is `registrations.id`.
- Client sends `Authorization: Bearer <token>` on every authenticated call.
- Web stores `token` and `user` JSON in **localStorage**. On 401, both are cleared and the browser is sent to `/login`.
- `POST /api/auth/logout` is a no-op on the server (stateless JWT). The client just deletes storage.
- Users live in two tables:
  - `registrations` — profile, role, approval, verification token
  - `logins` — email, password, reset token, last login

`GET /api/auth/me` returns the joined profile (no password).

---

## Shop, cart, and checkout (the core money flow)

```
Browse products (public)
        │
        ▼
Login required to add to cart  ──►  cart is per-user in MySQL (not local)
        │
        ▼
Cart: qty, size, optional color
        │
        ▼
Checkout (protected)
  - shipping_address: { street, city, province, zip, phone }  (JSON column)
  - referral_code REQUIRED unless user.role === admin
  - referral must match an approved reseller_profiles.referral_code
        │
        ▼
POST /api/orders  creates order + order_items, payment_status=pending
        │
        ├─ PayFast configured  →  client POST /api/payfast/order/{id}
        │                         server returns { url, fields }
        │                         client POSTs a hidden HTML form to PayFast
        │
        └─ PayFast not configured → OrderFulfillment::fulfill() immediately
                                    (marks paid, decrements stock, pays commission)
        │
        ▼
PayFast ITN  POST /api/payfast/notify
  - verifies signature + PayFast validate endpoint
  - m_payment_id is "order-{id}" or "donation-{id}"
  - on COMPLETE + amount match → fulfill order
```

**Referral capture:** any URL with `?ref=VNA-XXXXXXXX` is stored in `localStorage` key `reseller_referral_code` (`frontend/src/lib/referral.js`). Checkout pre-fills from that. Reseller share link is `{origin}/shop?ref={code}`.

**Fulfillment** (`backend-php/lib/OrderFulfillment.php`) when payment succeeds:

1. Decrement product stock (fails if insufficient)
2. If referral code is an approved reseller: insert `commissions` row = `order.total * commission_rate/100` (default **10%**), add to `wallet_balance` and `total_earned`
3. Set `orders.payment_status = paid`, `status = processing`
4. Clear the user's cart
5. Email site inbox with order details

Order statuses: `pending` → `processing` → `shipped` → `delivered` (or `cancelled`). Admins update status and tracking number.

---

## Donations

Anyone (logged in or not) can donate.

Required: amount ≥ R1, **academy name**.

If PayFast is on: email required; name required unless anonymous.

`POST /api/donations` inserts `payment_status=pending` then either:

- returns signed PayFast `{ url, fields }` immediately, or
- records a pledge and emails the site (when PayFast is off)

ITN marks donation `completed` and emails the site.

Recurring flags exist in the DB (`is_recurring`, `recurring_interval`) but the **current donation form always sends `is_recurring: false`**.

---

## PayFast (payments)

South African payment gateway. Sandbox vs live via `PAYFAST_SANDBOX`.

The browser never signs payments. The PHP API builds the field set (merchant id/key, amount, item name, `m_payment_id`, return/cancel/notify URLs, MD5 signature) and the client POSTs those fields to:

- sandbox: `https://sandbox.payfast.co.za/eng/process`
- live: `https://www.payfast.co.za/eng/process`

Return paths:

- success: `/payment/success?type=order|donation&id={id}`
- cancel: `/payment/cancel?type=order|donation&id={id}`

Notify URL: `POST /api/payfast/notify` (must be publicly reachable; localhost cannot receive ITN).

`GET /api/payfast/status` → `{ configured: true|false }` so the donation page can warn users.

---

## Reseller programme

On reseller register:

- `registrations.is_approved = pending`
- `reseller_profiles` row with `referral_code` like `VNA-` + 8 hex chars, `commission_rate` default 10, `status=pending`
- Email to site inbox

Admin approves via Users (`is_approved`) or Resellers (`status`). Those two fields are kept in sync.

**API exists but the web UI does not use it:**

- `POST /api/resellers/withdraw` + bank details (deducts wallet immediately, admin can reject and refund)
- notifications (`/api/notifications`, admin send)

A mobile app can implement withdrawals even though the website currently does not.

---

## Search

`GET /api/search?q=` (min 2 chars) returns:

- up to 8 active products (name/description/category)
- matching categories
- matching **static page titles** (Home, Shop, Donation, …)

Web navbar uses Ctrl/Cmd+K.

---

## Data model (simplified)

Users are split:

```
registrations (id, name, role, avatar, phone, is_verified, is_approved, verification_token)
logins        (registration_id, email, password, reset_token, reset_token_expires, last_login_at)
```

Commerce:

```
categories → products (slug, price, compare_price, image, stock, sizes JSON, colors JSON, is_active)
cart       (user_id, product_id, quantity, size, color)
wishlist   unique (user_id, product_id)
reviews    unique-per-user-product in practice (409 if duplicate)
orders     (total, status, shipping_address JSON, payment_status, referral_code, tracking_number)
order_items
```

Money / partners:

```
donations (optional user_id, academy, amount, payment_status, is_anonymous)
reseller_profiles (user_id, referral_code, commission_rate, status, wallet_balance, total_earned, academy)
commissions (reseller_id, order_id, amount, status pending|paid)
withdrawals (reseller_id, amount, bank_details JSON, status)
notifications
contact_messages
```

Product `sizes` / `colors` are JSON **strings** in the database, e.g. `["S","M","L"]`. The frontend `JSON.parse`s them.

Images are files on disk under `UPLOADS_DIR`, served as `/uploads/{filename}`.

---

## What is static vs dynamic

**Static (hardcoded in React):** Home, About, Courses, most Footer/Navbar copy, course list, Digititan stats/pillars, external academy registration URLs.

**Dynamic (MySQL):** users, products, cart, orders, donations, resellers, reviews, wishlist, contact messages, search.

A mobile clone that is “almost exactly the same” must implement the dynamic shop/auth/reseller/admin flows against this API. Marketing pages can stay as content screens.

---

## Gaps and gotchas (copy these in a mobile app, or fix them)

1. **Cart is login-only.** Guests cannot add items; the shop shows a toast “Please login to add to cart”.
2. **Every non-admin order needs a valid approved reseller code.** There is no “no reseller” checkout.
3. **Product listing `total` ignores category/search filters** (counts all active products).
4. **Verify-email and reset-password emails point at routes the SPA does not implement.**
5. **Wishlist is not linked in the navbar** (only `/wishlist` + heart on product detail).
6. **Withdrawals and in-app notifications are API-only.**
7. **CORS in production** allowlists `CLIENT_URL`. Native HTTP clients do not use CORS; a WebView of the SPA does.
8. **PayFast confirmation is async.** The success page polls `GET /api/orders/{id}` for `payment_status === "paid"` for ~30 seconds because ITN can lag behind the browser return.
9. `schema.sql` still shows a legacy `users` table; **runtime uses `registrations` + `logins`**. Trust `database/tables/*.sql` and `migrate.php`.

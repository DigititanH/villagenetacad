# How the website and mobile app share data

**There is no data migration between Village NetAcad web and the mobile app.**

Both are **clients of one backend**. Users, products, carts, orders, donations, and reseller wallets already live in **one MySQL database**, behind the **existing production PHP API** (`backend-php/`). The phone does not get its own copy of that database.

If you add a hoodie to cart in the app, it is the **same cart row** the website loads after you log in with the same email and password.

---

## The picture

```
  Production website                    Mobile app
  (React SPA)                           (browse + cart only)
              │                                  │
              │  HTTPS /api/*                    │  HTTPS /api/*
              │  Bearer JWT                      │  Bearer JWT
              │                                  │
              └──────────────┬───────────────────┘
                             ▼
                 existing PHP API  /api/*
                 (the live villagenetacad host)
                             │
                             ▼
                 one MySQL database
                 + /uploads product images
```

| What | Where it lives | Shared? |
|------|----------------|---------|
| Users, passwords, roles | MySQL `registrations` + `logins` | Yes — **same email + password** on web and phone |
| Products, stock, prices | MySQL `products` | Yes |
| Cart | MySQL `cart` (per `user_id`, **server-side**) | Yes — add on phone, checkout on web |
| Orders / purchase history | MySQL `orders` + `order_items` | Yes — My Orders on both |
| Wishlist, reviews, donations | MySQL | Yes |
| Reseller codes, commissions, wallet | MySQL | Yes |
| Product images | `/uploads/...` on the same host | Yes |
| JWT token | Browser `localStorage` **or** phone Keychain | **No** — each device has its own token for the **same user id** |
| Theme, last referral code | Device storage | Per device |
| Courses “I’m interested in” | **Does not exist** | Courses are static marketing + external Google/Microsoft forms. Nothing is saved per user today |

There is no “web user” vs “app user”. One `registrations.id`.

---

## Intended product split (no PayFast in the app)

The mobile app **does not take payment**. Users can browse, log in, and add to cart. Checkout stays on the **production website** (PayFast already works there).

```
Phone                              Production website
─────                              ──────────────────
Login (same email/password)
Browse shop
POST /api/cart  ──writes──►  MySQL cart for that user
Tap “Checkout”
     │
     │  open browser
     ▼
                          GET /login?next=/cart
                          User signs in (same account)
                          CartContext GET /api/cart
                          → same items they added on the phone
                          Proceed to /checkout → PayFast
```

Website login now honours `?next=` (safe same-origin paths only). After sign-in, `/login?next=/cart` lands on the cart instead of Home.

**Mobile checkout button** should open the live site, not call `POST /api/orders`:

```text
https://<production-host>/login?next=/cart
```

If the phone browser already has a website session, `/cart` is enough.

Donations can use the same pattern: open `https://<production-host>/donation` (or `/login?next=/donation`).

After they pay on the web, `GET /api/orders/my-orders` in the app shows the new order — same database.

---

## What you should *not* do

| Approach | Why not |
|----------|---------|
| Export MySQL → import into mobile SQLite / Firebase / a second API | Two sources of truth. Carts and stock would drift. |
| CSV / JSON dump “for the app” | A snapshot, not live shop data. |
| Rebuild a Node/Laravel backend “for mobile” | You’d migrate *into* a new system and keep it in sync forever. |
| Copy users into a new “mobile accounts” table | They would not be the same login. |
| Take card payments in the app | Out of scope: redirect to the website cart instead. |

The only “migration” this repo already has is **hosting setup**: `php backend-php/database/migrate.php` when you first create MySQL. That is for the server. It is **not** web → phone.

---

## How a user actually shares data

1. Register or log in on **either** client → `POST /api/auth/login` → JWT whose `id` is `registrations.id`.
2. Mobile stores that JWT in **secure storage** (website uses `localStorage`).
3. Cart/wishlist/orders send `Authorization: Bearer <jwt>`.
4. PHP loads the same rows. No mapping table.

Same credentials work on both because they hit the **same** `logins` table.

Website and app JWTs are independent. Logging out of the app does not log them out of the browser (and vice versa). The **cart** still matches because it is keyed by user id, not by token.

---

## Courses (important)

The Courses screen is **not** user data. It is hardcoded in `frontend/src/pages/Courses.jsx`. Registration goes to external forms (`digititanLinks` in `frontend/src/data/digititanAbout.js`).

So “courses I am interested in” **will not appear on the other client** unless you later add a real table (e.g. `course_interests`) and API. Wishlist today is **products only**.

---

## Device-only data (not shared)

Safe to keep only on the phone:

- JWT + cached `user` (refresh with `GET /api/auth/me`)
- Last reseller `ref` code (website: `localStorage.reseller_referral_code`) — still send it, or let them enter it on web checkout
- UI prefs (theme, onboarding)

Do **not** keep a private cart on the phone. Always `POST /api/cart` so the website can see it.

Referral at web checkout is still **required** for non-admins. If they captured `?ref=` in the app, either:

- pass it in the URL: `/login?next=/cart` and also set it on the site (`/shop?ref=CODE` first), or
- they type the code on the website cart (the cart page already has that field)

Simplest handoff that keeps the referral:

```text
https://<host>/shop?ref=VNA-XXXXXXXX
```

then after login they still have `reseller_referral_code` in website `localStorage`. Or open:

```text
https://<host>/login?next=/cart
```

and they enter the code on the cart page if it is missing.

---

## Network

- **Native apps ignore CORS.** Point the app at `https://<live-host>/api`.
- Production PHP must be reachable over HTTPS from the phone.
- Image paths like `/uploads/foo.jpg` need the site origin prefix on mobile.
- Do not wrap a second database. Optional offline **cache** of product cards is fine; the cart must be live.

---

## If you ever *did* migrate data

Only when **moving hosts** (Afrihost MySQL → another MySQL), not when adding a mobile app:

1. Dump/import the same schema
2. Copy `UPLOADS_DIR`
3. Point **both** the website and the mobile `API_URL` at the new API
4. Keep `JWT_SECRET` the same if you want existing tokens to keep working

Adding a mobile app does not require that work.

---

## Practical setup

```text
API_URL    = https://<existing-villagenetacad-host>/api
ORIGIN     = https://<existing-villagenetacad-host>
CHECKOUT   = https://<existing-villagenetacad-host>/login?next=/cart
```

Admin stays on the website. Customers use website, app, or both. One database. Payment only on the website.

# How the website and mobile app share data

**There is no data migration between Village NetAcad web and the mobile app.**

Both are **clients of one backend**. Users, products, carts, orders, donations, and reseller wallets already live in **one MySQL database**, behind the **existing PHP API** (`backend-php/`). The phone does not get its own copy of that database.

If someone buys a hoodie on the website, it is the same order they see in My Orders on the app — same account, same `GET /api/orders/my-orders`.

---

## The picture

```
  Village NetAcad website          Village NetAcad mobile app
  (React SPA in the browser)       (React Native / Flutter / etc.)
              │                                  │
              │  HTTPS JSON                      │  HTTPS JSON
              │  Authorization: Bearer <jwt>     │  Authorization: Bearer <jwt>
              │                                  │
              └──────────────┬───────────────────┘
                             ▼
                 existing PHP API  /api/*
                 backend-php/  (Afrihost / Azure)
                             │
                             ▼
                 one MySQL database
                 + /uploads product images
```

| What | Where it lives | Shared? |
|------|----------------|---------|
| Users, passwords, roles | MySQL `registrations` + `logins` | Yes — same login on web and phone |
| Products, stock, prices | MySQL `products` | Yes |
| Cart | MySQL `cart` (per user, **server-side**) | Yes — add on phone, see it on web after refresh |
| Orders, donations, wishlist, reviews | MySQL | Yes |
| Reseller codes, commissions, wallet | MySQL | Yes |
| Product images | Files under `UPLOADS_DIR`, URL `/uploads/...` | Yes — load from the same origin |
| JWT token | Browser `localStorage` **or** phone Keychain | **No** — each device stores its own token for the **same user id** |
| Theme, last referral code | Device storage | Per device (referral should still be sent at checkout) |

The website already works this way: the React app does not hold the shop. It calls `/api`. A mobile app is a second UI doing the same calls.

---

## What you should *not* do

These are the usual “data migration” instincts — skip them:

| Approach | Why not |
|----------|---------|
| Export MySQL → import into a mobile SQLite / Firebase / second API | Two sources of truth. Stock, carts, and payments would drift. |
| CSV / JSON dump “for the app” | That’s a snapshot, not live shop data. |
| Rebuild a Node/Laravel backend “for mobile” | You’d have to migrate *into* a new system and keep it in sync forever. |
| Sync engines (WatermelonDB, Realm, custom queues) as the source of truth | Optional **cache** later; never the database of record. |

The only “migration” this project already has is **hosting**: `php backend-php/database/migrate.php` (or phpMyAdmin import) when you set up MySQL. That is web **and** mobile together. It is not web → phone.

---

## How a user actually shares data

1. User registers or logs in on **either** client → `POST /api/auth/login` → JWT with `id` = `registrations.id`.
2. Mobile stores that JWT in **secure storage** (same role as website `localStorage`).
3. Every cart/order/wishlist call sends `Authorization: Bearer <jwt>`.
4. PHP looks up the same row. There is no user-mapping table between “web users” and “app users”.

Same email + password works on both. There is no separate “mobile account”.

---

## Device-only data (not migrated)

Safe to keep only on the phone:

- JWT (and a cached `user` object, refreshed with `GET /api/auth/me`)
- Last reseller `ref` code (website uses `localStorage.reseller_referral_code`)
- UI prefs (theme, onboarding flags)
- Optional **cache** of the last product list for offline browse — must re-fetch before checkout so stock/price match the server

Do **not** treat the on-device cache as the shop. Checkout must use `GET /api/cart` + `POST /api/orders` against live MySQL.

---

## Network details that matter

- **Native apps ignore CORS.** CORS only applies to browsers. Point the app at `https://your-production-host/api`. Production PHP still needs to be reachable over HTTPS.
- If you instead wrap the **existing website** in a WebView, you are not a second client — you are the same SPA, same cookies/localStorage origin issues. Prefer a native HTTP client + the JSON API.
- **PayFast** does not live in the database as “pending card data”. The API creates the order/donation, PayFast redirects the user, then **ITN** `POST /api/payfast/notify` updates MySQL. The phone never talks to MySQL; it must still complete PayFast in a browser/WebView, then poll `GET /api/orders/{id}`.
- Image URLs like `/uploads/foo.jpg` are relative. On mobile, prefix the site origin: `https://your-host/uploads/foo.jpg`.

---

## If you ever *did* migrate data

Only when **moving hosts** (e.g. Afrihost MySQL → another MySQL), not when adding a mobile app:

1. Dump/import the same schema (`backend-php/database/`)
2. Copy `UPLOADS_DIR`
3. Point **both** `CLIENT_URL` (website) and the mobile `API_URL` at the new API
4. Keep `JWT_SECRET` the same if you want existing tokens to keep working

Adding a mobile app does not require that work. Ship the app against the API you already have.

---

## Practical setup for the mobile team

```text
API_URL   = https://<existing-villagenetacad-host>/api
ORIGIN    = https://<existing-villagenetacad-host>     # images + referral links
```

Admin keeps using the website. Customers/resellers can use website, app, or both. One database.

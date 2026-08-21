# Village NetAcad API

JSON API used by the React website. A mobile app should call the **same** endpoints.

Base path: `{API_URL}` (local `http://localhost:5000`, production is the site origin).

All JSON routes are under `/api/...`. Errors look like `{ "message": "..." }` with the HTTP status below.

## Conventions

| Item | Detail |
|------|--------|
| Content-Type | `application/json` except product create/update (`multipart/form-data`) |
| Auth | Header `Authorization: Bearer <jwt>` |
| CORS | Production: origins from `CLIENT_URL` (comma-separated). Dev: any origin |
| Money | Decimal strings/numbers in ZAR. Display as `R12.50` |
| IDs | Integers |
| Product sizes/colors | JSON **strings** in DB/API: `'["S","M"]'` — parse in the client |

Public endpoints need no token. Authenticated endpoints return **401** if the token is missing/invalid/expired. Wrong role returns **403**.

---

## Health

### `GET /health`

Not under `/api`. Used by hosting checks.

---

## Auth

### `POST /api/auth/register`

Body:

```json
{
  "name": "Jane",
  "email": "jane@example.com",
  "password": "secret6+",
  "role": "customer",
  "academy": ""
}
```

- `role` is `customer` (default) or `reseller`. Anything else becomes customer. Cannot register as `admin`.
- Reseller **must** send non-empty `academy`.
- **201 customer:** `{ token, user: { id, name, email, role, is_approved } }`
- **201 reseller pending:** `{ pending: true, message, user }` — **no token**
- **400** missing fields / missing academy
- **409** email already registered

Frontend also enforces password length ≥ 6 (API does not).

### `POST /api/auth/login`

```json
{ "email": "jane@example.com", "password": "..." }
```

**200:** `{ token, user: { id, name, email, role, avatar, is_approved } }`

**401** invalid credentials. **403** pending (non-admin) or declined.

Email is lowercased.

### `GET /api/auth/verify-email?token=`

Sets `is_verified=1`. **200** `{ message }`. **400** invalid token.

### `POST /api/auth/forgot-password`

```json
{ "email": "jane@example.com" }
```

Always **200** `{ message: "If that email exists, a reset link was sent" }` (no user enumeration). Reset link: `{CLIENT_URL}/reset-password?token=`. Token valid 1 hour.

### `POST /api/auth/reset-password`

```json
{ "token": "...", "password": "new" }
```

### `GET /api/auth/me` — **auth required**

**200:** `{ user: { id, name, email, role, avatar, phone, is_verified, is_approved } }`

### `POST /api/auth/logout`

**200** `{ message }` — JWT is not revoked.

---

## Products (catalog is public)

### `GET /api/products`

Query: `category` (category **slug**), `search`, `sort` (`price_asc` \| `price_desc` \| newest), `page` (default 1), `limit` (default 12).

**200:**

```json
{
  "products": [ { "id": 1, "name": "...", "slug": "...", "price": "199.00", "image": "/uploads/...", "stock": 10, "sizes": "[\"S\",\"M\"]", "colors": null, "category_name": "T-Shirts", "avg_rating": "4.5", "review_count": 3 } ],
  "total": 40,
  "page": 1,
  "limit": 12
}
```

Only `is_active = 1`. `total` is **all** active products, not the filtered count.

### `GET /api/products/meta/categories`

**200:** `[{ id, name, slug, image, created_at }, ...]`

### `GET /api/products/{slug}`

**200:** product row + `category_name`. **404** if missing.

### `POST /api/products` — **admin**

`multipart/form-data`: `name` (required), `description`, `price`, `compare_price`, `category_id`, `stock`, `sizes`, `colors`, file field `image`.

Slug is generated as `slugify(name)-{unixTime}`. Image stored under `/uploads/...`.

**201:** `{ id, message }`

### `PUT /api/products/{id}` — **admin**

Same fields as create (JSON or multipart). Changing `name` regenerates slug.

### `DELETE /api/products/{id}` — **admin**

---

## Cart — **auth required** (any logged-in role)

Cart is **server-side**, keyed by `user_id`. Guests have no cart.

### `GET /api/cart`

Array of cart rows joined to product: `id, user_id, product_id, quantity, size, color, name, price, image, stock, available_sizes`.

### `POST /api/cart`

```json
{ "product_id": 1, "quantity": 1, "size": "M", "color": "Black" }
```

If the same user+product+size+color exists, quantity is incremented. **201.**

### `PUT /api/cart/{id}`

```json
{ "quantity": 2, "size": "L" }
```

Quantity `< 1` deletes the row.

### `DELETE /api/cart/{id}`

### `DELETE /api/cart`

Clears the whole cart.

---

## Orders

### `POST /api/orders` — **auth**

```json
{
  "items": [
    { "product_id": 1, "quantity": 2, "size": "M", "color": null }
  ],
  "shipping_address": {
    "street": "...",
    "city": "...",
    "province": "...",
    "zip": "...",
    "phone": "..."
  },
  "referral_code": "VNA-ABCD1234"
}
```

Rules:

- `items` and `shipping_address` required
- Non-admins **must** send a referral code that exists on an **approved** reseller
- Product must be active; stock must cover quantity
- Prices are taken from the **database**, not the client
- `shipping_address` is stored as JSON text

**201** if PayFast configured:

```json
{ "order_id": 12, "total": 398, "payfast": true, "message": "..." }
```

Then call `POST /api/payfast/order/12` and POST `fields` to `url`.

**201** if PayFast **not** configured: `{ payfast: false }` and the order is fulfilled immediately (paid + stock + commission).

### `GET /api/orders/my-orders` — **auth**

Array of the current user's orders, each with `items: order_items[]`.

### `GET /api/orders/{id}` — **auth**

Owner or admin. Includes `items`. Used by the payment success page to poll `payment_status`.

### `GET /api/orders/admin/all` — **admin**

Query: `status`, `page`, `limit` (default 20).

**200:** `{ orders, total }` with `customer_name`, `customer_email`.

### `PUT /api/orders/{id}` — **admin**

```json
{ "status": "shipped", "tracking_number": "ABC123" }
```

`status` ∈ `pending | processing | shipped | delivered | cancelled`.

---

## Wishlist — **auth**

### `GET /api/wishlist`

Rows with `name, price, image, slug`.

### `POST /api/wishlist/toggle`

```json
{ "product_id": 1 }
```

**200:** `{ message, wishlisted: true|false }`

---

## Reviews

### `GET /api/reviews/product/{productId}` — public

Array with `user_name`, `avatar`, `rating` (1–5), `comment`.

### `POST /api/reviews` — **auth**

```json
{ "product_id": 1, "rating": 5, "comment": "Great" }
```

**409** if this user already reviewed that product.

### `DELETE /api/reviews/{id}` — **auth** (owner or admin)

---

## Donations

### `POST /api/donations` — public

```json
{
  "amount": 100,
  "donor_name": "Jane",
  "email": "jane@example.com",
  "message": "",
  "academy": "My Academy",
  "is_anonymous": false,
  "is_recurring": false,
  "recurring_interval": null,
  "user_id": 5
}
```

- `amount` ≥ 1
- `academy` required
- If PayFast on: `email` required; `donor_name` required unless anonymous
- `user_id` is optional (web sends `user.id` when logged in)

**201 PayFast:** `{ donation_id, academy, payfast: true, url, fields, message }`

**201 no PayFast:** `{ donation_id, academy, payfast: false, message }`

### `GET /api/donations/my-donations` — **auth**

### `GET /api/donations/{id}/summary` — public

`{ id, academy, amount, donor_name, payment_status, is_anonymous }`

### `GET /api/donations/admin/all` — **admin**

`{ donations, summary: { count, total }, monthly: [{ month, total, count }] }`

---

## PayFast

### `GET /api/payfast/status` — public

`{ configured: boolean, ... }` via `Payfast::statusPayload()`.

### `POST /api/payfast/pay` and `POST /api/pay` — public

Generic signed-form helper (used by debug / tutorial flow):

```json
{
  "amount": 50,
  "item_name": "Test",
  "name_first": "Jane",
  "name_last": "",
  "email_address": "jane@example.com",
  "m_payment_id": "donation-1",
  "return_url": "...",
  "cancel_url": "..."
}
```

**200:** `{ url, fields }` — POST `fields` as a form to `url`.

### `POST /api/payfast/order/{orderId}` — **auth** (owner or admin)

Builds payment for that order. `m_payment_id` = `order-{id}`.

Fails if already `paid` or PayFast unconfigured (**503**).

### `POST /api/payfast/donation/{donationId}` — public

Same for donations (`m_payment_id` = `donation-{id}`). Donation create already returns `url`/`fields`; this is a retry helper.

### `POST /api/payfast/notify` — PayFast server (ITN)

Form POST, not JSON. Responds `OK` immediately, then verifies signature + PayFast validate, then fulfills.

Dev-only: `GET /api/payfast/check`, `GET /api/payfast/debug-signature` (**404** in production).

---

## Resellers

### `GET /api/resellers/profile` — **reseller**

Full `reseller_profiles` row + `name`, `email`, `is_approved`. Syncs profile `status` with user approval if they drifted.

### `GET /api/resellers/commissions` — **reseller** (must be approved)

`[{ id, reseller_id, order_id, amount, status, created_at, order_total, order_date }]`

### `GET /api/resellers/sales` — **reseller** (approved)

`[{ id, total, status, created_at, customer_name }]` — orders that generated a commission for this reseller.

### `POST /api/resellers/withdraw` — **reseller** (approved)

```json
{
  "amount": 50,
  "bank_details": { "bank": "...", "account": "...", "holder": "..." }
}
```

Deducts `wallet_balance` immediately. **400** insufficient balance. Emails site inbox.

**Not used by the current website UI.**

### `GET /api/resellers/withdrawals` — **reseller** (approved)

### `GET /api/resellers/admin/all` — **admin**

### `PUT /api/resellers/admin/{id}/status` — **admin**

```json
{ "status": "approved" }
```

`approved | rejected | suspended`. Also sets `registrations.is_approved` to `approved` or `declined`.

### `GET /api/resellers/admin/withdrawals` — **admin**

### `PUT /api/resellers/admin/withdrawals/{id}` — **admin**

```json
{ "status": "completed" }
```

`approved | rejected | completed`. **rejected** refunds the amount to `wallet_balance`.

---

## Admin extras

All **admin**.

### `GET /api/admin/dashboard`

```json
{
  "stats": {
    "total_users": 0,
    "users_by_role": [{ "role": "customer", "count": 1 }],
    "total_orders": 0,
    "total_revenue": 0,
    "pending_orders": 0,
    "total_donations": 0,
    "donation_count": 0,
    "total_products": 0,
    "pending_resellers": 0
  },
  "monthly_sales": [{ "month": "2026-08", "revenue": 0, "orders": 0 }],
  "recent_orders": [],
  "top_products": []
}
```

### `GET /api/admin/users?role=&search=&page=&limit=`

`{ users, total }` — `total` is all registrations, not filtered.

### `PUT /api/admin/users/{id}/role`

```json
{ "role": "customer" }
```

`admin | reseller | customer`.

### `PUT /api/admin/users/{id}/approve`

```json
{ "status": "approved" }
```

`approved | declined`. If the user is a reseller, profile status becomes `approved` or `rejected`.

### `DELETE /api/admin/users/{id}`

Cannot delete yourself.

### `GET /api/admin/contacts`

### `POST /api/admin/notifications`

```json
{ "user_id": 1, "title": "...", "message": "...", "type": "info" }
```

`type`: `info | success | warning | error`. **Not used by the website UI.**

### `POST /api/admin/categories` / `DELETE /api/admin/categories/{id}`

### Reports (file download, still need Bearer token)

- `GET /api/admin/reports/sales/csv`
- `GET /api/admin/reports/sales/pdf` — **plain text** `.txt` (no PDF library on shared hosting)
- `GET /api/admin/reports/donations/csv`
- `GET /api/admin/reports/donations/pdf` — same, text file

---

## Notifications — **auth** (API only; no web UI)

### `GET /api/notifications`

Latest 50 for the current user.

### `PUT /api/notifications/read-all`

### `PUT /api/notifications/{id}/read`

---

## Search — public

### `GET /api/search?q=`

If `q` length &lt; 2: empty arrays.

**200:** `{ products: [... max 8], pages: [{ title, description, path }], categories: [... max 5] }`

---

## Contact — public

### `POST /api/contact`

```json
{ "name": "...", "email": "...", "subject": "...", "message": "..." }
```

Stores row + emails `SITE_EMAIL`. **201.**

---

## Uploads

`GET /uploads/{filename}` — product images. Not JSON.

---

## Typical mobile sequences

**Login**

1. `POST /api/auth/login`
2. Persist `token` (secure storage) and `user`
3. `GET /api/auth/me` on launch to refresh
4. Attach Bearer on all later calls
5. On 401: wipe token, show login

**Buy a hoodie**

1. `GET /api/products`
2. `POST /api/cart` (must be logged in)
3. `POST /api/orders` with shipping + `referral_code`
4. If `payfast: true` → `POST /api/payfast/order/{id}` → open PayFast in a WebView / browser with `url` + `fields`
5. Handle return URL; poll `GET /api/orders/{id}` until `payment_status` is `paid`

**Donate**

1. `POST /api/donations`
2. If `payfast` → POST form to PayFast
3. Optional: `GET /api/donations/{id}/summary`

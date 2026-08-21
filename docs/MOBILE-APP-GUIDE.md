# Mobile app guide (clone the existing website)

Use this when building a **native or cross-platform app** that should feel like the Village NetAcad website.

**Do not rebuild the backend, and do not migrate data onto the phone.** Point the app at the same production PHP API. Same login → same cart, orders, and reseller wallet.

**Do not take payment in the app.** Browse and add to cart on the phone; open the live website (`/login?next=/cart`) so they sign in with the same details and check out with PayFast there. See [DATA-SHARING.md](./DATA-SHARING.md).

Details: [DATA-SHARING.md](./DATA-SHARING.md) · [HOW-THE-APP-WORKS.md](./HOW-THE-APP-WORKS.md) · [API.md](./API.md)

---

## Recommended stack

Anything that can:

- Call HTTPS JSON APIs
- Store a JWT securely (Keychain / Keystore / `expo-secure-store`, not plain AsyncStorage in production)
- Open the **production website** in the system browser for checkout (`/login?next=/cart`)

React Native / Expo, Flutter, or Kotlin+Swift are all fine. The web app is React, so React Native reuses the most mental model (`AuthContext`, `CartContext`, axios interceptors).

Set `API_BASE` to the production origin, e.g. `https://your-domain/api` (web uses a relative `/api` because Vite/PHP serve same host).

Also prefix image paths: if `product.image` is `/uploads/foo.jpg`, load `{ORIGIN}/uploads/foo.jpg`.

---

## Information architecture (tabs)

Match the website’s main nav, then add account:

| Tab / stack | Web equivalent | Notes |
|-------------|----------------|-------|
| Home | `/` | Static marketing; reuse copy from `frontend/src/data/digititanAbout.js` |
| Courses | `/courses` | Static. Buttons open **external URLs** (`digititanLinks.academyRegistration`, `ascRegistration`) in the system browser |
| Shop | `/shop`, `/shop/:slug` | Core |
| Donate | `/donation` | Core |
| More | About, Contact, Login | Or a profile tab when logged in |

Logged-in extras (profile menu on web):

- My orders
- Wishlist (web hides this from the nav — include it in the app)
- Cart (web has a header icon; use a cart badge)
- Reseller dashboard **if** `user.role === "reseller"`
- Admin dashboard **if** `user.role === "admin"` (optional on mobile; many teams keep admin web-only)

---

## Screen checklist (parity with web)

### Guest / customer

- [ ] Splash / load token → `GET /auth/me`
- [ ] Home (hero, stats, CTAs)
- [ ] About
- [ ] Courses (4 cards + external register)
- [ ] Contact form → `POST /contact`
- [ ] Login / Register (customer vs reseller + academy field)
- [ ] Forgot password
- [ ] Shop list: search, category slug, sort `newest | price_asc | price_desc`
- [ ] Product detail: image, price, stock, size/color pickers, add to cart, wishlist heart, reviews + write review
- [ ] Cart: qty +/-, size select, remove, referral code field
- [ ] Checkout CTA opens the website: `{ORIGIN}/login?next=/cart` (no PayFast / no `POST /api/orders` in the app)
- [ ] My orders (read-only history from `GET /api/orders/my-orders`; new purchases appear after web checkout)
- [ ] Wishlist
- [ ] Wishlist
- [ ] Global search (`GET /search?q=`, debounce 300ms, min 2 chars)
- [ ] Capture `?ref=` (and universal links like `https://site/shop?ref=CODE`) into local referral storage

### Reseller (after admin approval)

- [ ] Dashboard: `total_earned`, `commission_rate`, copy referral code, copy `{origin}/shop?ref={code}`
- [ ] Commissions list
- [ ] Sales list
- [ ] Pending-approval screen if `is_approved !== "approved"`
- [ ] *(Optional, API-ready, not on website)* Wallet balance + withdraw with bank details

### Admin (optional on mobile)

- [ ] KPI dashboard + charts
- [ ] Products CRUD with image upload (`multipart`)
- [ ] Orders: filter status, set tracking
- [ ] Users: role, approve, delete
- [ ] Donations + CSV export
- [ ] Resellers: approve / reject / suspend

---

## Auth & session (copy the web behaviour)

Web (`frontend/src/context/AuthContext.jsx` + `lib/api.js`):

1. After login/register, save `token` and `user`
2. Axios interceptor adds `Authorization: Bearer`
3. On **401**, delete token/user and force login
4. On app start, if token exists, `GET /auth/me` and replace cached user

Mobile differences:

- Use **secure storage** for the JWT
- Do not rely on cookies
- CORS does not apply to native HTTP; you still need a reachable HTTPS API
- If production PHP only allowlists browser origins, native apps are unaffected

Register branching:

- Customer → store token, go Home
- Reseller `pending: true` → **do not** store token; show “wait for admin approval” and Login

Login branching (same as web):

- admin → Admin home
- reseller → Reseller home
- else → Home

---

## Cart rules (easy to get wrong)

- **No guest cart.** If add-to-cart 401s, send the user to Login (web toast: “Please login to add to cart”).
- Cart lines are unique on `(product_id, size, color)`.
- If the product has sizes, refuse add until a size is chosen (shop grid does this).
- Checkout refuses line items that have available sizes but empty `size`.
- Totals: `sum(price * quantity)` using **server** prices from `GET /cart`, not a client price list.

---

## Referral (required for checkout)

1. Persist last reseller `ref` code on the phone (website uses `localStorage.reseller_referral_code`).
2. If the app is opened via `.../shop?ref=VNA-XXXX`, save it.
3. Before opening the website for checkout, prefer `{ORIGIN}/shop?ref={code}` then cart, **or** they can type the code on the website cart (required for non-admins).

Reseller share text: `Shop Village NetAcad: {WEB_ORIGIN}/shop?ref={code}`

Reseller share text: `Shop Village NetAcad: {WEB_ORIGIN}/shop?ref={code}`

---

## Checkout: send them to the website (no PayFast in the app)

Cart lines are already in MySQL after `POST /api/cart`. Payment stays on the production site.

1. User taps Checkout in the app.
2. App opens the system browser to `{ORIGIN}/login?next=/cart`.
3. They sign in with the **same email and password**.
4. Website `Login` reads `next=/cart` and sends them to the cart (this is implemented in `frontend/src/pages/Login.jsx`).
5. `GET /api/cart` loads the items they added on the phone.
6. They proceed to `/checkout` and PayFast as they do today.
7. Back in the app, pull-to-refresh My Orders — the new order is there.

Do **not** call `POST /api/orders` or `/api/payfast/*` from the mobile client.

Donations: open `{ORIGIN}/login?next=/donation` (or `/donation` if they may already be logged in in that browser).

---

## Marketing content to copy (no API)

From `frontend/src/data/digititanAbout.js` and the Courses page:

- Brand: “Village Netacad powered by Digititan”
- Stats: 12,000+ learners, 50+ partners, 9 provinces, founded 2017
- Services / pillars
- Phone `+27 128440176`
- Email `info@villagenetacad.co.za`
- Map: 1 Mark Shuttleworth Street, The Innovation Hub, Lynwood, Pretoria 0087
- Courses: Networking Essentials, ICT Fundamentals, Cybersecurity Basics, Career Readiness
- External forms for academy / ASC registration

Visual language on web: dark glass UI, burnt-orange (`burnt-500/600`) accents, logo `frontend/public/logo.jpeg`.

---

## What you can skip (not on the live website)

These APIs work but have **no screens** today. Implement only if you want the app to go *beyond* the web app:

- In-app PayFast / `POST /api/orders` (checkout is website-only)
- Reseller withdrawals + admin withdrawal queue
- In-app notifications
- Email verify + reset-password pages (API exists; web never shipped the UI)
- Recurring donations (DB columns exist; form always sends `is_recurring: false`)

---

## Environment

| Variable (app) | Meaning |
|----------------|---------|
| `API_URL` | e.g. `https://villagenetacad.co.za/api` |
| `ORIGIN` | same host without `/api`, for images, referral links, and checkout |
| `CHECKOUT_URL` | `{ORIGIN}/login?next=/cart` |

---

## Testing against a local API

Same as the README:

1. MySQL + `php backend-php/database/migrate.php`
2. `npm run dev:backend` → `http://localhost:5000`
3. Point the simulator at that URL (Android emulator uses `10.0.2.2` instead of `localhost`)
4. Default admin: `admin@villagenetacad.com` / `Admin123!`

PayFast ITN cannot reach localhost unless you tunnel (`PAYFAST_NOTIFY_URL`).

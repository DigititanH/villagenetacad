# Mobile app guide (clone the existing website)

Use this when building a **native or cross-platform app** that should feel like the Village NetAcad website.

**Do not rebuild the backend, and do not migrate data onto the phone.** Point the app at the same PHP API. The website is a thin client; almost all rules and **all shop data** live on the server. Same login → same cart, orders, and reseller wallet.

Details: [DATA-SHARING.md](./DATA-SHARING.md) · [HOW-THE-APP-WORKS.md](./HOW-THE-APP-WORKS.md) · [API.md](./API.md)

---

## Recommended stack

Anything that can:

- Call HTTPS JSON APIs
- Store a JWT securely (Keychain / Keystore / `expo-secure-store`, not plain AsyncStorage in production)
- Open an external browser or WebView for PayFast (hosted payment page)
- Deep-link back to `payment/success` and `payment/cancel`

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
- [ ] Cart: qty +/-, size select, remove, referral code field, checkout CTA
- [ ] Checkout: street, city, province, zip, phone, referral (required unless admin), PayFast
- [ ] Payment success / cancel (deep links)
- [ ] My orders (status colours: pending / processing / shipped / delivered / cancelled)
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

1. Persist last referral code (web: `localStorage.reseller_referral_code`).
2. If the app is opened via `.../shop?ref=VNA-XXXX` (or a custom scheme), save it.
3. Show the field on Cart and Checkout.
4. Non-admins cannot submit an order without a code that the API accepts (`400 Invalid or inactive reseller referral code`).

Reseller share text: `Shop Village NetAcad: {WEB_ORIGIN}/shop?ref={code}`

---

## PayFast on mobile (critical)

The website does **not** use a card-number SDK. It:

1. Gets `{ url, fields }` from the API
2. Builds a hidden HTML form
3. `POST`s to PayFast’s hosted page
4. User pays on PayFast
5. PayFast redirects the **browser** to `{CLIENT_URL}/payment/success?...`
6. PayFast separately hits `{API}/api/payfast/notify` (ITN) — this is what actually marks the order paid

On mobile you must recreate step 2–5:

**Option A — in-app WebView**

Load a tiny HTML document that auto-submits the form (same as `frontend/src/lib/payfast.js`). Intercept navigation to your success/cancel URLs, then close the WebView and show native success.

**Option B — system browser (`ASWebAuthenticationSession` / Chrome Custom Tabs / `expo-web-browser`)**

Same form POST, then listen for the return URL via app links.

`CLIENT_URL` on the server must be a URL PayFast can redirect to **and** that the app can catch (universal links recommended). If `CLIENT_URL` stays the website, the user lands in a mobile browser on the **web** success page — that still works, but is not a native success screen.

ITN is independent of the app. After return, **poll** `GET /api/orders/{id}` every 3s for up to 30s until `payment_status === "paid"` (the website does this). Show “confirming payment…” meanwhile.

Donations: same pattern; create donation then POST `data.url` / `data.fields`.

Sandbox vs live is entirely server `.env` (`PAYFAST_SANDBOX`). The app does not embed merchant keys.

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

- Reseller withdrawals + admin withdrawal queue
- In-app notifications
- Email verify + reset-password pages (API exists; web never shipped the UI)
- Recurring donations (DB columns exist; form always sends `is_recurring: false`)

---

## Environment

| Variable (app) | Meaning |
|----------------|---------|
| `API_URL` | e.g. `https://villagenetacad.co.za/api` |
| `ORIGIN` | same host without `/api`, for images and referral links |
| `CLIENT_RETURN_URL` | must match what PHP puts on PayFast `return_url` (today driven by server `CLIENT_URL`) |

If PayFast return URLs must open the app, the **server** `CLIENT_URL` / PayFast payload may need a one-line change later (deep link). Until then, reuse the website return URLs.

---

## Testing against a local API

Same as the README:

1. MySQL + `php backend-php/database/migrate.php`
2. `npm run dev:backend` → `http://localhost:5000`
3. Point the simulator at that URL (Android emulator uses `10.0.2.2` instead of `localhost`)
4. Default admin: `admin@villagenetacad.com` / `Admin123!`

PayFast ITN cannot reach localhost unless you tunnel (`PAYFAST_NOTIFY_URL`).

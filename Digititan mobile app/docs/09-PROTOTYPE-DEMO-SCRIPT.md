# Digititan Mobile — Prototype Demo Script (Sprint 6)

Use this for stakeholder walkthroughs. Dummy data. No branding polish yet.

## Demo accounts
| Role | Email | Password |
|---|---|---|
| Customer | customer@demo.com | demo123 |
| Reseller | reseller@demo.com | demo123 |
| Admin | admin@demo.com | demo123 |

OTPs (prototype):
- Email verify OTP: `123456`
- Payment OTP: `654321`

---

## Walkthrough order (about 10–12 minutes)

### 1) Auth (1 min)
1. Open app → Login
2. Sign in as **customer@demo.com**
3. Point out: shared-login concept later with website; Google is stubbed for now

### 2) Customer Home + Training (2 min)
1. Home shows programmes + featured training
2. Open Training tab → open a course
3. Register interest → submit
4. Show flutter console line `INTEREST REGISTERED...`

### 3) Academies (2 min)
1. Academies tab
2. Filter province (e.g. Gauteng)
3. Open academy → Active/Recruiting chips
4. Register/apply
5. Top-right + → Register NPO/Academy organisation

### 4) Store + Orders + payment OTP (3 min)
1. Store → product → Add to cart
2. Cart → Checkout → Pay
3. Payment OTP `654321`
4. Order success + tracking timeline
5. My orders (Store icon or Profile)

Say out loud:
> “Live gateway comes later. Meeting required OTP confirmation for money movement.”

### 5) Reseller (2 min)
1. Logout → login **reseller@demo.com**
2. Dashboard: code, earnings, balance, due to Digititan
3. Copy referral code
4. Clients statuses (bought/pending/confirmed/didNotBuy)
5. Sales commissions
6. Monthly statement + withdrawal request

### 6) Admin (2 min)
1. Logout → login **admin@demo.com**
2. Dashboard stats
3. Orders → update status
4. Resellers → Approve (code issued)
5. Products → change price

Say out loud:
> “This is second-level admin: content/ops without developers.”

---

## Closing lines for leadership
- Website + mobile = one ecosystem (same identity direction)
- Pillars shown: Training · Academies · Store
- Sustainability model shown via Reseller
- Donations out of scope (as decided)
- Branding/colours intentionally deferred
- Next after sign-off: production integrations (Firebase Google, real API, real payments)

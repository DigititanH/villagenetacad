# Phase 7 — Live OTP (email first, SMS later)

Branch: `cursor/phase7-otp-security-09ad`  
Base: Phase 6.

## Scope (this slice)

| In | Out / later |
|----|-------------|
| Live **email** OTP / verify mail via Gmail SMTP | SMS OTP (provider TBD) |
| Server `Mailer` uses real SMTP auth | Lawyer POPI / legal |
| Docs for Google setup | T&Cs-before-pay gate |
| | In-app PayFast (deferred — browser checkout) |

## Important: OAuth Client ID ≠ sending email

Google **“Create OAuth client ID”** is for **Sign in with Google** (login), **not** for sending OTP emails.

For **simple test email from a Gmail account**, use a **Gmail App Password** + SMTP in `.env`.

---

## Email setup (Gmail App Password) — do this

### A. Google account

1. Use the mailbox that should send mail (e.g. `info@…` or a Gmail used for testing).
2. Enable **2-Step Verification**:  
   Google Account → Security → 2-Step Verification.
3. Create an **App Password**:  
   Google Account → Security → App passwords → App: **Mail** → Device: **Other** (`VillageNetAcad`) → Create.  
   Copy the 16-character password (no spaces).

You do **not** need “OAuth client ID” / Application type for this path.

### B. Server `.env`  
Path: `/public_html/village-netacad/backend-php/.env`

```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your.gmail.or.workspace@email.com
SMTP_PASS=xxxx xxxx xxxx xxxx
SITE_EMAIL=info@villagenetacad.co.za
```

- `SMTP_PASS` = the **App Password**, not your normal Google password.  
- Don’t paste App Passwords into chat.

### C. Deploy Mailer

Upload updated `backend-php/lib/Mailer.php` from this branch (real SMTP AUTH).  
Old Mailer logged “would send” / used `mail()` without SMTP login — App Passwords would not work.

### D. Smoke test

1. Register a new user on the website (or trigger forgot-password).  
2. Check inbox (and spam) for the verify / reset mail.  
3. If nothing arrives, check cPanel → Errors / PHP error log for `[Mailer]`.

---

## If you still create an OAuth client (optional — Sign in with Google later)

Only if leadership wants **Google login** (not OTP mail):

| Field | Choose |
|-------|--------|
| Application type | **Web application** (website) and/or **Android** / **iOS** for the app |
| Name | `Village NetAcad Web` / `Village NetAcad Android` |
| Authorized redirect URIs | Your site callback (when Google Sign-In is wired) |

That is a **different** Phase 7+ feature from email OTP.

---

## SMS OTP — not configured yet

We need a provider with SA delivery. Common options:

| Provider | Notes |
|----------|--------|
| **Africa’s Talking** | Strong SA / Africa fit |
| **Twilio** | Global; paid |
| **Clickatell** | SA-friendly |

**Needed from ops:** account + API key + sender ID, then we wire `SmsSender` + OTP channel picker to live send.

Until then: email path only; SMS stays demo/`123456` in the app.

---

## Parked (Phase 7 later)

- Lawyer POPI / legal (replace drafts)  
- T&Cs before pay  
- In-app PayFast (v1 = website browser)  
- Website login `?next=` (needs frontend permission)

## Done when (email slice)

- SMTP configured on server  
- New registration / reset email actually arrives  
- App/docs no longer treat email OTP as console-only for live API

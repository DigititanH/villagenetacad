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
SMTP_PASS=xxxxxxxxxxxxxxxx
SITE_EMAIL=info@villagenetacad.co.za
SMTP_FROM=Village NetAcad
```

- `SMTP_PASS` = the **App Password**, not your normal Google password.  
- **No spaces** in `SMTP_PASS` (Google shows groups of 4; paste as 16 characters with no spaces).  
- `SMTP_FROM` = display name only (optional). The From **address** is always `SMTP_USER`.  
- Don’t paste App Passwords into chat.

### C. Deploy Mailer (required — old file ignores Gmail)

Production still had the old `Mailer.php` that calls PHP `mail()` and **never uses** `SMTP_HOST` / App Password.

Upload this branch’s `backend-php/lib/Mailer.php` to:

`/public_html/village-netacad/backend-php/lib/Mailer.php`

Overwrite the old file, then test again.

### D. Smoke test

1. Register a new user on the website (or trigger forgot-password).  
2. Check inbox (and spam) for the verify / reset mail.  
3. If nothing arrives, check cPanel → Errors / PHP error log for `[Mailer]`.

---

## If you still create an OAuth client (optional — Sign in with Google later)

**Removed from the app for now** — website has no Google Sign-In, so the app
no longer shows a Google button. Revisit only if the website adds Google login.

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

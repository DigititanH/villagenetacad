# Gmail App Password + SMTP setup (Digititan)

Do this on your machine. Do **not** paste real passwords into chat.

## What we are doing
We will let the backend/app send emails through Gmail SMTP using an **App Password** (not your normal Gmail password).

This supports Digititan events like:
- registration OTP
- password reset
- order confirmation
(see `02-EMAIL-EVENTS.md`)

---

## Step 1 — Prepare Gmail
1. Use a Gmail account for the project (example: `digititan.app@gmail.com` or your chosen mailbox).
2. Turn on **2-Step Verification** for that Google account.
3. Go to Google Account → Security → **App passwords**.
4. Create an app password (name it e.g. `Digititan Mobile SMTP`).
5. Copy the 16-character password and keep it private.

---

## Step 2 — Where `.env` will live
For this project we will keep secrets in:

For Flutter MVP we prefer secrets on a tiny backend / Cloud Function, not inside the APK.

Local learning template can live in:
`Digititan mobile app/mobile/.env` (for local tools only)

or better:
`Digititan mobile app/server/.env` (recommended as soon as real email is wired)

Why not hardcode in source?
- Encapsulation / security
- Different values per machine
- Prevent accidental GitHub leaks

---

## Step 3 — `.env` template (you fill values)

```env
# Gmail SMTP
SMTP_HOST=smtp.gmail.com
SMTP_PORT=465
SMTP_USER=YOUR_GMAIL_EMAIL
SMTP_PASSWORD=YOUR_GMAIL_APP_PASSWORD
SMTP_FROM=YOUR_GMAIL_EMAIL

# App
APP_NAME=Digititan Mobile
OTP_EXPIRY_MINUTES=10
```

### What each variable means
- `SMTP_HOST` → Gmail SMTP server address
- `SMTP_PORT` → usually `465` (SSL) or `587` (TLS)
- `SMTP_USER` → Gmail account used to authenticate
- `SMTP_PASSWORD` → App Password you generated
- `SMTP_FROM` → “From” address users see
- `OTP_EXPIRY_MINUTES` → how long an OTP remains valid

---

## Step 4 — Important architecture note
Mobile apps should **not** permanently hold SMTP passwords in production builds if avoidable.
Best production design:
- Mobile calls our backend API
- Backend sends email with SMTP secrets

For learning/prototype we will:
1. Start with `ConsoleEmailSender` (prints OTP in logs) so you understand the flow
2. Then wire real Gmail SMTP from a small server endpoint
3. Keep App Password out of the Flutter app binary

We do this deliberately in Sprint 1 and explain each swap via DI.

---

## Step 5 — Google Sign-In (separate from SMTP)
SMTP sends emails.  
Google Sign-In authenticates users.

You will later create OAuth client IDs in Google Cloud Console:
- Android client
- iOS client
- Expo/Web client (as needed)

We will do that when we reach Auth implementation, step by step.

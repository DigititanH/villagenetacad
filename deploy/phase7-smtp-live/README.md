# Phase 7 — SMTP email (live pack)

**Live tree only:** `public_html/backend-php/`  
(not `village-netacad/backend-php/`)

## What this fixes
Current live `Mailer.php` only calls PHP `mail()` (or does nothing if SMTP_* empty).  
Afrihost often blocks outbound Gmail SMTP. This pack uses **real SMTP AUTH**.

Prefer a **cPanel mailbox** (`info@` / `noreply@villagenetacad.co.za`), not Gmail.

## Note on “OTP”
Live website/app auth uses an **email verification link**, not a 6-digit app OTP.  
Getting SMTP working means register / forgot-password / contact / reseller-notify emails actually arrive.

## 1) Download

```powershell
cd $env:USERPROFILE\Downloads
Invoke-WebRequest -Uri "https://cdn.jsdelivr.net/gh/DigititanH/villagenetacad@cursor/phase7-smtp-cpanel-09ad/deploy/phase7-smtp-live/Mailer.php" -OutFile "Mailer.php"
Invoke-WebRequest -Uri "https://cdn.jsdelivr.net/gh/DigititanH/villagenetacad@cursor/phase7-smtp-cpanel-09ad/deploy/phase7-smtp-live/smtp-ping.php" -OutFile "smtp-ping.php"
dir Mailer.php, smtp-ping.php
```

## 2) cPanel mailbox (if you don’t have one)
1. cPanel → **Email Accounts** → Create `noreply@villagenetacad.co.za` (or use `info@…`)
2. Set a strong password — you’ll put it in `.env`

## 3) Edit live `.env`
File Manager → **`public_html/backend-php/.env`**

Set (example — adjust password):

```env
SITE_EMAIL=info@villagenetacad.co.za
SMTP_HOST=localhost
SMTP_PORT=587
SMTP_USER=noreply@villagenetacad.co.za
SMTP_PASS=YOUR_MAILBOX_PASSWORD
SMTP_FROM=Village NetAcad
SMTP_TEST_KEY=pick-a-long-random-secret
```

If `localhost:587` fails, try:

```env
SMTP_HOST=mail.villagenetacad.co.za
SMTP_PORT=465
```

**Avoid** `SMTP_HOST=smtp.gmail.com` on Afrihost unless you already proved it works.

## 4) Upload files
| Local file | Upload to |
|------------|-----------|
| `Mailer.php` | `public_html/backend-php/lib/Mailer.php` (overwrite) |
| `smtp-ping.php` | `public_html/backend-php/public/smtp-ping.php` (new, temporary) |

## 5) Ping test
Browser:

```text
https://villagenetacad.co.za/smtp-ping.php?key=YOUR_SMTP_TEST_KEY&to=YOUR_INBOX@example.com
```

- `{"ok":true,...}` → check inbox/spam  
- `ok:false` → read `error` / try other host/port  

## 6) Cleanup
**Delete** `public_html/backend-php/public/smtp-ping.php`  
Remove `SMTP_TEST_KEY` from `.env` (optional).

## 7) Real flow UAT
Register a throwaway customer on the website or app → expect **Verify your Village NetAcad account** email with link.

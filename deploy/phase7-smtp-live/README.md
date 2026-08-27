# Phase 7 — SMTP email (live pack)

**Live tree only:** `public_html/backend-php/`  
**Do NOT edit:** `public_html/village-netacad/backend-php/`

## Replace this live Mailer

Live currently uses PHP `mail()` (stub). Overwrite with `Mailer.php` from this folder (real SMTP AUTH).

## .env (same folder as live API)

```env
SITE_EMAIL=info@villagenetacad.co.za
SMTP_HOST=localhost
SMTP_PORT=587
SMTP_USER=info@villagenetacad.co.za
SMTP_PASS=YOUR_MAILBOX_PASSWORD
```

- `SMTP_USER` = full address `info@villagenetacad.co.za`
- Change host **off** `smtp.gmail.com`
- If `localhost` fails, try `mail.villagenetacad.co.za`

## Upload

1. Edit `public_html/backend-php/.env` (SMTP_* as above)
2. Overwrite `public_html/backend-php/lib/Mailer.php` with this pack's `Mailer.php`
3. Optional test: upload `smtp-ping.php` → open with `?key=YOUR_KEY&to=you@email.com` → **DELETE** ping file after

## Download

```powershell
cd $env:USERPROFILE\Downloads
$base = "https://cdn.jsdelivr.net/gh/DigititanH/villagenetacad@cursor/phase7-smtp-cpanel-09ad/deploy/phase7-smtp-live"
Invoke-WebRequest -Uri "$base/Mailer.php" -OutFile "Mailer.php"
Invoke-WebRequest -Uri "$base/smtp-ping.php" -OutFile "smtp-ping.php"
dir Mailer.php, smtp-ping.php
```

Branch: `cursor/phase7-smtp-cpanel-09ad` (PR #18)

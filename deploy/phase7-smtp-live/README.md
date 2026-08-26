# Phase 7 — SMTP email (live pack) — **PARKED**

Resume **with the team** — do not solo-deploy unless leadership asks.

**Live tree:** `public_html/backend-php/` only.

When ready:

1. cPanel mailbox + `.env` SMTP_* (`localhost` / `mail.villagenetacad.co.za`, not Gmail-first)
2. Overwrite `lib/Mailer.php` with `Mailer.php` from this folder
3. Optional: upload `smtp-ping.php` → test with `?key=&to=` → **DELETE** ping file

Branch: `cursor/phase7-smtp-cpanel-09ad` (PR #18)

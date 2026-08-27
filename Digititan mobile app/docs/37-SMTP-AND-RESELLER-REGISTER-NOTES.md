# Phase 7 SMTP + reseller register UX notes

## Email not arriving after register

1. Confirm `.env` in **`public_html/backend-php/.env`** (not village-netacad duplicate):
```env
SMTP_HOST=localhost
SMTP_PORT=587
SMTP_USER=info@villagenetacad.co.za
SMTP_PASS=YOUR_MAILBOX_PASSWORD
```
2. If no mail with `localhost`, change to:
```env
SMTP_HOST=mail.villagenetacad.co.za
```
3. Confirm `lib/Mailer.php` is the **real SMTP** version (not the short `mail()` stub).
4. Check spam. Register again with a fresh email after host change.

## Reseller / centre confusion (app)

- Live codes today are provisional `VNA-{hex}` (e.g. `VNA-C1A2B3D4`).
- App bug: hex starting with `C` was wrongly shown as **Centre 26%**. Fixed: only `VNA-C-*` / `VNA-B-*` count.
- Typing an academy name does **not** make you a centre — Ops issues VNA-B / VNA-C later.
- Academy field is now **optional** (blank = independent).

### Live backend upload (optional academy)

Overwrite:
`public_html/backend-php/controllers/AuthController.php`

(from this branch / PR)

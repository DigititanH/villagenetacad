# SMTP ownership — mobile app vs website

## Locked (28 Aug 2026)

| Who | Mailbox | Where it lives |
|-----|---------|----------------|
| **Mobile app (us)** | **`app@villagenetacad.co.za`** | Afrihost cPanel → used by **`public_html/backend-php/.env`** `SMTP_*` |
| **Website team** | Their own account(s) | Their tree / their `.env` — **not our job** |

- The Flutter app does **not** send mail itself. It calls the live API; the API `Mailer` sends as `app@`.
- `SITE_EMAIL=info@villagenetacad.co.za` = ops **inbox** (who receives “new reseller” alerts). Keep or change separately from SMTP send-from.
- Do **not** put website SMTP (Gmail / their mailbox) into our `SMTP_USER` / `SMTP_PASS`.
- Website team must **not** overwrite our `SMTP_*` in `public_html/backend-php/.env` if they share that folder. If they need different mail, they configure **their** backend copy / stack.

## Our live SMTP (app only)

```env
SITE_EMAIL=info@villagenetacad.co.za
SMTP_HOST=villagenetacad.co.za
SMTP_PORT=465
SMTP_USER=app@villagenetacad.co.za
SMTP_PASS=<app mailbox password>
SMTP_FROM=Village NetAcad
```

Ping UAT passed with this mailbox. Register welcome mail uses the same path.

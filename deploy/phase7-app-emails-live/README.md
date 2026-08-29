# Phase 7 — App transactional emails (app@)

Upload into `public_html/backend-php/`:

| File | Live path |
|------|-----------|
| `AppEmails.php` | `lib/AppEmails.php` **(new)** |
| `AuthController.php` | `controllers/AuthController.php` |
| `OrderFulfillment.php` | `lib/OrderFulfillment.php` |
| `OrdersController.php` | `controllers/OrdersController.php` |
| `ResellersController.php` | `controllers/ResellersController.php` |
| `AdminController.php` | `controllers/AdminController.php` |

Requires dual SMTP (`APP_SMTP_*`) + `Mailer.php` / `Request.php` already live.

## Events (email + in-app where noted)
- Reseller apply (mobile) → pending welcome (“We are reviewing…”)
- Reseller approved (Ops) → code + how reselling works (+ in-app)
- Order paid → customer confirmation; seller/centre sale notice; ops notify
- Order status change → customer email + in-app

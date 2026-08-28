# Phase 7 — Welcome email (no verify link)

**Live path:** `public_html/backend-php/controllers/AuthController.php`

## Change
On register, send a **detailed welcome** from `app@` instead of a verify-email confirm link.  
New accounts are marked `is_verified = 1` immediately (login never required the link anyway).

## Upload
Overwrite live `controllers/AuthController.php` with this folder’s file (or paste from chat).

## UAT
1. Register a **new** customer in the app (live API).
2. Inbox: subject **Welcome to Village NetAcad** — no confirm button/link required.
3. App dialog: welcome mail mentioned, not verify link.
4. Sign in works without opening any email link.

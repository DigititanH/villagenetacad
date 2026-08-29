# Phase 7 — Welcome email (mobile-only)

**Live path:** `public_html/backend-php/controllers/AuthController.php`

## Shared backend / `.env`
Website and mobile share `public_html/backend-php/` and the same `.env`.  
`SMTP_*` + `app@villagenetacad.co.za` are for the **mobile app**.  
Website team must wire **their own** outbound mail (do not rely on this welcome send).

## Behaviour
| Register from | Welcome mail from `app@` |
|---------------|--------------------------|
| Mobile app (`client=mobile` + `X-VNA-Client: mobile`) | **Yes** — detailed welcome, no verify link |
| Website | **No** |

New accounts still `is_verified = 1` immediately (either client).

## Upload
Overwrite live `controllers/AuthController.php` with this folder’s file (or paste from chat).  
App branch must include `client: 'mobile'` on register + `X-VNA-Client` header.

## UAT
1. Register on **website** with a new email → **no** welcome from `app@`.
2. Register on **app** (live API) with another new email → inbox **Welcome to Village NetAcad**.

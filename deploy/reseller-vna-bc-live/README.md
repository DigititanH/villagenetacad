# Reseller VNA-B / VNA-C register (live)

**Upload only to:** `public_html/backend-php/controllers/AuthController.php`

## Behaviour
- `reseller_kind=independent` (or blank academy) → `VNA-B-*`, 53%
- `reseller_kind=affiliated` + academy → `VNA-B-*`, 53% (centre name stored for 26%/21%)
- `reseller_kind=centre` + academy name → `VNA-C-*`, 26%

SMTP verify mail is best-effort (parked if host mail fails).

## App
Sync branch `cursor/reseller-register-ux-09ad` mobile lib.

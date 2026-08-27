# SMTP parked + reseller VNA-B / VNA-C register

## SMTP
Live email send is **parked** again (host SMTP not delivering). Register still works; verify-mail is best-effort only.

## Reseller register (meeting model)
| Choice | Code | Your cut | Notes |
|--------|------|----------|-------|
| Independent (no centre) | `VNA-B-*` | **53%** | Rest Digititan |
| Affiliated with a centre | `VNA-B-*` | **53%** | Centre **26%** · Digititan **21%** (name stored) |
| I am a centre | `VNA-C-*` | **26%** | Rest Digititan |

### Live upload
1. App: sync this branch `mobile/lib`
2. Backend: overwrite `public_html/backend-php/controllers/AuthController.php` from `deploy/reseller-vna-bc-live/`

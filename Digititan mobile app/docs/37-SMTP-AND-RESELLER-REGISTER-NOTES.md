# SMTP parked + reseller VNA-B / VNA-C register

## SMTP
Live email send is **parked** (host SMTP not delivering). Register still works; verify-mail is best-effort only.

## Reseller register (meeting model)
| Choice | Code | Your cut | Notes |
|--------|------|----------|-------|
| Independent (no centre) | `VNA-B-*` | **53%** | Rest Digititan |
| Affiliated with a centre | `VNA-B-*` | **53%** | Centre **26%** · Digititan **21%** (name stored) |
| I am a centre | `VNA-C-*` | **26%** | Rest Digititan |

## Mobile UAT (27 Aug 2026): **PASSED**
1. Register UI — 3 paths — PASS  
2. Independent → `VNA-B-` · 53% — PASS  
3. Affiliated → `VNA-B-` · 53% + centre name — PASS  
4. Centre → `VNA-C-` · 26% — PASS  
5. Pending block / approve login — PASS  

### Live upload (done for UAT)
1. App: `INSTALL-RESELLER-VNA.ps1` / branch `cursor/reseller-register-ux-09ad`
2. Backend: `public_html/backend-php/controllers/AuthController.php` (VNA-B/C register)

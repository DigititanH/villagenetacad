# SMTP + reseller VNA-B / VNA-C register

## SMTP — **LIVE** (28 Aug 2026)

Mailbox: **`app@villagenetacad.co.za`** (cPanel)  
Host: `villagenetacad.co.za` · Port **465** · From name: Village NetAcad  
Ops inbox: `info@villagenetacad.co.za` (`SITE_EMAIL`)

Ping UAT passed. Keep one SMTP block in `.env` (remove duplicates).  
Do **not** leave `smtp-ping.php` on production.

See `docs/33-PHASE7-OTP-EMAIL-SMS.md` for app register → verify UAT.

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

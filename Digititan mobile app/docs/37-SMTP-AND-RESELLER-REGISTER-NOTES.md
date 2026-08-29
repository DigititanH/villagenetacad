# SMTP — mobile vs website (same `.env`)

**Do not** create a separate `.envMail`. Shared `backend-php/.env` holds both profiles.

| | Mobile (you) | Website team |
|-|--------------|--------------|
| Keys | `APP_SMTP_*` | `SMTP_*` |
| Mailbox | `app@villagenetacad.co.za` | Their choice |
| Trigger | Flutter `X-VNA-Client: mobile` | Browser / website |

See `deploy/phase7-dual-smtp-live/README.md`.

## Reseller register (meeting model)
| Choice | Code | Your cut | Notes |
|--------|------|----------|-------|
| Independent (no centre) | `VNA-B-*` | **53%** | Rest Digititan |
| Affiliated with a centre | `VNA-B-*` | **53%** | Centre **26%** · Digititan **21%** |
| I am a centre | `VNA-C-*` | **26%** | Rest Digititan |

## Mobile UAT (27 Aug 2026): **PASSED** — VNA-B/C register paths

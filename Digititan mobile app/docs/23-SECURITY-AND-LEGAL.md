# Security, legal & POPI (meeting feedback)

Draft for launch. Not final legal advice — Digititan must have counsel review before go-live.

## Security baseline (item 3)

| Layer | Requirement |
|-------|-------------|
| Transport | HTTPS / TLS 1.2+ for app ↔ API and PayFast |
| Passwords | bcrypt/argon2 hashes; never store plaintext |
| Sessions | Short-lived access tokens + refresh; revoke on logout |
| OTP | Email **and** SMS; rate-limit; expire codes; one-time use |
| Payments | PayFast hosted checkout; verify ITN/notify signatures server-side |
| Data at rest | Encrypt DB backups and sensitive fields (IDs, bank details) |
| Authz | Role checks on every admin/reseller route (Ops vs Super) |
| Audit | Log login, withdraw requests, approvals, order attribution |
| Reseller trust | Public verify endpoint exposes **only** non-sensitive profile fields |

## Authentication additions (beyond password)

1. Email OTP on register / sensitive actions  
2. SMS OTP option (same flow)  
3. Payment confirmation OTP after gateway return (or PayFast ITN alone in production)  
4. Google sign-in (optional later)  
5. Admin: stronger password policy + optional 2FA before launch  

## Legal pages in the app (item 8)

In-app drafts under **Profile → Legal & privacy**:

1. Terms and conditions  
2. Privacy / user data (POPI Act alignment)  
3. Security notice  
4. Returns policy (7 days after delivery — locked decision)  
5. POPI Act summary for SA users  

## POPI (Protection of Personal Information Act)

We collect: name, email, phone, gender (learners), organisation details, payment metadata.

Principles we must honour:

- **Purpose**: programme, shop, LMS alignment, reseller payouts  
- **Consent**: clear opt-in on register / interest forms  
- **Minimality**: only fields needed for LMS + fulfilment  
- **Access**: user can request correction via support  
- **Security**: appropriate technical measures (above)  
- **Operators**: Digititan as responsible party; PayFast / SMS vendors as operators under agreement  

## App icon (item 10)

Use the **Village NetAcad programme** mark (`VillageNetAcadTransparentBackground.png` / brand pack) as Android/iOS launcher icon — not a generic Digititan-only glyph. Generate mipmaps/AppIcon from that asset on the laptop Flutter project.

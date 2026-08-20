# Reseller codes + dual admin (Ops / Super) — prototype functional flows

Updated: 20 Aug 2026

## Reseller codes (now working end-to-end in demo memory)

| Type | Prefix | Who |
|---|---|---|
| Centre | `VNA-C-*` | Academies / centres |
| Beneficiary | `VNA-B-*` | Independent / beneficiary resellers |

**Seeded demo code:** `VNA-B-LERATO` (Reseller login `reseller@demo.com`)

### Flow to demo
1. Login **Customer** → Store → add to prototype cart → Checkout  
2. Enter code `VNA-B-LERATO` → Apply → Pay → OTP `654321`  
3. Logout → **Reseller** → Sales shows new commission with that code  
4. **Ops Admin** → Orders shows the order with referral code  
5. **Ops Admin** → Resellers → Approve + choose Centre or Beneficiary code  
6. **Codes** tab lists all issued codes  

## Dual admin

| Account | Password | Role |
|---|---|---|
| `ops@demo.com` | `demo123` | Ops Admin — orders, products, reseller approve/reject, codes |
| `admin@demo.com` | `demo123` | Same as Ops (legacy alias) |
| `super@demo.com` | `demo123` | Super Admin — everything Ops has + **Payouts** + **Activity** |

Ops Admin can add/update products and process day-to-day **without** Super Admin.

## Still backlog (after presentation)
- Real OTP emails  
- Google Sign-In  
- Real database (next when you unhold DB only)

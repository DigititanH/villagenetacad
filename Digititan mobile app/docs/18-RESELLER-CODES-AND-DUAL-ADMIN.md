# Reseller codes + dual admin (Ops / Super) — prototype functional flows

Updated: 20 Aug 2026

## Revenue split (locked)

| Slice | % |
|---|---|
| Reseller / Beneficiary | 53% |
| Centre | 26% |
| Digititan / Village NetAcad | 21% |

- `VNA-B-*` sellers earn the **53%** slice  
- `VNA-C-*` sellers earn the **26%** Centre slice  
- Every attributed sale also tracks Digititan **21%** as amount due  

## Exact reseller journey (meeting-aligned)

1. **Apply** — Register → choose *Reseller* → optional academy → Create / Apply  
2. **Pending** — Reseller shell shows “Application pending” (no real code yet)  
3. **Ops Admin approve + code** — Resellers tab → Approve → Centre (`VNA-C-*`) or Beneficiary (`VNA-B-*`)  
4. **Reseller Refresh** — Dashboard unlocks with copyable referral code  
5. **Clients** — Add client / lead → tap to update status (`pending` / `confirmed` / `bought` / `didNotBuy`)  
6. **Sale via code** — Customer checkout enters the reseller’s code → Pay → OTP `654321` → sale + commission appear under Sales  

### Seeded shortcut (already approved)
| Account | Password | Code |
|---|---|---|
| `reseller@demo.com` | `demo123` | `VNA-B-LERATO` |

Use this when you only need to demo attribution, not the apply/approve path.

## Reseller codes

| Type | Prefix | Who |
|---|---|---|
| Centre | `VNA-C-*` | Academies / centres |
| Beneficiary | `VNA-B-*` | Independent / beneficiary resellers |

## What reseller can do (not full admin CRUD)

| Action | Reseller |
|---|---|
| Apply to become reseller | Yes |
| Issue / edit codes | No — Ops Admin |
| Add clients + update pipeline status | Yes |
| See sales / statement / request withdrawal | Yes (after approved) |
| Products / prices / order status | No — Ops Admin |

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
- Bank auto-debit from reseller accounts  

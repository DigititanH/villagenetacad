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
- Every attributed sale also tracks Digititan **21%** internally  
- **Reseller UI:** only shows money due to them (their share)  
- **Withdrawals:** last day of the month only; reseller enters the amount; Super Admin approves  

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

| Type | Prefix | Who | Earns |
|---|---|---|---|
| Beneficiary | `VNA-B-*` | **Individual** reseller (e.g. Sipho) | **53%** |
| Centre | `VNA-C-*` | **Centre / academy organisation** as the seller | **26%** |

If an individual is linked to a centre, they still get **VNA-B-***; the linked centre receives the **26%** slice from that person's sales. Do **not** give the individual a C-code just because they have a centre.

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

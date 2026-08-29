# Reviews + returns (customer post-delivery)

Branch: `cursor/customer-reviews-returns-09ad`  
Locked: returns within **7 days** of delivery (`12-LOCKED-DECISIONS.md`).

## Behaviour

| Event | App | Email |
|-------|-----|-------|
| Leave review on delivered order | Stars + text → products on order | — |
| Request return (≤7 days) | Status `return_requested` + in-app | Customer + Ops (`SITE_EMAIL`) via `app@` |

Live pack: `deploy/phase-reviews-returns-live/`  
Windows sync: `INSTALL-REVIEWS-RETURNS.ps1`

## UAT checklist

| # | Step | Pass? |
|---|------|-------|
| R1 | Migration + PHP uploaded | |
| R2 | Delivered order shows Leave a review + Request return | |
| R3 | Submit review → success, flags reviewed | |
| R4 | Submit return → emails + return_requested | |
| R5 | After 7 days, return button hidden / API rejects | |

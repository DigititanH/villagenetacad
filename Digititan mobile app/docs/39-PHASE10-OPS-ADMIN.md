# Phase 10 — Ops Admin live + in-app notifications (no SMTP)

**Branch:** `cursor/phase10-ops-admin-09ad`  
**Base:** `cursor/phase9-wait-website-09ad`

## Scope (this slice)
- Wire **Ops Admin** app to existing live PHP APIs (no phpMyAdmin, no PayFast ITN, no SMTP)
- **In-app notifications** inbox only (DB rows — **not** Gmail)
- UI polish: empty states, retry, live vs demo copy

## Out of scope (parked / waiting)
- Email / SMS notifications (SMTP parked)
- Academy register admin queue (Khanyi)
- Phase 8 ledger/clients live deploy (parked)
- Ambassador live admin API (not on server yet)

## App changes
- `HttpAdminRepository` — dashboard, orders, products, resellers approve/reject/suspend, withdrawals
- `injection.dart` uses it when `API_BASE_URL` is set
- Live admin approve = unlock login (codes already at register)
- Payouts tab shown for live `admin` role (mapped to Ops in app)
- Ambassadors tab: clear “not on live API” empty state
- `NotificationsScreen` → `GET /api/notifications` (+ mark read)

## Live account note
Ops user must have website role **`admin`** (PHP `Auth::authorize('admin')`).  
Sign in on the app with that account + live API base URL.

## UAT (27 Aug 2026): **PASSED**
1. Login as live admin → Ops shell — PASS  
2. Dashboard loads — PASS  
3. Orders tab — PASS  
4. Order status update — PASS  
5. Resellers list — PASS  
6. Approve/reject pending — PASS  
7. Deactivate/reactivate — PASS  
8. Products — PASS  
9. Payouts empty (no pending) — PASS (expected)  
10. Ambassadors “not on live API” — PASS  
11. Notifications inbox opens — PASS  

### Follow-up from UAT
Live Profile no longer shows **Become a Reseller** (that path only errored — register as reseller at signup, same as website). Demo mode keeps the button for decks.

## Sync
```powershell
cd S:\WORK\VillageNetAcad
.\INSTALL-PHASE10.ps1
cd mobile
flutter pub get
flutter run --no-dds --dart-define=API_BASE_URL=https://villagenetacad.co.za
```

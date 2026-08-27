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

## Sync
```powershell
cd S:\WORK\VillageNetAcad
.\INSTALL-PHASE10.ps1
cd mobile
flutter pub get
flutter run --no-dds --dart-define=API_BASE_URL=https://villagenetacad.co.za
```

## UAT
1. Login as live admin  
2. Dashboard shows real counts  
3. Resellers: pending approve/reject; deactivate/reactivate  
4. Orders: change status  
5. Products: price / stock / add  
6. Payouts: pending withdrawals approve/reject  
7. Profile → Notifications: opens (may be empty — OK, no email)

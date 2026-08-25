# Phase 4 — Shared accounts (real ecosystem)

Branch: `cursor/phase4-shared-accounts-09ad`  
Base: Phase 3.

## Slice shipped (4.1–4.2)

| Item | Notes |
|------|--------|
| `API_BASE_URL` dart-define | Empty = dummy auth (decks). Set = live `/api` |
| `ApiClient` + Bearer JWT | `lib/infrastructure/api/` |
| `HttpAuthRepository` | login, register (+ academy), `/me`, logout |
| JWT in `flutter_secure_storage` | Restored on launch via `getCurrentUser` |
| Dummy still default | Safe for presentation without a server |

## Android / Windows build notes

| Issue | Fix |
|-------|-----|
| `Building with plugins requires symlink support` | Windows → Settings → Developer Mode (`start ms-settings:developers`), then rebuild |
| `flutter_secure_storage` / `android-37` | Phase 4 pins `flutter_secure_storage: ^9.2.4` (works with compileSdk **36**). Do **not** bump to SDK 37 unless Platform `android-37` exists under your SDK (the `android-37.0` install path often fails Gradle’s hash lookup) |
| Backend not running | Terminal A must actually start `backend-php` / your usual `npm run dev:backend` so something listens on port **5000** |

## Run against local backend

```powershell
# Terminal A — backend (must be running, not just a comment)
cd S:\WORK\VillageNetAcad
# e.g. npm run dev:backend   — confirm http://127.0.0.1:5000 responds

# Terminal B — app (Android emulator → host loopback)
cd S:\WORK\VillageNetAcad\mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000
```

Windows desktop / Chrome against local:

```powershell
flutter run -d windows --dart-define=API_BASE_URL=http://127.0.0.1:5000
```

Production (only when team agrees):

```powershell
flutter run --dart-define=API_BASE_URL=https://villagenetacad.co.za
```

## Done when (full Phase 4)

Website register → app login with the same details (and reverse).  
Still open: drop demo emails for UAT, staging DB, HTTPS-only policy sign-off.

## Laptop sync

```powershell
cd S:\WORK\VillageNetAcad
Remove-Item .\INSTALL-PHASE4.ps1 -ErrorAction SilentlyContinue
Remove-Item .\INSTALL-PHASE4B.ps1 -ErrorAction SilentlyContinue
# Use 4B (new filename) so Windows/CDN cannot reuse a cached broken script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/DigititanH/villagenetacad/cursor/phase4-shared-accounts-09ad/Digititan%20mobile%20app/INSTALL-PHASE4B.ps1?v=2" -OutFile .\INSTALL-PHASE4B.ps1 -Headers @{ "Cache-Control" = "no-cache" }
# Confirm no broken arrow bytes (should print 0)
([System.IO.File]::ReadAllBytes((Resolve-Path .\INSTALL-PHASE4B.ps1)) | Where-Object { $_ -gt 127 }).Count
powershell -ExecutionPolicy Bypass -File .\INSTALL-PHASE4B.ps1
```

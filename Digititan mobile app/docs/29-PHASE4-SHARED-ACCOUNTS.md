# Phase 4 — Shared accounts (real ecosystem)

Branch: `cursor/phase4-shared-accounts-09ad`  
Base: Phase 3.

## Slice shipped (4.1–4.3)

| Item | Notes |
|------|--------|
| `API_BASE_URL` dart-define | Empty = dummy auth (decks). Set = live `/api` |
| `ApiClient` + Bearer JWT | `lib/infrastructure/api/` |
| `HttpAuthRepository` | login, register (+ academy), `/me`, logout |
| JWT in `flutter_secure_storage` | Restored on launch via `getCurrentUser` |
| Dummy still default | Safe for presentation without a server |
| Live login screen | Hides demo emails + Google stub when `API_BASE_URL` is set |
| Live register | Success dialog: same account works on the website |

## Android / Windows build notes

| Issue | Fix |
|-------|-----|
| `Building with plugins requires symlink support` | Windows → Settings → Developer Mode (`start ms-settings:developers`), then rebuild |
| `flutter_secure_storage` / `android-37` | Phase 4 pins `flutter_secure_storage: ^9.2.4` (works with compileSdk **36**). Do **not** bump to SDK 37 unless Platform `android-37` exists under your SDK (the `android-37.0` install path often fails Gradle’s hash lookup) |
| `npm run dev:backend` → no package.json | **`S:\WORK\VillageNetAcad` is mobile-only.** There is no root `package.json` / PHP API there. Use production API **or** `START-LOCAL-API.ps1` below |
| Backend not running | Nothing on host `:5000` → login shows connection refused |

## Run against live website API (simplest for Phase 4 login UAT)

No local PHP/MySQL needed. App talks to the same accounts as the website.

```powershell
cd S:\WORK\VillageNetAcad\mobile
flutter run --no-dds --dart-define=API_BASE_URL=https://villagenetacad.co.za
```

Register on the website (or in-app), then sign in with the same email/password.

## Run against local API (optional)

`VillageNetAcad` does not contain `backend-php`. Pull it once and start PHP:

```powershell
# Terminal A — API (needs php on PATH + MySQL village_netacad)
cd S:\WORK\VillageNetAcad
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/DigititanH/villagenetacad/cursor/phase4-shared-accounts-09ad/Digititan%20mobile%20app/START-LOCAL-API.ps1?v=1" -OutFile .\START-LOCAL-API.ps1 -Headers @{ "Cache-Control" = "no-cache" }
powershell -ExecutionPolicy Bypass -File .\START-LOCAL-API.ps1

# Other window — prove it:
Invoke-WebRequest http://127.0.0.1:5000/health

# Terminal B — app (emulator → host)
cd S:\WORK\VillageNetAcad\mobile
flutter run --no-dds --dart-define=API_BASE_URL=http://10.0.2.2:5000
```

Windows desktop / Chrome against local:

```powershell
flutter run -d windows --dart-define=API_BASE_URL=http://127.0.0.1:5000
```


## Done when (full Phase 4)

| Check | Status |
|-------|--------|
| Website account → app login (existing) | **Verified** (production API) |
| Website register → app login (new account) | **Verified** (production API) |
| App register → website login | **Ready for UAT** (see below) |
| Drop demo emails on live login UI | **Done** (hidden when `API_BASE_URL` set) |
| Staging DB / HTTPS-only policy sign-off | Still open |

Run command used for UAT:

```powershell
flutter run --no-dds --dart-define=API_BASE_URL=https://villagenetacad.co.za
```

### UAT — app register → website login

1. App → **Create account** → new email + password (Customer).
2. Confirm the success dialog (same account as website).
3. You should land inside the app signed in.
4. On a browser open https://villagenetacad.co.za → Log in with **that same email/password**.
5. Pass = website accepts the account created in the app.

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

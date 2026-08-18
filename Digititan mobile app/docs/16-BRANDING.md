# Sprint 7 — Branding pass

Updated: 18 Aug 2026

## Brand source
Taken from `https://www.digititan.co.za/` theme tokens + official logo.

| Token | Value |
|---|---|
| Primary | `#13418A` (deep blue) |
| Primary dark | `#14325C` |
| Accent | `#2C9F58` (green) |
| Teal highlight | `#2CC4C9` |
| Background | `#F8F9FB` |
| Foreground | `#15213B` |
| Logo | `assets/branding/logo.png` |

## What changed
- App-wide Material 3 theme (AppBar, buttons, nav, inputs, cards)
- Login: Digititan logo + wordmark hero + soft brand gradient
- Demo banner: navy + teal (not amber)
- Google / OTP / DB still on hold

## Install on laptop
```powershell
cd "S:\WORK\Digititan mobile app"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/DigititanH/villagenetacad/cursor/fix-s-drive-url-launcher-09ad/Digititan%20mobile%20app/INSTALL-BRANDING.ps1" -OutFile ".\INSTALL-BRANDING.ps1"
powershell -ExecutionPolicy Bypass -File .\INSTALL-BRANDING.ps1
cd mobile
flutter run
```
Pick Android emulator (or Chrome). Full restart — hot reload is not enough for assets.

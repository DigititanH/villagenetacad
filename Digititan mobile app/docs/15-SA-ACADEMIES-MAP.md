# South Africa Academies Map

Updated: 18 Aug 2026

## What you asked for
A **real South African map** (not boxes):
1. See South Africa with the **9 provinces**
2. Tap a **province** → list of academies in that province
3. **Pins** on academy locations
4. Tap academy → events, programmes, location, apply

## What we ship now
- Geographic province outlines (real SA shape — Limpopo north, Western Cape south-west, etc.)
- Tap province regions to filter
- Red location pins
- Detail: address, programmes, events

No Google Maps plugin (keeps S: drive builds working). Later we can swap in live Google Maps / Mapbox with DB coordinates.

## Install / update on laptop
```powershell
cd "S:\WORK\Digititan mobile app"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/DigititanH/villagenetacad/cursor/fix-s-drive-url-launcher-09ad/Digititan%20mobile%20app/INSTALL-SA-ACADEMIES-MAP.ps1" -OutFile ".\INSTALL-SA-ACADEMIES-MAP.ps1"
powershell -ExecutionPolicy Bypass -File .\INSTALL-SA-ACADEMIES-MAP.ps1
cd mobile
flutter run -d windows
```
(Use the Android emulator when Pixel_6 starts cleanly again.)

## Demo
Academies tab → you should recognise South Africa → tap Gauteng → pins + list → open academy.

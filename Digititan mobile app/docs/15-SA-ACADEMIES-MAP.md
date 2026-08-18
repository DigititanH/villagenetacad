# South Africa Academies Map

Updated: 18 Aug 2026

## What leadership asked for
1. A **South African map**
2. Tap a **province** → see that province + **list of academies**
3. **Pins / location points** for academies
4. Tap an academy → **events**, **programmes**, **location**, status, apply

## What we had before
Province **ChoiceChips** as a temporary stand-in for the map.

## What we built (prototype)
- Interactive SA map (`SouthAfricaAcademiesMap`) — CustomPainter, **no Google Maps plugin** (S-drive safe)
- Tap province region → filters list + highlights province
- Red pins → tap opens academy
- List under the map mirrors the filter
- Academy detail shows address, coordinates, programmes, events

## Flow
Map (SA) → Province → Academies list/pins → Academy detail → Register/apply

## Later (production)
- Real Google Maps / Mapbox with live GPS coordinates from database
- Real events calendar from API
- Compare academies (if leadership confirms)

## Install on laptop
```powershell
cd "S:\WORK\Digititan mobile app"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/DigititanH/villagenetacad/cursor/fix-s-drive-url-launcher-09ad/Digititan%20mobile%20app/INSTALL-SA-ACADEMIES-MAP.ps1" -OutFile ".\INSTALL-SA-ACADEMIES-MAP.ps1"
powershell -ExecutionPolicy Bypass -File .\INSTALL-SA-ACADEMIES-MAP.ps1
cd mobile
flutter run -d emulator-5554
```

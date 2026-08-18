# Fix: url_launcher build fail on S: drive

## What happened
Your app is on `S:\...`
Pub packages live on `C:\Users\...\Pub\Cache\...`

Kotlin incremental cache breaks across different drive roots.
Error key line:
`this and base files have different roots: C:\... and S:\...`

Task that fails:
`:url_launcher_android:compileDebugKotlin`

## Store URL (confirmed)
`https://www.shop.digititan.co.za/`

Apply on laptop if needed:
```powershell
cd "S:\WORK\Digititan mobile app"
powershell -ExecutionPolicy Bypass -File .\INSTALL-STORE-URL.ps1
```

## Durable fix (recommended) — no url_launcher plugin

Use installer:

```powershell
cd "S:\WORK\Digititan mobile app"
powershell -ExecutionPolicy Bypass -File .\INSTALL-FIX-S-DRIVE-BUILD.ps1
```

What it does:
1. Removes `url_launcher` from the project
2. Store CTA copies the website URL and shows a dialog (Flutter clipboard only — no native plugin)
3. Sets `kotlin.incremental=false` in `android/gradle.properties` (helps other plugins too)
4. Runs `flutter clean` + `flutter pub get`

Then:

```powershell
cd "S:\WORK\Digititan mobile app\mobile"
flutter run -d emulator-5554
```

## Why this works
Clipboard uses `package:flutter/services.dart` only.
No Kotlin compile of a Pub Cache package on `C:` into a build on `S:`.

## Optional later (when on C: drive)
If you move the whole project to `C:\WORK\...`, you can re-add `url_launcher` and open the browser automatically again.

## Manual clean only (usually not enough alone)

```powershell
cd "S:\WORK\Digititan mobile app\mobile"
flutter clean
Remove-Item -Recurse -Force .\build -ErrorAction SilentlyContinue
flutter pub get
flutter run -d emulator-5554
```

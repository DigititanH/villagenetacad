# Flutter setup on Windows (your laptop)

Path we are using:
`S:\WORK\Digititan mobile app`

## Why Flutter
- One codebase for Android + iOS
- Later desktop/web possible
- Good fit for “production-like MVP”

You still need:
- Android Studio / SDK for Android emulator
- A Mac or CI (Codemagic) later for iOS store builds

---

## Step-by-step install

1. Install **Git** (if missing)
2. Install **Flutter SDK** from https://docs.flutter.dev/get-started/install/windows
3. Unzip to a stable path e.g. `C:\src\flutter`
4. Add `C:\src\flutter\bin` to PATH
5. Install **Android Studio**
6. In Android Studio: install Android SDK + create an emulator
7. Open new PowerShell:

```powershell
flutter doctor
```

Fix anything `flutter doctor` marks with X (accept Android licenses, etc.):

```powershell
flutter doctor --android-licenses
```

---

## Create the project (only once)

```powershell
cd "S:\WORK\Digititan mobile app"
flutter create --org za.co.digititan --project-name digititan_mobile mobile
cd mobile
flutter run
```

If `mobile/` already has random files, that’s fine — `flutter create mobile` will scaffold into it.

---

## Editor
Use Cursor or VS Code with:
- Flutter extension
- Dart extension

Open folder:
`S:\WORK\Digititan mobile app`

---

## What success looks like
- Emulator/device opens
- Default Flutter counter app runs
- Then we replace it with our architecture folders (explained, not dumped)

---

## Next checkpoint (tell me)
Reply with:
1. `flutter doctor` summary (pass/fail items)
2. Whether `flutter run` showed the default app

Then we start Sprint 0 coding slice 1: folder map + DI entrypoint explanation.

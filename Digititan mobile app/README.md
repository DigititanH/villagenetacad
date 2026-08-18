# Digititan Mobile App

Local project root: keep this on your laptop (`S:\WORK\Digititan mobile app`).  
Do **not** push to GitHub until you decide to.

## Stack decision (locked for prototype)

| Layer | Choice | Why |
|---|---|---|
| Mobile framework | **Flutter** | One codebase → Android + iOS (+ desktop later) |
| Language | Dart | Comes with Flutter |
| Architecture | Clean Architecture + DI | OOP, SOLID, testable, not vibe-coding |
| Backend (MVP) | Firebase Auth first for Google Sign-In; mail via backend/SMTP | Fast Google login; secrets not baked into the APK |
| Existing website | Stay integrated conceptually | Same user identity later via shared API |
| Design / branding | Later | Core flows first |

---

## How we work (important)

I will **not** dump the whole app in one go.

We follow SDLC + Agile sprints:
1. You read the context (why / what / how data flows)
2. We add **one slice**
3. You explain it back / ask questions
4. We move to the next slice

Docs live in `docs/`. Read them in order:

1. `docs/00-SDLC-AND-AGILE.md`
2. `docs/02-EMAIL-EVENTS.md` ← **when emails are sent**
3. `docs/03-ARCHITECTURE.md`
4. `docs/04-USER-STORIES.md`
5. `docs/01-SPRINT-BOARD.md`
6. `docs/05-GMAIL-AND-GOOGLE-SETUP.md`
7. `docs/06-FLUTTER-SETUP-WINDOWS.md`
8. `docs/07-FOLDER-MAP.md`

---

## Your first action on the laptop (Sprint 0)

Open PowerShell:

```powershell
cd "S:\WORK\Digititan mobile app"
flutter --version
```

If Flutter is missing, follow `docs/06-FLUTTER-SETUP-WINDOWS.md`.

Then create the app (only if `mobile/` is still empty of a Flutter project):

```powershell
cd "S:\WORK\Digititan mobile app"
flutter create --org za.co.digititan --project-name digititan_mobile mobile
```

Tell me when that succeeds — next we add the clean-architecture folders **together** and explain each one.

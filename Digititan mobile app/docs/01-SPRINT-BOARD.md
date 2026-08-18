# Sprint Board — Digititan Mobile App (Flutter)

## Current sprint: Sprint 0 — Analysis + Design foundation
**Dates:** 18 Aug 2026 – 20 Aug 2026  
**Goal:** Understand the system and prepare Flutter skeleton before feature screens.

---

### What we did
- Turned meeting minutes into requirements + phased rollout plan
- Agreed prototype-first; branding/colours later
- Clarified email events (when OTP/emails are sent)
- Locked stack direction to **Flutter** (Android + iOS one codebase)
- Documented SDLC, Agile, architecture, user stories
- Created Flutter project + ran on Android emulator
- Installed Auth slice (domain/application/infrastructure/presentation + DI)
- Login screen opens on emulator

### What we are currently doing
- Sprint 6: Prototype demo script + sign-off checklist
- Feature prototype is presentation-ready (plain UI)
- Awaiting stakeholder GO / GO WITH CHANGES / NO-GO

### Problems we are facing now
1. Cloud workspace ≠ laptop `S:\` path — files installed via `INSTALL-ON-LAPTOP.ps1`
2. Google Sign-In not real yet
3. Branding intentionally deferred

### Problems we might face
1. Firebase Google OAuth setup on Android
2. Gmail App Password / 2FA for real OTP mail
3. Scope creep into Store/Academies before Auth+shell is solid

### How we will solve them
1. Keep laptop as source of truth; ship install scripts when needed
2. Wire Firebase after role navigation works
3. Stick to sprint order: Auth → shells → Home/Training → Academies → Store → Reseller/Admin

---

## Sprint 0 done criteria
- [x] Architecture doc (Flutter)
- [x] Email event map
- [x] User stories
- [x] Folder map explained
- [x] Flutter project created on laptop (`flutter create`)
- [x] `flutter run` shows app on Android emulator
- [x] Clean architecture folders + Auth slice running (Login opens)
- [ ] Role-based navigation after login (next)
- [ ] You understand: UI → UseCase → Repository → DataSource

---

## Upcoming sprints (prototype)
| Sprint | Focus |
|---|---|
| Sprint 1 (now) | Auth UI done → role navigation shell + OTP verify path |
| Sprint 2 | Home + Training |
| Sprint 3 | Academies |
| Sprint 4 | Store + Orders + simulated payment OTP |
| Sprint 5 | Reseller + Admin core |
| Sprint 6 | Prototype demo + sign-off |

---

## Your next action (do this before more code)
On laptop PowerShell:

```powershell
cd "S:\WORK\Digititan mobile app"
flutter doctor
```

Then follow `docs/06-FLUTTER-SETUP-WINDOWS.md` and create the Flutter project.

# SDLC + Agile — How we will build

## Where we are in SDLC

| SDLC Phase | Status | What it means for us |
|---|---|---|
| 1. Requirements | Done (from meeting minutes) | We know Training / Academies / Store + roles |
| 2. Analysis | In progress (Sprint 0) | Convert requirements into architecture, stories, risks |
| 3. Design | In progress (Sprint 0) | Folder structure, layers, auth design, data flow |
| 4. Implementation | Next (Sprint 1+) | Code feature by feature |
| 5. Testing | Each sprint | Demo + verify flows with dummy data first |
| 6. Deployment | Later | Soft launch → Play Store / App Store |
| 7. Maintenance | After launch | Phase 10 improvements |

Design/colours/branding are **parked** until core functionality works.

---

## Agile rules for this project

- Work in **sprints** (1 week target).
- Each sprint has: Goal, User Stories, Done criteria.
- Every standup-style update answers:
  1. What we did
  2. What we are doing
  3. Problems now
  4. Problems we might face
  5. How we will solve them
- No giant unexplained code dumps. Every folder/module gets context.

---

## Sprint 0 (NOW) — Analysis + Design foundation

**Goal:** Understand the system before building screens.

**Done when:**
- Architecture documented
- User stories written for prototype
- Project folders exist with clear responsibility
- Auth designed with email + Google behind one interface (DI)
- App runs empty Flutter shell on your laptop

**Not in Sprint 0:**
- Full screens for Store/Academies/Reseller
- Branding/colours polish
- Live payment gateway

---

## Upcoming sprints (prototype)

| Sprint | Focus |
|---|---|
| Sprint 1 | Flutter Auth UI (email + Google) + role navigation shell + OTP |
| Sprint 2 | Home + Training journeys |
| Sprint 3 | Academies journeys |
| Sprint 4 | Store + Orders + tracking (simulated payment) |
| Sprint 5 | Reseller + Admin core |
| Sprint 6 | Prototype demo + sign-off |

---

## Definition of Done (prototype story)

A story is done when:
1. Flow works with dummy data
2. You can explain what the code does and why
3. It follows our layer rules (UI does not talk to storage directly)
4. No branding polish required yet

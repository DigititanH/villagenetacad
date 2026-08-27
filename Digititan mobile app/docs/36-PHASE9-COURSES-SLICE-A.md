# Phase 9 — Courses slice A (hardcoded + website pay)

**Branch:** `cursor/phase9-wait-website-09ad`  
**Status:** Slice A **unlocked** for app implementation. Academies API still waits on **Khanyi**.

## Can implement now
| # | Work | Behaviour |
|---|------|-----------|
| 1 | Hardcoded courses in app | Mirror live website catalogue (free NetAcad skills + CCNA pathway) |
| 2 | Free enrol CTA | Open Cisco `enrollUrl` in system browser |
| 3 | Paid CCNA CTA | Open `https://villagenetacad.co.za/courses/enrol` (PayFast on site) |
| 4 | Align Training tab | Use this catalogue instead of unrelated DemoHub fiction where needed |

## Still blocked
- Academies list/map from MySQL API (Khanyi)
- Learner LMS fields in DB
- Any in-app PayFast / course payment WebView

## Website reference URLs
- Courses: `https://villagenetacad.co.za/courses`
- Paid CCNA enrol: `https://villagenetacad.co.za/courses/enrol`
- Free enrol: Cisco `netacad.com` links from website course cards

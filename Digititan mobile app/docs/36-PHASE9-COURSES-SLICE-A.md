# Phase 9 — Courses slice A (hardcoded + website pay)

**Branch:** `cursor/phase9-wait-website-09ad`  
**Status:** Slice A **UAT PASSED** (27 Aug 2026). Academies API still waits on **Khanyi**.

## UAT (passed)
- Light theme (matches Home/Store)
- Website Unsplash photo cards
- Category filters
- Pagination 5/10/15 + Prev/Next (scroll to top)
- Free → Enroll on Cisco
- Paid CCNA → website `/courses/enrol`

## Implemented (Slice A)
- `WebsiteCoursesCatalogue` — 16 courses from live `/courses`
- Same Unsplash images as live site
- Courses tab: image cards + category chips + pagination
- Detail: hero image + sticky enrol CTA
- Home: featured horizontal photo row
- Free → Cisco · Paid CCNA → website PayFast
- No MySQL courses; no in-app PayFast

## Still blocked (Slice B)
- Academies list/map from MySQL API (**Khanyi**)
- Learner LMS fields in DB
- Any in-app PayFast / course payment WebView

## Website reference URLs
- Courses: `https://villagenetacad.co.za/courses`
- Paid CCNA enrol: `https://villagenetacad.co.za/courses/enrol`
- Free enrol: Cisco `netacad.com` links from website course cards

## What's next
1. **Phase 9 Slice B** — wait for Khanyi academies API (do not invent DB in app)
2. Or other parked items with the team (SMTP) when ready — PayFast ITN **UAT PASSED** 28 Aug 2026
3. Phase 8 later: VNA-B/C + 53/26/21 (team consult)
4. Phase 10: notifications + ops admin

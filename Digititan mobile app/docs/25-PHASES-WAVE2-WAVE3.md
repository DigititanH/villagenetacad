# Meeting feedback phases (24 Aug 2026)

Work in **order**. Do not jump to launch hardening before Wave 2 product trust/money is demoable.

| Phase | Focus | Status |
|-------|--------|--------|
| **Wave 1** | Demo-visible polish | Done (install on laptop) |
| **Wave 2** | Trust + money + LMS data | **Next** |
| **Wave 3** | Security + launch readiness | After Wave 2 |

---

## Wave 1 — Done (demo polish)

| # | Item | Notes |
|---|------|--------|
| 1 | Bigger login logo | Hero ~248px |
| 7 | Min withdraw R100 | Button disabled under R100 + clear error |
| 8 | Legal drafts | T&Cs, privacy, security, returns — POPI later |
| 6 | Academy/org register with Digititan | Not Cisco-only |
| 9 | App icon = Village NetAcad | Launcher icons |

**Demo:** Login logo → Legal → Academies register → Withdraw R100 gate → App icon.

---

## Wave 2 — Remaining phase A (trust + money + LMS)

Do these **in this order** — each builds on the last for a clean demo story.

### Phase 2A — Buyer trust (reseller legitimacy)
| Meeting # | Work | Outcome |
|-----------|------|---------|
| 4 | Reseller in DB + **QR code** | Reseller dashboard shows QR / verify payload |
| 4 | Buyer **Verify reseller** screen | Enter code or paste `vna://verify/{CODE}` → approved name, status, academy |
| 4 | PHP public API | `GET /api/resellers/verify/{code}` (no secrets) |

**Exit:** Customer can prove a reseller is legit before checkout.

### Phase 2B — OTP channels
| Meeting # | Work | Outcome |
|-----------|------|---------|
| 2 | Email **and SMS** OTP option | Channel picker on register OTP + payment OTP |
| 2 | Demo codes unchanged until provider live | Email/SMS demo: `123456`; payment: `654321` |

**Exit:** Stakeholder sees SMS as a real option (stub OK until Twilio/Africa’s Talking).

### Phase 2C — LMS learner alignment
| Meeting # | Work | Outcome |
|-----------|------|---------|
| 5 | Store learner **full name, gender, email** | Training + academy interest forms |
| 5 | Persist in DemoHub / DB shape | Ready for LMS export later |

**Exit:** Ops can see learner fields that LMS needs.

### Phase 2D — Pay in the app (same gateway as store)
| Meeting # | Work | Outcome |
|-----------|------|---------|
| 10 | Same gateway as Digititan Store | **PayFast** (not a second merchant) |
| 11 | Payment happens **in the app** | Checkout → PayFast step → confirm → order |
| — | Flip locked decision | Samples + **in-app** checkout (website still available) |

**Exit:** Customer pays in-app; referral code still attributes 53/26/21.

### Wave 2 demo script (end of phase)
1. Reseller shows QR  
2. Customer verifies reseller → Approved  
3. Register / pay with SMS OTP option  
4. Training interest with gender  
5. Checkout → Pay with PayFast (prototype) → order + reseller earnings  

### Wave 2 out of scope
- Live SMS provider keys  
- Live PayFast merchant go-live  
- Full POPI lawyer copy  
- Production encryption audit  

→ Those land in **Wave 3**.

---

## Wave 3 — Remaining phase B (security + launch)

Do after Wave 2 is signed off in a meeting.

### Phase 3A — Security hardening
| Meeting # | Work | Outcome |
|-----------|------|---------|
| 3 | Encryption in transit | HTTPS / TLS only for API + PayFast |
| 3 | Stronger authentication | Hashed passwords, OTP expiry + rate limit, role checks |
| 3 | More auth layers | Payment OTP / PayFast ITN verify; optional admin 2FA |
| 3 | Data protection | Sensitive fields + backup encryption plan |

### Phase 3B — Legal / POPI (later stage from meeting)
| Meeting # | Work | Outcome |
|-----------|------|---------|
| 8 | POPI Act full wording | Lawyer-reviewed privacy + operator agreements |
| 8 | Final T&Cs / returns | Replace Wave 1 drafts |

### Phase 3C — Launch readiness (“everything up”)
| Meeting # | Work | Outcome |
|-----------|------|---------|
| 12 | All minor elements polished | Copy, empty states, icons, errors |
| 12 | Smoke every role | Customer / Reseller / Ops / Super |
| 12 | Live wiring | PayFast notify URL, SMS provider, verify API on prod |
| 12 | Checklist green | See below |

### Wave 3 launch checklist
- [ ] PayFast live keys + notify URL reachable  
- [ ] SMS OTP provider live (or documented fallback)  
- [ ] HTTPS everywhere; passwords hashed; sessions revoke on logout  
- [ ] Legal pages lawyer-reviewed (incl. POPI)  
- [ ] Village NetAcad app icon on store builds  
- [ ] Learner fields sync/export path to LMS  
- [ ] Min withdraw R100 enforced **server-side**  
- [ ] Reseller QR / verify works on web + app  
- [ ] Academy org queue visible to Ops  
- [ ] Smoke: login → shop → PayFast → OTP → order → reseller balance → month-end withdraw ≥ R100  

---

## How we run the remaining work

1. **One wave at a time** — finish Wave 2 demos before Wave 3 security sprint.  
2. **One branch per wave** (or clear commits): e.g. `cursor/wave2-trust-payfast-09ad` then `cursor/wave3-security-launch-09ad`.  
3. **Laptop sync** — same INSTALL pattern as Wave 1 (`INSTALL-WAVE2.ps1` / `INSTALL-WAVE3.ps1` when ready).  
4. **PHP + Flutter together** for verify + PayFast + withdraw min (server is source of truth).  

## Suggested next action

Start **Wave 2A** (QR + verify reseller + PHP verify). That answers the meeting’s biggest trust question before money flows in-app.

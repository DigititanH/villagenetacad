# Sprint 6 — What is done / next

## Prototype status: FEATURE-COMPLETE for presentation
Built (core functionality, plain UI):
1. Auth (email/password + OTP stub + Google stub)
2. Role shells (Customer / Reseller / Admin)
3. Home + Training
4. Academies
5. Store + Orders + payment OTP simulation
6. Reseller ops
7. Admin ops
8. Demo polish: one-tap role sign-in, demo banners, Store link copy, Profile cheat sheet

Not done yet (by design):
- Final branding/colours/icons
- Real Google Sign-In (Firebase)
- Real Gmail SMTP emails
- Live payment gateway
- Real website API sync
- iOS TestFlight/App Store release

## Your actions now
1. Install demo polish: `INSTALL-DEMO-POLISH.ps1`
2. Run full demo using `docs/09-PROTOTYPE-DEMO-SCRIPT.md`
3. Capture feedback
4. Complete `docs/10-PROTOTYPE-SIGNOFF.md`
5. Only after GO: start production integrations

## Suggested production next slices (after sign-off)
A. Firebase Auth + real Google Sign-In  
B. Backend mail endpoint + Gmail App Password (OTP emails)  
C. Connect to existing Digititan/Village NetAcad API  
D. Real payment approach decision (store billing vs website checkout)  
E. Branding pass  
F. Soft launch

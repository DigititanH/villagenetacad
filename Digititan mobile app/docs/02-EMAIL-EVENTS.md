# When does the user receive an email?

## Direct answer
A user receives an email only after a **specific action/event** in the system.
Nothing emails them “just because the app exists.”

Think: **Event → System decides → Email service sends → Inbox**

---

## Email vs OTP (do not confuse)

| Type | When it happens | What it is |
|---|---|---|
| Email verification OTP | After **Register with email/password** | Proves they own the inbox |
| Password reset email | After **Forgot password** | Lets them reset safely |
| Payment / action OTP | After they try to **pay / confirm sensitive action** | Fraud reduction (meeting requirement) |
| Transactional email | After **order placed**, **status changed**, **reseller approved**, etc. | Information / confirmation |
| Google Sign-In | User taps Google | **Usually NO verification OTP** (Google already verified email) |

---

## Concrete Digititan examples

### 1) Register with email/password
What happened:
1. User opens Register
2. Enters name, email, password
3. Taps Create account

Then system:
4. Creates account as “unverified”
5. Generates OTP (e.g. 6 digits, expires in 10 minutes)
6. Sends email: “Your Digititan verification code is 482193”
7. User enters OTP in app
8. Account becomes verified → continue to Home

### 2) Sign in with Google
What happened:
1. User taps Sign in with Google
2. Google login succeeds

Then system:
3. Creates/finds user by Google email
4. **Does not send registration OTP**
5. Goes to Home by role

They may still get later emails (order confirmation, etc.).

### 3) Checkout / payment confirmation
What happened:
1. User is on checkout
2. Taps Pay

Then system (meeting security story):
3. Asks for confirmation OTP (email/SMS/gateway-owned — partner decision)
4. User confirms
5. Payment continues via payment gateway (not cash to people)

Prototype: simulate this on screen first; wire real email OTP after SMTP works.

### 4) Order placed
What happened:
1. Payment/simulation succeeds

Then system:
2. Saves order
3. Emails customer: order confirmation + reference

### 5) Admin approves reseller
What happened:
1. Admin taps Approve

Then system:
2. Activates reseller
3. Emails reseller: approved + how code works

---

## About the Gmail “victim / case registered” prompt
That prompt is for a **different app**.
Technically we still use Gmail SMTP the same way, but Digititan triggers are the events above — not “victim case registered.”

---

## Prototype minimum emails
1. Register → verification OTP
2. Forgot password → reset OTP/link
3. Order success → confirmation (or simulated)
4. Reseller approved → approval mail (or simulated)

Full event table: keep this file aligned with sprint board.

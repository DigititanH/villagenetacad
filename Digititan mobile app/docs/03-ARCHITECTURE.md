# System Architecture (Flutter Prototype)

## 1. Big picture

```
[ Flutter UI screens ]
        |
        | calls use-cases (never talks to SMTP/Google SDK directly)
        v
[ Application layer: UseCases ]
        |
        v
[ Domain layer: Entities + Interfaces ]
        |
        +--> [ Infrastructure: Firebase/Google Auth adapter ]
        +--> [ Infrastructure: Email sender (backend SMTP) ]
        +--> [ Infrastructure: Dummy repositories for prototype ]
```

Website + mobile = one ecosystem conceptually:
- same identity model (email)
- same roles
- later: shared real API with the website backend

Prototype strategy:
- Interfaces first
- Dummy implementations so screens work offline
- Swap in Google Auth + real email via DI without rewriting UI

---

## 2. Why layers? (anti vibe-coding)

Bad:
`RegisterScreen` directly opens Gmail SMTP and writes users into random storage.

Good:
1. Screen collects input
2. `RegisterWithEmail` use-case validates + orchestrates
3. `UserRepository` saves user
4. `EmailSender` sends OTP
5. UI only shows result / navigates

Benefits:
- testable
- replaceable
- each file has one job
- you can explain the flow

---

## 3. OOP 4 pillars here

### Encapsulation
Hide secrets and transport details inside infrastructure.
UI never sees Gmail App Password.

### Abstraction
Depend on `AuthRepository`, `EmailSender` contracts — not concrete Firebase/SMTP classes.

### Inheritance
Use sparingly.
Example: shared base for form validators, or role-specific profile extensions.
Prefer composition for repositories/services.

### Polymorphism
`EmailPasswordAuth` and `GoogleAuth` both satisfy an auth method contract.
Login screen calls “authenticate”, implementations differ.

---

## 4. SOLID

| Principle | Application |
|---|---|
| S | One use-case = one business action (`SendEmailOtp`, `PlaceOrder`) |
| O | Add Google sign-in by adding a provider, not rewriting all auth UI |
| L | Dummy and Firebase repositories must honour the same contract |
| I | Reseller module doesn’t depend on Admin-only interfaces |
| D | Use-cases depend on abstractions; DI wires implementations |

---

## 5. Dependency Injection
At app start (`injection.dart` / service locator or Riverpod/GetIt):
- bind `AuthRepository` → `DummyAuthRepository` (Sprint 0/1) or `FirebaseAuthRepository`
- bind `EmailSender` → `ConsoleEmailSender` first, then `HttpEmailSender` calling backend SMTP

Why:
- screens stay dumb
- switching dummy → real is one binding change

---

## 6. Data flows

### A) Email/password register + OTP
```
RegisterScreen
  -> RegisterWithEmailUseCase
     -> UserRepository.createUnverifiedUser
     -> OtpService.generate
     -> EmailSender.sendVerificationOtp
  -> Navigate to VerifyOtpScreen
VerifyOtpScreen
  -> VerifyEmailOtpUseCase
     -> OtpService.validate
     -> UserRepository.markVerified
  -> Home
```

### B) Google Sign-In
```
LoginScreen (Google button)
  -> SignInWithGoogleUseCase
     -> GoogleAuthGateway.signIn
     -> UserRepository.findOrCreateFromGoogle
  -> Home by role
(No registration OTP email)
```

### C) Order confirmation email
```
CheckoutScreen
  -> PlaceOrderUseCase
     -> OrderRepository.create
     -> EmailSender.sendOrderConfirmation
  -> OrderSuccessScreen
```

---

## 7. Backend choice for MVP

| Option | Pros | Cons |
|---|---|---|
| Firebase Auth | Fast Google Sign-In | Custom OTP email still needs Cloud Function/SMTP or link-based verify |
| Supabase | Email OTP friendly | Extra learning if team already on Firebase/Google |
| Existing PHP API | True ecosystem with website | Needs more setup before prototype demo |

**Sprint 0/1 decision:**
1. Flutter clean architecture + dummy auth/email (learn structure)
2. Add Google Sign-In next
3. Add real email via small backend/SMTP (secrets stay server-side)

Production note:
Do **not** ship Gmail App Passwords inside the mobile app binary.
Mobile calls backend → backend sends mail.

---

## 8. Folder shape (Flutter)

```
mobile/lib/
  main.dart                 <- app entry, DI bootstrap
  app/                      <- MaterialApp, routes
  domain/                   <- entities + abstract interfaces
  application/              <- use-cases
  infrastructure/           <- firebase/google/smtp/dummy adapters
  presentation/             <- screens, widgets, controllers/providers
  shared/                   <- constants, failures, result types
```

See `07-FOLDER-MAP.md` for what each folder is responsible for.

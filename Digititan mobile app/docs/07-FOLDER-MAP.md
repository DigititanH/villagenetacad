# Folder map — what / why / how connected

We create these under `mobile/lib/` after `flutter create`.

Rule: **UI never owns business rules or secrets.**

```
lib/
  main.dart
  app/
  domain/
  application/
  infrastructure/
  presentation/
  shared/
```

---

## `main.dart`
**What:** App entry point.  
**Why:** Flutter starts here.  
**Does:** init bindings (DI), then `runApp(...)`.  
**Does not:** contain login business logic.

---

## `app/`
**What:** Application wrapper — `MaterialApp`, routes/theme stubs.  
**Why:** Keep startup/navigation config in one place.  
**Connected to:** `presentation/` screens via routes.  
**Branding:** temporary default theme only (final branding later).

---

## `domain/`
**What:** Pure business concepts.
- entities: `User`, `Order`, `Academy`, `ResellerProfile`
- enums/roles
- abstract interfaces: `AuthRepository`, `EmailSender`, `OrderRepository`

**Why:** Centre of the system. No Flutter widgets. No Gmail code.  
**When used:** Always — every feature depends inward on domain.  
**OOP link:** Abstraction + encapsulation of business meaning.

---

## `application/`
**What:** Use-cases / application services.
Examples:
- `RegisterWithEmail`
- `VerifyEmailOtp`
- `SignInWithGoogle`
- `PlaceOrder`
- `ApproveReseller`

**Why:** One action = one class (Single Responsibility).  
**How connected:**
`presentation` → calls use-case → use-case calls `domain` interfaces → `infrastructure` implements them.

**Data flow ownership:** lives here.

---

## `infrastructure/`
**What:** Real-world adapters.
- `dummy/` fake data for prototype
- `auth/` Google/Firebase adapters
- `email/` backend HTTP mail client (not raw SMTP password in app for production)
- local storage adapters

**Why:** This is where messy external systems live, isolated.  
**Polymorphism:** `DummyAuthRepository` and `FirebaseAuthRepository` both implement `AuthRepository`.

---

## `presentation/`
**What:** Screens + widgets + state controllers/providers.
Folders by feature:
- `auth/`
- `home/`
- `training/`
- `academies/`
- `store/`
- `reseller/`
- `admin/`

**Why:** UI changes often; keep it replaceable.  
**Rule:** Screens call use-cases/providers, not SMTP/Firebase SDKs directly.

---

## `shared/`
**What:** Cross-cutting helpers — `Result`, failures, constants, validators.  
**Why:** Avoid copy-paste without creating a junk drawer for business logic.

---

## Dependency direction (remember this)

```
presentation -> application -> domain <- infrastructure
```

`infrastructure` depends on `domain` (implements interfaces).  
`presentation` must NOT depend on `infrastructure` concrete classes (wire via DI).

---

## Sprint 0 coding order (small slices)
1. Create folders + README stubs in each
2. Domain `User` + `AuthRepository` interface
3. Dummy auth repository
4. Register/Login use-cases
5. Very plain Auth screens (no branding polish)
6. Then Google + email adapters

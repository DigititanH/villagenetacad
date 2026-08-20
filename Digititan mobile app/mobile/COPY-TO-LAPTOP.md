# Sprint 0 → Sprint 1 slice: Auth foundation

Copy every file under this `lib/` tree into:

`S:\WORK\Digititan mobile app\mobile\lib\`

Keep your existing Flutter project files (`main.dart` will be replaced).

## Data flow you just installed

```
LoginScreen
  -> SignInWithEmail / SignInWithGoogle / RegisterWithEmail
      -> AuthRepository (interface)
          -> DummyAuthRepository (prototype)
      -> EmailSender (interface)
          -> ConsoleEmailSender (prints OTP to flutter run console)
```

## Demo accounts
- customer@demo.com / demo123
- reseller@demo.com / demo123
- admin@demo.com / demo123

## Register OTP
Prototype OTP is always `123456` and is printed in the `flutter run` console.

## After copy, run
```powershell
cd "S:\WORK\Digititan mobile app\mobile"
flutter run -d emulator-5554
```

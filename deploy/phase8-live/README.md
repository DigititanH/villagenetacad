# Phase 8 live upload pack

These two files are built from the **real** production tree
`public_html/backend-php/` (keeps CCNA + products admin routes) plus Phase 8 verify/withdraw gates.

## Download (jsDelivr)

```powershell
cd $env:USERPROFILE\Downloads
Invoke-WebRequest -Uri "https://cdn.jsdelivr.net/gh/DigititanH/villagenetacad@cursor/phase8-reseller-production-09ad/deploy/phase8-live/ResellersController.php" -OutFile "ResellersController.php"
Invoke-WebRequest -Uri "https://cdn.jsdelivr.net/gh/DigititanH/villagenetacad@cursor/phase8-reseller-production-09ad/deploy/phase8-live/Router.php" -OutFile "Router.php"
dir ResellersController.php, Router.php
```

## Upload (overwrite)

1. `public_html/backend-php/controllers/ResellersController.php`
2. `public_html/backend-php/routes/Router.php`

## Smoke test

`https://villagenetacad.co.za/api/resellers/verify/FAKE-CODE`

Expect: `{"message":"Code not found or inactive"}`

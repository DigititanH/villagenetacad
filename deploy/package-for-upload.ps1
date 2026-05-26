# Build and zip for Afrihost upload (PHP backend + React build)
# Run from project root:  .\deploy\package-for-upload.ps1

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$out = Join-Path $root "village-netacad-afrihost.zip"
$temp = Join-Path $env:TEMP "village-netacad-afrihost"

Write-Host "Building frontend..."
Push-Location (Join-Path $root "frontend")
npm run build
if ($LASTEXITCODE -ne 0) { Pop-Location; exit 1 }
Pop-Location

if (Test-Path $temp) { Remove-Item $temp -Recurse -Force }
New-Item -ItemType Directory -Path $temp | Out-Null

# backend-php (API)
$phpDest = Join-Path $temp "backend-php"
Copy-Item (Join-Path $root "backend-php") $phpDest -Recurse -Force
@("database.sqlite", "database.sqlite-wal", "database.sqlite-shm", ".env") | ForEach-Object {
    $p = Join-Path $phpDest $_
    if (Test-Path $p) { Remove-Item $p -Force }
}

# Copy React build into public/ (keep index.php)
$dist = Join-Path $root "frontend\dist"
$public = Join-Path $phpDest "public"
Get-ChildItem $dist -File | ForEach-Object {
    if ($_.Name -ne "index.php") {
        Copy-Item $_.FullName (Join-Path $public $_.Name) -Force
    }
}
if (Test-Path (Join-Path $dist "assets")) {
    Copy-Item (Join-Path $dist "assets") (Join-Path $public "assets") -Recurse -Force
}

Copy-Item (Join-Path $root "deploy") (Join-Path $temp "deploy") -Recurse -Force
Copy-Item (Join-Path $root "DEPLOYMENT.md") $temp -Force
Copy-Item (Join-Path $root "README-PHP.md") $temp -Force

if (Test-Path $out) { Remove-Item $out -Force }
Compress-Archive -Path "$temp\*" -DestinationPath $out
Remove-Item $temp -Recurse -Force

Write-Host ""
Write-Host "Created: $out"
Write-Host ""
Write-Host "On Afrihost cPanel:"
Write-Host "  1. Upload and extract zip"
Write-Host "  2. Document root -> backend-php/public"
Write-Host "  3. Copy deploy/env.production.template -> backend-php/.env and edit"
Write-Host "  4. Upload database.sqlite + WAL files to backend-php/ (writable)"
Write-Host "  5. Run migrate once via SSH: php backend-php/database/migrate.php"
Write-Host ""

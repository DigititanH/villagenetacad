# Run backend with Node 22 (required for better-sqlite3 prebuild on Windows)
$node22 = "$env:LOCALAPPDATA\Programs\cursor\resources\app\resources\helpers\node.exe"
if (-not (Test-Path $node22)) {
  $v = & node -v 2>$null
  if ($v -notmatch '^v22\.') {
    Write-Error "Node 22 LTS required (found $v). Install from https://nodejs.org/ or use nvm: nvm install 22"
    exit 1
  }
  $node22 = "node"
}
Set-Location $PSScriptRoot
& $node22 ./node_modules/nodemon/bin/nodemon.js src/server.js

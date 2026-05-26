#!/bin/bash
set -euo pipefail

cd /home/site/wwwroot

export NODE_ENV="${NODE_ENV:-production}"
export DATABASE_PATH="${DATABASE_PATH:-/home/site/data/database.sqlite}"
export UPLOADS_DIR="${UPLOADS_DIR:-/home/site/data/uploads}"

mkdir -p "$(dirname "$DATABASE_PATH")" "$UPLOADS_DIR"

echo "==> Village NetAcad — migrate database"
node backend/src/database/migrate.js

echo "==> Village NetAcad — starting API on port ${PORT:-8080}"
exec node backend/src/server.js

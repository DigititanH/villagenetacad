#!/bin/bash
# Run on your Linux VPS as the deploy user (Ubuntu 22.04+)
set -e

APP_DIR="${APP_DIR:-/var/www/village-netacad}"
DATA_DIR="/var/lib/village-netacad"

echo "==> Creating data directories"
sudo mkdir -p "$DATA_DIR/uploads"
sudo chown -R "$USER:$USER" "$DATA_DIR"

echo "==> Install Node 20 if missing"
if ! command -v node &>/dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi

echo "==> App directory: $APP_DIR"
mkdir -p "$APP_DIR"
cd "$APP_DIR"

echo "==> Install dependencies"
npm run install:all

echo "==> Production env"
if [ ! -f backend/.env ]; then
  cp deploy/env.production.template backend/.env
  echo "EDIT backend/.env (JWT, PayFast, SMTP) then run: npm run deploy"
  exit 0
fi

echo "==> Migrate, build, start with PM2"
npm run predeploy
sudo npm install -g pm2 2>/dev/null || true
pm2 start ecosystem.config.cjs
pm2 save

echo "==> Done. Configure nginx: deploy/nginx.villagenetacad.co.za.conf"
echo "    Health: https://villagenetacad.co.za/health"

# Host Village NetAcad on Afrihost

**Stack:** PHP API (`backend-php/`) + SQLite + React (`frontend/dist`).  
**Domain:** `villagenetacad.co.za`  
**No Node.js required** on the server.

---

## Choose your Afrihost product

| Product | Good for this site? |
|---------|---------------------|
| **Web Hosting / cPanel (PHP)** | Yes — easiest |
| **Cloud VPS Self Managed** | Yes — more control (nginx + PHP) |
| **Basic hosting without PHP 8.1+** | No — upgrade or use VPS |

You need: **PHP 8.1+**, extensions `pdo_sqlite`, `curl`, `mbstring`, `fileinfo`.

---

## Before you upload (on your PC)

```powershell
cd c:\Users\diteb\Downloads\shop-share-support-main\shop-share-support-main
.\deploy\package-for-upload.ps1
```

This builds the React app and creates **`village-netacad-afrihost.zip`** ready to upload.

---

## Part 1 — DNS (Client Zone)

1. Log in: [https://clientzone.afrihost.com](https://clientzone.afrihost.com)
2. **Domains** → `villagenetacad.co.za` → **DNS**
3. Point to your hosting IP:

| Type | Host | Value |
|------|------|--------|
| A | `@` | Your server IP |
| A | `www` | Your server IP |

Wait 15 min – 48 hours. Test: `ping villagenetacad.co.za`

---

## Part 2 — cPanel / shared PHP hosting (recommended)

### Upload

1. Upload `village-netacad-afrihost.zip` via **File Manager**
2. Extract into e.g. `village-netacad/`

### Document root

Set the domain’s **document root** to:

```
village-netacad/backend-php/public
```

(Not the project root — must be `public` so `.env` and `database.sqlite` stay private.)

### Environment

1. Copy `deploy/env.production.template` → `backend-php/.env`
2. Edit paths for your account (cPanel shows home path, e.g. `/home/username/`):

```env
NODE_ENV=production
DATABASE_PATH=/home/username/village-netacad-data/database.sqlite
UPLOADS_DIR=/home/username/village-netacad-data/uploads
CLIENT_URL=https://villagenetacad.co.za
API_URL=https://villagenetacad.co.za
PAYFAST_NOTIFY_URL=https://villagenetacad.co.za/api/payfast/notify
JWT_SECRET=<long random string>
PAYFAST_MERCHANT_ID=...
PAYFAST_MERCHANT_KEY=...
```

3. Create folder `village-netacad-data/` with **write** permission for PHP
4. Upload your `database.sqlite` (+ `-wal` / `-shm` if present) or run once via SSH:

```bash
php backend-php/database/migrate.php
```

### SSL

In cPanel: **SSL/TLS** → AutoSSL or Let’s Encrypt for `villagenetacad.co.za`

### Permissions

- `backend-php/` data folder: **755** or **775**
- `database.sqlite`: writable by PHP
- `uploads/`: writable by PHP

---

## Part 3 — VPS (Ubuntu + nginx + PHP)

```bash
sudo apt update && sudo apt install -y nginx php8.3-fpm php8.3-sqlite3 php8.3-curl php8.3-mbstring certbot python3-certbot-nginx unzip
```

Upload zip to `/var/www/`, extract, then:

```bash
cd /var/www/village-netacad
cp deploy/env.production.template backend-php/.env
nano backend-php/.env

sudo mkdir -p /var/lib/village-netacad/uploads
sudo chown -R www-data:www-data /var/lib/village-netacad backend-php/uploads

php backend-php/database/migrate.php

sudo cp deploy/nginx.villagenetacad.php.conf /etc/nginx/sites-available/villagenetacad.co.za
sudo ln -sf /etc/nginx/sites-available/villagenetacad.co.za /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
sudo certbot --nginx -d villagenetacad.co.za -d www.villagenetacad.co.za
```

---

## Part 4 — PayFast (required for payments)

In `backend-php/.env` on the server:

```env
PAYFAST_NOTIFY_URL=https://villagenetacad.co.za/api/payfast/notify
PAYFAST_SANDBOX=true
```

Use **HTTPS** only in production. Test a donation after go-live.

---

## Part 5 — Go-live checklist

- [ ] https://villagenetacad.co.za loads the homepage
- [ ] https://villagenetacad.co.za/health → `{"status":"ok"}`
- [ ] Login works — change admin password (`admin@villagenetacad.com`)
- [ ] Donation / shop checkout redirects to PayFast
- [ ] SMTP set for contact form emails

---

## Backups

Download weekly:

- `backend-php/database.sqlite`
- `backend-php/uploads/` (or your `UPLOADS_DIR`)

---

## Support

- Afrihost Client Zone: [clientzone.afrihost.com](https://clientzone.afrihost.com)
- WhatsApp: 071 883 5005

---

## Quick reference

| Item | Value |
|------|--------|
| Document root | `backend-php/public` |
| API | `https://villagenetacad.co.za/api/...` |
| PayFast ITN | `https://villagenetacad.co.za/api/payfast/notify` |
| Local package script | `.\deploy\package-for-upload.ps1` |

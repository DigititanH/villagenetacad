# Deploy Village NetAcad → villagenetacad.co.za

This guide matches **your** project: domain `villagenetacad.co.za`, email `info@villagenetacad.co.za`, PayFast merchant `14050025` (sandbox first), single Node server on port **5000**.

> **Hosting on Microsoft Azure?** Use **[deploy/azure/AZURE.md](deploy/azure/AZURE.md)** (App Service, GitHub Actions, custom domain).  
> **Hosting on Afrihost?** Use **[deploy/AFRIHOST.md](deploy/AFRIHOST.md)**  
> (Client Zone DNS, VPS SSH, nginx, SSL, and what to do if you only have shared hosting.)

---

## Overview

```
Internet → HTTPS (nginx) → Node :5000
                              ├── /api/*     API
                              ├── /uploads/* images
                              └── /*         React app (frontend/dist)
```

SQLite database + uploads live in `/var/lib/village-netacad/` (not inside the app folder).

---

## Step 1 — DNS

At your domain registrar, point **villagenetacad.co.za** to your VPS IP:

| Type | Name | Value        |
|------|------|--------------|
| A    | @    | YOUR_VPS_IP  |
| A    | www  | YOUR_VPS_IP  |

Wait until `ping villagenetacad.co.za` returns your server IP.

---

## Step 2 — Upload code to the VPS

On your PC (PowerShell), from the project folder:

```powershell
# Example: replace user and IP
scp -r backend frontend package.json package-lock.json ecosystem.config.cjs deploy DEPLOYMENT.md user@YOUR_VPS_IP:/var/www/village-netacad/
```

Or use **Git** on the server:

```bash
cd /var/www
git clone YOUR_REPO village-netacad
cd village-netacad
```

---

## Step 3 — Production `.env` on the server

```bash
cd /var/www/village-netacad
cp deploy/env.production.template backend/.env
nano backend/.env
```

Set these (see `deploy/env.production.template`):

| Variable | Your value |
|----------|------------|
| `CLIENT_URL` | `https://villagenetacad.co.za` |
| `API_URL` | `https://villagenetacad.co.za` |
| `PAYFAST_NOTIFY_URL` | `https://villagenetacad.co.za/api/payfast/notify` |
| `JWT_SECRET` | New random string (`openssl rand -hex 32`) — **not** the dev secret |
| `PAYFAST_MERCHANT_ID` | `14050025` (sandbox) until you go live |
| `PAYFAST_MERCHANT_KEY` | From [sandbox.payfast.co.za](https://sandbox.payfast.co.za) |
| `PAYFAST_PASSPHRASE` | Must match PayFast → Settings → Security exactly |
| `PAYFAST_SANDBOX` | `true` first, then `false` with live credentials |
| `SMTP_USER` / `SMTP_PASS` | Gmail app password for `info@villagenetacad.co.za` |

Create data folders:

```bash
sudo mkdir -p /var/lib/village-netacad/uploads
sudo chown -R $USER:$USER /var/lib/village-netacad
```

---

## Step 4 — Build and run

```bash
cd /var/www/village-netacad
npm run install:all
npm run predeploy

# PM2 (keeps app running after logout)
sudo npm install -g pm2
pm2 start ecosystem.config.cjs
pm2 save
pm2 startup
```

Check locally on the server:

```bash
curl http://127.0.0.1:5000/health
```

---

## Step 5 — HTTPS with nginx

```bash
sudo apt update && sudo apt install -y nginx certbot python3-certbot-nginx
sudo cp /var/www/village-netacad/deploy/nginx.villagenetacad.co.za.conf /etc/nginx/sites-available/villagenetacad.co.za
sudo ln -sf /etc/nginx/sites-available/villagenetacad.co.za /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
sudo certbot --nginx -d villagenetacad.co.za -d www.villagenetacad.co.za
```

---

## Step 6 — Verify

1. **Health:** https://villagenetacad.co.za/health → `"status":"ok"`
2. **Homepage:** https://villagenetacad.co.za loads the shop
3. **Admin:** https://villagenetacad.co.za/login  
   - `admin@villagenetacad.com` / `Admin123!` → **change password immediately**
4. **Contact form:** needs SMTP filled in `.env`
5. **PayFast (sandbox):** small donation or order → payment completes → status updates in admin

PayFast ITN only works over **HTTPS** with the live domain — not `localhost`.

---

## PayFast: your two-phase rollout

### Phase A — Sandbox on live domain (recommended first)

```env
PAYFAST_SANDBOX=true
PAYFAST_MERCHANT_ID=14050025
# key + passphrase from sandbox.payfast.co.za
PAYFAST_NOTIFY_URL=https://villagenetacad.co.za/api/payfast/notify
```

Test card details: [PayFast sandbox documentation](https://developers.payfast.co.za/docs#step_4_confirm_payment).

### Phase B — Live payments

1. Register / verify merchant at [www.payfast.co.za](https://www.payfast.co.za)
2. Update `.env`:
   ```env
   PAYFAST_SANDBOX=false
   PAYFAST_MERCHANT_ID=<live id>
   PAYFAST_MERCHANT_KEY=<live key>
   PAYFAST_PASSPHRASE=<live passphrase>
   ```
3. `pm2 restart village-netacad`

---

## Local development (your PC)

Keep `backend/.env` with:

```env
NODE_ENV=development
CLIENT_URL=http://localhost:5173
API_URL=http://localhost:5000
PAYFAST_SANDBOX=true
```

Run:

```powershell
# Terminal 1
cd backend
npm run dev

# Terminal 2
cd frontend
npm run dev
```

For PayFast ITN while developing locally, use ngrok:

```env
PAYFAST_NOTIFY_URL=https://YOUR-ID.ngrok-free.app/api/payfast/notify
```

---

## Backups

```bash
cp /var/lib/village-netacad/database.sqlite ~/backups/db-$(date +%F).sqlite
tar -czf ~/backups/uploads-$(date +%F).tar.gz /var/lib/village-netacad/uploads
```

---

## Useful commands

| Task | Command |
|------|---------|
| View logs | `pm2 logs village-netacad` |
| Restart app | `pm2 restart village-netacad` |
| Redeploy after code pull | `npm run predeploy && pm2 restart village-netacad` |
| PayFast config check (dev only) | `http://localhost:5000/api/payfast/check` |

---

## Checklist before announcing the site

- [ ] DNS points to VPS
- [ ] HTTPS works on villagenetacad.co.za
- [ ] `/health` returns ok
- [ ] Admin password changed
- [ ] SMTP works (contact form email arrives at info@villagenetacad.co.za)
- [ ] PayFast sandbox payment completes end-to-end
- [ ] Switch to PayFast live when ready (`PAYFAST_SANDBOX=false`)

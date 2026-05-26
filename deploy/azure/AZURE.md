# Deploy Village NetAcad on Microsoft Azure

This app is a **single Node.js server** (Express API + React static files + SQLite). Use **Azure App Service (Linux, Node 22)** — not Azure Static Web Apps alone (SWA cannot run this Express API or SQLite).

```
Internet → HTTPS (Azure) → App Service :8080
                              ├── /api/*       API
                              ├── /uploads/*   images
                              └── /*           React (frontend/dist)
```

Database and uploads persist under `/home/site/data/` on Linux App Service.

---

## 1. Create the App Service (Portal)

1. [Azure Portal](https://portal.azure.com) → **Create a resource** → **Web App**
2. **Basics**
   - Name: e.g. `villagenetacad` (becomes `villagenetacad.azurewebsites.net`)
   - Publish: **Code**
   - Runtime stack: **Node 22 LTS**
   - Operating System: **Linux**
   - Region: closest to South Africa if most users are ZA (e.g. South Africa North, or West Europe)
3. **App Service Plan**: B1 or higher recommended (Free F1 has cold starts and limited CPU)
4. Create the web app

---

## 2. Configure the app

**Configuration** → **General settings**

| Setting | Value |
|--------|--------|
| Startup Command | `bash deploy/azure/startup.sh` |
| Stack | Node 22 |

**Configuration** → **Application settings** — add variables from [`env.azure.template`](./env.azure.template). Minimum:

- `NODE_ENV` = `production`
- `JWT_SECRET` = (32+ char random)
- `CLIENT_URL` / `API_URL` = `https://YOUR_APP.azurewebsites.net`
- `PAYFAST_*` and `SMTP_*` as needed

**Configuration** → **General settings** → **HTTPS Only**: On

---

## 3. Deploy from GitHub

### Option A — GitHub Actions (recommended)

1. In Azure Portal: Web App → **Deployment Center** → **GitHub** → authorize and select repo `DigititanH/villagenetacad`, branch `main`
2. Or use the workflow [`.github/workflows/azure-app-service.yml`](../../.github/workflows/azure-app-service.yml):

   - Create an **Azure service principal** or use **Publish profile**:
   - Web App → **Download publish profile**
   - GitHub repo → **Settings** → **Secrets** → add `AZURE_WEBAPP_PUBLISH_PROFILE` (paste XML)

3. Edit the workflow env `AZURE_WEBAPP_NAME` to match your app name
4. Push to `main` — Actions builds frontend and deploys

### Option B — Local Git / ZIP

```bash
# From project root, after building frontend locally
npm install --prefix backend
npm install --prefix frontend
npm run build --prefix frontend
az webapp up --name YOUR_APP --resource-group YOUR_RG --runtime "NODE:22-lts"
```

---

## 4. Custom domain (villagenetacad.co.za)

1. App Service → **Custom domains** → **Add custom domain**
2. At your DNS host, add the CNAME or A record Azure shows
3. Enable **Managed certificate** (free SSL)
4. Update App Settings:
   - `CLIENT_URL=https://villagenetacad.co.za`
   - `API_URL=https://villagenetacad.co.za`
   - `PAYFAST_NOTIFY_URL=https://villagenetacad.co.za/api/payfast/notify`

---

## 5. Verify

| Check | URL |
|-------|-----|
| Health | `https://YOUR_APP.azurewebsites.net/health` |
| Shop | `https://YOUR_APP.azurewebsites.net/` |
| Admin login | `https://YOUR_APP.azurewebsites.net/login` |

Default admin (change after first login): `admin@villagenetacad.com` / `Admin123!`

---

## 6. Azure Static Web Apps workflow

The repo includes [`.github/workflows/azure-static-web-apps-*.yml`](../../.github/workflows/) from an earlier Azure setup. That deploys **frontend only** and will **not** run the API. For this project, rely on **App Service** (`azure-app-service.yml`). You can disable or delete the Static Web Apps workflow in GitHub if you are not using SWA.

---

## 7. Production notes

| Topic | Guidance |
|-------|----------|
| **SQLite** | Fine for small/medium traffic; for high scale use Azure Database for PostgreSQL and migrate later |
| **Backups** | Periodically copy `/home/site/data/database.sqlite` (Kudu SSH or backup slot) |
| **Scaling** | Scale up App Service plan; SQLite is single-instance — use one instance or external DB for multiple instances |
| **Secrets** | Prefer **Key Vault references** in App Settings for production |
| **Node version** | Must be **22.x** (see `.nvmrc`) for `better-sqlite3` on Windows dev; Linux App Service builds native module on deploy |

---

## Quick CLI (optional)

```bash
az login
az group create --name rg-villagenetacad --location southafricanorth
az appservice plan create --name plan-villagenetacad --resource-group rg-villagenetacad --sku B1 --is-linux
az webapp create --name villagenetacad --resource-group rg-villagenetacad --plan plan-villagenetacad --runtime "NODE:22-lts"
az webapp config set --name villagenetacad --resource-group rg-villagenetacad --startup-file "bash deploy/azure/startup.sh"
```

Then set application settings from `env.azure.template` and connect GitHub deployment.

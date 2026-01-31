# Dokploy Deployment Guide - Ragnarok Online Private Server

This guide explains how to deploy the RO private server on Dokploy.

## Prerequisites

- Dokploy installed on your Linux server
- Domain or public IP for your server

## Deployment Options

### Option A: FTP Upload (Recommended for large files)

1. Upload these files via FTP to `/home/dokploy/ro-server/`:
   ```
   Dockerfile
   docker-compose.yml
   .env.example → rename to .env
   docker/
   ```

2. SSH into server:
   ```bash
   cd /home/dokploy/ro-server
   chmod +x docker/entrypoint.sh
   cp .env.example .env
   nano .env  # Edit values
   docker compose up -d --build
   ```

### Option B: Git Repository

### 1. Push to Git Repository

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin <your-git-repo-url>
git push -u origin main
```

### 2. Create Service in Dokploy

1. Login to Dokploy dashboard
2. Click **Create Service** → **Docker Compose**
3. Connect your Git repository
4. Set the following environment variables:

| Variable | Example Value | Description |
|----------|---------------|-------------|
| `MYSQL_ROOT_PASSWORD` | `securepass123` | MySQL root password |
| `DB_USER` | `ragnarok` | Database username |
| `DB_PASS` | `ragnarok123` | Database password |
| `DB_NAME` | `hercules` | Database name |
| `SERVER_NAME` | `MyROServer` | Server name shown in client |
| `PUBLIC_IP` | `ro.example.com` | Server IP or domain name |

5. Click **Deploy**

### 3. Configure Firewall

Open these ports on your server:

```bash
# UFW (Ubuntu)
sudo ufw allow 6900/tcp  # Login Server
sudo ufw allow 6121/tcp  # Char Server
sudo ufw allow 5121/tcp  # Map Server
```

### 4. First Login

Default test account:
- Username: `s1`
- Password: `p1`

To create accounts, access phpMyAdmin at `http://your-server:8080`

## Port Reference

| Port | Service | Protocol |
|------|---------|----------|
| 6900 | Login Server | TCP |
| 6121 | Char Server | TCP |
| 5121 | Map Server | TCP |
| 8080 | phpMyAdmin | HTTP |

## Client Configuration

Edit your kRO client's `clientinfo.xml` (supports both IP and domain):

```xml
<?xml version="1.0" encoding="euc-kr" ?>
<clientinfo>
    <servicetype>korea</servicetype>
    <servertype>primary</servertype>
    <connection>
        <display>MyROServer</display>
        <!-- Use IP or domain -->
        <address>ro.yourdomain.com</address>
        <port>6900</port>
        <version>55</version>
        <langtype>0</langtype>
    </connection>
</clientinfo>
```

## Troubleshooting

### Check logs
```bash
docker compose logs emulator
docker compose logs db
```

### Restart services
```bash
docker compose restart emulator
```

### Reset database
```bash
docker compose down -v
docker compose up -d
```

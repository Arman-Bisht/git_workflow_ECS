# Task 3: Dockerized Strapi with PostgreSQL and Nginx

**Author:** Arman Bisht  
**Date:** December 5, 2025  
**Status:** ✅ Complete

## Overview

This setup creates a production-ready Dockerized environment with:
- PostgreSQL database for data persistence
- Strapi CMS application
- Nginx reverse proxy for routing
- Custom Docker network for container communication

## Quick Start

```bash
# 1. Navigate to directory
cd strapi/examples/getstarted

# 2. Start all services (builds and starts in background)
docker-compose up -d

# 4. Check status
docker-compose ps

# 5. View logs
docker-compose logs -f

# 6. Access Strapi
# Open browser: http://localhost/admin
```

## What's Included

- ✅ PostgreSQL database (strapi-postgres)
- ✅ Strapi application (strapi-app)
- ✅ Nginx reverse proxy (strapi-nginx)
- ✅ Custom Docker network (strapi-net)
- ✅ Persistent data volumes

## Architecture

```
Internet → Port 80 → Nginx → Strapi (1337) → PostgreSQL (5432)
                      ↓
                All on strapi-net network
```

## Access Points

- **Admin Dashboard:** http://localhost/admin
- **API:** http://localhost/api
- **Homepage:** http://localhost

## Files

- `docker-compose.yml` - Multi-container setup
- `nginx.conf` - Reverse proxy configuration
- `Dockerfile` - Strapi container build
- `.env.example` - Environment variables template
- `TASK3_FILE_EXPLANATIONS.md` - Detailed file explanations

## Common Commands

```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# Restart
docker-compose restart

# Logs
docker-compose logs -f strapi

# Rebuild
docker-compose build --no-cache
docker-compose up -d
```

## Troubleshooting

**Port 80 already in use?**
```bash
# Find process using port 80
netstat -ano | findstr :80
# Kill the process or change nginx port in docker-compose.yml
```

**Database connection failed?**
```bash
# Check PostgreSQL health
docker-compose exec postgres pg_isready -U strapi
```

**Can't access http://localhost?**
```bash
# Check all containers are running
docker-compose ps

# Check nginx logs
docker-compose logs nginx
```

## Network Details

All containers communicate on `strapi-net`:
- Nginx can reach Strapi at `http://strapi:1337`
- Strapi can reach PostgreSQL at `postgres:5432`

## Data Persistence

- PostgreSQL data: Docker volume `postgres-data`
- Strapi uploads: Local folder `./public/uploads`

## Environment Variables

Database credentials (defined in docker-compose.yml):
- **User:** strapi
- **Password:** strapi123
- **Database:** strapi
- **Host:** postgres (Docker DNS)
- **Port:** 5432

## Verification

Check that all services are running:
```bash
docker-compose ps

# Should show:
# strapi-postgres  (healthy)
# strapi-app       (running)
# strapi-nginx     (running)
```

Check network connectivity:
```bash
docker network inspect getstarted_strapi-net

# Should show all 3 containers connected
```

## Cleanup

```bash
# Remove containers and network (keep data)
docker-compose down

# Remove everything including data
docker-compose down -v
```

## Task Requirements Completed

✅ User-defined Docker network (strapi-net)  
✅ PostgreSQL container with credentials  
✅ Strapi connected to PostgreSQL via environment variables  
✅ All containers on same network  
✅ Nginx reverse proxy on port 80  
✅ nginx.conf configured to proxy localhost → Strapi:1337  
✅ Access Strapi Admin at http://localhost/admin  
✅ Complete documentation  

---

**Created by:** Arman Bisht  
**Task:** 3 - Docker Network Setup  
**Date:** December 5, 2025

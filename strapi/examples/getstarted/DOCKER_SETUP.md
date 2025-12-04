# Docker Setup for Strapi

**Created by**: Arman Bisht  
**Date**: December 3, 2025

---

## 📋 Prerequisites

- Docker installed on your system
- Docker Desktop running (for Windows)

---

## 🐳 Build Docker Image

```bash
# Navigate to the strapi root folder
cd strapi

# Build the Docker image (this may take 5-10 minutes)
docker build -t strapi-app .
```

**Note**: The build process installs all dependencies and sets up the entire Strapi monorepo.

---

## 🚀 Run Docker Container

```bash
# Run the container
docker run -p 1337:1337 strapi-app
```

Access Strapi at: `http://localhost:1337/admin`

---

## 🛠️ Useful Docker Commands

### List running containers
```bash
docker ps
```

### Stop the container
```bash
docker stop <container_id>
```

### Remove container
```bash
docker rm <container_id>
```

### Remove image
```bash
docker rmi strapi-app
```

### View logs
```bash
docker logs <container_id>
```

### Run with volume (persist data)
```bash
docker run -p 1337:1337 -v strapi-data:/app/examples/getstarted/.tmp strapi-app
```

### Run in detached mode (background)
```bash
docker run -d -p 1337:1337 --name strapi-container strapi-app
```

---

## 📝 Dockerfile Details

- **Base Image**: Node.js 20 Alpine (lightweight Linux)
- **Working Directory**: `/app/examples/getstarted`
- **Exposed Port**: 1337
- **Environment**: Development mode
- **Command**: `npm run develop`

---

## 🔧 Troubleshooting

### Port already in use
```bash
# Stop any running Strapi instance first
# Or use a different port
docker run -p 3000:1337 strapi-app
```

### Build fails
```bash
# Clean Docker cache and rebuild
docker system prune -a
docker build --no-cache -t strapi-app .
```

---

**Status**: ✅ Dockerized Successfully

# Docker Quick Start Guide

Get your Smart Parking Backend running with Docker in 5 minutes!

---

## Prerequisites

Install Docker Desktop:
- **Mac/Windows:** Download from [docker.com](https://www.docker.com/products/docker-desktop)
- **Linux:**
  ```bash
  sudo apt update
  sudo apt install docker.io docker-compose
  sudo systemctl start docker
  sudo usermod -aG docker $USER  # Logout and login again
  ```

---

## Quick Test (3 Commands)

```bash
# 1. Navigate to project
cd /home/hello/Desktop/smartParkingBackend

# 2. Start everything (PostgreSQL + Backend)
docker-compose up -d

# 3. Test health endpoint
curl http://localhost:8080/api/health
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Service is running",
  "data": {
    "status": "UP"
  }
}
```

---

## View Logs

```bash
# Watch application logs in real-time
docker-compose logs -f app

# Press Ctrl+C to stop watching
```

Look for this line:
```
Started SmartParkingApplication in X.XXX seconds
```

---

## Test API Endpoints

### Health Check
```bash
curl http://localhost:8080/api/health
```

### Get All Parking Lots
```bash
curl http://localhost:8080/api/parking-lots
```

### Get All Employees
```bash
curl http://localhost:8080/api/employees
```

### Create a Parking Lot
```bash
curl -X POST http://localhost:8080/api/parking-lots \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Main Parking",
    "location": "Downtown",
    "capacity": 100,
    "numberOfFloors": 2
  }'
```

---

## Stop Services

```bash
# Stop containers (keeps data)
docker-compose down

# Stop and remove all data (fresh start next time)
docker-compose down -v
```

---

## Rebuild After Code Changes

```bash
# Rebuild and restart
docker-compose up -d --build
```

---

## Troubleshooting

### "Port already in use"
Another service is using port 8080. Stop it or change port in `docker-compose.yml`:
```yaml
ports:
  - "8081:8080"  # Use 8081 instead
```

### "Cannot connect to Docker daemon"
Start Docker Desktop or run:
```bash
sudo systemctl start docker
```

### "Container exits immediately"
Check logs:
```bash
docker-compose logs app
```

### "Database connection failed"
Wait 30 seconds for PostgreSQL to start, then restart:
```bash
docker-compose restart app
```

---

## Access PostgreSQL Database

```bash
# Connect to database
docker-compose exec postgres psql -U smartparking_user -d smartparking

# List tables
\dt

# View employees
SELECT * FROM employees;

# Exit
\q
```

---

## Docker Commands Cheat Sheet

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# List running containers
docker-compose ps

# Restart a service
docker-compose restart app

# Rebuild images
docker-compose build

# Execute command in container
docker-compose exec app sh

# Clean everything (including volumes)
docker-compose down -v
```

---

## Next Steps

1. ✅ Test locally with Docker
2. ✅ Verify all endpoints work
3. ✅ Review [DOCKER_DEPLOYMENT_GUIDE.md](DOCKER_DEPLOYMENT_GUIDE.md) for full deployment
4. ✅ Follow [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) to deploy to Render

---

## What's Running?

When you run `docker-compose up -d`, you get:

1. **PostgreSQL Container:**
   - Port: 5432
   - Database: `smartparking`
   - User: `smartparking_user`
   - Password: `smartparking_pass`

2. **Spring Boot Container:**
   - Port: 8080
   - Profile: `render` (uses PostgreSQL)
   - Connected to PostgreSQL
   - Auto-creates tables on startup

---

## Understanding Docker Compose Output

```bash
$ docker-compose up -d
Creating network "smartparkingbackend_default" ... done
Creating smartparking-postgres ... done
Creating smartparking-backend  ... done
```

This means:
- ✅ Network created for containers to communicate
- ✅ PostgreSQL started
- ✅ Spring Boot app started and connected to PostgreSQL

Check status:
```bash
$ docker-compose ps
NAME                    STATUS        PORTS
smartparking-postgres   Up (healthy)  5432->5432
smartparking-backend    Up (healthy)  8080->8080
```

---

## When to Use Docker vs Maven

### Use Docker when:
- ✅ Testing production-like environment
- ✅ Testing with PostgreSQL
- ✅ Preparing for deployment
- ✅ Sharing with team (consistent environment)

### Use Maven when:
- ✅ Active development (faster rebuilds)
- ✅ Debugging with IDE
- ✅ Running tests frequently
- ✅ Using H2 database

---

## Docker Benefits

1. **Consistency:** Works the same on all machines
2. **Isolation:** Dependencies don't conflict with your system
3. **Production-like:** Tests with PostgreSQL, not H2
4. **Quick Setup:** No need to install Java, Maven, PostgreSQL
5. **Clean Removal:** `docker-compose down -v` removes everything

---

## Performance Tips

### Build Cache
Docker caches layers. First build is slow (~5 min), subsequent builds are fast (~30 sec).

### Volume Mounts for Development
For live code reloading during development, add to `docker-compose.yml`:
```yaml
volumes:
  - ./src:/app/src
```

Then use Spring DevTools for auto-restart.

### Memory Limits
If running slow, increase memory in `docker-compose.yml`:
```yaml
environment:
  JAVA_OPTS: -Xmx768m -Xms384m
```

---

## Security Note

**Do NOT commit these to Git:**
- `firebase-service-account.json`
- `.env` files with secrets
- Database passwords in production

The `.dockerignore` file already excludes these.

---

## Summary

**Start:**
```bash
docker-compose up -d
```

**Test:**
```bash
curl http://localhost:8080/api/health
```

**Stop:**
```bash
docker-compose down
```

That's it! Your backend is running in Docker! 🐳

For full deployment guide, see [DOCKER_DEPLOYMENT_GUIDE.md](DOCKER_DEPLOYMENT_GUIDE.md).

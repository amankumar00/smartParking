# Docker Deployment Guide - Smart Parking Backend

Complete guide to deploy your Spring Boot application using Docker.

---

## WHY DOCKER?

Docker provides:
- ✅ Consistent environment across development and production
- ✅ No need to install Java/Maven on the server
- ✅ Easy deployment to any cloud platform (Render, AWS, Azure, etc.)
- ✅ Isolated dependencies and configurations
- ✅ Simple rollbacks and scaling

---

## PREREQUISITES

### Local Development:
- Docker Desktop installed ([Get Docker](https://www.docker.com/products/docker-desktop))
- Docker Compose (included with Docker Desktop)
- Git

### For Render Deployment:
- Render account (free tier available)
- Git repository pushed to GitHub/GitLab/Bitbucket

---

## PART 1: LOCAL TESTING WITH DOCKER

### Step 1: Build the Docker Image

```bash
cd /home/hello/Desktop/smartParkingBackend

# Build the Docker image
docker build -t smartparking-backend:latest .
```

This will:
1. Download Maven and Java 17
2. Install all dependencies
3. Build your Spring Boot application
4. Create a lightweight runtime image (~200MB)

### Step 2: Run with Docker Compose (Recommended)

Docker Compose will start both PostgreSQL and your application:

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f app

# Stop all services
docker-compose down

# Stop and remove volumes (clean slate)
docker-compose down -v
```

### Step 3: Test Your Application

Once running, test the health endpoint:

```bash
# Health check
curl http://localhost:8080/api/health

# Expected response:
{
  "success": true,
  "message": "Service is running",
  "data": {
    "status": "UP"
  }
}
```

### Step 4: Test Other Endpoints

```bash
# Get all parking lots
curl http://localhost:8080/api/parking-lots

# Get all employees
curl http://localhost:8080/api/employees
```

For authenticated endpoints, you'll need a Firebase token (see FIREBASE_SETUP.md).

---

## PART 2: UNDERSTANDING THE DOCKER SETUP

### Dockerfile Explained

```dockerfile
# Stage 1: Build (uses Maven and JDK)
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B  # Download dependencies (cached)
COPY src ./src
RUN mvn clean package -DskipTests  # Build JAR

# Stage 2: Runtime (only JRE, much smaller)
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
RUN addgroup -S spring && adduser -S spring -G spring  # Security
USER spring:spring
COPY --from=build /app/target/smart-parking-backend-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT [...]  # Start the application
```

**Benefits of Multi-stage Build:**
- Build image: ~800MB (includes Maven, JDK, build tools)
- Final image: ~200MB (only JRE and your JAR)
- Faster deployments and less storage

### docker-compose.yml Explained

```yaml
services:
  postgres:
    # PostgreSQL database for development/testing
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: smartparking
      POSTGRES_USER: smartparking_user
      POSTGRES_PASSWORD: smartparking_pass

  app:
    # Your Spring Boot application
    build: .
    environment:
      DATABASE_URL: postgresql://...
      SPRING_PROFILES_ACTIVE: render
    depends_on:
      postgres:
        condition: service_healthy  # Wait for DB to be ready
```

---

## PART 3: DEPLOY TO RENDER WITH DOCKER

### Step 1: Commit Docker Files to Git

```bash
cd /home/hello/Desktop/smartParkingBackend

# Check what's new
git status

# Add Docker files
git add Dockerfile
git add .dockerignore
git add docker-compose.yml
git add DOCKER_DEPLOYMENT_GUIDE.md

# Commit
git commit -m "Add Docker configuration for deployment"

# Push to your repository
git push origin main
```

### Step 2: Create PostgreSQL Database on Render

1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click **New +** → **PostgreSQL**
3. Configure:
   - **Name:** `smartparking-db`
   - **Database:** `smartparking`
   - **User:** `smartparking_user`
   - **Region:** Choose closest to you
   - **PostgreSQL Version:** 15
   - **Plan:** **Free**
4. Click **Create Database**
5. **IMPORTANT:** Copy the **Internal Database URL**
   - Format: `postgresql://smartparking_user:xxxxx@dpg-xxxxx/smartparking`

### Step 3: Create Web Service on Render

1. Click **New +** → **Web Service**
2. Connect your Git repository
3. Configure:

#### Basic Settings:
- **Name:** `smart-parking-backend`
- **Region:** Same as database
- **Branch:** `main`
- **Root Directory:** (leave empty)
- **Runtime:** **Docker** ← IMPORTANT!

#### Build Settings:
When you select **Docker**, Render will automatically:
- Use your `Dockerfile`
- Build the image
- Deploy the container

No build command needed! Render detects the Dockerfile automatically.

#### Instance Settings:
- **Plan:** **Free** (512 MB RAM, spins down after 15 min inactivity)

### Step 4: Add Environment Variables

Scroll to **Environment Variables** and add:

| Key | Value |
|-----|-------|
| `SPRING_PROFILES_ACTIVE` | `render` |
| `DATABASE_URL` | (Paste Internal Database URL from Step 2) |
| `PORT` | `8080` |
| `JAVA_OPTS` | `-Xmx512m -Xms256m` |

**Optional - For Firebase:**
| Key | Value |
|-----|-------|
| `FIREBASE_CONFIG_FILE` | `/etc/secrets/firebase-service-account.json` |

### Step 5: Add Firebase Secret File (Optional)

If using Firebase authentication:

1. Go to **Environment** → **Secret Files**
2. Click **Add Secret File**
3. Configure:
   - **Filename:** `firebase-service-account.json`
   - **Mount Path:** `/etc/secrets/firebase-service-account.json`
   - **Contents:** Paste your entire Firebase service account JSON
4. Click **Save**

### Step 6: Deploy

1. Click **Create Web Service**
2. Render will:
   - Clone your repository
   - Build the Docker image (5-10 minutes first time)
   - Start the container
3. Watch the **Logs** tab
4. Look for: `Started SmartParkingApplication`

### Step 7: Test Your Deployment

Your app will be at: `https://smart-parking-backend.onrender.com`

```bash
# Test health endpoint
curl https://smart-parking-backend.onrender.com/api/health

# Expected response:
{
  "success": true,
  "message": "Service is running",
  "data": {
    "status": "UP"
  }
}
```

---

## PART 4: MANAGING YOUR DOCKER DEPLOYMENT

### View Logs in Render

1. Go to Render Dashboard
2. Click on your service
3. **Logs** tab shows real-time container logs

### Restart Service

1. Render Dashboard → Your Service
2. Click **Manual Deploy** → **Deploy latest commit**
3. Or: **Clear build cache & deploy** (if having issues)

### Update Your Application

Simply push to Git:

```bash
# Make your code changes
git add .
git commit -m "Your changes"
git push origin main
```

Render will automatically:
1. Rebuild the Docker image
2. Deploy the new container
3. Zero-downtime deployment

### Scale Up (If Needed)

Free tier limitations:
- 512 MB RAM
- Spins down after 15 min inactivity
- Shared CPU

To upgrade:
1. Render Dashboard → Your Service → **Settings**
2. Change **Instance Type** to **Starter** ($7/month) or higher
3. Benefits: Always-on, dedicated CPU, more RAM

---

## PART 5: LOCAL DEVELOPMENT WORKFLOW

### Option 1: Docker Compose (Recommended for Testing)

```bash
# Start everything
docker-compose up -d

# Make code changes...

# Rebuild and restart
docker-compose up -d --build

# View logs
docker-compose logs -f app

# Stop
docker-compose down
```

### Option 2: Maven (Recommended for Development)

Use Docker for database only:

```bash
# Start only PostgreSQL
docker-compose up -d postgres

# Run app with Maven (faster for development)
mvn spring-boot:run

# Or use your IDE to run the application
```

Update `application.properties` for local PostgreSQL:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/smartparking
spring.datasource.username=smartparking_user
spring.datasource.password=smartparking_pass
```

---

## PART 6: TROUBLESHOOTING

### Build Fails - "Cannot find pom.xml"

**Solution:** Make sure Dockerfile is in project root directory:

```bash
smartParkingBackend/
├── Dockerfile          ← Must be here
├── pom.xml
├── src/
└── ...
```

### Build Fails - "dependency resolution failed"

**Solution:** Check your internet connection and Maven Central is accessible:

```bash
# Test Maven locally first
mvn clean package -DskipTests
```

### Container Starts but Health Check Fails

**Solution:** Check logs for errors:

```bash
# Docker Compose
docker-compose logs app

# Render
Check Logs tab in dashboard
```

Common issues:
- Database connection failed (check DATABASE_URL)
- Firebase config file missing
- Port binding issue

### Database Connection Failed

**Solution:**

1. **Local (Docker Compose):**
   - Check if PostgreSQL container is running: `docker-compose ps`
   - Check logs: `docker-compose logs postgres`

2. **Render:**
   - Verify DATABASE_URL environment variable is set
   - Check if PostgreSQL instance is running in Render dashboard
   - Ensure you're using **Internal Database URL**, not External

### Out of Memory Error

**Solution:** Increase memory limit:

```bash
# Docker Compose - update docker-compose.yml
environment:
  JAVA_OPTS: -Xmx768m -Xms384m  # Increase from 512m

# Render - update JAVA_OPTS environment variable
```

### Slow Build Times

**Solution:** Docker caches layers. If rebuilding often:

```bash
# Clear Docker cache
docker builder prune -a

# Rebuild without cache
docker build --no-cache -t smartparking-backend:latest .
```

---

## PART 7: DOCKER COMMANDS REFERENCE

### Build & Run

```bash
# Build image
docker build -t smartparking-backend:latest .

# Run container (standalone)
docker run -d -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=render \
  -e DATABASE_URL=postgresql://... \
  --name smartparking-app \
  smartparking-backend:latest

# Stop container
docker stop smartparking-app

# Remove container
docker rm smartparking-app

# Remove image
docker rmi smartparking-backend:latest
```

### Docker Compose Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# Rebuild and start
docker-compose up -d --build

# View logs
docker-compose logs -f

# View logs for specific service
docker-compose logs -f app

# List running containers
docker-compose ps

# Execute command in container
docker-compose exec app sh

# Remove everything including volumes
docker-compose down -v
```

### Debugging

```bash
# Enter running container
docker-compose exec app sh

# Check environment variables inside container
docker-compose exec app env

# Check if app is listening on port
docker-compose exec app wget -O- http://localhost:8080/api/health
```

---

## PART 8: SECURITY BEST PRACTICES

### ✅ What We Did:

1. **Non-root User:**
   ```dockerfile
   RUN addgroup -S spring && adduser -S spring -G spring
   USER spring:spring
   ```
   - Container runs as non-root user for security

2. **Multi-stage Build:**
   - Build tools not included in final image
   - Smaller attack surface

3. **Secret Files:**
   - Firebase credentials via Render Secret Files
   - Not hardcoded in image

4. **Environment Variables:**
   - Database credentials via environment variables
   - Not committed to Git

### 🔒 Additional Recommendations:

1. **Use specific image versions:**
   ```dockerfile
   FROM eclipse-temurin:17.0.9_9-jre-alpine
   ```
   Instead of: `FROM eclipse-temurin:17-jre-alpine`

2. **Scan for vulnerabilities:**
   ```bash
   docker scan smartparking-backend:latest
   ```

3. **Keep dependencies updated:**
   ```bash
   mvn versions:display-dependency-updates
   ```

---

## PART 9: COST OPTIMIZATION

### Free Tier Strategy

**Render Free Tier Includes:**
- 750 hours/month (enough for 1 always-on service)
- 512 MB RAM
- Automatic HTTPS
- PostgreSQL (1 GB storage)

**Tips:**
- Spin down after 15 min inactivity (default)
- Use [UptimeRobot](https://uptimerobot.com) to ping every 5 min (keeps awake)
- Combine with free frontend hosting (Vercel/Netlify)

**Total Cost: $0/month** for small projects!

### When to Upgrade?

Consider paid tier when:
- Need guaranteed uptime (no spin down)
- Traffic > 100 requests/minute
- Database > 1 GB
- Need faster response times
- Need more than 512 MB RAM

**Render Starter Plan:** $7/month
- Always-on
- 512 MB - 8 GB RAM
- Faster builds

---

## PART 10: MONITORING & OBSERVABILITY

### Health Checks

Built into Dockerfile:

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --spider http://localhost:8080/api/health || exit 1
```

Render uses this to:
- Detect when service is ready
- Restart unhealthy containers
- Show service status

### Logs

View in real-time:

```bash
# Docker Compose
docker-compose logs -f app

# Render
Dashboard → Your Service → Logs tab
```

### Metrics

Render provides:
- CPU usage
- Memory usage
- Request count
- Response times

Access: Dashboard → Your Service → Metrics

---

## PART 11: CI/CD WITH DOCKER

### Automatic Deployments

Render automatically deploys when you push to Git:

```bash
# Make changes
git add .
git commit -m "Update feature X"
git push origin main

# Render will:
# 1. Detect the push
# 2. Rebuild Docker image
# 3. Deploy new container
# 4. Run health checks
# 5. Switch traffic to new container
```

### GitHub Actions (Optional)

Create `.github/workflows/docker-build.yml`:

```yaml
name: Docker Build & Test

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Build Docker image
        run: docker build -t smartparking-backend:latest .

      - name: Run tests
        run: docker run smartparking-backend:latest mvn test
```

---

## PART 12: ALTERNATIVE DEPLOYMENT OPTIONS

### Deploy to Other Platforms

Your Dockerfile works with any platform that supports Docker:

#### **AWS ECS:**
```bash
# Tag image
docker tag smartparking-backend:latest your-account.dkr.ecr.region.amazonaws.com/smartparking:latest

# Push to ECR
docker push your-account.dkr.ecr.region.amazonaws.com/smartparking:latest
```

#### **Google Cloud Run:**
```bash
# Tag image
docker tag smartparking-backend:latest gcr.io/your-project/smartparking:latest

# Push to GCR
docker push gcr.io/your-project/smartparking:latest
```

#### **Azure Container Instances:**
```bash
# Tag image
docker tag smartparking-backend:latest yourregistry.azurecr.io/smartparking:latest

# Push to ACR
docker push yourregistry.azurecr.io/smartparking:latest
```

#### **Heroku:**
```bash
heroku container:login
heroku container:push web -a your-app-name
heroku container:release web -a your-app-name
```

---

## SUMMARY

### Quick Start (Local Testing):

```bash
# 1. Build and start
docker-compose up -d

# 2. Test
curl http://localhost:8080/api/health

# 3. Stop
docker-compose down
```

### Quick Deploy (Render):

1. Push code to Git
2. Create PostgreSQL on Render
3. Create Web Service (select **Docker** runtime)
4. Add environment variables (DATABASE_URL, etc.)
5. Deploy automatically!

Your app will be live at: `https://smart-parking-backend.onrender.com`

---

## CHECKLIST

Before deploying:

- [ ] Dockerfile created
- [ ] .dockerignore created
- [ ] docker-compose.yml created
- [ ] Tested locally with `docker-compose up`
- [ ] Health endpoint works (`/api/health`)
- [ ] Changes committed to Git
- [ ] PostgreSQL created on Render
- [ ] Web Service created (Docker runtime)
- [ ] Environment variables configured
- [ ] Firebase secret uploaded (if using)
- [ ] Deployment successful
- [ ] Production health check works

---

## NEXT STEPS

After successful deployment:

1. ✅ Update frontend to use production URL
2. ✅ Configure CORS for production frontend domain
3. ✅ Set up monitoring (UptimeRobot, Sentry)
4. ✅ Test all endpoints in production
5. ✅ Share app with users!

---

## RESOURCES

- [Docker Documentation](https://docs.docker.com/)
- [Render Docker Deployment](https://render.com/docs/deploy-docker)
- [Spring Boot Docker Guide](https://spring.io/guides/gs/spring-boot-docker/)
- [PostgreSQL Docker Image](https://hub.docker.com/_/postgres)

---

🎉 **You're all set! Your backend is now Dockerized and ready for deployment!** 🎉

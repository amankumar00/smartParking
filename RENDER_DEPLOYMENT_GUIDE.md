# Deploy Smart Parking Backend to Render

Complete guide to deploy your Spring Boot application to Render.

---

## PREREQUISITES

✅ You've already done:
- Git repository created and pushed to GitHub/GitLab/Bitbucket

Still needed:
- Render account (free)
- Production database (PostgreSQL on Render - free tier)

---

## STEP 1: PREPARE YOUR PROJECT FOR DEPLOYMENT

### 1.1: Create Render Build Script

We need to tell Render how to build your Spring Boot app.

Create `render-build.sh` in project root:

```bash
#!/usr/bin/env bash
# exit on error
set -o errexit

# Build the project
./mvnw clean install -DskipTests
```

Make it executable:
```bash
chmod +x render-build.sh
```

### 1.2: Create Render Start Script

Create `render-start.sh` in project root:

```bash
#!/usr/bin/env bash
# Start the Spring Boot application
java -Dserver.port=$PORT $JAVA_OPTS -jar target/smart-parking-backend-1.0.0.jar
```

Make it executable:
```bash
chmod +x render-start.sh
```

### 1.3: Update application.properties for Production

Your current `application.properties` uses H2 (in-memory). For production, we'll use PostgreSQL.

Keep your existing file, but we'll create a production profile.

---

## STEP 2: CREATE PRODUCTION CONFIGURATION

Create `src/main/resources/application-render.properties`:

```properties
# Application Configuration
spring.application.name=smart-parking-backend
server.port=${PORT:8080}

# PostgreSQL Database Configuration (Render provides this)
spring.datasource.url=${DATABASE_URL}
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false

# Logging
logging.level.com.smartparking=INFO
logging.level.org.springframework.web=WARN
logging.level.org.hibernate.SQL=WARN

# Jackson Configuration
spring.jackson.serialization.write-dates-as-timestamps=false
spring.jackson.time-zone=UTC

# Firebase Configuration
firebase.config.file=${FIREBASE_CONFIG_FILE:firebase-service-account.json}

# Security
server.error.include-message=always
server.error.include-binding-errors=always
```

---

## STEP 3: ADD POSTGRESQL DEPENDENCY

Your app currently uses H2. We need to add PostgreSQL driver.

Update `pom.xml` - add this dependency:

```xml
<!-- PostgreSQL Driver (for production) -->
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>
```

Add it after the MySQL driver dependency.

---

## STEP 4: COMMIT AND PUSH CHANGES

```bash
git add .
git commit -m "Add Render deployment configuration"
git push origin main
```

---

## STEP 5: CREATE RENDER ACCOUNT & DEPLOY

### 5.1: Sign Up for Render

1. Go to [render.com](https://render.com)
2. Click **Get Started** or **Sign Up**
3. Sign up with GitHub (recommended) or email
4. Verify your email

### 5.2: Create PostgreSQL Database

1. Click **New +** → **PostgreSQL**
2. Configure database:
   - **Name:** `smartparking-db`
   - **Database:** `smartparking`
   - **User:** `smartparking_user`
   - **Region:** Choose closest to you
   - **PostgreSQL Version:** 15 (or latest)
   - **Plan:** **Free** (0.1 GB RAM, 1 GB Storage)
3. Click **Create Database**
4. Wait for database to be created (takes 1-2 minutes)

**Important:** Copy the **Internal Database URL** - we'll need this!

### 5.3: Create Web Service

1. Click **New +** → **Web Service**
2. Connect your Git repository:
   - If using GitHub: Click **Connect GitHub** → Select repository
   - If using GitLab/Bitbucket: Paste repository URL
3. Configure the service:

#### Basic Settings:
- **Name:** `smart-parking-backend`
- **Region:** Same as database
- **Branch:** `main` (or your default branch)
- **Root Directory:** (leave empty)
- **Runtime:** `Java`

#### Build Settings:
- **Build Command:**
  ```bash
  ./render-build.sh
  ```
- **Start Command:**
  ```bash
  ./render-start.sh
  ```

#### Instance Settings:
- **Plan:** **Free** (0.1 GB RAM, Spins down after inactivity)

### 5.4: Add Environment Variables

Scroll down to **Environment Variables** section and add:

| Key | Value |
|-----|-------|
| `SPRING_PROFILES_ACTIVE` | `render` |
| `DATABASE_URL` | (Internal Database URL from Step 5.2) |
| `JAVA_OPTS` | `-Xmx512m -Xms256m` |

**For Firebase (if using):**
| Key | Value |
|-----|-------|
| `FIREBASE_CONFIG_FILE` | `/etc/secrets/firebase-service-account.json` |

### 5.5: Add Firebase Service Account (Optional)

If using Firebase authentication:

1. Go to **Environment** → **Secret Files**
2. Click **Add Secret File**
3. **Filename:** `firebase-service-account.json`
4. **Contents:** Paste your Firebase service account JSON
5. Click **Save**

### 5.6: Deploy

1. Click **Create Web Service**
2. Render will automatically:
   - Clone your repository
   - Run the build script
   - Start your application
3. Wait 5-10 minutes for first deployment

---

## STEP 6: VERIFY DEPLOYMENT

### 6.1: Check Deploy Logs

In Render dashboard:
1. Click on your service
2. Go to **Logs** tab
3. Look for:
   ```
   Started SmartParkingApplication in X.XXX seconds
   ```

### 6.2: Test Your API

Your app will be available at: `https://smart-parking-backend.onrender.com`

Test the health endpoint:
```bash
curl https://smart-parking-backend.onrender.com/api/health
```

Expected response:
```json
{
  "success": true,
  "message": "Service is running",
  "data": {
    "status": "UP",
    ...
  }
}
```

---

## STEP 7: UPDATE SECURITY CONFIG FOR PRODUCTION

You need to update CORS to allow your frontend domain.

Update `SecurityConfig.java`:

```java
@Bean
public CorsConfigurationSource corsConfigurationSource() {
    CorsConfiguration configuration = new CorsConfiguration();

    // Add your production frontend URLs
    configuration.setAllowedOrigins(Arrays.asList(
        "http://localhost:3000",           // React dev
        "http://localhost:4200",           // Angular dev
        "https://your-frontend.vercel.app", // Production frontend
        "https://your-frontend.netlify.app" // Alternative
    ));

    configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
    configuration.setAllowedHeaders(Arrays.asList("*"));
    configuration.setAllowCredentials(true);

    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", configuration);
    return source;
}
```

Commit and push:
```bash
git add src/main/java/com/smartparking/config/SecurityConfig.java
git commit -m "Update CORS for production"
git push origin main
```

Render will automatically redeploy.

---

## COMPLETE FILE STRUCTURE

After adding deployment files, your project should have:

```
smartParkingBackend/
├── src/
│   └── main/
│       ├── java/...
│       └── resources/
│           ├── application.properties           # Development
│           ├── application-prod.properties      # MySQL production
│           └── application-render.properties    # Render PostgreSQL
├── render-build.sh        ← NEW
├── render-start.sh        ← NEW
├── pom.xml               ← UPDATED (add PostgreSQL)
└── ...
```

---

## RENDER FREE TIER LIMITATIONS

⚠️ **Important to know:**

### What's Free:
- ✅ 750 hours/month compute time
- ✅ PostgreSQL database (1 GB storage)
- ✅ Automatic HTTPS
- ✅ Automatic deployments from Git
- ✅ Environment variables

### Limitations:
- ⏰ **Spins down after 15 minutes of inactivity**
  - First request after spin-down takes 30-60 seconds
  - Subsequent requests are instant
- 💾 **0.1 GB RAM** (enough for Spring Boot)
- 🗄️ **Database limited to 1 GB**
- 🚫 **No custom domains on free tier**

### Workaround for Spin Down:
Use a service like [UptimeRobot](https://uptimerobot.com) to ping your health endpoint every 5 minutes (keeps it awake).

---

## TROUBLESHOOTING

### Issue 1: Build Fails - "mvnw: Permission denied"

**Solution:** Add Maven wrapper to git and make it executable:

```bash
git rm .gitignore  # Temporarily
git add .mvn/
git add mvnw
git add mvnw.cmd
chmod +x mvnw
git add .
git commit -m "Add Maven wrapper"
git push
```

Or update `render-build.sh` to use `mvn` instead:
```bash
#!/usr/bin/env bash
set -o errexit
mvn clean install -DskipTests
```

### Issue 2: Application Crashes - "Cannot determine embedded database driver class"

**Solution:** Make sure PostgreSQL dependency is in pom.xml and DATABASE_URL is set in Render.

### Issue 3: Port Binding Error

**Solution:** Ensure `application-render.properties` has:
```properties
server.port=${PORT:8080}
```

Render provides the PORT environment variable.

### Issue 4: Firebase Initialization Failed

**Solution:**
1. Make sure Firebase secret file is uploaded in Render
2. Set environment variable: `FIREBASE_CONFIG_FILE=/etc/secrets/firebase-service-account.json`

### Issue 5: Database Connection Failed

**Solution:**
1. Verify DATABASE_URL in Render environment variables
2. Check if PostgreSQL instance is running
3. Make sure firewall allows connection (Render handles this automatically)

---

## MONITORING YOUR DEPLOYMENT

### Check Logs:
1. Render Dashboard → Your Service → **Logs**
2. Real-time logs showing requests, errors, etc.

### Check Metrics:
1. Render Dashboard → Your Service → **Metrics**
2. Shows CPU, Memory, Request count

### Manual Restart:
1. Render Dashboard → Your Service
2. Click **Manual Deploy** → **Clear build cache & deploy**

---

## UPDATING YOUR DEPLOYMENT

After making code changes:

```bash
git add .
git commit -m "Your changes"
git push origin main
```

Render will automatically:
1. Detect the push
2. Rebuild your application
3. Deploy the new version
4. Zero-downtime deployment

---

## COST OPTIMIZATION

### Free Tier Strategy:
- Use Render Free for backend
- Use Vercel/Netlify Free for frontend
- Use Firebase Free for authentication
- Use Render PostgreSQL Free for database

**Total Cost: $0/month** for small projects!

### Upgrade When:
- Traffic > 100 requests/minute consistently
- Need guaranteed uptime (no spin down)
- Database > 1 GB
- Need custom domain

---

## PRODUCTION CHECKLIST

Before going live:

- [ ] PostgreSQL dependency added to pom.xml
- [ ] `application-render.properties` created
- [ ] `render-build.sh` created and executable
- [ ] `render-start.sh` created and executable
- [ ] Changes committed and pushed to Git
- [ ] Render account created
- [ ] PostgreSQL database created on Render
- [ ] Web service created and connected to repo
- [ ] Environment variables configured
- [ ] Firebase secret file uploaded (if using)
- [ ] CORS updated with production URLs
- [ ] Health endpoint tested
- [ ] API endpoints tested
- [ ] Database connection verified

---

## ALTERNATIVE: USING DOCKER (Optional)

If you prefer Docker deployment, create `Dockerfile`:

```dockerfile
FROM maven:3.8.5-openjdk-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=build /app/target/smart-parking-backend-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

Then in Render:
- Runtime: **Docker**
- Dockerfile Path: `Dockerfile`

---

## SUMMARY

**Quick Deploy Steps:**

1. Add deployment files (render-build.sh, render-start.sh)
2. Add PostgreSQL to pom.xml
3. Create application-render.properties
4. Push to Git
5. Create PostgreSQL on Render
6. Create Web Service on Render
7. Set environment variables
8. Deploy!

**Your app will be live at:** `https://smart-parking-backend.onrender.com`

🎉 **That's it! Your backend is now deployed!** 🎉

---

## NEXT STEPS

After deployment:
1. Test all endpoints with production URL
2. Update frontend to use production backend URL
3. Deploy frontend (Vercel/Netlify)
4. Set up monitoring (Sentry, LogRocket)
5. Configure custom domain (if needed)

Need help? Check Render's documentation: https://render.com/docs

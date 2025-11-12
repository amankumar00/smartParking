# Render Deployment Checklist (Docker)

Follow these steps to deploy your Smart Parking Backend to Render using Docker.

---

## ✅ STEP 1: Commit & Push Docker Files

```bash
cd /home/hello/Desktop/smartParkingBackend

# Check what's changed
git status

# Add Docker files
git add Dockerfile
git add .dockerignore
git add docker-compose.yml
git add DOCKER_DEPLOYMENT_GUIDE.md

# Add other deployment files (if not already committed)
git add src/main/resources/application-render.properties
git add pom.xml
git add RENDER_DEPLOYMENT_GUIDE.md
git add DEPLOYMENT_CHECKLIST.md

# Commit
git commit -m "Add Docker configuration for Render deployment"

# Push to your repository
git push origin main
```

**Note:** If git push fails with authentication error, you need to configure Git credentials or use SSH. Push manually from your terminal.

---

## ✅ STEP 2: Create Render Account

1. Go to https://render.com
2. Click **Sign Up**
3. Sign up with **GitHub** (easiest) or email
4. Verify your email

---

## ✅ STEP 3: Create PostgreSQL Database

1. In Render Dashboard, click **New +** → **PostgreSQL**
2. Fill in:
   - **Name:** `smartparking-db`
   - **Database:** `smartparking`
   - **User:** `smartparking_user`
   - **Region:** Choose closest to you (e.g., Oregon USA, Frankfurt EU)
   - **PostgreSQL Version:** 15
   - **Plan:** Select **Free**
3. Click **Create Database**
4. **IMPORTANT:** Copy the **Internal Database URL**
   - It looks like: `postgresql://smartparking_user:xxxxx@dpg-xxxxx/smartparking`
   - Save it for Step 4!

---

## ✅ STEP 4: Create Web Service

1. Click **New +** → **Web Service**
2. Click **Connect GitHub** → Select your repository
   - Repository name: `smartParkingBackend` (or your repo name)
3. Configure:

### Basic:
- **Name:** `smart-parking-backend`
- **Region:** Same as database
- **Branch:** `main`
- **Root Directory:** (leave empty)
- **Runtime:** `Docker` ← **IMPORTANT: Select Docker, not Java!**

### Build & Deploy:
When you select Docker, Render automatically:
- Detects your `Dockerfile`
- Builds the Docker image
- Deploys the container

**No build or start commands needed!** Render handles everything automatically.

### Instance:
- **Instance Type:** Select **Free**

---

## ✅ STEP 5: Add Environment Variables

Scroll to **Environment Variables** and add these:

### Required:
| Key | Value |
|-----|-------|
| `SPRING_PROFILES_ACTIVE` | `render` |
| `DATABASE_URL` | Paste the Internal Database URL from Step 3 |
| `PORT` | `8080` |
| `JAVA_OPTS` | `-Xmx512m -Xms256m` |

### Optional (for Firebase):
| Key | Value |
|-----|-------|
| `FIREBASE_CONFIG_FILE` | `/etc/secrets/firebase-service-account.json` |

**Note:** Docker deployment uses these environment variables automatically. The Dockerfile is configured to read them.

---

## ✅ STEP 6: Add Firebase Secret (Optional)

If using Firebase authentication:

1. Go to **Environment** → **Secret Files**
2. Click **Add Secret File**
3. Configure:
   - **Filename:** `firebase-service-account.json`
   - **Contents:** Paste your entire Firebase service account JSON
4. Click **Save**

---

## ✅ STEP 7: Deploy

1. Click **Create Web Service**
2. Render will automatically:
   - Clone your Git repository
   - Detect your `Dockerfile`
   - Build the Docker image (5-10 minutes first time)
   - Start the container
3. Watch the **Logs** tab to see build progress
4. Wait 5-10 minutes for first deployment
5. Look for: `Started SmartParkingApplication in X.XXX seconds`

---

## ✅ STEP 8: Test Your Deployment

Your app will be at: `https://smart-parking-backend.onrender.com`

Test it:
```bash
# Replace with your actual URL
curl https://smart-parking-backend.onrender.com/api/health
```

Expected response:
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

## ✅ STEP 9: Update CORS (Important!)

Your frontend needs to access the backend. Update CORS in your code.

Edit `src/main/java/com/smartparking/config/SecurityConfig.java`:

Find the `corsConfigurationSource()` method and update:

```java
configuration.setAllowedOrigins(Arrays.asList(
    "http://localhost:3000",           // Local React
    "http://localhost:4200",           // Local Angular
    "https://your-frontend.vercel.app", // Add your production frontend URL
    "https://your-frontend.netlify.app" // Or wherever you deploy frontend
));
```

Then commit and push:
```bash
git add src/main/java/com/smartparking/config/SecurityConfig.java
git commit -m "Update CORS for production"
git push origin main
```

Render will auto-redeploy!

---

## 🎯 QUICK REFERENCE

### Your URLs:
- **Backend:** `https://smart-parking-backend.onrender.com`
- **API Base:** `https://smart-parking-backend.onrender.com/api`
- **Health Check:** `https://smart-parking-backend.onrender.com/api/health`

### Important Notes:
- 🐳 Deployed as Docker container (portable and consistent)
- ⏰ Free tier spins down after 15 min inactivity
- 🚀 First request after spin-down takes 30-60 seconds
- 🔄 Auto-deploys on every git push (rebuilds Docker image)
- 💾 Database limited to 1 GB on free tier
- 📦 Docker image size: ~200MB (optimized multi-stage build)

---

## 🔧 TROUBLESHOOTING

### Build fails?
Check **Logs** tab in Render dashboard for error details.

### Can't connect to database?
Verify `DATABASE_URL` environment variable is set correctly.

### App won't start?
Check logs for errors. Common issues:
- Wrong PORT configuration
- Missing environment variables
- Database connection issues

### Firebase not working?
1. Check secret file is uploaded
2. Verify `FIREBASE_CONFIG_FILE` environment variable
3. Check logs for Firebase initialization errors

---

## 📱 CONNECT FRONTEND

In your frontend, use:
```javascript
// API base URL
const API_URL = 'https://smart-parking-backend.onrender.com/api';

// Example: Get parking lots
fetch(`${API_URL}/parking-lots`, {
  headers: {
    'Authorization': `Bearer ${firebaseToken}`
  }
})
```

---

## ✨ YOU'RE DONE!

Your backend is now live and accessible from anywhere! 🎉

**Next Steps:**
1. Deploy your frontend (Vercel/Netlify)
2. Update frontend to use production backend URL
3. Test end-to-end flow
4. Share your app with users!

Need help? Check: https://render.com/docs

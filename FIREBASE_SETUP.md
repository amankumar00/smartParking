# Firebase Integration Setup Guide

This guide will walk you through setting up Firebase Authentication for your Smart Parking Backend.

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or **"Create a project"**
3. Enter project name: `smart-parking` (or any name you prefer)
4. Click **Continue**
5. Disable Google Analytics (optional, can enable later)
6. Click **Create project**
7. Wait for the project to be created, then click **Continue**

## Step 2: Enable Authentication

1. In the Firebase Console, click on **Authentication** in the left sidebar
2. Click **Get started**
3. Go to the **Sign-in method** tab
4. Enable the authentication methods you want:
   - **Email/Password**: Click on it, toggle **Enable**, click **Save**
   - **Google**: (Optional) Click on it, toggle **Enable**, click **Save**
   - **Other providers**: Enable as needed

## Step 3: Generate Service Account Key

1. In Firebase Console, click on the **gear icon** (⚙️) next to **Project Overview**
2. Click **Project settings**
3. Go to the **Service accounts** tab
4. Click **Generate new private key**
5. A dialog will appear, click **Generate key**
6. A JSON file will be downloaded (e.g., `smart-parking-xxxxx-firebase-adminsdk-xxxxx.json`)

## Step 4: Configure Backend

1. **Rename the downloaded JSON file** to `firebase-service-account.json`

2. **Copy the file** to your project's resources folder:
   ```bash
   cp ~/Downloads/firebase-service-account.json /home/hello/Desktop/smartParkingBackend/src/main/resources/
   ```

3. **Important**: Add to `.gitignore` to prevent committing sensitive data:
   ```bash
   echo "src/main/resources/firebase-service-account.json" >> .gitignore
   ```

4. The file should be placed at:
   ```
   smartParkingBackend/
   └── src/
       └── main/
           └── resources/
               └── firebase-service-account.json
   ```

## Step 5: Get Firebase Web Configuration (For Frontend)

1. In Firebase Console, go to **Project settings** (gear icon ⚙️)
2. Scroll down to **Your apps** section
3. Click on the **Web icon** (`</>`) to add a web app
4. Register your app:
   - App nickname: `Smart Parking Web`
   - Check **"Also set up Firebase Hosting"** (optional)
   - Click **Register app**
5. Copy the Firebase configuration object. It will look like:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  authDomain: "smart-parking-xxxxx.firebaseapp.com",
  projectId: "smart-parking-xxxxx",
  storageBucket: "smart-parking-xxxxx.appspot.com",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:web:xxxxxxxxxxxx"
};
```

6. Save this configuration for your frontend application

## Step 6: Test Backend Setup

1. **Rebuild the project**:
   ```bash
   mvn clean package
   ```

2. **Run the application**:
   ```bash
   mvn spring-boot:run
   ```

3. Look for this log message:
   ```
   Firebase has been initialized successfully
   ```

4. **Test health endpoint** (should work without authentication):
   ```bash
   curl http://localhost:8080/api/health
   ```

## Step 7: Test Authentication Flow

### Create a Test User in Firebase Console

1. Go to **Authentication** > **Users** tab
2. Click **Add user**
3. Enter:
   - Email: `test@example.com`
   - Password: `Test123456`
4. Click **Add user**

### Test with Frontend or Postman

Since authentication happens on the frontend (Firebase SDK), you need to:

**Option A: Use Firebase REST API (for testing)**

1. Get your Firebase Web API Key from Project Settings
2. Sign in using Firebase REST API:

```bash
curl -X POST 'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=YOUR_WEB_API_KEY' \
-H 'Content-Type: application/json' \
-d '{
  "email": "test@example.com",
  "password": "Test123456",
  "returnSecureToken": true
}'
```

3. This will return an `idToken`. Use it to test protected endpoints:

```bash
curl http://localhost:8080/api/auth/me \
  -H "Authorization: Bearer YOUR_ID_TOKEN"
```

**Option B: Use a Frontend Application**

Create a simple HTML file for testing:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Firebase Auth Test</title>
    <script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-auth-compat.js"></script>
</head>
<body>
    <h1>Firebase Auth Test</h1>
    <button onclick="signIn()">Sign In</button>
    <button onclick="testAPI()">Test Protected API</button>
    <div id="result"></div>

    <script>
        // Replace with your Firebase config
        const firebaseConfig = {
            apiKey: "YOUR_API_KEY",
            authDomain: "YOUR_AUTH_DOMAIN",
            projectId: "YOUR_PROJECT_ID"
        };

        firebase.initializeApp(firebaseConfig);

        async function signIn() {
            try {
                const result = await firebase.auth().signInWithEmailAndPassword(
                    'test@example.com',
                    'Test123456'
                );
                const token = await result.user.getIdToken();
                document.getElementById('result').innerHTML = 'Token: ' + token;
                localStorage.setItem('token', token);
            } catch (error) {
                console.error(error);
            }
        }

        async function testAPI() {
            const token = localStorage.getItem('token');
            const response = await fetch('http://localhost:8080/api/auth/me', {
                headers: {
                    'Authorization': 'Bearer ' + token
                }
            });
            const data = await response.json();
            document.getElementById('result').innerHTML = JSON.stringify(data, null, 2);
        }
    </script>
</body>
</html>
```

## API Endpoints

### Public Endpoints (No Authentication Required)
- `GET /api/health` - Health check
- `GET /api` - Welcome message
- `POST /api/auth/**` - Authentication endpoints

### Protected Endpoints (Require Firebase Token)
- `GET /api/auth/me` - Get current user info
- `GET /api/auth/user/{uid}` - Get user info by UID
- `POST /api/auth/verify-token` - Verify token validity
- All parking management endpoints
- All employee management endpoints
- All parking lot management endpoints

## How to Use Protected Endpoints

All protected endpoints require the Firebase ID token in the Authorization header:

```bash
curl http://localhost:8080/api/parking-lots \
  -H "Authorization: Bearer YOUR_FIREBASE_ID_TOKEN"
```

## Security Configuration

The backend is configured to:
- ✅ Verify Firebase tokens on every protected request
- ✅ Use stateless sessions (JWT-based)
- ✅ Enable CORS for frontend applications
- ✅ Disable CSRF (since using token-based auth)
- ✅ Allow public access to health and auth endpoints

### CORS Configuration

By default, the following origins are allowed:
- `http://localhost:3000` (React default)
- `http://localhost:4200` (Angular default)

To add more origins, edit [SecurityConfig.java](src/main/java/com/smartparking/config/SecurityConfig.java):

```java
configuration.setAllowedOrigins(Arrays.asList(
    "http://localhost:3000",
    "http://localhost:4200",
    "https://yourdomain.com"  // Add your domain
));
```

## Troubleshooting

### Issue: "Error initializing Firebase"
**Solution**: Make sure `firebase-service-account.json` is in `src/main/resources/`

### Issue: "Invalid or expired token"
**Solution**:
- Make sure the token is valid (tokens expire after 1 hour)
- Refresh the token on the frontend
- Check that the token is from the same Firebase project

### Issue: "403 Forbidden" on protected endpoints
**Solution**:
- Ensure you're sending the token in the Authorization header
- Format: `Authorization: Bearer YOUR_TOKEN`
- Make sure the token is not expired

### Issue: CORS errors
**Solution**: Add your frontend origin to the CORS configuration in `SecurityConfig.java`

## Production Deployment

For production:

1. **Use environment variables** for Firebase config:
   ```bash
   export FIREBASE_CONFIG_FILE=/path/to/firebase-service-account.json
   ```

2. **Update application-prod.properties**:
   ```properties
   firebase.config.file=${FIREBASE_CONFIG_FILE}
   ```

3. **Store service account key securely**:
   - Use secret management (AWS Secrets Manager, Azure Key Vault, etc.)
   - Don't commit to version control
   - Use environment variables or secure file storage

4. **Update CORS origins** to include your production domain

## Next Steps

1. ✅ Integrate Firebase Authentication in your frontend
2. ✅ Implement user registration flow
3. ✅ Add role-based access control (admin, operator, user)
4. ✅ Add Firebase Storage for employee photos
5. ✅ Implement email verification
6. ✅ Add password reset functionality

## Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Firebase Admin SDK for Java](https://firebase.google.com/docs/admin/setup)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Spring Security Documentation](https://spring.io/projects/spring-security)

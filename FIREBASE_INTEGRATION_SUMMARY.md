# Firebase Integration Complete!

Your Smart Parking Backend now has full Firebase Authentication integration. Here's what was added:

## What's Been Integrated

### 1. Dependencies Added ([pom.xml](pom.xml:46-57))
- **Spring Security** - For authentication framework
- **Firebase Admin SDK** - For token verification and user management

### 2. Security Architecture

#### Firebase Configuration ([FirebaseConfig.java](src/main/java/com/smartparking/config/FirebaseConfig.java))
- Initializes Firebase Admin SDK on application startup
- Loads service account credentials from `firebase-service-account.json`
- Gracefully handles missing configuration (app starts even without Firebase setup)

#### Authentication Filter ([FirebaseAuthenticationFilter.java](src/main/java/com/smartparking/security/FirebaseAuthenticationFilter.java))
- Intercepts all HTTP requests
- Extracts Firebase token from `Authorization: Bearer <token>` header
- Verifies token with Firebase
- Sets Spring Security authentication context

#### Security Configuration ([SecurityConfig.java](src/main/java/com/smartparking/config/SecurityConfig.java))
- **Public endpoints** (no auth required):
  - `/api/health`
  - `/api`
  - `/h2-console/**`
  - `/api/auth/**`
- **Protected endpoints** (require Firebase token):
  - All parking management APIs
  - All employee APIs
  - All parking lot APIs
- **CORS enabled** for:
  - `http://localhost:3000` (React)
  - `http://localhost:4200` (Angular)

### 3. Authentication Services

#### Auth Service ([AuthService.java](src/main/java/com/smartparking/service/AuthService.java))
- Get user info from Firebase by UID
- Get current authenticated user
- Maps Firebase users to your DTOs

#### Auth Controller ([AuthController.java](src/main/java/com/smartparking/controller/AuthController.java))
New endpoints:
- `GET /api/auth/me` - Get current user info
- `GET /api/auth/user/{uid}` - Get user by UID
- `POST /api/auth/verify-token` - Verify token validity

### 4. DTOs Created

- **AuthRequest** - Login credentials
- **AuthResponse** - Auth response with tokens
- **UserInfoResponse** - User profile information

### 5. Configuration Files

- [application.properties](src/main/resources/application.properties:29-30) - Firebase config path
- [.gitignore](..gitignore:41-42) - Prevents committing sensitive Firebase credentials
- Template file for service account JSON

## How It Works

```
┌─────────────────┐
│   Frontend      │
│  (React/Web)    │
└────────┬────────┘
         │ 1. User signs in with Firebase
         │    (email/password or Google)
         ↓
┌─────────────────┐
│  Firebase Auth  │ → Returns ID Token
└────────┬────────┘
         │ 2. Send request with token
         │    Authorization: Bearer <token>
         ↓
┌─────────────────┐
│ Your Backend    │
│ (Spring Boot)   │
└────────┬────────┘
         │ 3. Verify token with Firebase
         ↓
┌─────────────────┐
│ Firebase Admin  │ → Token valid ✓
└────────┬────────┘
         │ 4. Allow access to protected API
         ↓
┌─────────────────┐
│  Response       │
│  (JSON data)    │
└─────────────────┘
```

## Next Steps

### Step 1: Set Up Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project: `smart-parking`
3. Enable Authentication (Email/Password, Google, etc.)
4. Generate Service Account Key:
   - Project Settings → Service Accounts → Generate Private Key
5. Download the JSON file

### Step 2: Configure Your Backend

1. Rename downloaded file to `firebase-service-account.json`
2. Place it in `src/main/resources/`
   ```bash
   cp ~/Downloads/smart-parking-xxxxx.json src/main/resources/firebase-service-account.json
   ```

### Step 3: Run Your Application

```bash
mvn clean package
mvn spring-boot:run
```

Look for: `Firebase has been initialized successfully`

### Step 4: Test Authentication

**Public endpoint (no auth):**
```bash
curl http://localhost:8080/api/health
```

**Protected endpoint (requires auth):**
```bash
# This will fail with 401 Unauthorized
curl http://localhost:8080/api/parking-lots

# This will work with valid Firebase token
curl http://localhost:8080/api/parking-lots \
  -H "Authorization: Bearer YOUR_FIREBASE_TOKEN"
```

### Step 5: Frontend Integration

In your React/Angular app:

```javascript
// Initialize Firebase
import { initializeApp } from 'firebase/app';
import { getAuth, signInWithEmailAndPassword } from 'firebase/auth';

const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "smart-parking-xxxxx.firebaseapp.com",
  // ... other config
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);

// Sign in
async function login(email, password) {
  const userCredential = await signInWithEmailAndPassword(auth, email, password);
  const token = await userCredential.user.getIdToken();

  // Use this token for API calls
  const response = await fetch('http://localhost:8080/api/parking-lots', {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });

  return response.json();
}
```

## API Security

### Before Firebase:
```bash
# Anyone could access this
curl http://localhost:8080/api/parking-lots
# Returns: All parking lots
```

### After Firebase:
```bash
# Without token
curl http://localhost:8080/api/parking-lots
# Returns: 401 Unauthorized

# With valid token
curl http://localhost:8080/api/parking-lots \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
# Returns: All parking lots (authenticated)
```

## Project Structure (Updated)

```
smartParkingBackend/
├── src/main/java/com/smartparking/
│   ├── config/
│   │   ├── FirebaseConfig.java          ← Firebase initialization
│   │   └── SecurityConfig.java          ← Security rules
│   ├── security/
│   │   └── FirebaseAuthenticationFilter.java ← Token verification
│   ├── controller/
│   │   └── AuthController.java          ← Auth endpoints
│   ├── service/
│   │   ├── AuthService.java
│   │   └── impl/
│   │       └── AuthServiceImpl.java
│   └── dto/
│       ├── request/
│       │   └── AuthRequest.java
│       └── response/
│           ├── AuthResponse.java
│           └── UserInfoResponse.java
└── src/main/resources/
    ├── application.properties
    └── firebase-service-account.json    ← YOU NEED TO ADD THIS
```

## Important Files

1. **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)** - Complete setup guide
2. **[SecurityConfig.java](src/main/java/com/smartparking/config/SecurityConfig.java)** - Configure which endpoints require auth
3. **[FirebaseConfig.java](src/main/java/com/smartparking/config/FirebaseConfig.java)** - Firebase initialization

## Testing Checklist

- [ ] Firebase project created
- [ ] Service account key downloaded and placed in resources/
- [ ] Application starts without errors
- [ ] See "Firebase has been initialized successfully" in logs
- [ ] Public endpoints work without auth
- [ ] Protected endpoints return 401 without token
- [ ] Protected endpoints work with valid Firebase token

## Common Issues & Solutions

### Issue: "Error initializing Firebase"
**Solution:** Make sure `firebase-service-account.json` is in `src/main/resources/`

### Issue: "Invalid or expired token"
**Solution:**
- Tokens expire after 1 hour - refresh them
- Make sure token is from the correct Firebase project

### Issue: 403 Forbidden
**Solution:** Check the `Authorization` header format: `Bearer <token>`

### Issue: CORS errors from frontend
**Solution:** Add your frontend URL to `SecurityConfig.java`:
```java
configuration.setAllowedOrigins(Arrays.asList(
    "http://localhost:3000",  // React
    "http://localhost:4200",  // Angular
    "https://yourdomain.com"  // Your domain
));
```

## Key Benefits

✅ **Secure** - Industry-standard JWT token authentication
✅ **Scalable** - Firebase handles millions of users
✅ **Easy** - No password management on your backend
✅ **Flexible** - Support email, Google, Facebook, etc.
✅ **Free tier** - 50,000 MAU (Monthly Active Users) free

## Documentation

- Complete setup guide: [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
- Firebase Docs: https://firebase.google.com/docs/auth
- Spring Security: https://spring.io/projects/spring-security

## Your Next Actions

1. **Now:** Read [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed setup
2. **Create:** Firebase project and download service account key
3. **Place:** `firebase-service-account.json` in `src/main/resources/`
4. **Run:** `mvn spring-boot:run`
5. **Test:** APIs with Postman or your frontend

Need help? Check [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for troubleshooting!

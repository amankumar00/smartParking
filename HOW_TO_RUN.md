# How to Run Smart Parking Backend

Complete guide to running your Spring Boot application.

---

## PREREQUISITES

Before running the project, make sure you have:

### ✅ Required:
1. **Java 17** (or higher)
   ```bash
   java -version
   # Should show: openjdk version "17.x.x" or higher
   ```

2. **Maven 3.6+**
   ```bash
   mvn -version
   # Should show: Apache Maven 3.6.x or higher
   ```

### ⚠️ Optional (for Firebase):
3. **Firebase Service Account Key**
   - Only needed if you want to use authentication
   - See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for setup instructions

---

## QUICK START (Without Firebase)

The application will run fine without Firebase - authentication will just be disabled.

### Option 1: Using Maven (Recommended for Development)

```bash
# Navigate to project directory
cd /home/hello/Desktop/smartParkingBackend

# Run the application
mvn spring-boot:run
```

### Option 2: Build and Run JAR

```bash
# Build the project
mvn clean package

# Run the JAR file
java -jar target/smart-parking-backend-1.0.0.jar
```

### Option 3: Using Maven Wrapper (if available)

```bash
# On Linux/Mac
./mvnw spring-boot:run

# On Windows
mvnw.cmd spring-boot:run
```

---

## STEP-BY-STEP GUIDE

### Step 1: Verify Java Installation

```bash
java -version
```

**Expected Output:**
```
openjdk version "17.0.x" 2024-xx-xx
OpenJDK Runtime Environment (build 17.0.x+x)
OpenJDK 64-Bit Server VM (build 17.0.x+x, mixed mode, sharing)
```

**If you see Java 8 or lower:**
```bash
# Install Java 17
sudo apt update
sudo apt install openjdk-17-jdk

# Set Java 17 as default
sudo update-alternatives --config java
# Select Java 17 from the list
```

---

### Step 2: Navigate to Project Directory

```bash
cd /home/hello/Desktop/smartParkingBackend
```

---

### Step 3: Clean and Build the Project

```bash
# Clean previous builds and compile
mvn clean compile

# Or build everything including tests
mvn clean package
```

**Expected Output:**
```
[INFO] BUILD SUCCESS
[INFO] Total time: xx.xxx s
```

---

### Step 4: Run the Application

```bash
mvn spring-boot:run
```

**What You'll See:**

```
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v3.2.0)

2024-11-06 19:xx:xx.xxx  INFO xxxxx --- [main] c.s.SmartParkingApplication : Starting SmartParkingApplication
2024-11-06 19:xx:xx.xxx  INFO xxxxx --- [main] c.s.SmartParkingApplication : No active profile set, falling back to default profiles: default
2024-11-06 19:xx:xx.xxx  INFO xxxxx --- [main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat initialized with port(s): 8080 (http)
...
2024-11-06 19:xx:xx.xxx  INFO xxxxx --- [main] c.s.config.FirebaseConfig : Error initializing Firebase (this is OK if you haven't set up Firebase yet)
...
2024-11-06 19:xx:xx.xxx  INFO xxxxx --- [main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port(s): 8080 (http)
2024-11-06 19:xx:xx.xxx  INFO xxxxx --- [main] c.s.SmartParkingApplication : Started SmartParkingApplication in x.xxx seconds
```

**✅ Application is ready when you see:** `Started SmartParkingApplication`

---

### Step 5: Test the Application

Open a new terminal and test:

```bash
# Test health endpoint
curl http://localhost:8080/api/health
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Service is running",
  "data": {
    "status": "UP",
    "timestamp": "2024-11-06T14:30:00",
    "service": "Smart Parking Backend",
    "version": "1.0.0"
  }
}
```

**✅ If you see this, your application is running successfully!**

---

## RUNNING WITH FIREBASE (Full Authentication)

### Step 1: Set Up Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a project: "smart-parking"
3. Enable Authentication (Email/Password)
4. Download Service Account Key:
   - Project Settings → Service Accounts → Generate Private Key

### Step 2: Add Firebase Credentials

```bash
# Rename and copy the downloaded JSON file
cp ~/Downloads/smart-parking-xxxxx-firebase-adminsdk-xxxxx.json \
   src/main/resources/firebase-service-account.json
```

### Step 3: Run the Application

```bash
mvn spring-boot:run
```

**Look for this log:**
```
2024-11-06 19:xx:xx.xxx  INFO xxxxx --- [main] c.s.config.FirebaseConfig : Firebase has been initialized successfully
```

**✅ Firebase is now active!**

---

## ACCESS THE APPLICATION

### URLs:

- **API Base:** http://localhost:8080/api
- **Health Check:** http://localhost:8080/api/health
- **H2 Database Console:** http://localhost:8080/h2-console

### H2 Console Login:

```
JDBC URL: jdbc:h2:mem:smartparking
Username: sa
Password: (leave empty)
```

---

## TESTING THE APIS

### 1. Test Public Endpoints (No Authentication)

```bash
# Health check
curl http://localhost:8080/api/health

# Welcome message
curl http://localhost:8080/api
```

---

### 2. Create a Parking Lot

```bash
curl -X POST http://localhost:8080/api/parking-lots \
  -H "Content-Type: application/json" \
  -d '{
    "name": "City Center Parking",
    "address": "123 Main Street",
    "totalFloors": 3
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Parking lot created successfully",
  "data": {
    "parkingLotId": "550e8400-e29b-41d4-a716-446655440000",
    "name": "City Center Parking",
    "address": "123 Main Street",
    "totalFloors": 3,
    "floors": []
  }
}
```

**💡 Save the `parkingLotId` for next steps!**

---

### 3. Add a Floor with Slots

Replace `<PARKING_LOT_ID>` with the ID from previous step:

```bash
curl -X POST http://localhost:8080/api/parking-lots/floors \
  -H "Content-Type: application/json" \
  -d '{
    "floorNo": 1,
    "parkingLotId": "<PARKING_LOT_ID>",
    "slotConfiguration": {
      "TWO_WHEELER": 20,
      "FOUR_WHEELER": 15,
      "HEAVY_VEHICLE": 5
    }
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Floor added successfully",
  "data": {
    "floorId": "abc123...",
    "floorNo": 1,
    "totalSlots": 40,
    "allottedSlots": 0,
    "availableSlots": 40,
    "slots": [...]
  }
}
```

---

### 4. Park a Vehicle

```bash
curl -X POST http://localhost:8080/api/parking/entry \
  -H "Content-Type: application/json" \
  -d '{
    "vehicleType": "FOUR_WHEELER",
    "vehicleRegistration": "KA01AB1234"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Vehicle parked successfully",
  "data": {
    "vehicleId": "xyz789...",
    "vehicleType": "FOUR_WHEELER",
    "vehicleRegistration": "KA01AB1234",
    "timeIn": "2024-11-06T14:30:00",
    "status": "PARKED",
    "assignedSlotId": "slot-abc..."
  }
}
```

---

### 5. Exit Vehicle (Generate Bill)

```bash
curl -X POST http://localhost:8080/api/parking/exit/KA01AB1234
```

**Response:**
```json
{
  "success": true,
  "message": "Vehicle exited successfully. Bill generated.",
  "data": {
    "vehicleId": "xyz789...",
    "vehicleRegistration": "KA01AB1234",
    "timeIn": "2024-11-06T14:30:00",
    "timeOut": "2024-11-06T16:45:00",
    "status": "EXITED",
    "billAmt": 40.0
  }
}
```

**💰 Bill calculated: 2.25 hours = 3 hours (rounded up) × ₹20/hour = ₹60**

---

### 6. Create an Employee

```bash
curl -X POST http://localhost:8080/api/employees \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john.doe@example.com",
    "phNo": "+919876543210",
    "dob": "1990-01-01",
    "gender": "MALE",
    "address": "123 Street, City",
    "roles": "OPERATOR"
  }'
```

---

## COMPLETE TEST SCRIPT

Save this as `test-parking.sh`:

```bash
#!/bin/bash

echo "=== Smart Parking Backend - Full Test ==="

BASE_URL="http://localhost:8080/api"

echo -e "\n1. Health Check"
curl -s $BASE_URL/health | jq

echo -e "\n2. Creating Parking Lot"
PARKING_LOT=$(curl -s -X POST $BASE_URL/parking-lots \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Parking","address":"Test St","totalFloors":2}')
echo $PARKING_LOT | jq
PARKING_LOT_ID=$(echo $PARKING_LOT | jq -r '.data.parkingLotId')
echo "Parking Lot ID: $PARKING_LOT_ID"

echo -e "\n3. Adding Floor with Slots"
curl -s -X POST $BASE_URL/parking-lots/floors \
  -H "Content-Type: application/json" \
  -d "{\"floorNo\":1,\"parkingLotId\":\"$PARKING_LOT_ID\",\"slotConfiguration\":{\"TWO_WHEELER\":10,\"FOUR_WHEELER\":5,\"HEAVY_VEHICLE\":2}}" | jq

echo -e "\n4. Parking Vehicle"
curl -s -X POST $BASE_URL/parking/entry \
  -H "Content-Type: application/json" \
  -d '{"vehicleType":"FOUR_WHEELER","vehicleRegistration":"TEST123"}' | jq

echo -e "\n5. Waiting 5 seconds..."
sleep 5

echo -e "\n6. Exiting Vehicle (Generating Bill)"
curl -s -X POST $BASE_URL/parking/exit/TEST123 | jq

echo -e "\n7. Creating Employee"
curl -s -X POST $BASE_URL/employees \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","phNo":"+919999999999","dob":"1990-01-01","gender":"MALE","address":"Test Address","roles":"OPERATOR"}' | jq

echo -e "\n=== Test Complete ==="
```

**Run the script:**
```bash
chmod +x test-parking.sh
./test-parking.sh
```

---

## STOPPING THE APPLICATION

### If running with `mvn spring-boot:run`:
Press `Ctrl + C` in the terminal

### If running as JAR:
```bash
# Find the process
ps aux | grep smart-parking-backend

# Kill the process
kill <PID>
```

---

## COMMON ISSUES & SOLUTIONS

### Issue 1: Port 8080 Already in Use

**Error:**
```
***************************
APPLICATION FAILED TO START
***************************

Description:
Web server failed to start. Port 8080 was already in use.
```

**Solution:**
```bash
# Find what's using port 8080
sudo lsof -i :8080

# Kill the process
sudo kill -9 <PID>

# Or change the port in application.properties
server.port=8081
```

---

### Issue 2: Java Version Error

**Error:**
```
Fatal error compiling: invalid flag: --release
```

**Solution:**
```bash
# Check Java version
java -version

# If Java 8, install Java 17
sudo apt install openjdk-17-jdk

# Set as default
sudo update-alternatives --config java
```

---

### Issue 3: Maven Not Found

**Error:**
```
mvn: command not found
```

**Solution:**
```bash
# Install Maven
sudo apt update
sudo apt install maven

# Verify installation
mvn -version
```

---

### Issue 4: Build Failures

**Solution:**
```bash
# Clean everything and rebuild
mvn clean install -U

# Skip tests if needed
mvn clean package -DskipTests
```

---

### Issue 5: H2 Console Not Accessible

**Solution:**
Make sure you're accessing: http://localhost:8080/h2-console (not /h2)

Use these credentials:
- JDBC URL: `jdbc:h2:mem:smartparking`
- Username: `sa`
- Password: (empty)

---

### Issue 6: Firebase Initialization Error

**This is OK!** The app runs fine without Firebase. Authentication features just won't work.

**To fix (optional):**
1. Follow [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
2. Add `firebase-service-account.json` to `src/main/resources/`

---

## DIFFERENT RUN MODES

### Development Mode (with auto-reload)
```bash
mvn spring-boot:run
```
Changes to Java files require restart, but resources reload automatically.

### Production Mode (optimized)
```bash
# Build optimized JAR
mvn clean package -Pprod

# Run with production profile
java -jar target/smart-parking-backend-1.0.0.jar --spring.profiles.active=prod
```

### Debug Mode
```bash
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
```
Then attach your IDE debugger to port 5005.

---

## CHECKING LOGS

### View Application Logs:
Logs appear in the terminal where you ran `mvn spring-boot:run`

### Log Levels (configured in application.properties):
- Application: `DEBUG`
- Spring: `INFO`
- Hibernate SQL: `DEBUG`

### To change log level:
Edit `src/main/resources/application.properties`:
```properties
logging.level.com.smartparking=INFO  # Change DEBUG to INFO
```

---

## RUNNING IN BACKGROUND

```bash
# Run in background
nohup mvn spring-boot:run > app.log 2>&1 &

# View logs
tail -f app.log

# Stop the application
pkill -f "spring-boot:run"
```

---

## USING AN IDE

### IntelliJ IDEA:
1. Open project folder
2. Wait for Maven import to complete
3. Right-click on `SmartParkingApplication.java`
4. Select "Run 'SmartParkingApplication'"

### Eclipse:
1. File → Import → Existing Maven Projects
2. Select project folder
3. Right-click on `SmartParkingApplication.java`
4. Run As → Java Application

### VS Code:
1. Open project folder
2. Install "Extension Pack for Java"
3. Press F5 or click Run

---

## NEXT STEPS

1. ✅ **Application Running** - You're here!
2. 📚 **Test APIs** - Use the test script above
3. 🔐 **Add Firebase** - Follow [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
4. 🗄️ **Switch to MySQL** - For production (see below)
5. 🚀 **Deploy** - To server/cloud

---

## SWITCHING TO MYSQL (Production)

### Step 1: Install MySQL
```bash
sudo apt install mysql-server
sudo mysql_secure_installation
```

### Step 2: Create Database
```sql
CREATE DATABASE smart_parking;
CREATE USER 'parking_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON smart_parking.* TO 'parking_user'@'localhost';
FLUSH PRIVILEGES;
```

### Step 3: Update Configuration
Edit `src/main/resources/application-prod.properties`:
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/smart_parking
spring.datasource.username=parking_user
spring.datasource.password=your_password
```

### Step 4: Run with Production Profile
```bash
mvn spring-boot:run -Dspring-boot.run.profiles=prod
```

---

## MONITORING THE APPLICATION

### Check if running:
```bash
curl http://localhost:8080/api/health
```

### Monitor database:
http://localhost:8080/h2-console

### Check logs:
Terminal output shows all activity

---

## USEFUL MAVEN COMMANDS

```bash
# Clean build
mvn clean

# Compile only
mvn compile

# Run tests
mvn test

# Package JAR
mvn package

# Install to local repository
mvn install

# Run application
mvn spring-boot:run

# Skip tests
mvn clean package -DskipTests

# Update dependencies
mvn clean install -U
```

---

## SUMMARY

**Quick Start:**
```bash
cd /home/hello/Desktop/smartParkingBackend
mvn spring-boot:run
```

**Test:**
```bash
curl http://localhost:8080/api/health
```

**Stop:**
Press `Ctrl + C`

That's it! Your Smart Parking Backend is now running! 🚀

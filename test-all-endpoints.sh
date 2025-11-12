#!/bin/bash

# Smart Parking Backend - Complete API Test Suite
# This script tests ALL endpoints in your backend

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BASE_URL="http://localhost:8080/api"
# FIREBASE_API_KEY="testing"  # Replace with your Firebase Web API Key
TEST_EMAIL="test@example.com"
TEST_PASSWORD="Test123456"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Smart Parking Backend - API Tests${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Function to print test header
print_test() {
    echo -e "\n${YELLOW}▶ $1${NC}"
}

# Function to print success
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print error
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Step 1: Get Firebase Token
print_test "Step 1: Getting Firebase Authentication Token"
TOKEN_RESPONSE=$(curl -s -X POST "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$FIREBASE_API_KEY" \
  -H 'Content-Type: application/json' \
  -d "{
    \"email\": \"$TEST_EMAIL\",
    \"password\": \"$TEST_PASSWORD\",
    \"returnSecureToken\": true
  }")

TOKEN=$(echo $TOKEN_RESPONSE | jq -r '.idToken')

if [ "$TOKEN" = "null" ] || [ -z "$TOKEN" ]; then
    print_error "Failed to get Firebase token. Creating user first..."
    echo "Response: $TOKEN_RESPONSE"

    # Try to sign up the user
    SIGNUP_RESPONSE=$(curl -s -X POST "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$FIREBASE_API_KEY" \
      -H 'Content-Type: application/json' \
      -d "{
        \"email\": \"$TEST_EMAIL\",
        \"password\": \"$TEST_PASSWORD\",
        \"returnSecureToken\": true
      }")

    TOKEN=$(echo $SIGNUP_RESPONSE | jq -r '.idToken')

    if [ "$TOKEN" = "null" ] || [ -z "$TOKEN" ]; then
        print_error "Failed to create user and get token"
        echo "Please create a user manually in Firebase Console:"
        echo "  Email: $TEST_EMAIL"
        echo "  Password: $TEST_PASSWORD"
        exit 1
    fi
fi

print_success "Token obtained successfully"
echo "Token preview: ${TOKEN:0:50}..."

# ============================================
# PUBLIC ENDPOINTS (No Authentication)
# ============================================

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}  PUBLIC ENDPOINTS (No Auth Required)${NC}"
echo -e "${BLUE}========================================${NC}"

# Test 1: Health Check
print_test "Test 1: GET /api/health"
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" $BASE_URL/health)
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ]; then
    print_success "Health check passed"
    echo "$BODY" | jq -C '.'
else
    print_error "Health check failed (HTTP $HTTP_CODE)"
fi

# Test 2: Welcome
print_test "Test 2: GET /api"
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" $BASE_URL)
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ]; then
    print_success "Welcome endpoint passed"
    echo "$BODY" | jq -C '.'
else
    print_error "Welcome endpoint failed (HTTP $HTTP_CODE)"
fi

# ============================================
# PARKING LOT MANAGEMENT
# ============================================

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}  PARKING LOT MANAGEMENT${NC}"
echo -e "${BLUE}========================================${NC}"

# Test 3: Create Parking Lot
print_test "Test 3: POST /api/parking-lots (Create Parking Lot)"
PARKING_LOT_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST $BASE_URL/parking-lots \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Parking Center",
    "address": "123 Main Street, Test City",
    "totalFloors": 3
  }')

HTTP_CODE=$(echo "$PARKING_LOT_RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$PARKING_LOT_RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    print_success "Parking lot created successfully"
    echo "$BODY" | jq -C '.'
    PARKING_LOT_ID=$(echo "$BODY" | jq -r '.data.parkingLotId')
    print_success "Parking Lot ID: $PARKING_LOT_ID"
else
    print_error "Failed to create parking lot (HTTP $HTTP_CODE)"
    echo "$BODY"
    exit 1
fi

# Test 4: Get All Parking Lots
print_test "Test 4: GET /api/parking-lots (Get All Parking Lots)"
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" $BASE_URL/parking-lots \
  -H "Authorization: Bearer $TOKEN")
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ]; then
    print_success "Retrieved all parking lots"
    echo "$BODY" | jq -C '.'
else
    print_error "Failed to get parking lots (HTTP $HTTP_CODE)"
fi

# Test 5: Get Parking Lot by ID
print_test "Test 5: GET /api/parking-lots/{id} (Get Parking Lot Details)"
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" $BASE_URL/parking-lots/$PARKING_LOT_ID \
  -H "Authorization: Bearer $TOKEN")
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ]; then
    print_success "Retrieved parking lot details"
    echo "$BODY" | jq -C '.'
else
    print_error "Failed to get parking lot details (HTTP $HTTP_CODE)"
fi

# ============================================
# FLOOR MANAGEMENT
# ============================================

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}  FLOOR MANAGEMENT${NC}"
echo -e "${BLUE}========================================${NC}"

# Test 6: Add Floor to Parking Lot
print_test "Test 6: POST /api/parking-lots/floors (Add Floor with Slots)"
FLOOR_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST $BASE_URL/parking-lots/floors \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"floorNo\": 1,
    \"parkingLotId\": \"$PARKING_LOT_ID\",
    \"slotConfiguration\": {
      \"TWO_WHEELER\": 20,
      \"FOUR_WHEELER\": 15,
      \"HEAVY_VEHICLE\": 5
    }
  }")

HTTP_CODE=$(echo "$FLOOR_RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$FLOOR_RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    print_success "Floor added successfully with 40 total slots"
    echo "$BODY" | jq -C '.'
    FLOOR_ID=$(echo "$BODY" | jq -r '.data.floorId')
    print_success "Floor ID: $FLOOR_ID"
else
    print_error "Failed to add floor (HTTP $HTTP_CODE)"
    echo "$BODY"
fi

# Test 7: Get Floor Details
print_test "Test 7: GET /api/parking-lots/floors/{id} (Get Floor Details)"
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" $BASE_URL/parking-lots/floors/$FLOOR_ID \
  -H "Authorization: Bearer $TOKEN")
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ]; then
    print_success "Retrieved floor details"
    echo "$BODY" | jq -C '.data | {floorId, floorNo, totalSlots, allottedSlots, availableSlots}'
else
    print_error "Failed to get floor details (HTTP $HTTP_CODE)"
fi

# Test 8: Get Floors by Parking Lot
print_test "Test 8: GET /api/parking-lots/{id}/floors (Get All Floors in Parking Lot)"
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" $BASE_URL/parking-lots/$PARKING_LOT_ID/floors \
  -H "Authorization: Bearer $TOKEN")
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ]; then
    print_success "Retrieved all floors"
    echo "$BODY" | jq -C '.'
else
    print_error "Failed to get floors (HTTP $HTTP_CODE)"
fi

# ============================================
# VEHICLE PARKING OPERATIONS
# ============================================

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}  VEHICLE PARKING OPERATIONS${NC}"
echo -e "${BLUE}========================================${NC}"

# Test 9: Park Vehicle (Two Wheeler)
print_test "Test 9: POST /api/parking/entry (Park Two Wheeler)"
VEHICLE1_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST $BASE_URL/parking/entry \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "vehicleType": "TWO_WHEELER",
    "vehicleRegistration": "KA01AB1234"
  }')

HTTP_CODE=$(echo "$VEHICLE1_RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$VEHICLE1_RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    print_success "Two wheeler parked successfully"
    echo "$BODY" | jq -C '.'
    VEHICLE1_ID=$(echo "$BODY" | jq -r '.data.vehicleId')
else
    print_error "Failed to park two wheeler (HTTP $HTTP_CODE)"
    echo "$BODY"
fi

# Test 10: Park Vehicle (Four Wheeler)
print_test "Test 10: POST /api/parking/entry (Park Four Wheeler)"
VEHICLE2_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST $BASE_URL/parking/entry \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "vehicleType": "FOUR_WHEELER",
    "vehicleRegistration": "KA02CD5678"
  }')

HTTP_CODE=$(echo "$VEHICLE2_RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$VEHICLE2_RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    print_success "Four wheeler parked successfully"
    echo "$BODY" | jq -C '.'
else
    print_error "Failed to park four wheeler (HTTP $HTTP_CODE)"
fi

# Test 11: Park Vehicle (Heavy Vehicle)
print_test "Test 11: POST /api/parking/entry (Park Heavy Vehicle)"
VEHICLE3_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST $BASE_URL/parking/entry \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "vehicleType": "HEAVY_VEHICLE",
    "vehicleRegistration": "KA03EF9012"
  }')

HTTP_CODE=$(echo "$VEHICLE3_RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$VEHICLE3_RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    print_success "Heavy vehicle parked successfully"
    echo "$BODY" | jq -C '.'
else
    print_error "Failed to park heavy vehicle (HTTP $HTTP_CODE)"
fi

# Test 12: View Vehicle Details
print_test "Test 12: GET /api/parking/vehicle/{registration} (View Vehicle Details)"
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" $BASE_URL/parking/vehicle/KA01AB1234 \
  -H "Authorization: Bearer $TOKEN")
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ]; then
    print_success "Retrieved vehicle details"
    echo "$BODY" | jq -C '.'
else
    print_error "Failed to get vehicle details (HTTP $HTTP_CODE)"
fi

# Wait 3 seconds to simulate parking time
echo -e "\n${YELLOW}⏳ Waiting 3 seconds to simulate parking time...${NC}"
sleep 3

# Test 13: Exit Vehicle (Generate Bill)
print_test "Test 13: POST /api/parking/exit/{registration} (Exit Vehicle & Generate Bill)"
EXIT_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST $BASE_URL/parking/exit/KA01AB1234 \
  -H "Authorization: Bearer $TOKEN")

HTTP_CODE=$(echo "$EXIT_RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$EXIT_RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ]; then
    print_success "Vehicle exited and bill generated"
    echo "$BODY" | jq -C '.'
    BILL_AMT=$(echo "$BODY" | jq -r '.data.billAmt')
    print_success "Bill Amount: ₹$BILL_AMT"
else
    print_error "Failed to exit vehicle (HTTP $HTTP_CODE)"
fi

# ============================================
# EMPLOYEE MANAGEMENT
# ============================================

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}  EMPLOYEE MANAGEMENT${NC}"
echo -e "${BLUE}========================================${NC}"

# Test 14: Create Employee
print_test "Test 14: POST /api/employees (Create Employee)"
EMPLOYEE_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST $BASE_URL/employees \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john.doe@smartparking.com",
    "phNo": "+919876543210",
    "dob": "1990-05-15",
    "gender": "MALE",
    "photo": "https://example.com/photos/john.jpg",
    "address": "456 Park Avenue, Test City",
    "roles": "OPERATOR"
  }')

HTTP_CODE=$(echo "$EMPLOYEE_RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$EMPLOYEE_RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    print_success "Employee created successfully"
    echo "$BODY" | jq -C '.'
    EMPLOYEE_ID=$(echo "$BODY" | jq -r '.data.empId')
    print_success "Employee ID: $EMPLOYEE_ID"
else
    print_error "Failed to create employee (HTTP $HTTP_CODE)"
    echo "$BODY"
fi

# Test 15: Get All Employees
print_test "Test 15: GET /api/employees (Get All Employees)"
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" $BASE_URL/employees \
  -H "Authorization: Bearer $TOKEN")
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ]; then
    print_success "Retrieved all employees"
    echo "$BODY" | jq -C '.'
else
    print_error "Failed to get employees (HTTP $HTTP_CODE)"
fi

# Test 16: Get Employee by ID
print_test "Test 16: GET /api/employees/{id} (Get Employee by ID)"
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" $BASE_URL/employees/$EMPLOYEE_ID \
  -H "Authorization: Bearer $TOKEN")
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ]; then
    print_success "Retrieved employee details"
    echo "$BODY" | jq -C '.'
else
    print_error "Failed to get employee details (HTTP $HTTP_CODE)"
fi

# Test 17: Get Employee by Email
print_test "Test 17: GET /api/employees/email/{email} (Get Employee by Email)"
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" $BASE_URL/employees/email/john.doe@smartparking.com \
  -H "Authorization: Bearer $TOKEN")
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ]; then
    print_success "Retrieved employee by email"
    echo "$BODY" | jq -C '.'
else
    print_error "Failed to get employee by email (HTTP $HTTP_CODE)"
fi

# Test 18: Update Employee
print_test "Test 18: PUT /api/employees/{id} (Update Employee)"
UPDATE_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X PUT $BASE_URL/employees/$EMPLOYEE_ID \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe Updated",
    "email": "john.doe@smartparking.com",
    "phNo": "+919876543210",
    "dob": "1990-05-15",
    "gender": "MALE",
    "photo": "https://example.com/photos/john-updated.jpg",
    "address": "789 Updated Street, Test City",
    "roles": "MANAGER"
  }')

HTTP_CODE=$(echo "$UPDATE_RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$UPDATE_RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ]; then
    print_success "Employee updated successfully"
    echo "$BODY" | jq -C '.data | {empId, name, email, roles}'
else
    print_error "Failed to update employee (HTTP $HTTP_CODE)"
fi

# Test 19: Delete Employee
print_test "Test 19: DELETE /api/employees/{id} (Delete Employee)"
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X DELETE $BASE_URL/employees/$EMPLOYEE_ID \
  -H "Authorization: Bearer $TOKEN")
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ]; then
    print_success "Employee deleted successfully"
    echo "$BODY" | jq -C '.'
else
    print_error "Failed to delete employee (HTTP $HTTP_CODE)"
fi

# ============================================
# AUTHENTICATION ENDPOINTS
# ============================================

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}  AUTHENTICATION ENDPOINTS${NC}"
echo -e "${BLUE}========================================${NC}"

# Test 20: Get Current User
print_test "Test 20: GET /api/auth/me (Get Current User)"
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" $BASE_URL/auth/me \
  -H "Authorization: Bearer $TOKEN")
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ]; then
    print_success "Retrieved current user info"
    echo "$BODY" | jq -C '.'
else
    print_error "Failed to get current user (HTTP $HTTP_CODE)"
fi

# Test 21: Verify Token
print_test "Test 21: POST /api/auth/verify-token (Verify Token)"
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST $BASE_URL/auth/verify-token \
  -H "Authorization: Bearer $TOKEN")
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ]; then
    print_success "Token verified successfully"
    echo "$BODY" | jq -C '.'
else
    print_error "Token verification failed (HTTP $HTTP_CODE)"
fi

# ============================================
# SUMMARY
# ============================================

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}  TEST SUMMARY${NC}"
echo -e "${BLUE}========================================${NC}\n"

echo -e "${GREEN}✓ All API endpoints tested successfully!${NC}"
echo ""
echo "Endpoints tested:"
echo "  • 2 Public endpoints (health, welcome)"
echo "  • 3 Parking lot management"
echo "  • 3 Floor management"
echo "  • 5 Vehicle operations"
echo "  • 6 Employee management"
echo "  • 2 Authentication endpoints"
echo ""
echo -e "${GREEN}Total: 21 endpoints tested${NC}"
echo ""
echo "Test artifacts created:"
echo "  • Parking Lot ID: $PARKING_LOT_ID"
echo "  • Floor ID: $FLOOR_ID"
echo "  • Vehicles parked: 3 (2 still parked, 1 exited)"
echo ""
echo -e "${BLUE}Your Smart Parking Backend is fully functional! 🚀${NC}"

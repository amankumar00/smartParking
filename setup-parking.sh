#!/bin/bash

# Setup Parking Infrastructure Script
# This script creates parking lots, floors, and slots in your Smart Parking Backend

set -e

API_BASE="http://localhost:8080/api"

echo "🚀 Setting up Smart Parking Infrastructure..."
echo ""

# Step 1: Create Parking Lot
echo "📍 Step 1: Creating parking lot..."
PARKING_LOT_RESPONSE=$(curl -s -X POST "${API_BASE}/parking-lots" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Main Smart Parking",
    "address": "123 Main Street, City Center",
    "totalFloors": 3
  }')

echo "$PARKING_LOT_RESPONSE"
PARKING_LOT_ID=$(echo "$PARKING_LOT_RESPONSE" | grep -o '"parkingLotId":"[^"]*"' | cut -d'"' -f4)

if [ -z "$PARKING_LOT_ID" ]; then
  echo "❌ Failed to create parking lot. Check if authentication is required."
  echo "Response: $PARKING_LOT_RESPONSE"
  exit 1
fi

echo "✅ Parking Lot Created: $PARKING_LOT_ID"
echo ""

# Step 2: Create Floors with Slots
echo "🏢 Step 2: Creating floors and parking slots..."

# Floor 0 - Ground Floor
echo "  Creating Floor 0 (Ground Floor)..."
FLOOR_0_RESPONSE=$(curl -s -X POST "${API_BASE}/parking-lots/floors" \
  -H "Content-Type: application/json" \
  -d '{
    "floorNo": 0,
    "parkingLotId": "'"$PARKING_LOT_ID"'",
    "slotConfiguration": {
      "TWO_WHEELER": 15,
      "FOUR_WHEELER": 25,
      "HEAVY_VEHICLE": 5
    }
  }')
echo "    $FLOOR_0_RESPONSE"
echo "  ✅ Floor 0 created with 45 slots (15 TWO_WHEELER, 25 FOUR_WHEELER, 5 HEAVY_VEHICLE)"

# Floor 1 - First Floor
echo "  Creating Floor 1..."
FLOOR_1_RESPONSE=$(curl -s -X POST "${API_BASE}/parking-lots/floors" \
  -H "Content-Type: application/json" \
  -d '{
    "floorNo": 1,
    "parkingLotId": "'"$PARKING_LOT_ID"'",
    "slotConfiguration": {
      "TWO_WHEELER": 20,
      "FOUR_WHEELER": 30,
      "HEAVY_VEHICLE": 0
    }
  }')
echo "    $FLOOR_1_RESPONSE"
echo "  ✅ Floor 1 created with 50 slots (20 TWO_WHEELER, 30 FOUR_WHEELER)"

# Floor 2 - Second Floor
echo "  Creating Floor 2..."
FLOOR_2_RESPONSE=$(curl -s -X POST "${API_BASE}/parking-lots/floors" \
  -H "Content-Type: application/json" \
  -d '{
    "floorNo": 2,
    "parkingLotId": "'"$PARKING_LOT_ID"'",
    "slotConfiguration": {
      "TWO_WHEELER": 25,
      "FOUR_WHEELER": 20,
      "HEAVY_VEHICLE": 5
    }
  }')
echo "    $FLOOR_2_RESPONSE"
echo "  ✅ Floor 2 created with 50 slots (25 TWO_WHEELER, 20 FOUR_WHEELER, 5 HEAVY_VEHICLE)"

echo ""
echo "🎉 Setup Complete!"
echo ""
echo "📊 Summary:"
echo "  - Parking Lot ID: $PARKING_LOT_ID"
echo "  - Total Floors: 3"
echo "  - Total Slots: 145"
echo "    • TWO_WHEELER: 60 slots"
echo "    • FOUR_WHEELER: 75 slots"
echo "    • HEAVY_VEHICLE: 10 slots"
echo ""
echo "✅ Your parking system is now ready to use!"
echo ""
echo "🧪 Test parking a vehicle:"
echo "  curl -X POST ${API_BASE}/parking/entry \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -d '{\"vehicleType\":\"FOUR_WHEELER\",\"vehicleRegistration\":\"ABC123\"}'"
echo ""

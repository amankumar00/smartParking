#!/usr/bin/env bash
# Render start script for Smart Parking Backend
# This script runs on Render to start your Spring Boot application

echo "=========================================="
echo "  Starting Smart Parking Backend"
echo "=========================================="

# Set Java options for memory management
export JAVA_OPTS="-Xmx512m -Xms256m"

# Start the application with the PORT environment variable from Render
java -Dserver.port=$PORT \
     -Dspring.profiles.active=render \
     $JAVA_OPTS \
     -jar target/smart-parking-backend-1.0.0.jar

#!/usr/bin/env bash
# Render build script for Smart Parking Backend
# This script runs on Render to build your Spring Boot application

set -o errexit  # Exit on error

echo "=========================================="
echo "  Building Smart Parking Backend"
echo "=========================================="

# Install Maven if not present (Render usually has it)
if ! command -v mvn &> /dev/null; then
    echo "Installing Maven..."
    apt-get update
    apt-get install -y maven
fi

# Build the project
echo "Building with Maven..."
mvn clean install -DskipTests

echo "Build completed successfully!"
echo "=========================================="

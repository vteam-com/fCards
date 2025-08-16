d#!/bin/bash

# Exit on any error
set -e

echo "🚀 Starting deployment process..."

# Clean the project
echo "🧹 Cleaning the project..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Run tests
echo "🧪 Running tests..."
./tool/check.sh

# Build the web app
echo "🔨 Building web app..."
flutter build web --release

# Deploy to Firebase
echo "🚀 Deploying to Firebase..."
firebase deploy

echo "✅ Deployment completed successfully!"

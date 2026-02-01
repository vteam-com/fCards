#!/bin/bash

# =============================================================================
# VTeam Cards - Firebase Deployment Script
# =============================================================================
# This script automates the deployment process of the Cards Flutter web app
# to Firebase Hosting. It includes quality checks, building, and deployment.
#
# Usage: ./tool/deploy.sh
#
# Prerequisites:
# - Firebase CLI installed and logged in
# - Flutter SDK installed
# - Project initialized with Firebase (firebase.json exists)
# =============================================================================

# Exit on any error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_ID="vteam-cards"
LIVE_URL="https://vteam-cards.web.app"
CONSOLE_URL="https://console.firebase.google.com/project/$PROJECT_ID/overview"

echo -e "${BLUE}🚀 Starting VTeam Cards deployment process...${NC}"
echo -e "${BLUE}================================================================${NC}"

# Check prerequisites
echo -e "${YELLOW}📋 Checking prerequisites...${NC}"

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}❌ Firebase CLI not found. Please install it with:${NC}"
    echo -e "${YELLOW}npm install -g firebase-tools${NC}"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter not found. Please install Flutter SDK.${NC}"
    exit 1
fi

# Check if firebase.json exists
if [ ! -f "firebase.json" ]; then
    echo -e "${RED}❌ Firebase not initialized. Run 'firebase init hosting' first.${NC}"
    exit 1
fi

# Check if logged into Firebase
if ! firebase projects:list &> /dev/null; then
    echo -e "${RED}❌ Not logged into Firebase. Run 'firebase login' first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Clean the project
echo -e "${YELLOW}🧹 Cleaning the project...${NC}"
flutter clean

# Get dependencies
echo -e "${YELLOW}📦 Getting dependencies...${NC}"
flutter pub get

# Run quality checks and tests
echo -e "${YELLOW}🧪 Running quality checks and tests...${NC}"
if [ -f "./tool/check.sh" ]; then
    ./tool/check.sh
else
    echo -e "${YELLOW}⚠️  check.sh not found, running basic tests...${NC}"
    flutter test
fi

# Build the web app
echo -e "${YELLOW}🔨 Building web app for production...${NC}"
flutter build web --release

# Check if build was successful
if [ ! -d "build/web" ]; then
    echo -e "${RED}❌ Build failed - build/web directory not found${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Web app built successfully${NC}"

# Deploy to Firebase
echo -e "${YELLOW}🚀 Deploying to Firebase Hosting...${NC}"
firebase deploy --project $PROJECT_ID

echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo -e "${BLUE}================================================================${NC}"
echo -e "${GREEN}🎉 Your VTeam Cards app is now live!${NC}"
echo ""
echo -e "${BLUE}📱 Live App:${NC} $LIVE_URL"
echo -e "${BLUE}🔧 Firebase Console:${NC} $CONSOLE_URL"
echo -e "${BLUE}📊 Project ID:${NC} $PROJECT_ID"
echo ""
echo -e "${YELLOW}💡 Tip: Check the live app to ensure everything works as expected.${NC}"
echo -e "${BLUE}================================================================${NC}"

#!/bin/sh
echo --- Pub Clean
flutter clean > /dev/null || { echo "Pub get failed"; exit 1; }

echo --- Pub Get
flutter pub get > /dev/null || { echo "Pub get failed"; exit 1; }

echo --- Pub Upgrade
flutter pub upgrade > /dev/null || { echo "Pub get failed"; exit 1; }

echo --- Pub Outdated
flutter pub outdated --no-transitive --no-prereleases

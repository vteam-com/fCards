#!/bin/bash

echo "🔥 Deploying Firebase Realtime Database Rules..."
firebase deploy --only database --project vteam-cards
echo "✅ Rules deployed successfully!"

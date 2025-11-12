#!/bin/bash

echo "Deploying Firestore rules..."

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "Firebase CLI is not installed. Please install it first:"
    echo "npm install -g firebase-tools"
    exit 1
fi

# Deploy only Firestore rules
firebase deploy --only firestore:rules

echo "Firestore rules deployment completed!"
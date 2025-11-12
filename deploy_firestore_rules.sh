#!/bin/bash

# Deploy Firestore security rules
echo "Deploying Firestore security rules..."

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "Firebase CLI is not installed. Please install it first:"
    echo "npm install -g firebase-tools"
    exit 1
fi

# Check if user is logged in
if ! firebase projects:list &> /dev/null; then
    echo "Please login to Firebase first:"
    echo "firebase login"
    exit 1
fi

# Deploy the rules
firebase deploy --only firestore:rules

echo "Firestore rules deployed successfully!"
echo ""
echo "You can also manually copy the rules from firestore.rules to your Firebase Console:"
echo "1. Go to https://console.firebase.google.com"
echo "2. Select your project"
echo "3. Go to Firestore Database > Rules"
echo "4. Copy and paste the content from firestore.rules"
echo "5. Click Publish"
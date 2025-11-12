#!/bin/bash

echo "Stopping Flutter web server..."
pkill -f "flutter run"

echo "Cleaning Flutter cache..."
flutter clean

echo "Getting dependencies..."
flutter pub get

echo "Starting Flutter web server..."
flutter run -d web-server --web-port 8080 --web-hostname localhost

echo "App should be available at: http://localhost:8080"
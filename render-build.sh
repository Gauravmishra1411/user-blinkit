#!/usr/bin/env bash

# Exit on error
set -o errexit

# Clone Flutter stable branch
if [ ! -d "flutter" ]; then
  echo "Cloning Flutter SDK..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable ./flutter
fi

# Add Flutter to path
export PATH="$PATH:$(pwd)/flutter/bin"

# Increase memory for Dart VM to prevent build crashes
export DART_VM_OPTIONS="--max-old-space-size=3072"

# Enable Web
flutter config --enable-web

# Clear build cache to free up memory
flutter clean

# Get dependencies
flutter pub get

# Build for web
echo "Starting Flutter Web build..."

# Validate important env vars
if [ -z "$FIREBASE_API_KEY" ]; then
  echo "WARNING: FIREBASE_API_KEY is not set. The app will likely fail to initialize Firebase."
fi

flutter build web --release \
  -O2 \
  --base-href / \
  --dart-define="FIREBASE_API_KEY=$FIREBASE_API_KEY" \
  --dart-define="FIREBASE_AUTH_DOMAIN=$FIREBASE_AUTH_DOMAIN" \
  --dart-define="FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID" \
  --dart-define="FIREBASE_STORAGE_BUCKET=$FIREBASE_STORAGE_BUCKET" \
  --dart-define="FIREBASE_MESSAGING_SENDER_ID=$FIREBASE_MESSAGING_SENDER_ID" \
  --dart-define="FIREBASE_APP_ID=$FIREBASE_APP_ID" \
  --dart-define="FIREBASE_MEASUREMENT_ID=$FIREBASE_MEASUREMENT_ID"

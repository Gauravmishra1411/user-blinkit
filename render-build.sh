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

# Generate .env file for build-time injection
echo "Generating .env for build-time injection..."
cat <<EOF > .env
FIREBASE_API_KEY="$FIREBASE_API_KEY"
FIREBASE_AUTH_DOMAIN="$FIREBASE_AUTH_DOMAIN"
FIREBASE_PROJECT_ID="$FIREBASE_PROJECT_ID"
FIREBASE_STORAGE_BUCKET="$FIREBASE_STORAGE_BUCKET"
FIREBASE_MESSAGING_SENDER_ID="$FIREBASE_MESSAGING_SENDER_ID"
FIREBASE_APP_ID="$FIREBASE_APP_ID"
FIREBASE_MEASUREMENT_ID="$FIREBASE_MEASUREMENT_ID"
EOF

# Build for web using the .env file for compile-time constants
echo "Starting Flutter Web build..."
flutter build web --release \
  -O2 \
  --base-href / \
  --dart-define-from-file=.env

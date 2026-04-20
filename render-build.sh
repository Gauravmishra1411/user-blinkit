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

# Enable Web
flutter config --enable-web

# Get dependencies
flutter pub get

# Generate .env file from environment variables (for Vercel/Render deployments)
echo "Generating .env file from environment variables..."
cat <<EOF > .env
FIREBASE_API_KEY=${FIREBASE_API_KEY}
FIREBASE_AUTH_DOMAIN=${FIREBASE_AUTH_DOMAIN}
FIREBASE_PROJECT_ID=${FIREBASE_PROJECT_ID}
FIREBASE_STORAGE_BUCKET=${FIREBASE_STORAGE_BUCKET}
FIREBASE_MESSAGING_SENDER_ID=${FIREBASE_MESSAGING_SENDER_ID}
FIREBASE_APP_ID=${FIREBASE_APP_ID}
FIREBASE_MEASUREMENT_ID=${FIREBASE_MEASUREMENT_ID}
EOF

# Verify .env exists
if [ ! -f ".env" ]; then
  echo "Error: Failed to create .env file"
  exit 1
fi

# Build for web
echo "Starting Flutter Web build..."
flutter build web --release --tree-shake-icons --base-href /

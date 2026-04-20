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

# Create dummy .env if it doesn't exist (to prevent build failure as it is a required asset)
if [ ! -f ".env" ]; then
  echo "Creating dummy .env file..."
  touch .env
fi

# Build for web using HTML renderer (more memory efficient for Render free tier)
echo "Starting Flutter Web build..."
flutter build web --release --web-renderer html --tree-shake-icons --base-href /

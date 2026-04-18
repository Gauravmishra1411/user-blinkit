#!/bin/bash

# Define Flutter version/path
FLUTTER_VERSION="stable"
FLUTTER_HOME=$HOME/flutter

# Check if Flutter is already cached/installed
if [ ! -d "$FLUTTER_HOME" ]; then
  echo "Downloading Flutter..."
  git clone https://github.com/flutter/flutter.git -b $FLUTTER_VERSION $FLUTTER_HOME
fi

# Add Flutter to PATH
export PATH="$PATH:$FLUTTER_HOME/bin"

# Pre-cache web artifacts
flutter precache --web

# Enable web support
flutter config --enable-web

# Get packages
flutter pub get

# Build the app to build/web
flutter build web --release --base-href /

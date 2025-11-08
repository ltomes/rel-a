#!/bin/bash

# Build script for Android targets using cargo-ndk
set -e

echo "Building Rust library for Android..."

# Build for Android using cargo-ndk
# This will build for both arm64-v8a and armeabi-v7a
cargo ndk -t arm64-v8a -t armeabi-v7a --platform 24 -o ../android/app/src/main/jniLibs build --release

echo "✓ Build completed successfully!"
echo "Libraries copied to: ../android/app/src/main/jniLibs"

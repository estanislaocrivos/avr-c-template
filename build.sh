#!/bin/bash

# This script builds the project using CMake and Make

BUILD_DIR="build"
TOOLCHAIN_FILE="avr-gcc-toolchain.cmake"

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  echo "Usage: ./build.sh [mcu] [fcpu] [clean]"
  echo "mcu:    Target MCU (default: atmega2560)"
  echo "fcpu:   MCU clock frequency in Hz (default: 16000000UL)"
  echo "clean:  Removes the build directory"
  exit 0
fi

if [[ "$1" == "clean" ]]; then
  echo "Cleaning build directory..."
  rm -rf "$BUILD_DIR"
  exit 0
fi

# Parse parameters for MCU and F_CPU
TARGET_MCU="${1:-atmega2560}"
TARGET_F_CPU="${2:-16000000UL}"

if [ -z "$TARGET_MCU" ]; then
  echo "Error: TARGET_MCU is not set. Please provide a valid MCU."
  exit 1
fi

if [ -z "$TARGET_F_CPU" ]; then
  echo "Error: TARGET_F_CPU is not set. Please provide a valid clock frequency."
  exit 1
fi

# Ensure the script exits on any error
set -e

# Create a build directory if it doesn't exist
if [ ! -d "$BUILD_DIR" ]; then
  mkdir "$BUILD_DIR"
fi

# Check if the toolchain file exists
if [ ! -f "$TOOLCHAIN_FILE" ]; then
  echo "Toolchain file not found: $TOOLCHAIN_FILE"
  exit 1
fi  

# Change to the build directory
cd "$BUILD_DIR"

# Run CMake with the specified toolchain file and MCU
echo "Building project for MCU: $TARGET_MCU with F_CPU: $TARGET_F_CPU..."
cmake -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN_FILE" -DMCU="$TARGET_MCU" -DF_CPU="$TARGET_F_CPU" ..
make

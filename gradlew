#!/bin/sh
GRADLE_VERSION=8.8
BASE_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
GRADLE_HOME="$BASE_DIR/.gradle-wrapper/gradle-$GRADLE_VERSION"
GRADLE_ZIP="$BASE_DIR/.gradle-wrapper/gradle-$GRADLE_VERSION-bin.zip"
GRADLE_URL="https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip"

if [ ! -x "$GRADLE_HOME/bin/gradle" ]; then
  echo "Gradle $GRADLE_VERSION not found. Downloading..."
  mkdir -p "$BASE_DIR/.gradle-wrapper"
  if command -v curl >/dev/null 2>&1; then
    curl -fL "$GRADLE_URL" -o "$GRADLE_ZIP" || exit 1
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$GRADLE_ZIP" "$GRADLE_URL" || exit 1
  else
    echo "curl or wget is required."
    exit 1
  fi
  unzip -q -o "$GRADLE_ZIP" -d "$BASE_DIR/.gradle-wrapper" || exit 1
fi

exec "$GRADLE_HOME/bin/gradle" "$@"

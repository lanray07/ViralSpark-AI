#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${ASC_KEY_ID:-}" || -z "${ASC_ISSUER_ID:-}" || -z "${ASC_KEY_PATH:-}" ]]; then
  echo "Set ASC_KEY_ID, ASC_ISSUER_ID, and ASC_KEY_PATH before running."
  echo "Example:"
  echo "  export ASC_KEY_ID=YGUJ392L3K"
  echo "  export ASC_ISSUER_ID=69a6de76-14b3-47e3-e053-5b8c7c11a4d1"
  echo "  export ASC_KEY_PATH=/path/to/AuthKey_YGUJ392L3K.p8"
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARCHIVE_PATH="$ROOT_DIR/build/ViralSparkAI.xcarchive"
EXPORT_OPTIONS="$ROOT_DIR/Tools/ExportOptions-AppStore.plist"

cd "$ROOT_DIR"
mkdir -p build

xcodebuild \
  -project ViralSparkAI.xcodeproj \
  -scheme ViralSparkAI \
  -sdk iphoneos \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  -allowProvisioningUpdates \
  -authenticationKeyID "$ASC_KEY_ID" \
  -authenticationKeyIssuerID "$ASC_ISSUER_ID" \
  -authenticationKeyPath "$ASC_KEY_PATH" \
  DEVELOPMENT_TEAM=5ZP6GV85J6 \
  CODE_SIGN_STYLE=Automatic \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  archive

xcodebuild \
  -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS" \
  -allowProvisioningUpdates \
  -authenticationKeyID "$ASC_KEY_ID" \
  -authenticationKeyIssuerID "$ASC_ISSUER_ID" \
  -authenticationKeyPath "$ASC_KEY_PATH"

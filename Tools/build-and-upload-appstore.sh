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

if [[ -z "${SIGNING_IDENTITY:-}" || -z "${PROFILE_SPECIFIER:-}" ]]; then
  echo "Set SIGNING_IDENTITY and PROFILE_SPECIFIER for manual App Store signing."
  echo "The GitHub Actions workflow installs these automatically from repository secrets."
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARCHIVE_PATH="$ROOT_DIR/build/ViralSparkAI.xcarchive"
EXPORT_OPTIONS="$ROOT_DIR/build/ExportOptions-AppStore.plist"

cd "$ROOT_DIR"
mkdir -p build

cat > "$EXPORT_OPTIONS" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>destination</key>
	<string>upload</string>
	<key>method</key>
	<string>app-store-connect</string>
	<key>provisioningProfiles</key>
	<dict>
		<key>com.viralsparkai.app</key>
		<string>$PROFILE_SPECIFIER</string>
	</dict>
	<key>signingCertificate</key>
	<string>$SIGNING_IDENTITY</string>
	<key>signingStyle</key>
	<string>manual</string>
	<key>stripSwiftSymbols</key>
	<true/>
	<key>teamID</key>
	<string>5ZP6GV85J6</string>
	<key>uploadSymbols</key>
	<true/>
</dict>
</plist>
PLIST

xcodebuild \
  -project ViralSparkAI.xcodeproj \
  -scheme ViralSparkAI \
  -sdk iphoneos \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  DEVELOPMENT_TEAM=5ZP6GV85J6 \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="$SIGNING_IDENTITY" \
  PROVISIONING_PROFILE_SPECIFIER="$PROFILE_SPECIFIER" \
  archive

xcodebuild \
  -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS" \
  -authenticationKeyID "$ASC_KEY_ID" \
  -authenticationKeyIssuerID "$ASC_ISSUER_ID" \
  -authenticationKeyPath "$ASC_KEY_PATH"

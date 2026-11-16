#!/usr/bin/env bash
# Builds and runs the test suite on an iOS 27 simulator. Usage: ./run-tests.sh [extra xcodebuild args, e.g. -only-testing:ChefsJournalTests]
set -o pipefail
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
cd "$(dirname "$0")"
xcodebuild test -project ChefsJournal.xcodeproj -scheme ChefsJournal \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.0' "$@" 2>&1 \
  | grep -E "error:|warning:|Test case|✘|passed|failed|TEST (SUCCEEDED|FAILED)|BUILD (SUCCEEDED|FAILED)|Executed|Test run" \
  | grep -v -E "✔ (Suite|Test [a-zA-Z_]+\()" | grep -v -e "started\.$" -e "appintentsmetadataprocessor" | tail -n 80
exit ${PIPESTATUS[0]}

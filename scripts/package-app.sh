#!/bin/zsh

set -euo pipefail

script_dir="${0:A:h}"
project_dir="${script_dir:h}"
configuration="${1:-release}"
app_bundle="${project_dir}/dist/AndroidSister.app"

cd "${project_dir}"
swift build -c "${configuration}" --product AndroidSister
binary_dir="$(swift build -c "${configuration}" --show-bin-path)"

rm -rf "${app_bundle}"
mkdir -p "${app_bundle}/Contents/MacOS"
mkdir -p "${app_bundle}/Contents/Resources"

cp "${binary_dir}/AndroidSister" "${app_bundle}/Contents/MacOS/AndroidSister"
cp "${project_dir}/Packaging/Info.plist" "${app_bundle}/Contents/Info.plist"
cp "${project_dir}/Packaging/AppIcon.icns" "${app_bundle}/Contents/Resources/AppIcon.icns"

codesign --force --sign - "${app_bundle}"
codesign --verify --deep --strict "${app_bundle}"

echo "${app_bundle}"

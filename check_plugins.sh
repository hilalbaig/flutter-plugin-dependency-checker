#!/usr/bin/env bash
set -euo pipefail

PUB_CACHE="${HOME}/.pub-cache"

# ✅ Configurable thresholds
MIN_AGP=8
MIN_GRADLE=8
MIN_KOTLIN=1.9
MIN_COMPILE_SDK=35
MIN_TARGET_SDK=35

# Colors
AGP_COLOR='\033[38;5;196m'        # bright red
GRADLE_COLOR='\033[38;5;27m'      # blue
KOTLIN_COLOR='\033[38;5;199m'     # magenta-red
SDK_COLOR='\033[38;5;202m'        # orange-red
TARGET_SDK_COLOR='\033[38;5;160m' # deep red
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'


# 📝 Print current thresholds
echo -e "${YELLOW}Minimum required versions (you can edit these in the script header):${RESET}"
echo -e "  - AGP: ${AGP_COLOR}$MIN_AGP+${RESET}"
echo -e "  - Gradle: ${GRADLE_COLOR}$MIN_GRADLE.x+${RESET}"
echo -e "  - Kotlin: ${KOTLIN_COLOR}$MIN_KOTLIN+${RESET}"
echo -e "  - Compile SDK: ${SDK_COLOR}$MIN_COMPILE_SDK+${RESET}"
echo -e "  - Target SDK: ${TARGET_SDK_COLOR}$MIN_TARGET_SDK+${RESET}"
echo

# Ask user which check to perform (default=All)
echo "Select what to check (comma-separated, default=1,2,3,4,5 = All):"
echo "1) AGP"
echo "2) Gradle Distribution"
echo "3) Kotlin"
echo "4) Compile SDK"
echo "5) Target SDK"
read -rp "Enter 1,2,3,4,5 (e.g., 1,2): " choice
choice="${choice:-1,2,3,4,5}"

# Set flags
CHECK_AGP=0
CHECK_GRADLE=0
CHECK_KOTLIN=0
CHECK_SDK=0
CHECK_TARGET_SDK=0

for opt in $(echo "$choice" | tr ',' ' '); do
  case "$opt" in
    1) CHECK_AGP=1 ;;
    2) CHECK_GRADLE=1 ;;
    3) CHECK_KOTLIN=1 ;;
    4) CHECK_SDK=1 ;;
    5) CHECK_TARGET_SDK=1 ;;
    *) echo "Invalid option: $opt"; exit 1 ;;
  esac
done

found=0
counter=1

# Scan git and hosted plugins
for dir in "$PUB_CACHE"/{git/*,hosted/pub.dev/*}; do
  [ -d "$dir/android" ] || continue

  build_file=""
  if [ -f "$dir/android/build.gradle" ]; then
    build_file="$dir/android/build.gradle"
  elif [ -f "$dir/android/build.gradle.kts" ]; then
    build_file="$dir/android/build.gradle.kts"
  fi

  gradle_wrapper="$dir/android/gradle/wrapper/gradle-wrapper.properties"
  outdated=""
  report=""

  # === Check AGP ===
  if [ "$CHECK_AGP" -eq 1 ] && [ -n "$build_file" ]; then
    agp_line=$(grep -E "com\.android\.tools\.build:gradle" "$build_file" || true)
    if [ -n "$agp_line" ]; then
      version=$(echo "$agp_line" | sed -nE "s/.*gradle:([0-9][0-9.]*).*/\1/p")
      if [ -n "$version" ]; then
        major=${version%%.*}
        if [ "$major" -lt "$MIN_AGP" ]; then
          outdated=1
          report+=" ${AGP_COLOR}AGP=$version${RESET}"
        fi
      fi
    fi
  fi

  # === Check Gradle Distribution ===
  if [ "$CHECK_GRADLE" -eq 1 ] && [ -f "$gradle_wrapper" ]; then
    dist_line=$(grep "distributionUrl" "$gradle_wrapper" || true)
    if [ -n "$dist_line" ]; then
      gradle_version=$(echo "$dist_line" | sed -nE "s/.*gradle-([0-9]+)\..*/\1/p")
      if [ -n "$gradle_version" ] && [ "$gradle_version" -lt "$MIN_GRADLE" ]; then
        outdated=1
        report+=" ${GRADLE_COLOR}Gradle=$gradle_version${RESET}"
      fi
    fi
  fi

  # === Check Kotlin ===
  if [ "$CHECK_KOTLIN" -eq 1 ] && [ -n "$build_file" ]; then
    kotlin_line=$(grep -E "kotlin_version|kotlin\(\"jvm\"\).*version" "$build_file" || true)
    if [ -n "$kotlin_line" ]; then
      kotlin_version=$(echo "$kotlin_line" | sed -nE "s/.*(['\"])([0-9]+\.[0-9]+(\.[0-9]+)?).*/\2/p" | head -n1)
      if [ -n "$kotlin_version" ]; then
        base_version=$(echo "$kotlin_version" | cut -d. -f1-2)
        if (( $(echo "$base_version < $MIN_KOTLIN" | bc -l) )); then
          outdated=1
          report+=" ${KOTLIN_COLOR}Kotlin=$kotlin_version${RESET}"
        fi
      fi
    fi
  fi

  # === Check compileSdkVersion ===
  if [ "$CHECK_SDK" -eq 1 ] && [ -n "$build_file" ]; then
    sdk_line=$(grep -E "compileSdkVersion|compileSdk " "$build_file" | head -n1 || true)
    if [ -n "$sdk_line" ]; then
      sdk=$(echo "$sdk_line" | sed -nE "s/.*(compileSdkVersion|compileSdk)[[:space:]]+([0-9]+).*/\2/p")
      if [ -n "$sdk" ] && [ "$sdk" -lt "$MIN_COMPILE_SDK" ]; then
        outdated=1
        report+=" ${SDK_COLOR}compileSdk=$sdk${RESET}"
      fi
    fi
  fi

  # === Check targetSdkVersion ===
  if [ "$CHECK_TARGET_SDK" -eq 1 ] && [ -n "$build_file" ]; then
    target_line=$(grep -E "targetSdkVersion|targetSdk " "$build_file" | head -n1 || true)
    if [ -n "$target_line" ]; then
      target=$(echo "$target_line" | sed -nE "s/.*(targetSdkVersion|targetSdk)[[:space:]]+([0-9]+).*/\2/p")
      if [ -n "$target" ] && [ "$target" -lt "$MIN_TARGET_SDK" ]; then
        outdated=1
        report+=" ${TARGET_SDK_COLOR}targetSdk=$target${RESET}"
      fi
    fi
  fi

  if [ -n "$outdated" ]; then
    if [ "$found" -eq 0 ]; then
      echo -e "${YELLOW}⚠️ The following plugins need updates to meet minimum defined versions:${RESET}"
    fi
    plugin=$(basename "$dir" | sed -E 's/-[0-9a-f]{7,}//')
    echo -e "${YELLOW}${counter}. ${plugin}${RESET} -> ${CYAN}${build_file:-$gradle_wrapper}${RESET}${report}"
    found=1
    ((counter++))
  fi
done

if [ "$found" -eq 0 ]; then
  echo "🎉 Hurray! All checked plugins are up to date 🚀✨"
fi

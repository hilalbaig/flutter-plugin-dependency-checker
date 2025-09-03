# flutter-plugin-dependency-checker
Bash script to scan Flutter plugins for outdated AGP, Gradle, Kotlin, compileSdk, and targetSdk versions — keep your Android builds up-to-date 🚀



# 🔍 Flutter Plugin Dependency Checker

A simple **Bash script** that scans your Flutter project's cached plugins in  
`~/.pub-cache` and reports if they are using **outdated versions** of:

- **Android Gradle Plugin (AGP)**
- **Gradle Distribution**
- **Kotlin**
- **Compile SDK**
- **Target SDK**

> ✅ Helps you keep your dependencies up-to-date and compatible with the latest Android SDK requirements.

---

## ✨ Features

- Scans cached **git** and **pub.dev hosted** plugins.  
- Detects **outdated AGP, Gradle, Kotlin, compileSdk, and targetSdk** versions.  
- Prints **minimum required versions** at the top (configurable inside the script).  
- Lets you choose **what to check** (AGP only, SDK only, or all together).  
- Color-coded output for quick scanning.  
- Works on **macOS & Linux**.

---

## 📦 Installation

Clone the repo and make the script executable:

```bash
git clone https://github.com/YOUR_USERNAME/flutter-plugin-dependency-checker.git
cd flutter-plugin-dependency-checker
chmod +x check_plugins.sh


(Optional) Add it to your PATH for global use:

cp check_plugins.sh /usr/local/bin/check_plugins


Now you can run it from anywhere:

check_plugins

⚙️ Usage

Run the script:

./check_plugins.sh


It will first print the minimum required versions (editable inside the script):

Minimum required versions (you can edit these in the script header):
  - AGP: 8+
  - Gradle: 8.x+
  - Kotlin: 1.9+
  - Compile SDK: 35
  - Target SDK: 35


Then it will ask what you want to check:

Select what to check (comma-separated, default=1,2,3,4,5 = All):
1) AGP
2) Gradle Distribution
3) Kotlin
4) Compile SDK
5) Target SDK


Example input:

1,3,5

📋 Example Output

If outdated versions are found:

⚠️ The following plugins need updates to meet minimum defined versions:
1. android_dynamic_icon -> /Users/username/.pub-cache/git/android_dynamic_icon/android/build.gradle  AGP=7.3.0 Kotlin=1.6.21 targetSdk=33


If everything is good:

🎉 Hurray! All checked plugins are up to date 🚀✨

🛠 How It Works

Reads Flutter plugin cache in ~/.pub-cache/git/* and ~/.pub-cache/hosted/pub.dev/*.

Scans build.gradle, build.gradle.kts, and gradle-wrapper.properties.

Extracts AGP, Gradle, Kotlin, compileSdk, and targetSdk versions.

Compares them against minimum thresholds defined in the script header.

Prints a report of outdated plugins.

You can adjust thresholds here:

# ✅ Configurable thresholds (edit these if needed)
MIN_AGP=8
MIN_GRADLE=8
MIN_KOTLIN=1.9
MIN_COMPILE_SDK=35
MIN_TARGET_SDK=35

👨‍💻 Author

Hilal Baig
Flutter/Dart Developer • Striving to be top-notch 🚀

📜 License

MIT License – Free to use & modify.

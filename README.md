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

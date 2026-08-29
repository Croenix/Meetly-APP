# Meetly - Developer Setup Guide

Follow this guide to set up the Flutter development environment and launch the Meetly frontend prototype application.

---

## 📋 Prerequisites

1. **Flutter SDK**: Ensure you have Flutter installed (version `>=3.3.0` recommended, configured with Material 3).
   * Check your installation by running:
     ```bash
     flutter doctor
     ```
2. **Editor**: Visual Studio Code, Android Studio, or the Antigravity IDE.
3. **Devices**: Android emulator, iOS simulator, or standard Web browsers (Chrome, Edge, Safari).

---

## 🚀 Getting Started

### 1. Clone & Navigate
Ensure you are in the project root directory:
```bash
cd c:\Users\achub\OneDrive\Documents\Meetly
```

### 2. Fetch Dependencies
Fetch all the packages listed in `pubspec.yaml` (Riverpod, GoRouter, flutter_animate, Uuid, intl, etc.):
```bash
flutter pub get
```

### 3. Run Static Code Analysis
Verify that the codebase compiles with zero analysis errors:
```bash
flutter analyze
```

### 4. Run the Test Suite
Ensure all widget and mock repository unit tests are running and 100% green:
```bash
flutter test
```

---

## 📱 Running the Application

Launch the Meetly application on your preferred target platform:

### Run on Web Browser (Chrome/Edge)
```bash
flutter run -d chrome
```

### Run on Android Device / Emulator
Ensure your emulator is running, then execute:
```bash
flutter run
```

### Run on iOS Simulator (macOS only)
```bash
flutter run -d ios
```

---

## 🔑 One-Tap Demo Login Flows

To make manual vetting and presentation testing frictionless, Meetly's login portal has **One-Tap Quick Logins** enabled. 

When you navigate to the Onboarding / Authorization page, you can choose from the following presets to instantly login to the designated workspace without typing passwords:

1. **Customer View**: Tap **"Login as Customer"** to log in as Aarav Nair (Location: Kochi).
   * Exposes the home feeds, filters, search map, scheduling panels, and chat channels.
2. **Provider View**: Tap **"Login as Professional"** to log in as Arun Thomas (Licensed Electrician, Location: Kochi).
   * Exposes the provider dashboard, job status progress CTAs, operability scheduler, and services configurator.
3. **Administrator View**: Tap **"Login as Admin"** to log in as Sonia Pillai (Location: Kottayam).
   * Exposes the operations overview metrics, verification vetting lists, category builders, and review moderation tool.

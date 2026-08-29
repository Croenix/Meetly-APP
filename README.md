# Meetly - Connect. Collaborate. Grow.

Meetly is a modern, premium local-service discovery and booking platform built with **Flutter & Dart**. It features a rich, responsive interface designed to cater to three distinct user personas: Customers, Service Providers, and Platform Administrators.

This version is a **frontend-only interactive prototype/MVP** configured with zero external backend dependencies. It uses a decoupled clean MVVM (Model-View-ViewModel) architecture with reactive mock repositories, allowing developers to hot-swap mock data for real backend integrations (REST APIs, Firebase, or Supabase) later without rebuilding the UI.

---

## 🌟 Persona Feature Highlights

### 1. Customer Experience
* **Dynamic Home Dashboard**: Location Greeting (Indian Kerala context: Kochi, Kottayam, etc.), category grids, "Near You" and "Recommended" professionals lists, and custom skeleton shimmers.
* **Category Listing**: Advanced side-panel filters (distance range, rating chips, price range, verified toggle) and multi-option sorting.
* **Map Search & Pins Selection**: Simulated vector map custom painter plotting provider pins with distance Golden Angles and click details overlays.
* **Pro Profile Detail View**: Interactive schedule scheduler, portfolio image viewer, list of customer reviews, and business information tabs.
* **Booking Wizard**: Step-by-step wizard capturing service choice, date calendar, time slot chips, address, cost estimation, and confirmation.
* **Favorites Tab**: Persistent favorite professionals saved locally via `SharedPreferences`.

### 2. Provider Workspace
* **Operation Dashboard**: Visual stats (Pending bookings count, active jobs tracking, monthly estimated earnings, average ratings).
* **Vetting Submissions Stepper**: Document upload wizard (Aadhaar proof, trade license, आईटीआई/diploma credentials) that updates status from Unverified to Under Review dynamically.
* **Job Progress Tracker**: Updates client bookings in real-time through standard progress stages: `Accepted` ➔ `Confirmed` ➔ `On the Way` ➔ `In Progress` ➔ `Completed`.
* **Services Manager**: Add, edit, or delete services with customizable fixed/hourly rates, descriptions, and durations.
* **Availability Planner**: Configure week operating schedules (Mon-Sun working hours toggles).

### 3. Admin Operations Control
* **System Overview Stats**: High-level platform analytics (Total users, registered pros, transaction volume, and platform revenue estimates).
* **Pro Vetting Audits**: Inspect professional credential claims and Approve/Reject applications.
* **Category Configurator**: Create, edit, and delete platform service categories dynamically.
* **Review Moderation Panel**: Platforms review feed moderation allowing admins to delete spam or invalid review reports.

---

## 🛠️ Technology Stack & Architecture

* **Framework**: Flutter (M3 Design guidelines, fully responsive for Mobile, Tablet, and Desktop web views).
* **State Management**: Riverpod (for reactive, testable state caching).
* **Navigation**: GoRouter (declarative routing structure).
* **Local Caching**: SharedPreferences (for persistent authentication roles and bookmarks).
* **Animations**: `flutter_animate` (for premium micro-animations and skeletons).
* **Localizations**: Indian Locale settings (Locations include: Thiruvalla, Kottayam, Kochi, Alappuzha, Changanassery).

For detailed setup instructions, please refer to [SETUP.md](SETUP.md). For deep architectural patterns, refer to [ARCHITECTURE.md](ARCHITECTURE.md) and [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md).

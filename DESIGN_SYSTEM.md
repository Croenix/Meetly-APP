# Meetly - UI & Design System

Meetly adheres to a modern, premium design system configured under Material 3 guidelines, prioritizing vibrant gradients, readable contrast, glassmorphic card highlights, and rich micro-animations.

---

## 🎨 Color Palette & Contrast Tokens

### Brand Core
* **Primary Indigo** (`#4F46E5`): Core focus lines, primary CTAs, active highlights.
* **Secondary Violet** (`#7C3AED`): Subtle headers, tab indicators, secondary accents.
* **Accent Cyan** (`#06B6D4`): Special status elements, stars, custom overlays.

### Light Theme Surfaces
* **Background**: Slate Tint (`#F8FAFC`) - clean, soft on the eyes.
* **Surface**: Pure White (`#FFFFFF`) - elevated elements, cards, sheets.
* **Text Primary**: Slate Dark (`#0F172A`).
* **Text Secondary**: Slate Medium (`#475569`).

### Dark Theme Surfaces
* **Background**: Deep Slate (`#0B0F19`) - premium deep-contrast space.
* **Surface**: Slate Dark (`#1E293B`) - elevated container panels.
* **Text Primary**: Off-White (`#F8FAFC`).
* **Text Secondary**: Slate light (`#94A3B8`).

### State Colors
* **Success**: Emerald Green (`#10B981`) - used for completed timelines, verified badges.
* **Warning**: Amber Orange (`#F59E0B`) - pending status flags.
* **Error**: Rose Red (`#EF4444`) - cancelled timelines, destructive buttons.

---

## 📏 Spacing & Roundness Scales

To maintain visual rhythm, spacing is aligned to an **8dp baseline grid**:
* `AppSpacing.width4` / `height4`: Micro gaps (icon-text distance).
* `AppSpacing.width8` / `height8`: Small gaps (sub-header padding).
* `AppSpacing.width12` / `height12`: Mid gaps (card children padding).
* `AppSpacing.width16` / `height16`: Standard margins.
* `AppSpacing.width24` / `height24` / `width32` / `height32`: Core block separators.

### Border Radius
* `AppDimensions.borderRadiusSmall` (`8.0`): Small elements, filter chips, rating pills.
* `AppDimensions.borderRadiusMedium` (`12.0`): Primary card shapes, dialog boxes.
* `AppDimensions.borderRadiusLarge` (`16.0`): Onboarding sheets, detail sheets.

---

## 📱 Responsive Layout Strategy

Meetly utilizes custom wrappers to guarantee visual excellence on mobile, tablet, and desktop views:
1. **`ResponsiveContainer`**: Restricts the maximum content width on wide screens (capped at 900px) and centers content.
2. **`ResponsiveLayoutShell`**:
   * **Mobile/Tablet**: Displays a sleek bottom `NavigationBar` for tab switches.
   * **Desktop (width > 800px)**: Auto-expands to a sidebar navigation format featuring a persistent user avatar widget, scroll-wheel menus, and high-density details panels.

---

## ✨ Micro-Animations & Skeletons
We use `flutter_animate` to keep the application feeling alive:
* **Skeleton cards**: Displays grey block layout wrappers configured with looping shimmering animations during lists loading.
  ```dart
  Widget build(BuildContext context) {
    return const SkeletonCard()
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1200.ms, color: Colors.white24);
  }
  ```
* **Page/Card Transitions**: Elements slide slightly upward (`slideY`) and fade in (`fadeIn`) on page loads to present premium transitions.

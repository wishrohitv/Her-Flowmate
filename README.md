# HerFlowmate 🌸
**Your gentle, premium cycle and pregnancy companion built with Flutter.**

[![Flutter Build](https://img.shields.io/badge/Flutter-v3.29.0-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Deployment](https://img.shields.io/badge/Live-Web%20Demo-ff69b4)](https://hillhack.github.io/Her-Flowmate/)
[![Discord](https://img.shields.io/badge/Discord-Join%20Community-7289DA?logo=discord&logoColor=white)](https://discord.gg/aehkEXj8q)

HerFlowmate is a minimalist, privacy-first health tracker designed to empower women with deep biological insights, clinical-grade pregnancy tracking, and calm, premium aesthetics.

---

## ✨ Feature Spotlight

### 🧠 Cycle Evolution & Insights
- **🔄 Interactive Evolution Wheel**: A beautiful, floral-inspired visualization of your current biological phase and fertility window.
- **🧪 Magazine-style Insights**: High-density daily updates on your **Hormones**, **Energy**, and **Mood**, tailored to your exact cycle day.
- **💧 Advanced Hydration**: Smart tracking with a daily **15 Glass target** and intuitive, fractional progress logging.
- **📝 Holistic Logging**: Seamlessly track symptoms, moods, and energy levels to discover your unique health patterns.

### 🤰 Pregnancy Dashboard (Premium)
- **🏔️ Milestone Hero**: An immersive, trimester-aware header that tracks your progress with high-impact typography and glowing progress markers.
- **🍐 Baby Development**: Visualize your baby's growth with recognizable fruit/veg comparisons and precise weight/length data.
- **🏥 Trimester Logic**: The UI automatically shifts its theme (Rose Quartz ➡️ Lavender ➡️ Baby Blue) as you progress through each trimester.

---

## 🏗️ Technical & Clinical Core

### 📅 Clinical Accuracy (LMP)
HerFlowmate follows strict medical standards for pregnancy tracking:
- **LMP-Based Logic**: All calculations represent the **Last Menstrual Period (LMP)**.
- **280-Day Rule**: Due dates are calculated as `LMP + 280 days`.
- **Accurate Weeks**: Progress is computed as `(Today - LMP) / 7 + 1`.

### 🛡️ Web Stability (Fragment-First)
To ensure a crash-free experience on Flutter Web/Chrome, the app uses a proprietary **Fragment-First Architecture**:
- **Atomic Components**: High-density UI elements are built as standalone, stateless fragments to avoid nested scrollable deadlocks.
- **Nuclear Stability**: Optimized for performance by replacing complex blurs (BackdropFilters) with high-speed linear gradients.

---

## 🛠️ Technological Stack
- **Core**: [Flutter](https://flutter.dev) & [Dart](https://dart.dev)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Local Database**: [Hive_ce](https://pub.dev/packages/hive_ce) (Privacy-first encryption)
- **Animations**: [flutter_animate](https://pub.dev/packages/flutter_animate)
- **Styling**: Custom Neumorphic & Glassmorphic design system.

---

## 🚀 Getting Started

1. **Clone & Setup**:
   ```bash
   git clone https://github.com/hillhack/Her-Flowmate.git
   cd Her-Flowmate
   flutter pub get
   ```

2. **Run Locally**:
   ```bash
   flutter run -d chrome
   ```

---

## 💬 Community & Contributing
Join our official [Discord Community](https://discord.gg/aehkEXj8q) to discuss features, get help, or collaborate on the future of women's health.

For contribution guidelines, please see [CONTRIBUTING.md](CONTRIBUTING.md).

---
*HerFlowmate - Understand Your Own Rhythm.*

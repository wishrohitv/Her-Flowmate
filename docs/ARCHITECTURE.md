# Architecture & Stability Guide

This document outlines the architectural patterns and stability strategies used in Her-Flowmate to ensure a premium, crash-free experience across Mobile and Web.

## 🧱 Fragment Architecture Pattern
The `PregnancyDashboard` and other high-density UI components are built using a **Fragment Pattern**.

### Why Fragments?
Standard Flutter screens often use a `Scaffold` and `SingleChildScrollView`. However, when these are nested (e.g., a dashboard inside a home screen), it creates **Hit-Test Deadlocks** on Flutter Web, leading to the `MouseTracker` assertion error.

**Key Rules:**
1. **No Nested Scaffolds**: Fragments must be "naked" widgets (usually `Column` or `CustomScrollView` slivers).
2. **Top-Level Ownership**: Only the parent screen (e.g., `HomeScreen`) owns the `Scaffold` and the primary `ScrollController`.
3. **Stateless Fragments**: Fragments should be `StatelessWidget` and use `Provider` or `watch` to react to state changes, minimizing `setState` rebuilds.

## ☢️ Nuclear Stability Phase (Web Optimization)
Flutter Web (specifically the CanvasKit and HTML renderers) can be sensitive to complex graphics filters. To ensure 100% stability on Chrome, we've adopted the **Nuclear Stability** approach.

### 🚫 Prohibited Primitives (Web-only)
- **BackdropFilter (Blur)**: While visually premium, blurs are a primary cause of hit-testing assertions and layout overflow crashes on certain browser engines.
- **Looping Animations**: Continuous `repeat()` animations (like glowing backgrounds or sparkles) trigger constant layout passes that can conflict with mouse tracking.
- **Nested MouseRegions**: Complex Neumorphic buttons with internal `onHover` setState triggers are replaced with standard Material `InkWell` for stability.

### ✅ Recommended Alternatives
- **Linear Gradients**: High-performance color transitions that don't trigger layout passes.
- **Staggered Entrance Animations**: Single-play animations (via `flutter_animate`) are safe and provide a premium feel without constant overhead.
- **Standard Shadow/Elevation**: Using `Material` and `BoxShadow` instead of complex custom shader blurs.

## 📅 Clinical Data Layer (LMP)
To ensure medical accuracy, the app uses the **Last Menstrual Period (LMP)** as the source of truth for pregnancy tracking.

- **Conception vs. LMP**: The app ignores the internal 14-day conception offset.
- **280-Day Rule**: Due dates are calculated as `LMP + 280 days`.
- **Week Progress**: `(Today - LMP) / 7 + 1`.

---
*Maintained by the HerFlowmate Engineering Team.*

# The App Project

## Overview

The App Project is an **iOS productivity and wellbeing dashboard** built with **SwiftUI**.  
It combines **tasks**, **habits**, **weekly reflection**, **health metrics** (via HealthKit), and **local weather** (via WeatherKit) into a single, glanceable home screen.

The goal is to show how I design and ship a small but complete product:

- **Today dashboard** with a single screen that surfaces what matters now.
- **Task list** for lightweight planning and daily execution.
- **Habit tracking** with quick completion and simple editing.
- **Weekly review flow** to reflect on the last week and plan the next.
- **Health & weather widgets** that bring context (movement, hydration, weather) into your day.

If you’re an employer reviewing this repo, you can skim **Features**, **Architecture**, and **Implementation Highlights** to understand what this app demonstrates.

---

## Features

- **Home dashboard**
  - “Today” header with **live weather summary** and expanded details.
  - At‑a‑glance **today’s goal** pulled from your tasks.
  - **Health widget** showing water and exercise progress with progress rings.
  - Inline lists for **today’s tasks** and **current habits**.

- **Tasks**
  - `TodoListView` shows all tasks.
  - Tasks support **titles, due dates, and completion state**.
  - Tapping the icon toggles completion with immediate visual feedback.

- **Habits**
  - Add and edit habits via `AddHabitView` and `EditHabitView`.
  - Simple, tappable checkmarks for completion.
  - State kept in memory for quick iteration (could be swapped for persistence later).

- **Weekly review**
  - `WeeklyReviewView` guides a weekly reflection / planning flow.
  - Separates **looking back** at the past week from **setting focus** for the upcoming one.

- **Health integration (HealthKit)**
  - `HealthKitManager` reads water intake and exercise minutes.
  - Dashboard shows **two activity rings**: water and exercise.
  - Uses a shared singleton to manage permissions and data updates.

- **Weather integration (WeatherKit)**
  - `WeatherViewModel` handles permission, fetching, and error states.
  - Dashboard header shows **current temperature, conditions, and last updated time**.
  - Includes **manual refresh** and a **test mode** for debugging WeatherKit connectivity.

- **Settings**
  - `SettingsView` is a simple home for configuration / future preferences.

---

## Architecture & Tech Stack

- **Platform**: iOS, Swift 5+, SwiftUI
- **Architecture style**: Lightweight **MVVM**
  - `Views/` contain SwiftUI screens and UI composition.
  - `VewModels/` (intentional original spelling kept) contain app logic and state:
    - `TodoViewModel` for tasks
    - `WeatherViewModel` for WeatherKit
    - `AuthStore` and others for app‑level state
  - `Models/` define simple value types, e.g. `TaskItem`, `HabitItem`.
- **Frameworks**
  - **SwiftUI** for UI and navigation (`TabView`, `NavigationView`, sheets).
  - **WeatherKit** for local weather data.
  - **CoreLocation** for location permissions (via `WeatherViewModel`).
  - **HealthKit** for water and exercise metrics (`HealthKitManager`).

---

## Running the App

### Open in Xcode (recommended)

1. Open `TheAppProject.xcodeproj` in Xcode.
2. In the scheme selector, choose an **iOS Simulator** (e.g. iPhone 16 Pro).
3. Press **⌘R** to build and run.

### Requirements

- Xcode with the latest iOS SDK.
- An Apple Developer account to enable:
  - **WeatherKit** entitlement.
  - **HealthKit** capability (if you want HealthKit to function on device).

WeatherKit and location usage descriptions are already configured in `Info.plist`, and WeatherKit entitlement is defined in `The App Project.entitlements`.

---

## Implementation Highlights

- **Dashboard composition**
  - `ContentView` manages navigation with a **4‑tab `TabView`**: Dashboard, Tasks, Weekly, Settings.
  - `DashboardView` composes multiple sections (goal card, health, tasks, habits, debug tools) into a single scrollable view with a **day/night background gradient**.

- **State management**
  - Uses `@StateObject` for view models that own their lifecycle (e.g. `WeatherViewModel`, `HealthKitManager.shared`).
  - Uses `@EnvironmentObject` (`TodoViewModel`) to share task state across tabs.

- **Async and permissions**
  - On appear, `DashboardView`:
    - Requests location permission and fetches weather.
    - Requests HealthKit authorization.
    - Asynchronously updates water and exercise metrics.
  - Weather header includes **loading, success, and error states**, with a “time ago” label to show freshness of data.

- **Design**
  - Uses **modern, card‑based UI** with depth, rounded corners, and system materials.
  - Focuses on **glanceability**: today’s goal, key metrics, and weather are visible immediately on launch.

---

## Repository Structure

The core app lives under `The App Project/`:

```text
The App Project/
├── TheAppProject.xcodeproj/       # Xcode project
├── App/                           # Entry point and app configuration
├── Views/                         # SwiftUI screens and components
├── VewModels/                     # View models (tasks, weather, auth, etc.)
├── Models/                        # Task and habit models
├── Media.xcassets/                # App icons and image assets
├── Resources/                     # Asset catalogs and other resources
├── Info.plist                     # App metadata & permissions
└── The App Project.entitlements   # WeatherKit & other capabilities
```

---

## What This Project Demonstrates

For an employer, this project is meant to show:

- **Product thinking**: a focused app that ties tasks, habits, health, and context (weather) into a single daily view.
- **Modern iOS development**: SwiftUI, MVVM‑style separation, async workflows, and system integrations.
- **Attention to UX**: clear hierarchy, lightweight flows (add goal/habit), and helpful debug tooling while iterating.

If you’d like more detail on any specific part (WeatherKit integration, HealthKit, or the dashboard design), I’m happy to walk through the implementation. 

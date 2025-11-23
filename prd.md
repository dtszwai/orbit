# Product Requirements Document (PRD)

**Product Name:** Orbit (formerly ChillFlow)  
**Version:** 3.1 (The "Gravity" Update)  
**Status:** Final Draft  
**Platform:** macOS (Native SwiftUI)  
**Language:** English

---

## 1. Executive Summary

Orbit is a menu bar-resident productivity ecosystem that synchronizes time, sound, and biological energy. It solves the "fragmented focus" problem by merging a rigorous Pomodoro Timer with an Adaptive Soundscape Engine.

Unlike standard timers, Orbit functions as a "Mindset Operating System." It resides quietly in the menu bar but expands into a powerful Popover Command Center to manage tasks, audio mixing, and bio-rhythm forecasting.

### The "Dual-Orbit" Architecture

- **Micro-Orbit (Menu Bar):** A discrete, "Leaf-style" status indicator for quick control and at-a-glance status
- **Macro-Orbit (Popover):** A compact, always-available window (anchored to the menu bar) for deep state management, task planning, and analytics

---

## 2. Vision & Philosophy

### 2.1 Vision

To create a digital environment where "getting into the zone" is not a willpower act, but a passive default. Orbit acts as a gravitational force, pulling wandering attention back to the center using psycho-acoustic cues and rigid task structuring.

### 2.2 Core Value Proposition

- **For the Rational Brain:** Strict timer enforcement, task tagging, and GitHub-style consistency heatmaps
- **For the Emotional Brain:** Mood-based audio ("Soundscapes"), "Energy Decay" visualization, and atmospheric aesthetics
- **The "DJ" Algorithm:** The app automatically mixes audio stems (Background + Ambience + Binaural) based on the user's chosen focus mode

---

## 3. Target Audience

- **The "Deep Diver":** Senior Developers who need 4+ hours of uninterrupted flow
- **The "Visual Creator":** Designers who value aesthetic interfaces ("Midnight & Neon") that blend into a dark-mode workspace
- **The "Bio-Hacker":** Users who want to optimize when they work based on circadian rhythms

---

## 4. User Stories

| As a...       | I want to...                       | So that...                                                                                       |
| ------------- | ---------------------------------- | ------------------------------------------------------------------------------------------------ |
| Remote Worker | See my "Energy Decay" forecast     | I know if I should schedule deep coding or light admin tasks based on my predicted energy levels |
| Audiophile    | Use the "Spatial Orbit" soundscape | The sound moves slowly in 3D space, preventing "listener fatigue" common with static white noise |
| Planner       | Import my calendar events as tasks | I can seamlessly transition from a meeting to a focused work block without manual data entry     |
| Student       | Use "Lockdown Mode"                | I cannot quit the app or browse distractions until the 25-minute timer completes                 |
| Manager       | View the "Contribution Heatmap"    | I can visualize my consistency over the month using a familiar grid interface                    |

---

## 5. Functional Requirements

### 5.1 The "Dual-Orbit" Interface

#### A. Micro-Orbit (Menu Bar Utility)

**Behavior:** Resides permanently in the macOS menu bar

**Visuals:** A minimalist icon (Leaf) + Time Remaining (e.g., "24:59")

- **Idle:** White Icon
- **Running:** Teal Icon + Pulsing Text

**Interactions:**

- **Left Click:** Toggles the Macro-Orbit Popover
- **Right Click:** Context menu (Quick Start 25m, Pause, Quit)

#### B. Macro-Orbit (The Popover)

**Layout:** A fixed-width (340px) window featuring a Tab Bar for navigation: [Controls] [Tasks] [Stats]

##### Tab 1: Controls (The Cockpit)

- **Centerpiece:** Large, thin-font timer (e.g., "25:00") that dominates the view
- **Primary Action:** A full-width "Start Focus" / "Pause Session" button
- **Sound Engine:**
  - Grid of circular buttons for presets: "Deep Work" (Zap), "Natural" (Wind), "Spatial" (Moon), "Relax" (Coffee)
  - Volume Slider for master audio control
- **Footer:** "Bio-Rhythm Sync" status line displaying current weather, location, and energy decay prediction

##### Tab 2: Tasks (The Mission Log)

- **Task Creation:** Inline input to add tasks with specific durations (e.g., "Refactor API - 45m")
- **Calendar Sync:** A button to fetch events from Apple Calendar/Google Calendar and convert them into tasks
- **Active Mode:** Clicking "Play" on a specific task switches the view to the Cockpit, sets the timer to that task's duration, and tags the session
- **Completion:** Checkbox to mark tasks as done; swipe-to-delete support

##### Tab 3: Stats (The Records)

- **Metric:** Large "Total Focus Time" display for the selected period
- **Visualization:** A Contribution Heatmap (GitHub-style grid)
  - **Columns:** Days (Mon-Sun)
  - **Rows:** Time Blocks (Morning, Afternoon, Evening)
  - **Opacity:** Darker color = More focus minutes
- **Navigation:** Date range selectors (Previous Week / Next Week)

### 5.2 The Bio-Rhythm Engine

**Input:** User location (for sunrise/sunset times) and current local weather

**Logic:**

- **Morning (Peak):** Suggests 50min/10min cycles
- **Afternoon (Decay):** Detects the "3 PM Slump." Suggests shorter 25min/5min cycles
- **Evening (Recovery):** Suggests unstructured "Free Flow"

**Visual:** A text-based indicator in the Cockpit footer (e.g., "Afternoon Decay: Recharge in 27m")

### 5.3 Audio Architecture

**Layering:**

- **Base:** Pink Noise / Brown Noise (Constant)
- **Texture:** Rain / Wind / Fire (Variable)
- **Pulse:** Isochronic tones (40Hz for focus, 10Hz for relax)

**Smart Fades:**

- Timer starts → Audio swells (3s fade in)
- Timer pauses → Audio ducks (lowers volume by 50%)

---

## 6. UI/UX Design Specifications

**Theme:** "Midnight & Neon" (Dark Mode Only)

### Palette

| Element            | Color         | Hex     |
| ------------------ | ------------- | ------- |
| Background         | Deep Charcoal | #121212 |
| Primary (Focus)    | Electric Teal | #2DD4BF |
| Secondary (Relax)  | Warm Amber    | #F59E0B |
| Tertiary (Spatial) | Soft Purple   | #C084FC |

### Typography

- **Numbers:** SF Mono (or similar monospaced font)
- **UI Text:** SF Pro Rounded

### Animation

- Subtle "breathing" glow behind the timer when active
- Smooth slide transitions between tabs

---

## 7. Technical Stack

- **Platform:** macOS (Native)
- **Framework:** SwiftUI
- **Window Management:** MenuBarExtra (macOS 13+ API)
- **State Management:** Combine / ObservableObject
- **Data Persistence:** SwiftData (for storing tasks and session history)
- **Audio Engine:** AVFoundation (AVAudioEngine for 3D spatial positioning)
- **External APIs:** WeatherKit (for Atmospheric Sync), EventKit (for Calendar integration)

---

## 8. Roadmap

- **v3.0 (Gravity):** Core Menu Bar + Popover release. Includes Timer, Soundscapes, and Basic Heatmap
- **v3.1 (Mission):** Implementation of Task System and Calendar Integration
- **v3.5 (Atmosphere):** Full integration of WeatherKit for "Atmospheric Sync" (sound matches local weather)

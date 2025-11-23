# Orbit (v3.0 Gravity) - Development Design Document

**Status:** Ready for Development  
**Target Platform:** macOS (SwiftUI Native)  
**Architecture:** Menu Bar Utility (MenuBarExtra)  
**Design System:** "Midnight & Neon" (Dark Mode)

---

## 1. Executive Overview

Orbit is a macOS menu bar application designed to induce flow states. Unlike traditional Pomodoro timers, it functions as a "mindset operating system" by combining a rigorous timer, an adaptive soundscape engine, and bio-rhythm forecasting into a compact, always-available popover interface.

---

## 2. System Architecture

### 2.1 Core Frameworks

- **SwiftUI:** Primary UI framework for the popover interface
- **MenuBarExtra (macOS 13+):** To handle the menu bar icon and popover window lifecycle without a dock icon
- **Combine:** For timer logic and reactive state management
- **AVFoundation:** For the multi-stem audio engine (mixing Background, Ambience, and Binaural beats)
- **SwiftData:** For persisting tasks and session history locally
- **WeatherKit & CoreLocation:** For the Bio-Rhythm "Atmospheric Sync" feature

### 2.2 App Lifecycle

**Background Mode:** The app runs as an LSUIElement (Agent application), meaning no Dock icon.

**Global State (OrbitManager):** A singleton class (ObservableObject) that manages:

- TimerState (Running, Paused, Break)
- AudioState (Active tracks, Volume)
- BioRhythmState (Current energy decay calculation)

---

## 3. UI Structure & Specifications

The app consists of a Status Item (Menu Bar) and a Popover Window containing three tabs.

### 3.1 Micro-Orbit (Menu Bar Status Item)

**Visuals:**

- **Icon:** SF Symbol `leaf.fill` (or custom SVG)
- **Text:** MM:SS countdown

**States:**

- **Idle:** White Icon, Hidden Text
- **Running:** Teal Icon, Visible Text, Subtle "Pulse" animation on the colon (:)
- **Break:** Amber Icon, Visible Text

**Interaction:** Left-click toggles the Popover

### 3.2 Popover Window (Macro-Orbit)

- **Dimensions:** Fixed width 340px, Height adaptive (approx 600px)
- **Appearance:** `.ultraThinMaterial` or custom dark background `Color(hex: "121212")`
- **Navigation:** Segmented Control (Custom styled) for [Controls | Tasks | Stats]

---

## 4. Detailed View Specifications

### 4.1 Tab A: Controls (The Cockpit)

**Primary Function:** Timer management and Audio selection

#### Timer Display

- **Font:** `Font.system(.system(size: 72), design: .monospaced)`
- **Weight:** `.light` or `.thin`
- **Animation:** When running, add a subtle background glow (Blur layer behind timer)

#### Action Button

- Large, full-width rounded rectangle
- **Start:** Teal background, Black text
- **Pause:** Dark Grey background, Red text/border

#### Volume Slider

- Custom Slider style with a thin track and no knob (hover to reveal knob)

#### Soundscape Grid

- 4 Circular Buttons (`Grid LazyVGrid(columns: [GridItem(), ...])`)
- **States:**
  - **Selected:** Tint Color Ring + Tint Background (20% opacity)
  - **Unselected:** Grey Ring (10% opacity)
- **Presets:**
  - **Zap (Deep Work):** Pink Noise + Beta Waves
  - **Wind (Natural):** Rain + Birds
  - **Moon (Spatial):** Brown Noise + 3D Panning
  - **Coffee (Relax):** Cafe Ambience

#### Footer: Bio-Rhythm Sync

- Pinned to bottom
- **Displays:** Location, Weather Condition (Icon), and "Energy Decay" prediction text

---

### 4.2 Tab B: Tasks (The Mission Log)

**Primary Function:** Task CRUD and Calendar Sync

#### Header

- "Today's Mission" Label
- **Calendar Button:** Triggers EventKit permission to fetch today's events
- **Add Button (+):** Reveals inline input row

#### Task List (List)

- Rows must support swipe-to-delete
- **Row Layout:** [Checkmark Circle] [Title & Duration] [Play Button]
- **Play Logic:** Clicking the "Play" button on a task:
  - Sets `OrbitManager.currentTask = task`
  - Sets `timerDuration = task.duration`
  - Switches View to Tab A (Controls)
  - Updates Timer Label to "Focusing on: [Task Name]"

---

### 4.3 Tab C: Stats (The Records)

**Primary Function:** Historical tracking and visualization

#### Header

- Date Range Selector (< Date >)

#### Metric

- "Total Focus" (Large Title)

#### Heatmap Visualization

- **Implementation:** A `LazyVGrid` representing the week (Columns: Mon-Sun)
- **Rows:** 3 Rows representing Morning (6am-12pm), Afternoon (12pm-6pm), Evening (6pm-12am)
- **Cell Logic:**
  - 0 mins: `Color.white.opacity(0.05)`
  - 1-25 mins: `Color.teal.opacity(0.3)`
  - 25-50 mins: `Color.teal.opacity(0.6)`
  - 50+ mins: `Color.teal`

#### Persistence

Use SwiftData (`@Model class Session`) to store:

- `startTime: Date`
- `duration: TimeInterval`
- `taskID: UUID?`

---

## 5. Technical Requirements & API

### 5.1 Data Models (SwiftData)

```swift
@Model
class TaskItem {
    var id: UUID
    var title: String
    var durationMinutes: Int
    var isCompleted: Bool
    var source: String // "user" or "calendar"
}

@Model
class FocusSession {
    var timestamp: Date
    var durationSeconds: Int
    var task: TaskItem?
}
```

### 5.2 Audio Engine (AVFoundation)

- Must support **Looping** (seamless)
- Must support **Crossfading** (when switching scenes)
- **Spatial Audio:** Use `AVAudioEnvironmentNode` for 3D positioning of the "Spatial Orbit" stem

### 5.3 Bio-Rhythm Logic

**Input:** Current Time (`Date()`), Sunset Time (from WeatherKit)

**Algorithm:**

- If Time > 13:00 AND Time < 16:00: Trigger "Afternoon Slump" logic (Suggest shorter 25m cycles, boost volume +10%)

---

## 6. Assets & Colors

### Color Palette (Asset Catalog)

| Name        | Hex     | Usage                         |
| ----------- | ------- | ----------------------------- |
| OrbitBlack  | #121212 | Main Background               |
| OrbitPanel  | #1A1A1A | Secondary Backgrounds (Cards) |
| OrbitTeal   | #2DD4BF | Focus / Primary Action        |
| OrbitAmber  | #F59E0B | Relax / Break                 |
| OrbitPurple | #C084FC | Spatial / Creative            |
| OrbitRed    | #EF4444 | Stop / Delete                 |

### Typography

- **Monospace:** SF Mono (Timer digits)
- **Sans:** SF Pro Rounded (Labels, Task titles)

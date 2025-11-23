# Orbit Data Storage

## Simple Architecture

### SwiftData Models

**FocusSession** - Tracks completed focus sessions
```swift
- id: UUID
- startTime: Date        // When the session started
- durationSeconds: Int   // How long they focused
- taskTitle: String?     // Optional task name
```

**TaskItem** - User's task list
```swift
- id: UUID
- title: String
- durationMinutes: Int
- isCompleted: Bool
- createdAt: Date
```

### Storage Rules

1. **Sessions save automatically** when:
   - Timer is paused (after 1+ minute of focus)
   - Session completes naturally

2. **No cloud sync** - Local only (simple)
3. **No manual editing** - Data is append-only
4. **No deletion** - Sessions are permanent

### Data Location

SwiftData stores to:
```
~/Library/Containers/com.orbit.app/Data/Library/Application Support/default.store
```

### Stats Calculation

- **Daily totals**: Sum all sessions for each day
- **Intensity**: Normalized by 4-hour max (0.0-1.0)
- **Periods**: Filter by hour (Morning: 5-12, Afternoon: 12-17, Evening: 17-5)

---

## Mock Data for Testing

To test the Stats screen with realistic data:

1. **Run the app**: `./run.sh`
2. **Click the gear icon** (⚙️) in the top right
3. **Select "Generate Mock Data"**

This creates 3 weeks of realistic focus sessions with:
- Random number of sessions per day (0-4)
- Random session durations (15 min - 2 hours)
- Random times throughout the day (6 AM - 10 PM)

To reset and start fresh:
- Click gear icon → "Clear All Data"

---

**Philosophy**: Store everything, calculate on-demand. No premature optimization.

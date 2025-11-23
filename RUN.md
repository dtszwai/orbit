# Run Orbit

## Quick Start

```bash
./run.sh
```

That's it! The script will build and launch the app.

## Manual Build

If you prefer to build manually:

```bash
xcodebuild -project Orbit.xcodeproj -scheme Orbit build
open ./build/Build/Products/Debug/Orbit.app
```

## Development

Open the project in Xcode:
```bash
open Orbit.xcodeproj
```

---

**Note:** First build may take longer. Subsequent builds will be faster.

# Sushitrain Architecture Overview

## Project Type
Cross-platform file synchronization app (iOS/macOS) based on Syncthing

## Architecture Pattern
**Hybrid Language Stack:**
- Swift/SwiftUI for UI layer (60+ views)
- Go for business logic (SushitrainCore framework)
- gomobile bridge for Go↔Swift communication
- Embedded Syncthing core for sync engine

## Core Components

### Swift Side (Sushitrain/)
- **AppState.swift** (1000+ lines): Central state management
- **SushitrainDelegate**: Event bridge from Go to Swift
  - onChange(): File change events
  - onEvent(): System events  
  - onStreamChunk(): Streaming progress
- **60+ SwiftUI Views**: Modular UI components
  - BrowserView*: File browsing (list/table/grid/web)
  - FolderView*: Folder management
  - DeviceView*: Device management
  - PhotoBackup*: Photo album sync
  - SettingsView: App configuration

### Go Side (SushitrainCore/src/)
- **sushitrain.go**: Core Client struct (700+ lines)
  - Syncthing App embedding
  - Configuration management
  - Event delegation to Swift
- **server.go**: HTTP streaming server with Range support
- **folder.go**: Folder operations + selective sync
- **entry.go**: File/entry management
- **peer.go**: Device peer connections
- **selection.go**: Selective sync logic
- **encryption.go**: Encryption support
- **customfs.go**: Custom filesystem (PhotoFS)

## Key Features Implementation

### Selective Sync
- Mechanism: `.stignore` file manipulation
  - Default: `*` ignores all files
  - Selected: `!/path/to/file` exception pattern
- Files: `folder.go`, `selection.go`

### On-Demand Download
- HTTP streaming server (server.go)
- Range request support for video streaming
- URL signature verification (ed25519)

### Photo Backup/Sync
- `PhotoBackup.swift`: Auto album export
- `PhotoFS.swift`: Custom filesystem (virtual album)
- `customfs.go`: Go-side filesystem abstraction

### Remote Thumbnails
- Cross-device remote generation
- Caching in specified folder
- `ThumbnailView.swift`, `ThumbnailImage.swift`

## Data Flow
```
User Action → SwiftUI View
    ↓
AppState (@MainActor state update)
    ↓
SushitrainDelegate
    ↓
Go Client (gomobile bridge)
    ↓
Syncthing Core (actual sync)
    ↓
Event Callback → SushitrainDelegate.onChange/onEvent
    ↓
AppState update → SwiftUI automatic refresh
```

## Thread Safety
- Swift UI updates on `@MainActor`
- Go operations guarded by mutexes
- Careful main thread dispatch on Go callbacks

## Key Dependencies
- Syncthing (embedded)
- gomobile (bridging)
- SwiftUI (iOS 17.5+)
- Combine (reactive state)

## Build System
- Makefile for Go framework compilation
- Xcode for app build
- gomobile bindings auto-generated

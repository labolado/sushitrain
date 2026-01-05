# Sushitrain Important Files Reference

## Critical Core Files

### Swift Side
- **AppState.swift** - Central state manager, most important Swift file
  - Manages all sync state
  - Coordinates with Go backend
  - Handles UI updates

- **SushitrainDelegate** (in AppState.swift)
  - Bridge between Go events and Swift
  - Implements ClientDelegate protocol
  - Routes events to appropriate state updates

- **App.swift** - App entry point
  - SushitrainApp struct
  - MenuBarExtraView for macOS

- **BackgroundManager.swift** - Background sync handling
- **Sharing.swift** - System share sheet integration
- **PhotoBackup.swift** - Photo album export feature
- **PhotoFS.swift** - Virtual photo filesystem

### Go Side
- **sushitrain.go** - Core client implementation
  - Client struct (main entry point)
  - Configuration management
  - Syncthing App embedding
  - Event loop management

- **server.go** - HTTP streaming server
  - On-demand file access
  - Range request support
  - URL signing for security

- **folder.go** - Folder operations
  - Selective sync implementation
  - .stignore file management
  - Rescan operations

- **entry.go** - File entry operations
- **peer.go** - Device peer management
- **selection.go** - Selective sync logic
- **encryption.go** - Encryption folder support
- **customfs.go** - Custom filesystem implementation
- **conflicts.go** - Conflict resolution
- **puller.go** - File pulling/downloading
- **zip.go** - ZIP file operations
- **utils.go** - Utility functions
- **logging.go** - Log handling

## Configuration Files
- **Localizable.xcstrings** (1.2MB) - All localization strings
- **Sushitrain/Info.plist** - App metadata
- **Sushitrain.entitlements** - iOS/macOS permissions
- **.swift-format** - Code formatting rules
- **Makefile** - Build automation

## UI View Categories

### Browser Views
- BrowserView.swift - Main browser container
- BrowserListView.swift - List view
- BrowserTableView.swift - Table view (macOS)
- BrowserWebView.swift - Web preview
- GridFilesView.swift - Grid layout

### Folder Management
- FoldersView.swift - Folder list
- FolderView.swift - Single folder
- AddFolderView.swift - Add new folder
- FolderSettings.swift - Folder configuration
- SelectiveFolderView.swift - Selective sync UI

### Device Management
- DevicesView.swift - Device list
- DeviceView.swift - Single device
- AddDeviceView.swift - Add device
- AddressesView.swift - Connection addresses

### File Operations
- FileView.swift - Single file
- FileViewerView.swift - File preview
- DownloadsView.swift - Download queue
- UploadsView.swift - Upload queue
- EntryDownloaderView.swift - Download progress

### Advanced Features
- EncryptionView.swift - Encryption UI
- DecrypterView.swift - Decryption tool
- IgnoresView.swift - Ignore patterns
- ExtraFilesView.swift - Extraneous files
- ChangesView.swift - Recent changes
- SearchView.swift - File search
- StatisticsView.swift - Sync statistics

### Settings
- SettingsView.swift - Main settings
- OnboardingView.swift - First-run experience
- AboutView.swift - App info
- SupportView.swift - Help & support
- PhotoBackupView.swift - Photo backup settings
- PhotoFolderSettingsView.swift - Photo folder config
- FolderStatisticsView.swift - Folder stats

### Sharing
- ExternalSharing.swift - Share extension
- ExternalSharingView.swift - Share UI
- Sharing.swift - System share sheet

### Utilities
- Route.swift - Navigation routing
- IdenticonView.swift - Device identicon
- ThumbnailView.swift - Thumbnail display
- ThumbnailImage.swift - Thumbnail loading
- SafariView.swift - In-app browser
- ZipView.swift - ZIP operations
- PreviewWindow.swift - File preview window
- Utils.swift - Utility functions
- QuickActions.swift - Quick actions
- Intents.swift - App intents

## Documentation
- Docs/folder-server.md - Folder server documentation
- Docs/photo-fs.md - Photo filesystem documentation
- Docs/thumbnails.md - Thumbnail system documentation
- README.md - Project overview
- CONTRIBUTING.md - Contribution guidelines
- LICENSE - MPL 2.0 license

# Brink Testing Status

## Verified Locally

- App builds successfully with:

```bash
xcodebuild -project Brink.xcodeproj -scheme Brink -configuration Debug -destination 'platform=macOS,arch=arm64' build
```

- App launches on macOS
- Local task file is created at `~/Library/Application Support/Brink/tasks.json`
- Root task creation persists to disk
- Child task creation persists to disk
- Task deletion persists to disk
- Task title edits persist to disk
- JSON export produces a valid file
- Importing the exported JSON restores the same task state

## Known Gaps

- Accessibility exposure for some SwiftUI controls is inconsistent during UI automation
- CSV round-trip still needs a full manual verification pass
- Notification scheduling works from the app, but should still be tested more thoroughly against real user permission states

## Recommended Next Checks

1. Manually verify CSV export and re-import
2. Verify notification permission prompt and reminder delivery
3. Confirm menu bar behaviors after repeated app restarts

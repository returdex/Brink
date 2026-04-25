# Brink Testing Status

## Verified Locally

- App builds successfully with:

```bash
xcodebuild -project Brink.xcodeproj -scheme Brink -configuration Debug -destination 'platform=macOS,arch=arm64' build
```

- App launches on macOS
- Shared task file is created in the `group.brink` App Group container when the capability is available
- Legacy task data migrates from `~/Library/Application Support/Brink/tasks.json` into the shared container on first launch
- Root task creation persists to disk
- Child task creation persists to disk
- Task deletion persists to disk
- Task title edits persist to disk
- JSON export produces a valid file
- Importing the exported JSON restores the same task state
- Widget extension builds and is embedded in the macOS app bundle

## Signing Note

- The app and widget are configured to share data through the `group.brink` App Group
- On a new machine, select the same development team for both targets in Xcode and keep the `group.brink` capability enabled for each target before running

## Known Gaps

- Accessibility exposure for some SwiftUI controls is inconsistent during UI automation
- CSV round-trip still needs a full manual verification pass
- Notification scheduling works from the app, but should still be tested more thoroughly against real user permission states

## Recommended Next Checks

1. Manually verify CSV export and re-import
2. Verify notification permission prompt and reminder delivery
3. Confirm menu bar behaviors after repeated app restarts
4. Confirm widget reflects task edits after the app saves changes

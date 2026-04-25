# Widget Desktop Debugging

## Summary

This note captures the issues we hit while adapting `BrinkWidget` for the macOS desktop widget surface and the fixes that finally made the widget behave correctly.

## What Changed

- Improved dark mode colors across the app and widget.
- Replaced hard-edged panels with a more consistent rounded-corner treatment.
- Added a shared `BrinkTheme` for app-side surfaces.
- Reworked desktop widget rendering to better match macOS desktop widget behavior.
- Simplified non-small widget layouts so medium and large sizes are easier to read and less likely to waste vertical space.

## Key Findings

### 1. Desktop widgets do not always honor custom backgrounds

`chronod` logs showed the widget being rendered with environment modifiers like:

- `renderingMode=accented`
- `backgroundViewPolicy=Remove - hiding from developer`

That means macOS may actively remove the background provided by the widget, even when the view hierarchy itself is correct.

### 2. A white or stale-looking widget was often a snapshot issue, not a layout issue

Several times the desktop kept showing an older widget snapshot even after the extension had been rebuilt successfully.

Useful refresh actions:

- restart `Dock`
- restart `NotificationCenter`
- relaunch the latest built `Brink.app`

Commands used during debugging:

```bash
killall Dock
killall NotificationCenter
open ~/Library/Developer/Xcode/DerivedData/Brink-*/Build/Products/Debug/Brink.app
```

### 3. `pluginkit` helped verify the active extension path

To confirm the system was actually using the current debug build:

```bash
pluginkit -m -A -D -v | sed -n '/com.yifeng.brink.widget/,+8p'
```

That let us verify the registered extension path matched the current DerivedData build instead of a stale local copy.

### 4. `chronod` logs were the most useful source of truth

This command was especially helpful:

```bash
/usr/bin/log show --last 10m --predicate 'subsystem == "com.apple.widgetkit" OR process == "chronod" OR process == "widgetextensiond" OR process == "WidgetKitExtensionHost"' --style compact
```

It exposed:

- render scheme changes
- background removal behavior
- timeline reloads
- snapshot invalidation
- environment mismatch loops

## Final Direction

The widget now follows these rules:

- `systemSmall` keeps a focused single-task treatment.
- Non-small sizes prefer list-heavy layouts instead of oversized hero cards.
- Accented rendering is handled as a separate compatibility mode.
- Widget background handling avoids assuming the desktop surface will preserve developer-supplied backgrounds.

## Practical Guidance

If the desktop widget looks wrong again:

1. Rebuild the app and widget.
2. Confirm the extension path with `pluginkit`.
3. Check `chronod` logs for `renderingMode` and `backgroundViewPolicy`.
4. Restart `Dock` and `NotificationCenter`.
5. Re-open the latest built `Brink.app`.

If the widget still looks stale after that, treat it as a desktop snapshot/rendering problem first, not a SwiftUI layout bug first.

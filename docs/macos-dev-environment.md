# Brink macOS Dev Environment

This repository now includes a bootstrap script for the local macOS development toolchain:

```bash
./scripts/setup-macos-dev.sh
```

What it checks or installs:

- `Homebrew`
- `Swift`
- `xcodegen`
- `swiftformat`
- `xcbeautify`
- `mas`
- `codex`
- active Xcode developer directory

Important:

- `codex` is already installed on this machine.
- Full Xcode is still required for `xcodebuild`, app packaging, Simulator, and standard macOS app targets.
- If `xcode-select -p` points to `/Library/Developer/CommandLineTools`, you only have the command line toolchain active.

After installing Xcode:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
xcodebuild -version
```

Recommended day-to-day commands:

```bash
xcodebuild -project Brink.xcodeproj -scheme Brink -configuration Debug -destination 'platform=macOS,arch=arm64' build
./scripts/generate-xcodeproj.sh
swiftformat Sources project.yml
```

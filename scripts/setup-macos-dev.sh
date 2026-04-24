#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

info() {
  printf "\033[1;34m[info]\033[0m %s\n" "$1"
}

warn() {
  printf "\033[1;33m[warn]\033[0m %s\n" "$1"
}

fail() {
  printf "\033[1;31m[fail]\033[0m %s\n" "$1" >&2
  exit 1
}

require_command() {
  local command_name="$1"
  local help_text="$2"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    fail "$command_name is required. $help_text"
  fi
}

install_brew_package_if_missing() {
  local formula="$1"

  if brew list --formula "$formula" >/dev/null 2>&1; then
    info "$formula already installed"
    return
  fi

  info "Installing $formula"
  brew install "$formula"
}

check_xcode() {
  local developer_dir
  developer_dir="$(xcode-select -p 2>/dev/null || true)"

  if [[ -z "$developer_dir" ]]; then
    warn "xcode-select is not configured"
    return 1
  fi

  if [[ "$developer_dir" == "/Library/Developer/CommandLineTools" ]]; then
    warn "Only Command Line Tools are active. Full Xcode is still required for xcodebuild, app packaging, and simulator workflows."
    return 1
  fi

  if ! xcodebuild -version >/dev/null 2>&1; then
    warn "xcodebuild is not usable from the active developer directory: $developer_dir"
    return 1
  fi

  info "Full Xcode is active at $developer_dir"
  return 0
}

show_next_xcode_step() {
  cat <<'EOF'

Next step for Xcode:
1. Install Xcode from the Mac App Store.
2. Run:
   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
3. Then accept the license if prompted:
   sudo xcodebuild -license accept

EOF
}

main() {
  info "Preparing Brink macOS development environment"

  require_command brew "Install Homebrew first from https://brew.sh"
  require_command swift "Install Apple Command Line Tools or Xcode first"

  install_brew_package_if_missing xcodegen
  install_brew_package_if_missing swiftformat
  install_brew_package_if_missing xcbeautify
  install_brew_package_if_missing mas

  if command -v codex >/dev/null 2>&1; then
    info "codex already installed: $(codex --version)"
  else
    warn "codex is not installed. Install it with the appropriate OpenAI distribution method for your machine."
  fi

  info "Swift toolchain: $(swift --version | head -n 1)"

  if ! check_xcode; then
    show_next_xcode_step
  fi

  info "Environment check complete"
  info "From the repo root, build with: xcodebuild -project Brink.xcodeproj -scheme Brink -configuration Debug -destination 'platform=macOS,arch=arm64' build"
  info "Repo root: $ROOT_DIR"
}

main "$@"

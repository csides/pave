# shellcheck shell=bash

apply_macos_defaults() {
  log_step "macOS system defaults"
  if ! confirm "Apply opinionated macOS defaults (Finder, keyboard, screenshots)?"; then
    log_skip "Skipped"
    return 0
  fi

  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
  defaults write NSGlobalDomain KeyRepeat -int 2
  defaults write NSGlobalDomain InitialKeyRepeat -int 15

  defaults write com.apple.finder AppleShowAllFiles -bool true
  defaults write com.apple.finder ShowPathbar -bool true
  defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

  mkdir -p "$HOME/Screenshots"
  defaults write com.apple.screencapture location -string "$HOME/Screenshots"

  defaults write com.apple.dock autohide -bool true

  killall Finder Dock SystemUIServer >/dev/null 2>&1 || true
  log_success "Applied; some changes need a logout to fully take effect"
}

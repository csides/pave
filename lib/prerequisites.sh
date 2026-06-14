# shellcheck shell=bash

brew_shellenv() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    /opt/homebrew/bin/brew shellenv
  elif [[ -x /usr/local/bin/brew ]]; then
    /usr/local/bin/brew shellenv
  fi
}

ensure_command_line_tools() {
  log_step "Xcode Command Line Tools"
  if xcode-select -p >/dev/null 2>&1; then
    log_skip "Already installed"
    return 0
  fi
  log_info "Requesting installation; a system dialog will appear…"
  xcode-select --install >/dev/null 2>&1 || true
  # Block until the GUI installer the user just triggered has finished.
  until xcode-select -p >/dev/null 2>&1; do
    sleep 5
  done
  log_success "Command Line Tools installed"
}

ensure_homebrew() {
  log_step "Homebrew"
  if command -v brew >/dev/null 2>&1; then
    log_skip "Already installed"
  else
    log_info "Installing Homebrew…"
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
      || die "Homebrew installation failed"
    log_success "Homebrew installed"
  fi
  eval "$(brew_shellenv)"
}

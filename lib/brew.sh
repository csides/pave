# shellcheck shell=bash

brew_bundle() {
  local brewfile="$1"
  log_step "Installing software from $(basename "$brewfile")"
  [[ -f $brewfile ]] || die "Brewfile not found: $brewfile"

  if brew bundle check --file "$brewfile" >/dev/null 2>&1; then
    log_skip "Everything already installed"
    return 0
  fi

  brew bundle --file "$brewfile" || die "brew bundle failed"
  log_success "Software installed"
}

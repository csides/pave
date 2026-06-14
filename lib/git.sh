# shellcheck shell=bash

ensure_ssh_key() {
  log_step "SSH key"
  local key="$HOME/.ssh/id_ed25519"
  if [[ -f $key ]]; then
    log_skip "Already exists ($key)"
    return 0
  fi
  if [[ ! -t 0 ]]; then
    log_skip "Non-interactive; skipping SSH key generation"
    return 0
  fi
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  local email
  email="$(git config --global user.email || true)"
  ssh-keygen -t ed25519 -C "${email:-$USER@$(hostname -s)}" -f "$key" \
    || die "ssh-keygen failed"
  log_success "Generated $key"
}

ensure_gpg_signing_key() {
  log_step "GPG signing key"
  command -v gpg >/dev/null 2>&1 || {
    log_skip "gpg not installed"
    return 0
  }

  local email fpr
  email="$(git config --global user.email || true)"
  if [[ -z $email ]]; then
    log_skip "git user.email not set; skipping"
    return 0
  fi

  fpr="$(_gpg_signing_fpr "$email")"
  if [[ -z $fpr ]]; then
    if [[ ! -t 0 ]]; then
      log_skip "Non-interactive; skipping GPG key generation"
      return 0
    fi
    _configure_pinentry
    log_info "Generating a new GPG signing key for $email (you'll set a passphrase)…"
    gpg --quick-generate-key "$email" ed25519 sign 0 || die "GPG key generation failed"
    fpr="$(_gpg_signing_fpr "$email")"
    [[ -n $fpr ]] || die "could not determine the new GPG key fingerprint"
    log_success "Generated GPG key $fpr"
  else
    log_skip "Key already exists ($fpr)"
  fi

  local cfg="$HOME/.gitconfig.local"
  git config --file "$cfg" user.signingkey "$fpr"
  git config --file "$cfg" commit.gpgsign true
  git config --file "$cfg" tag.gpgSign true
  git config --file "$cfg" gpg.program "$(command -v gpg)"
  log_success "Signing configured in ~/.gitconfig.local"
}

_gpg_signing_fpr() {
  gpg --list-secret-keys --with-colons "$1" 2>/dev/null \
    | awk -F: '/^fpr:/ { print $10; exit }'
}

_configure_pinentry() {
  command -v pinentry-mac >/dev/null 2>&1 || return 0
  mkdir -p "$HOME/.gnupg"
  chmod 700 "$HOME/.gnupg"
  local conf="$HOME/.gnupg/gpg-agent.conf"
  if ! grep -qs pinentry-mac "$conf"; then
    echo "pinentry-program $(command -v pinentry-mac)" >>"$conf"
    gpgconf --kill gpg-agent >/dev/null 2>&1 || true
  fi
}

github_login() {
  log_step "GitHub CLI"
  command -v gh >/dev/null 2>&1 || {
    log_skip "gh not installed"
    return 0
  }
  if gh auth status >/dev/null 2>&1; then
    log_skip "Already authenticated"
  elif [[ ! -t 0 ]]; then
    log_warn "Run 'gh auth login' to authenticate (skipped: non-interactive)"
    return 0
  else
    gh auth login || log_warn "gh auth login did not complete"
  fi
  gh auth status >/dev/null 2>&1 && _upload_keys
}

_upload_keys() {
  local host email fpr
  host="$(hostname -s)"
  if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
    if gh ssh-key add "$HOME/.ssh/id_ed25519.pub" --title "$host" >/dev/null 2>&1; then
      log_success "Added SSH key to GitHub"
    else
      log_skip "SSH key already on GitHub (or add it manually)"
    fi
  fi
  email="$(git config --global user.email || true)"
  fpr="$(_gpg_signing_fpr "$email")"
  if [[ -n $fpr ]]; then
    if gpg --armor --export "$fpr" | gh gpg-key add - >/dev/null 2>&1; then
      log_success "Added GPG key to GitHub"
    else
      log_skip "GPG key already on GitHub (or add it manually)"
    fi
  fi
}

setup_git() {
  ensure_ssh_key
  ensure_gpg_signing_key
  github_login
}

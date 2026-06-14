# shellcheck shell=bash

OMZ_DIR="$HOME/.oh-my-zsh"

ensure_oh_my_zsh() {
  log_step "oh-my-zsh"
  if [[ -d $OMZ_DIR ]]; then
    log_skip "Already installed"
  else
    log_info "Installing oh-my-zsh…"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
      || die "oh-my-zsh installation failed"
    log_success "oh-my-zsh installed"
  fi

  local p10k="$OMZ_DIR/custom/themes/powerlevel10k"
  if [[ -d $p10k ]]; then
    log_skip "powerlevel10k already present"
  else
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k" \
      || die "powerlevel10k clone failed"
    log_success "powerlevel10k installed"
  fi
}

link_dotfiles() {
  log_step "Shell dotfiles"
  local src="$REPO_DIR/dotfiles"
  local f dest backup
  for f in .zprofile .zshrc .p10k.zsh; do
    dest="$HOME/$f"
    if [[ -e $dest ]] && ! diff -q "$src/$f" "$dest" >/dev/null 2>&1; then
      backup="$dest.pre-pave.$(date +%Y%m%d%H%M%S)"
      cp "$dest" "$backup"
      log_info "Backed up existing $f to $(basename "$backup")"
    fi
    cp "$src/$f" "$dest"
    log_success "Installed $f"
  done
}

setup_zsh() {
  ensure_oh_my_zsh
  link_dotfiles
}

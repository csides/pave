#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/log.sh
source "$REPO_DIR/lib/log.sh"
# shellcheck source=lib/prerequisites.sh
source "$REPO_DIR/lib/prerequisites.sh"
# shellcheck source=lib/brew.sh
source "$REPO_DIR/lib/brew.sh"
# shellcheck source=lib/macos.sh
source "$REPO_DIR/lib/macos.sh"
# shellcheck source=lib/checklist.sh
source "$REPO_DIR/lib/checklist.sh"

skip_brew=0
skip_macos=0
skip_checklist=0
brewfile="$REPO_DIR/Brewfile"

usage() {
  cat <<'EOF'
Usage: ./bootstrap.sh [options]

Pave a fresh macOS machine into a working development environment.
Safe to re-run: every step is idempotent.

Options:
  --yes              Assume "yes" for all prompts (non-interactive)
  --skip-brew        Skip Homebrew package installation
  --skip-macos       Skip applying macOS system defaults
  --skip-checklist   Skip the interactive manual-steps checklist
  --brewfile PATH    Install from an alternate Brewfile
  -h, --help         Show this help
EOF
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --yes) export ASSUME_YES=1 ;;
      --skip-brew) skip_brew=1 ;;
      --skip-macos) skip_macos=1 ;;
      --skip-checklist) skip_checklist=1 ;;
      --brewfile)
        brewfile="$2"
        shift
        ;;
      -h | --help)
        usage
        exit 0
        ;;
      *)
        usage
        die "Unknown option: $1"
        ;;
    esac
    shift
  done

  [[ "$(uname -s)" == "Darwin" ]] || die "This script supports macOS only"

  log_banner "sides-pave · fresh Mac setup"

  ensure_command_line_tools
  ensure_homebrew
  [[ $skip_brew == 1 ]] || brew_bundle "$brewfile"
  [[ $skip_macos == 1 ]] || apply_macos_defaults
  [[ $skip_checklist == 1 ]] || run_checklist

  log_step "Done"
  log_success "Your machine is set up. Re-run anytime; it's safe."
}

main "$@"

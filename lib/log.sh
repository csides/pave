# shellcheck shell=bash

if [[ -t 1 && -z ${NO_COLOR:-} ]]; then
  _c_reset=$'\e[0m' _c_bold=$'\e[1m' _c_dim=$'\e[2m'
  _c_red=$'\e[31m' _c_green=$'\e[32m' _c_yellow=$'\e[33m' _c_blue=$'\e[34m' _c_cyan=$'\e[36m'
else
  _c_reset='' _c_bold='' _c_dim=''
  _c_red='' _c_green='' _c_yellow='' _c_blue='' _c_cyan=''
fi

log_banner() {
  printf '\n%s%s%s\n\n' "$_c_bold$_c_cyan" "$1" "$_c_reset"
}

log_step() {
  printf '\n%s==>%s %s%s%s\n' "$_c_blue$_c_bold" "$_c_reset" "$_c_bold" "$1" "$_c_reset"
}

log_info() { printf '    %s\n' "$1"; }
log_success() { printf '%s  ✓%s %s\n' "$_c_green" "$_c_reset" "$1"; }
log_skip() { printf '%s  •%s %s%s%s\n' "$_c_dim" "$_c_reset" "$_c_dim" "$1" "$_c_reset"; }
log_warn() { printf '%s  !%s %s\n' "$_c_yellow" "$_c_reset" "$1" >&2; }
log_error() { printf '%s  ✗%s %s\n' "$_c_red" "$_c_reset" "$1" >&2; }

die() {
  log_error "$1"
  exit "${2:-1}"
}

confirm() {
  local prompt="${1:-Continue?}" reply
  [[ ${ASSUME_YES:-0} == 1 ]] && return 0
  [[ -t 0 ]] || return 1
  printf '%s  ?%s %s [y/N] ' "$_c_yellow" "$_c_reset" "$prompt"
  read -r reply
  [[ $reply =~ ^[Yy]$ ]]
}

pause() {
  [[ -t 0 && ${ASSUME_YES:-0} != 1 ]] || return 0
  printf '%s  ⏎%s %s' "$_c_dim" "$_c_reset" "${1:-Press Enter to continue}"
  read -r _
}

setup() {
  load test_helper
  setup_mock_bin
  HOME="$BATS_TEST_TMPDIR/home"
  GIT_CONFIG_GLOBAL="$HOME/.gitconfig"
  export HOME GIT_CONFIG_GLOBAL
  mkdir -p "$HOME"
  source "$REPO_ROOT/lib/log.sh"
  source "$REPO_ROOT/lib/git.sh"
}

@test "ensure_ssh_key skips when a key already exists" {
  mkdir -p "$HOME/.ssh"
  : >"$HOME/.ssh/id_ed25519"
  run ensure_ssh_key
  [ "$status" -eq 0 ]
  [[ $output == *"Already exists"* ]]
}

@test "ensure_gpg_signing_key configures signing when a key already exists" {
  git config --global user.email "test@example.com"
  cat >"$MOCK_BIN/gpg" <<'EOF'
#!/usr/bin/env bash
[[ "$1" == "--list-secret-keys" ]] && echo "fpr:::::::::ABC123DEF456:"
exit 0
EOF
  chmod +x "$MOCK_BIN/gpg"
  run ensure_gpg_signing_key
  [ "$status" -eq 0 ]
  [[ $output == *"already exists"* ]]
  run git config --file "$HOME/.gitconfig.local" user.signingkey
  [ "$output" = "ABC123DEF456" ]
}

@test "ensure_gpg_signing_key skips when git user.email is unset" {
  mock gpg 0
  run ensure_gpg_signing_key
  [ "$status" -eq 0 ]
  [[ $output == *"user.email not set"* ]]
}

@test "github_login reports when already authenticated" {
  mock gh 0
  run github_login
  [ "$status" -eq 0 ]
  [[ $output == *"Already authenticated"* ]]
}

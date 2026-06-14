setup() {
  load test_helper
  setup_mock_bin
  source "$REPO_ROOT/lib/log.sh"
  source "$REPO_ROOT/lib/brew.sh"
  brewfile="$BATS_TEST_TMPDIR/Brewfile"
  echo 'brew "git"' >"$brewfile"
}

@test "brew_bundle dies when the Brewfile is missing" {
  run brew_bundle "$BATS_TEST_TMPDIR/does-not-exist"
  [ "$status" -ne 0 ]
  [[ $output == *"not found"* ]]
}

@test "brew_bundle skips install when check passes" {
  mock brew 0
  run brew_bundle "$brewfile"
  [ "$status" -eq 0 ]
  [[ $output == *"already installed"* ]]
}

@test "brew_bundle installs when check reports missing packages" {
  cat >"$MOCK_BIN/brew" <<'EOF'
#!/usr/bin/env bash
[[ "$1 $2" == "bundle check" ]] && exit 1
exit 0
EOF
  chmod +x "$MOCK_BIN/brew"
  run brew_bundle "$brewfile"
  [ "$status" -eq 0 ]
  [[ $output == *"Software installed"* ]]
}

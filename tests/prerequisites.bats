setup() {
  load test_helper
  setup_mock_bin
  source "$REPO_ROOT/lib/log.sh"
  source "$REPO_ROOT/lib/prerequisites.sh"
}

@test "ensure_command_line_tools skips when already installed" {
  mock xcode-select 0
  run ensure_command_line_tools
  [ "$status" -eq 0 ]
  [[ $output == *"Already installed"* ]]
}

@test "ensure_homebrew skips when brew is present" {
  mock brew 0
  run ensure_homebrew
  [ "$status" -eq 0 ]
  [[ $output == *"Already installed"* ]]
}

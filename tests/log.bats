setup() {
  load test_helper
  source "$REPO_ROOT/lib/log.sh"
}

@test "log_success shows a check mark and the message" {
  run log_success "all good"
  [ "$status" -eq 0 ]
  [[ $output == *"✓"* ]]
  [[ $output == *"all good"* ]]
}

@test "log_error reports the message" {
  run log_error "boom"
  [[ $output == *"boom"* ]]
}

@test "die exits non-zero with the message" {
  run die "fatal"
  [ "$status" -eq 1 ]
  [[ $output == *"fatal"* ]]
}

@test "die honors a custom exit code" {
  run die "fatal" 3
  [ "$status" -eq 3 ]
}

@test "confirm returns 0 when ASSUME_YES=1" {
  ASSUME_YES=1 run confirm "ok?"
  [ "$status" -eq 0 ]
}

@test "confirm returns 1 in a non-interactive shell" {
  run confirm "ok?"
  [ "$status" -eq 1 ]
}

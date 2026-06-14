# shellcheck shell=bash

REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
export REPO_ROOT

setup_mock_bin() {
  MOCK_BIN="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$MOCK_BIN"
  PATH="$MOCK_BIN:$PATH"
}

mock() {
  local name="$1" code="${2:-0}"
  {
    echo '#!/usr/bin/env bash'
    echo "exit $code"
  } >"$MOCK_BIN/$name"
  chmod +x "$MOCK_BIN/$name"
}

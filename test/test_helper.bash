#!/usr/bin/env bash

setup() {
  docker history $REGISTRY/$REPOSITORY:$TAG >/dev/null 2>&1
}

assert_equal() {
  if [ "$1" != "$2" ]; then
    echo "expected: $1"
    echo "actual:   $2"
    return 1
  fi
}

assert_range() {
  if [ $1 -lt $2 ]; then
    echo "expected: $1"
    echo "greater than: $2"
    return 1
  fi

  if [ $1 -gt $3 ]; then
    echo "expected: $1"
    echo "less than: $3"
    return 1
  fi
}

assert_output() {
  assert_equal "$1" "$output"
}

assert_success() {
  if [ "$status" -ne 0 ]; then
    echo "command failed with exit status $status"
    return 1
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_fail() {
  if [ "$status" -eq 0 ]; then
    echo "command successed, but should fail"
    return 1
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

ensure_not_found_in_path() {
  local cmd
  for cmd; do
    if command -v "${cmd}" 1>/dev/null 2>&1; then
      remove_command_from_path "${cmd}"
    fi
  done
}

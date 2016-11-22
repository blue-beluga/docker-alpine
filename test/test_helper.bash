#!/usr/bin/env bash

setup() {
  export TAG=3.4
  export REGISTRY=docker.io
  export REPOSITORY=bluebeluga/alpine
  docker history $REGISTRY/$REPOSITORY:$TAG >/dev/null 2>&1
}

make_modified_in_past() {
  local current_timestamp=$(date +%Y%m%d%H%M)
  local past_timestamp=$(expr $current_timestamp - 10)
  touch -t $past_timestamp "$1"
}

assert() {
  if ! "$@"; then
    flunk "failed: $@"
  fi
}

refute() {
  if "$@"; then
    flunk "expected to fail: $@"
  fi
}

flunk() {
  { if [ "$#" -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed "s:${TMP}:\${TMP}:g" >&2
  return 1
}

assert_success() {
  if [ "$status" -ne 0 ]; then
    { echo "command failed with exit status $status"
      echo "output: $output"
    } | flunk
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_fail() {
  if [ "$status" -eq 0 ]; then
    flunk "expected failed exit status"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_equal() {
  if [ "$1" != "$2" ]; then
    { echo "expected: $1"
      echo "actual:   $2"
    } | flunk
  fi
}

assert_output() {
  local expected
  if [ $# -eq 0 ]; then expected="$(cat -)"
  else expected="$1"
  fi
  assert_equal "$expected" "$output"
}

assert_output_contains() {
  local expected="$1"
  if [ -z "$expected" ]; then
    echo "assert_output_contains needs an argument" >&2
    return 1
  fi
  echo "$output" | $(type -p ggrep grep | head -1) -F "$expected" >/dev/null || {
    { echo "expected output to contain $expected"
      echo "actual: $output"
    } | flunk
  }
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

remove_command_from_path() {
  OLDIFS="${IFS}"
  local cmd="$1"
  local path
  local paths=()
  IFS=:
  for path in ${PATH}; do
    if [ -e "${path}/${cmd}" ]; then
      local tmp_path="$(mktemp -d "${TMP}/path.XXXXX")"
      ln -fs "${path}"/* "${tmp_path}"
      rm -f "${tmp_path}/${cmd}"
      paths["${#paths[@]}"]="${tmp_path}"
    else
      paths["${#paths[@]}"]="${path}"
    fi
  done
  export PATH="${paths[*]}"
  IFS="${OLDIFS}"
}

ensure_not_found_in_path() {
  local cmd
  for cmd; do
    if command -v "${cmd}" 1>/dev/null 2>&1; then
      remove_command_from_path "${cmd}"
    fi
  done
}

# Retry a command $1 times until it succeeds. Wait $2 seconds between retries.
retry() {
  local attempts=$1
  shift
  local delay=$1
  shift
  local i

  for ((i=0; i < attempts; i++)); do
    run "$@"
    if [[ "$status" -eq 0 ]] ; then
      return 0
    fi
    sleep $delay
  done

  echo "Command \"$@\" failed $attempts times. Output: $output"
  false
}
